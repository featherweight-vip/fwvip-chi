// HVL top, xtor view: as the tlm view's, but the bench's tree is the plain
// fwvip_chi_b2b_sys and every link end is bound to its transactor through
// the kit's bridges, and the pin monitors publish to the fanout:
//
//   rn  -> chi_rn_xtor_bridge  -> pins -> chi_icn_rn_xtor_bridge -> home.rn
//   sn  -> chi_sn_xtor_bridge  -> pins -> chi_icn_sn_xtor_bridge -> home.sn
//   u_mon (each link) -> chi_link_mon_xtor_bridge -> fan
`include "uvm_macros.svh"
`include "fw_hdl_macros.svh"

module fwvip_chi_hvl_top_xtor;
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
        fwvip_chi_b2b_sys::vip_rn  = fwvip_chi_rn_config_ap::set(null, "uvm_test_top.m_env.m_rn*");
        fwvip_chi_b2b_sys::vip_sn  = fwvip_chi_sn_config::set(null, "uvm_test_top.m_env.m_sn*");
        fwvip_chi_b2b_sys::vip_mon = fwvip_chi_mon_config::set(null, "uvm_test_top.m_env.m_mon*", "cfg",
                                         chi_link_cfg::from_param(fwvip_chi_b2b_sys::link_p));
        fwvip_clock_config_p #(virtual fwvip_clock_xtor_if)::set(
            null, "uvm_test_top.m_env*", "clock", hdl.u_clk_if);
        fwvip_reset_config_p #(virtual fwvip_reset_xtor_if #(1))::set(
            null, "uvm_test_top.m_env*", "reset", hdl.u_rst_if);
        run_test();
    end

    `fw_root_begin(fwvip_chi_b2b_sys, u_root, hdl.clock, hdl.reset)
        `fw_root_bind_socket(rn.chi,   hdl.u_rn_link.u_rn.u_if,  chi_rn_xtor_bridge)
        `fw_root_bind_mirror(home.rn,  hdl.u_rn_link.u_icn.u_if, chi_icn_rn_xtor_bridge)
        `fw_root_bind_socket(sn.chi,   hdl.u_sn_link.u_sn.u_if,  chi_sn_xtor_bridge)
        `fw_root_bind_mirror(home.sn,  hdl.u_sn_link.u_icn.u_if, chi_icn_sn_xtor_bridge)
        `fw_root_bind_export(fan.in,   hdl.u_rn_link.u_mon.u_if, chi_link_mon_xtor_bridge)
        `fw_root_bind_export(fan.in,   hdl.u_sn_link.u_mon.u_if, chi_link_mon_xtor_bridge)
    `fw_root_end
endmodule
