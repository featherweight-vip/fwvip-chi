// The back-to-back cases and tests: the kit's l2_rn_sn suite ported to the
// VIP's agents (one sequence per case, chosen by +SEQ), random traffic, the
// monitor agent's teeth test, and the L1 agent's tests.
`include "uvm_macros.svh"

package fwvip_chi_b2b_tests_pkg;
    import uvm_pkg::*;
    import chi_types_pkg::*;
    import chi_flow_tables_pkg::*;
    import fw_proto_chi_pkg::*;
    import fwvip_chi_pkg::*;
    import fwvip_chi_b2b_bench_pkg::*;
    import fwvip_chi_b2b_env_pkg::*;

    `include "fwvip_chi_b2b_seq_base.svh"
    `include "fwvip_chi_l2_write_read_seq.svh"
    `include "fwvip_chi_l2_partial_writes_seq.svh"
    `include "fwvip_chi_l2_read_every_size_seq.svh"
    `include "fwvip_chi_l2_ordered_reads_seq.svh"
    `include "fwvip_chi_l2_ordered_writes_seq.svh"
    `include "fwvip_chi_l2_concurrent_seq.svh"
    `include "fwvip_chi_l2_retry_storm_seq.svh"
    `include "fwvip_chi_l2_flow_shapes_seq.svh"
    `include "fwvip_chi_l2_dwt_writes_seq.svh"
    `include "fwvip_chi_l2_write_comp_ack_seq.svh"
    `include "fwvip_chi_l2_write_data_cancel_seq.svh"
    `include "fwvip_chi_l2_errors_sn_seq.svh"
    `include "fwvip_chi_l2_errors_home_seq.svh"
    `include "fwvip_chi_l2_poison_seq.svh"
    `include "fwvip_chi_rand_traffic_seq.svh"

    `include "fwvip_chi_b2b_test.svh"
    `include "fwvip_chi_mon_teeth_test.svh"
    `include "fwvip_chi_l1_test.svh"
    `include "fwvip_chi_l1_stall_test.svh"
endpackage
