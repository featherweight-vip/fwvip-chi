# Getting started

## Set up

fwvip-chi is fetched and built with [IVPM](https://fvutils.github.io/ivpm)
and run with [dv-flow](https://dv-flow.github.io) (`dfm`):

```bash
ivpm update                 # dep-set `dev`: the kit, fwvip-core, Verilator, UVM, dfm
direnv allow                # the environment ivpm assembled (packages/packages.envrc)
pip install -e packages/fw-hdl/python   # fw-hdl's dfm plugin (ivpm does not install it yet)
export UVM_HOME=$IVPM_PACKAGES/uvm
```

## Run

```bash
dfm run smoke                           # a few cases, both views
dfm run tests                           # every case, both views
dfm run tests --tests l2_retry_storm    # one case
dfm run tests --views xtor              # one view
dfm run tests-info                      # what --tests and --views accept
dfm run docs                            # these pages, warnings as errors
```

## The back-to-back bench

`tests/uvm/` is a complete bench. It is also the worked example for
{doc}`integration`:

```
 RN agent ─▶ chi_rn_adapter ◀── RN link ──▶ chi_test_home ◀── SN link ──▶ chi_sn_adapter ─▶ SN agent
 (VIP)       (kit)                          (kit)                         (kit)              (VIP)
                     every flit on both links ─▶ chi_mon_fanout ─▶ monitor agent (VIP)
```

- **View `tlm`**: both links are bound directly, through the kit's TLM taps.
- **View `xtor`**: each link goes through the kit's bridge and transactor,
  real CHI pins with a pin checker on every channel, and the opposite
  transactor. The pin monitors publish to the fanout.

The cases are the kit's own `l2_rn_sn` suite, rewritten as UVM sequences on
the RN agent and selected by `+SEQ=<sequence>`. There is also random traffic,
the monitor agent's teeth test, and the L1 agent's tests on a second bench
(see {doc}`verification`).

| Path | What |
|---|---|
| `tests/uvm/env/fwvip_chi_b2b_sys.svh` | the fw-hdl tree: the kit's adapters and test Home, bound to the VIP configs |
| `tests/uvm/env/fwvip_chi_b2b_env.svh` | the UVM env: three agents, a data scoreboard, a message log |
| `tests/uvm/tests/` | one sequence per case, the test classes |
| `tests/uvm/tb/` | HDL and HVL tops per view |
