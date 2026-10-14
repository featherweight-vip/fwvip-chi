// HVL top for the L1 bench, xtor view: as the tlm view's, but every
// endpoint is bound to its transactor through the kit's bridge, on the same
// HDL top as the L2 bench's xtor view (an RN link and an SN link on pins,
// pin checkers, pin monitors).
`include "uvm_macros.svh"
`include "fw_hdl_macros.svh"

module fwvip_chi_hvl_top_l1_xtor;
    import uvm_pkg::*;
    import fw_hdl_pkg::*;
    import fw_proto_chi_pkg::*;
    import fw_proto_chi_xtor_pkg::*;
    import fwvip_core_uvm_pkg::*;
    import fwvip_chi_pkg::*;
    import fwvip_chi_b2b_bench_pkg::*;
    import fwvip_chi_b2b_tests_pkg::*;

    fwvip_chi_hdl_top_xtor hdl();

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

    `fw_root_begin(fwvip_chi_l1_sys, u_root, hdl.clock, hdl.reset)
        `fw_root_bind_socket(rn.chi,      hdl.u_rn_link.u_rn.u_if,  chi_rn_xtor_bridge)
        `fw_root_bind_mirror(icn_rn.chi,  hdl.u_rn_link.u_icn.u_if, chi_icn_rn_xtor_bridge)
        `fw_root_bind_socket(sn.chi,      hdl.u_sn_link.u_sn.u_if,  chi_sn_xtor_bridge)
        `fw_root_bind_mirror(icn_sn.chi,  hdl.u_sn_link.u_icn.u_if, chi_icn_sn_xtor_bridge)
        `fw_root_bind_export(fan.in,      hdl.u_rn_link.u_mon.u_if, chi_link_mon_xtor_bridge)
        `fw_root_bind_export(fan.in,      hdl.u_sn_link.u_mon.u_if, chi_link_mon_xtor_bridge)
    `fw_root_end
endmodule
