# fwvip-chi — CHI Verification IP

`fwvip-chi` is the UVM Verification IP for AMBA CHI (IHI0050H): the
methodology layer over the [`fw-proto-chi`](https://git.dvkit.org/featherweight-ip/fw-proto-chi)
transactor kit. It lets a UVM testbench issue CHI transactions, answer them
as a memory, watch links against the spec's flow rules, and drive raw flits
at one end of a link.

## How it is built

CHI's transaction layer is not small. Somebody has to allocate TxnIDs and
DBIDs, retry with P-credits, send CompAck, handle DMT and DWT, split data
into beats, and check every flow. The kit already does all of that, as
fw-hdl class code (its "L2"), tested in two views and partly proven
formally. fwvip-chi does not do it again. Its agents **bind to API handles
of the kit's classes**, and **the bench builds and owns the fw-hdl tree**
those classes live in:

| Agent | Role | Its seam (config) | Bound to |
|---|---|---|---|
| `fwvip_chi_rn_agent` | requester: sequences of `fwvip_chi_xact` | `fwvip_chi_rn_config_ap` holds a `chi_xact_if` | the `xact` export of the kit's `chi_rn_adapter` |
| `fwvip_chi_sn_agent` | completer: a responder sequence answers each request | `fwvip_chi_sn_config` *is* a `chi_xact_if` | the `mem` port of the kit's `chi_sn_adapter` |
| `fwvip_chi_mon_agent` | passive: flow checker plus analysis port of `chi_msg` | `fwvip_chi_mon_config` *is* a `chi_mon_if` | the kit's TLM taps or pin monitors, through a `chi_mon_fanout` |
| `fwvip_chi_l1_agent` | raw flits at one end of a link | `fwvip_chi_l1_config` holds a kit L1 endpoint | `chi_l1_rn_ep`, `chi_l1_icn_rn_ep`, `chi_l1_sn_ep` or `chi_l1_icn_sn_ep` |

How a link reaches the other side (a direct bind, or the kit's transactors
on real CHI pins) is the bench's business. The agents are the same either
way.

```{admonition} DFM package
:class: note
The VIP is the DFM package **`org.fwvip.chi`**. A testbench needs
`org.fwvip.chi.vip-uvm-hvlsrc` (the UVM package, `fwvip_chi_pkg`); the kit's
transactors and bridges, if the bench uses pins, are `fw.proto.chi.xtor-class`.
```

## Where to start

- {doc}`getting-started` builds and runs the back-to-back bench.
- {doc}`integration` shows how to wire each agent into a bench.
- {doc}`sequences` covers the item, the requester sequences and the responders.
- {doc}`l1-agent` covers raw flits.
- {doc}`reference` lists the constants, link presets and classes.
- {doc}`verification` says what is tested, and what testing found.

```{toctree}
:maxdepth: 2
:hidden:

getting-started
integration
sequences
l1-agent
reference
verification
```
