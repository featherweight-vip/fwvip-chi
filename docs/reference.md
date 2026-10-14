# Reference

## `fwvip_chi_xtor_pkg` (export `xtor-pkg`)

The fwvip width policy. CHI needs no widths of its own: the kit's
class-level flits are already maximum width, and a link's widths are a
`chi_link_param_t`.

| Name | Value | |
|---|---|---|
| `ADDR_WIDTH_MAX` | 52 | `CHI_ADDR_W_MAX` (B16.1.11) |
| `DATA_WIDTH_MAX` | 512 | `CHI_DATA_W_MAX` (B16.1.13) |
| `NODEID_WIDTH_MAX` | 16 | `CHI_NODEID_W_MAX` (B16.1.12) |
| `RSVDC_WIDTH_MAX` | 32 | `CHI_RSVDC_W_MAX` |
| `LINE_BYTES` | 64 | |
| `fwvip_chi_link_param_t` | type | `chi_link_param_t` |

Link presets. Pass one to the kit's transactors (`.P`) and to
`chi_link_cfg::from_param`, so both ends of a link and the class side agree:

| Preset | Node ID | Addr | Data | Options |
|---|---|---|---|---|
| `FWVIP_CHI_LINK_DEFAULT` | 7 | 48 | 256 | none (`CHI_LINK_PARAM_DEFAULT`) |
| `FWVIP_CHI_LINK_POISON` | 7 | 48 | 256 | Data_Poison |
| `FWVIP_CHI_LINK_D128` | 7 | 48 | 128 | none |
| `FWVIP_CHI_LINK_D512` | 7 | 48 | 512 | none |

## `fwvip_chi_pkg` (export `vip-uvm-hvlsrc`)

Imports `uvm_pkg`, `fw_hdl_pkg`, `chi_types_pkg`, `fw_proto_chi_pkg`,
`fwvip_core_pkg`, `fwvip_core_uvm_pkg` and `fwvip_chi_xtor_pkg`. Needs
`fw.proto.chi.class` and `org.fwvip.core.core-uvm-pkg`.

| Class | Kind | |
|---|---|---|
| `fwvip_chi_xact` | item | one transaction ({doc}`sequences`) |
| `fwvip_chi_rn_config`, `fwvip_chi_rn_config_ap` | config | RN seam; `_ap` holds a `chi_xact_if` |
| `fwvip_chi_rn_driver`, `fwvip_chi_rn_agent` | components | requester; `ap` of completed items |
| `fwvip_chi_rn_seq_base`, `fwvip_chi_read_seq`, `fwvip_chi_write_seq`, `fwvip_chi_rand_seq` | sequences | requester |
| `fwvip_chi_sn_if` | interface class | what a responder implements |
| `fwvip_chi_sn_item` | item | carries the responder to the driver |
| `fwvip_chi_sn_config` | config | SN seam; is a `chi_xact_if` |
| `fwvip_chi_sn_driver`, `fwvip_chi_sn_agent` | components | completer; `ap` of served requests |
| `fwvip_chi_sn_seq`, `fwvip_chi_mem_responder_seq` | sequences | responders |
| `fwvip_chi_sn_policy` | object | responder latency |
| `fwvip_chi_mon_config` | config | monitor seam; is a `chi_mon_if` |
| `fwvip_chi_mon_agent` | component | flow checker; `ap` of `chi_msg` |
| `fwvip_chi_l1_item` | item | one flit |
| `fwvip_chi_l1_config` | config | L1 seam; holds a kit L1 endpoint (`fwvip_chi_l1_side_e`) |
| `fwvip_chi_l1_driver`, `fwvip_chi_l1_agent` | components | raw flits; `ap` received, `sent_ap` sent |
| `fwvip_chi_l1_seq`, `fwvip_chi_l1_rand_seq` | sequences | raw flits |
