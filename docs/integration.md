# Integration

Every agent fetches its config as `"cfg"` from the UVM config DB in
`build_phase`. The config is the agent's whole view of the world. The bench
does three things:

1. **At time 0, before `run_test()`**: make each agent's config with its
   static `set()`. That puts it in the config DB and returns it. Also set
   fwvip-core's clock and reset providers.
2. **In its fw-hdl tree, every time the tree is built**: build the kit's
   classes and bind them to the configs. The tree is built after reset is
   released and rebuilt on every reset, so the binding is repeated.
3. **In the test**: wait for reset, through the reset provider, and for the
   tree, then start sequences.

The back-to-back bench (`tests/uvm/`) does exactly this. Its tree,
`fwvip_chi_b2b_sys`, keeps the configs in static slots that the HVL top
fills.

## Requester: `fwvip_chi_rn_agent`

```systemverilog
// HVL top, time 0
fwvip_chi_rn_config_ap rn_cfg = fwvip_chi_rn_config_ap::set(null, "uvm_test_top.m_env.m_rn*");

// the bench's fw-hdl tree, connect()
rn = new("rn", this, link_cfg);          // chi_rn_adapter (kit)
...
rn_cfg.bind_if(rn.xact);                 // the adapter's chi_xact_if
```

The driver runs each item through `rn_cfg.xact()`, which converts it to the
kit's `chi_xact_req_t`, calls the adapter, and copies back the
`chi_xact_rsp_t`. Up to `max_outstanding` items (16 by default) are in
flight at once. Calls made before `bind_if()` wait for it. Completed items
are published on the agent's `ap`.

## Completer: `fwvip_chi_sn_agent`

The SN config *is* a `chi_xact_if`. The bench makes it the provider behind
the kit SN adapter's `mem` port:

```systemverilog
// HVL top, time 0
fwvip_chi_sn_config sn_cfg = fwvip_chi_sn_config::set(null, "uvm_test_top.m_env.m_sn*");

// the bench's fw-hdl tree
sn   = new("sn", this, link_cfg);                   // chi_sn_adapter (kit)
sn_x = new("sn_x", this, sn_cfg);                   // fw_export #(chi_xact_if)
sn.mem.connect(sn_x);
sn_cfg.adapter = sn;                                // optional: completer_policy()
```

For each request, the adapter calls `sn_cfg.xact()`. The agent's driver
takes the running responder sequence from the sequencer and calls its
`handle_request()`. Requests are served concurrently; only the hand-over
from the sequencer is serialized. Start a responder in the background:

```systemverilog
fwvip_chi_mem_responder_seq resp = fwvip_chi_mem_responder_seq::type_id::create("resp");
fork resp.start(env.m_sn.m_seqr); join_none
```

The adapter's own choices are the kit's `chi_completer_policy`: combined or
separate write responses, and the response delay. If the bench handed over
the adapter, a test sets them with `sn_cfg.completer_policy(per_request, p)`.

The SN agent also fetches `"clock"` (fwvip-core's `fwvip_clock_config`), if
there is one. The memory responder counts its latency on it.

## Monitor: `fwvip_chi_mon_agent`

```systemverilog
// HVL top, time 0
fwvip_chi_mon_config mon_cfg = fwvip_chi_mon_config::set(null, "uvm_test_top.m_env.m_mon*",
                                                         "cfg", chi_link_cfg::from_param(P));
// the bench's fw-hdl tree
fan.subscribe(mon_cfg);                  // chi_mon_fanout fed by taps or pin monitors
```

Every flit goes through the agent's own `chi_flow_check`, then out on `ap`
(`uvm_analysis_port #(chi_msg)`). A violation is a `UVM_ERROR` (id
`CHI_FLOW`) at the moment it is seen. At `check_phase`, the checker must be
quiescent. Set `check_enable = 0` for traffic that is not transactions (raw
flits), and call `clear()` after a reset.

## L1: `fwvip_chi_l1_agent`

```systemverilog
fwvip_chi_l1_config rn_l1 = fwvip_chi_l1_config::set(null, "uvm_test_top.m_env.m_rn", FWVIP_CHI_L1_RN,
                                                     "cfg", chi_link_cfg::from_param(P));
// the bench's fw-hdl tree
rn = new("rn", this);                    // chi_l1_rn_ep (kit)
rn_l1.bind_rn(rn);
```

See {doc}`l1-agent`.

## Clock and reset

As in every fwvip, reset comes from fwvip-core's providers, never from a
fixed delay:

```systemverilog
fwvip_clock_config_p #(virtual fwvip_clock_xtor_if)::set(null, "uvm_test_top.m_env*", "clock", hdl.u_clk_if);
fwvip_reset_config_p #(virtual fwvip_reset_xtor_if #(1))::set(null, "uvm_test_top.m_env*", "reset", hdl.u_rst_if);
```

The env calls `reset.wait_reset()`, then waits for the bench's tree to be
running, before it starts anything.

## Pins

In the `xtor` view, the bench binds the kit endpoints to transactors with
fw-hdl's root macros. The agents do not change:

```systemverilog
`fw_root_begin(fwvip_chi_b2b_sys, u_root, hdl.clock, hdl.reset)
    `fw_root_bind_socket(rn.chi,  hdl.u_rn_link.u_rn.u_if,  chi_rn_xtor_bridge)
    `fw_root_bind_mirror(home.rn, hdl.u_rn_link.u_icn.u_if, chi_icn_rn_xtor_bridge)
    `fw_root_bind_export(fan.in,  hdl.u_rn_link.u_mon.u_if, chi_link_mon_xtor_bridge)
    ...
`fw_root_end
```

## Limits

- **Reset in mid-run.** A reset rebuilds the tree and the bench rebinds the
  configs. A transaction in flight across the reset is not aborted: its
  driver thread waits on the old adapter. Quiesce before a reset. Aborting
  in-flight items is future work, done the way fw-ic-chi's seam driver
  does it.
- **Opcodes.** The RN agent issues what the kit's L2 implements: ReadNoSnp,
  ReadOnce, WriteNoSnp{Full,Ptl} and WriteUnique{Full,Ptl}. CMOs, atomics
  and exclusives wait until the kit's L2 implements them (its request type
  gains the fields in fw-ic-chi plan K.01).
