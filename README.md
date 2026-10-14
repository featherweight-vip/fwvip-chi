# fwvip-chi

UVM Verification IP for AMBA CHI (IHI0050H), over the
[fw-proto-chi](https://git.dvkit.org/featherweight-ip/fw-proto-chi) transactor
kit. Its agents bind to API handles of the kit's transaction layer, and the
bench builds and owns the fw-hdl tree those classes live in. The VIP never
reimplements the kit's CHI flows.

| Agent | Role |
|---|---|
| `fwvip_chi_rn_agent` | requester: sequences of `fwvip_chi_xact` into the kit's RN adapter |
| `fwvip_chi_sn_agent` | completer: a responder sequence behind the kit's SN adapter |
| `fwvip_chi_mon_agent` | passive: the kit's flow checker, then an analysis port of `chi_msg` |
| `fwvip_chi_l1_agent` | raw flits at one end of a link, over the kit's L1 endpoints |

```bash
ivpm update && direnv allow
pip install -e packages/fw-hdl/python      # fw-hdl's dfm plugin
export UVM_HOME=$IVPM_PACKAGES/uvm
dfm run smoke        # or: dfm run tests, dfm run docs
```

The docs (`docs/`, `dfm run docs`) cover integration, sequences, the L1
agent, and what is tested. The DFM package is `org.fwvip.chi`; a testbench
needs `org.fwvip.chi.vip-uvm-hvlsrc`.
