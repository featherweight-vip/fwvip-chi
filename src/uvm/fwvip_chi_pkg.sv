// fwvip_chi_pkg -- the CHI VIP's UVM layer (design §10). Agents bind to
// API handles of the kit's L2 classes, which the bench builds and owns:
//   fwvip_chi_rn_agent   requester: fwvip_chi_xact items -> chi_xact_if
//   fwvip_chi_sn_agent   completer: a responder sequence behind the kit's
//                        SN adapter (it is the adapter's chi_xact_if)
//   fwvip_chi_mon_agent  passive: chi_mon_if -> chi_flow_check -> ap
//   fwvip_chi_l1_agent   raw flits at one end of a link, over the kit's
//                        scripted L1 endpoints
// Thin package: imports, class typedefs, then one class per .svh in
// dependency order.
`include "uvm_macros.svh"

package fwvip_chi_pkg;
    import uvm_pkg::*;
    import fw_hdl_pkg::*;
    import chi_types_pkg::*;
    import fw_proto_chi_pkg::*;
    import fwvip_core_pkg::*;
    import fwvip_core_uvm_pkg::*;
    import fwvip_chi_xtor_pkg::*;

    `include "fwvip_chi_xact.svh"

    // ---- requester
    typedef uvm_sequencer #(fwvip_chi_xact) fwvip_chi_rn_sequencer;
    `include "fwvip_chi_rn_config.svh"
    `include "fwvip_chi_rn_driver.svh"
    `include "fwvip_chi_rn_agent.svh"
    `include "fwvip_chi_rn_seq_base.svh"
    `include "fwvip_chi_read_seq.svh"
    `include "fwvip_chi_write_seq.svh"
    `include "fwvip_chi_rand_seq.svh"

    // ---- completer
    `include "fwvip_chi_sn_if.svh"
    `include "fwvip_chi_sn_item.svh"
    typedef uvm_sequencer #(fwvip_chi_sn_item) fwvip_chi_sn_sequencer;
    `include "fwvip_chi_sn_driver.svh"
    `include "fwvip_chi_sn_config.svh"
    `include "fwvip_chi_sn_agent.svh"
    `include "fwvip_chi_sn_seq.svh"
    `include "fwvip_chi_sn_policy.svh"
    `include "fwvip_chi_mem_responder_seq.svh"

    // ---- monitor
    `include "fwvip_chi_mon_config.svh"
    `include "fwvip_chi_mon_agent.svh"

    // ---- L1 (raw flits)
    `include "fwvip_chi_l1_item.svh"
    `include "fwvip_chi_l1_config.svh"
    `include "fwvip_chi_l1_driver.svh"
    `include "fwvip_chi_l1_agent.svh"
    `include "fwvip_chi_l1_seq.svh"
    `include "fwvip_chi_l1_rand_seq.svh"
endpackage
