// HVL top, tlm view. Sets the VIP's configs (RN, SN, monitor) in the config
// DB and in the bench's static slots, the clock and reset providers, roots
// the bench's fw-hdl tree (fwvip_chi_b2b_tlm: links through TLM taps) on the
// HDL top's clock and reset, and runs the test.
`include "uvm_macros.svh"
`include "fw_hdl_macros.svh"

module fwvip_chi_hvl_top_tlm;
    import uvm_pkg::*;
    import fw_hdl_pkg::*;
    import fw_proto_chi_pkg::*;
    import fwvip_core_uvm_pkg::*;
    import fwvip_chi_pkg::*;
    import fwvip_chi_b2b_bench_pkg::*;
    import fwvip_chi_b2b_tests_pkg::*;

    fwvip_chi_hdl_top_tlm hdl();

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

    `fw_root_begin(fwvip_chi_b2b_tlm, u_root, hdl.clock, hdl.reset)
    `fw_root_end
endmodule
