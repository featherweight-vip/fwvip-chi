// The SN link of the back-to-back bench on real pins (the xtor view): the interconnect's
// transactor (chi_icn_sn_xtor) facing the SN's (chi_sn_xtor), pin checkers,
// and the pin monitor. As fwvip_chi_rn_link.
`include "fwvip_chi_link_macros.svh"

module fwvip_chi_sn_link
    import chi_types_pkg::*;
#(
    parameter chi_link_param_t P = CHI_LINK_PARAM_DEFAULT
) (
    input wire clock,
    input wire reset
);
    localparam int REQ_W = chi_req_flit_w(P);
    localparam int RSP_W = chi_rsp_flit_w(P);
    localparam int DAT_W = chi_dat_flit_w(P);

    `FWVIP_CHI_CH(rsp_up, RSP_W)
    `FWVIP_CHI_CH(dat_up, DAT_W)
    `FWVIP_CHI_CH(req_dn, REQ_W)
    `FWVIP_CHI_CH(dat_dn, DAT_W)
    wire a_txreq, a_rxack, b_txreq, b_rxack, a_sact, b_sact;

    chi_sn_xtor #(.P(P)) u_sn (.clock, .reset,
        `FWVIP_CHI_TX(TXRSP, rsp_up), `FWVIP_CHI_TX(TXDAT, dat_up),
        `FWVIP_CHI_TX(RXREQ, req_dn), `FWVIP_CHI_TX(RXDAT, dat_dn),
        .TXLINKACTIVEREQ(a_txreq), .TXLINKACTIVEACK(b_rxack),
        .RXLINKACTIVEREQ(b_txreq), .RXLINKACTIVEACK(a_rxack),
        .TXSACTIVE(a_sact), .RXSACTIVE(b_sact));

    chi_icn_sn_xtor #(.P(P)) u_icn (.clock, .reset,
        `FWVIP_CHI_TX(TXREQ, req_dn), `FWVIP_CHI_TX(TXDAT, dat_dn),
        `FWVIP_CHI_TX(RXRSP, rsp_up), `FWVIP_CHI_TX(RXDAT, dat_up),
        .TXLINKACTIVEREQ(b_txreq), .TXLINKACTIVEACK(a_rxack),
        .RXLINKACTIVEREQ(a_txreq), .RXLINKACTIVEACK(b_rxack),
        .TXSACTIVE(b_sact), .RXSACTIVE(a_sact));

    `FWVIP_CHI_CHK(rsp_up, a_txreq, b_rxack)
    `FWVIP_CHI_CHK(dat_up, a_txreq, b_rxack)
    `FWVIP_CHI_CHK(req_dn, b_txreq, a_rxack)
    `FWVIP_CHI_CHK(dat_dn, b_txreq, a_rxack)
    chi_link_ctrl_checker u_cchk_sn  (.clock, .reset, .txlinkactivereq(a_txreq), .rxlinkactiveack(a_rxack));
    chi_link_ctrl_checker u_cchk_icn (.clock, .reset, .txlinkactivereq(b_txreq), .rxlinkactiveack(b_rxack));

    chi_link_mon_xtor #(.P(P), .LINK("sn")) u_mon (.clock, .reset,
        .up_req_v(1'b0),     .up_req_flit('0),
        .up_rsp_v(rsp_up_v), .up_rsp_flit(rsp_up_flit),
        .up_dat_v(dat_up_v), .up_dat_flit(dat_up_flit),
        .dn_req_v(req_dn_v), .dn_req_flit(req_dn_flit),
        .dn_rsp_v(1'b0),     .dn_rsp_flit('0),
        .dn_snp_v(1'b0),     .dn_snp_flit('0),
        .dn_dat_v(dat_dn_v), .dn_dat_flit(dat_dn_flit));
endmodule
