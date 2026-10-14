// HVL top for the L1 bench, tlm view: an L1 agent config for each end of
// both links (in the DB and the bench's static slots), the monitor's, the
// clock and reset providers; the bench's tree (fwvip_chi_l1_tlm: links
// through TLM taps) rooted on the HDL top's clock and reset.
`include "uvm_macros.svh"
`include "fw_hdl_macros.svh"

module fwvip_chi_hvl_top_l1_tlm;
    import uvm_pkg::*;
    import fw_hdl_pkg::*;
    import fw_proto_chi_pkg::*;
    import fwvip_core_uvm_pkg::*;
    import fwvip_chi_pkg::*;
    import fwvip_chi_b2b_bench_pkg::*;
    import fwvip_chi_b2b_tests_pkg::*;

    fwvip_chi_hdl_top_tlm hdl();

    initial begin
        chi_link_cfg lc = chi_link_cfg::from_param(fwvip_chi_l1_sys::link_p);
        fwvip_chi_l1_sys::vip_rn     = fwvip_chi_l1_config::set(null, "uvm_test_top.m_env.m_rn",     FWVIP_CHI_L1_RN,     "cfg", lc);
        fwvip_chi_l1_sys::vip_icn_rn = fwvip_chi_l1_config::set(null, "uvm_test_top.m_env.m_icn_rn", FWVIP_CHI_L1_ICN_RN, "cfg", lc);
        fwvip_chi_l1_sys::vip_sn     = fwvip_chi_l1_config::set(null, "uvm_test_top.m_env.m_sn",     FWVIP_CHI_L1_SN,     "cfg", lc);
        fwvip_chi_l1_sys::vip_icn_sn = fwvip_chi_l1_config::set(null, "uvm_test_top.m_env.m_icn_sn", FWVIP_CHI_L1_ICN_SN, "cfg", lc);
        fwvip_chi_l1_sys::vip_mon    = fwvip_chi_mon_config::set(null, "uvm_test_top.m_env.m_mon", "cfg", lc);
        fwvip_clock_config_p #(virtual fwvip_clock_xtor_if)::set(
            null, "uvm_test_top.m_env*", "clock", hdl.u_clk_if);
        fwvip_reset_config_p #(virtual fwvip_reset_xtor_if #(1))::set(
            null, "uvm_test_top.m_env*", "reset", hdl.u_rst_if);
        run_test();
    end

    `fw_root_begin(fwvip_chi_l1_tlm, u_root, hdl.clock, hdl.reset)
    `fw_root_end
endmodule
