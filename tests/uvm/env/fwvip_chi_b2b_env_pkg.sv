// The benches' UVM side: the L2 back-to-back env (scoreboard, message log)
// and the L1 env (a scoreboard per link direction).
`include "uvm_macros.svh"

package fwvip_chi_b2b_env_pkg;
    import uvm_pkg::*;
    import chi_types_pkg::*;
    import fw_proto_chi_pkg::*;
    import fwvip_core_pkg::*;
    import fwvip_core_uvm_pkg::*;
    import fwvip_chi_pkg::*;
    import fwvip_chi_b2b_bench_pkg::*;

    `uvm_analysis_imp_decl(_l1_sent)
    `uvm_analysis_imp_decl(_l1_recv)

    `include "fwvip_chi_b2b_sb.svh"
    `include "fwvip_chi_b2b_msg_log.svh"
    `include "fwvip_chi_b2b_env.svh"
    `include "fwvip_chi_l1_sb.svh"
    `include "fwvip_chi_l1_env.svh"
endpackage
