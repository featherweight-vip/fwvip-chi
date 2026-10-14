// HDL top, xtor view: the clock, reset and fwvip-core providers of the tlm
// view, plus both links on real CHI pins -- the kit's transactors facing
// each other, pin checkers on every channel, a pin monitor per link. The
// links carry fwvip_chi_b2b_sys's link parameters (FWVIP_CHI_LINK_POISON).
module fwvip_chi_hdl_top_xtor;
    import chi_types_pkg::*;
    import fwvip_chi_xtor_pkg::*;

    localparam chi_link_param_t P = FWVIP_CHI_LINK_POISON;

    reg clock = 0, reset = 1;
    always #5ns clock = ~clock;
    initial begin
        repeat (4) @(posedge clock);
        reset = 0;
    end

    fwvip_clock_xtor_if               u_clk_if (.clock(clock), .reset(reset));
    fwvip_reset_xtor_if #(.ACTIVE(1)) u_rst_if (.clock(clock), .reset(reset));

    fwvip_chi_rn_link #(.P(P)) u_rn_link (.clock, .reset);
    fwvip_chi_sn_link #(.P(P)) u_sn_link (.clock, .reset);
endmodule
