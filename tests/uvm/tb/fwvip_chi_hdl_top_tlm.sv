// HDL top, tlm view: a clock and reset, and fwvip-core's clock and reset
// transactors on them (the UVM env's providers). The bench itself is an
// fw-hdl tree, rooted in the HVL top on the same clock and reset.
module fwvip_chi_hdl_top_tlm;
    reg clock = 0, reset = 1;
    always #5ns clock = ~clock;
    initial begin
        repeat (4) @(posedge clock);
        reset = 0;
    end

    fwvip_clock_xtor_if               u_clk_if (.clock(clock), .reset(reset));
    fwvip_reset_xtor_if #(.ACTIVE(1)) u_rst_if (.clock(clock), .reset(reset));
endmodule
