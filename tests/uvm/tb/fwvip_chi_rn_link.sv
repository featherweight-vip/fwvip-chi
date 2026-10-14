// The RN link of the back-to-back bench on real pins (the xtor view): the
// node's transactor (chi_rn_xtor) facing the interconnect's (chi_icn_rn_xtor),
// a pin checker on every channel and on each end's link control, and the
// pin monitor. The class side reaches the transactors through u_rn.u_if and
// u_icn.u_if, and the monitor through u_mon.u_if (and names the link in it).
// As the kit's xtor harness (and fw-ic-chi's chi_sys_rn_link).
`include "fwvip_chi_link_macros.svh"

module fwvip_chi_rn_link
    import chi_types_pkg::*;
#(
    parameter chi_link_param_t P = CHI_LINK_PARAM_DEFAULT
) (
    input wire clock,
    input wire reset
);
    localparam int REQ_W = chi_req_flit_w(P);
    localparam int RSP_W = chi_rsp_flit_w(P);
    localparam int SNP_W = chi_snp_flit_w(P);
    localparam int DAT_W = chi_dat_flit_w(P);

    `FWVIP_CHI_CH(req_up, REQ_W)
    `FWVIP_CHI_CH(rsp_up, RSP_W)
    `FWVIP_CHI_CH(dat_up, DAT_W)
    `FWVIP_CHI_CH(rsp_dn, RSP_W)
    `FWVIP_CHI_CH(dat_dn, DAT_W)
    `FWVIP_CHI_CH(snp_dn, SNP_W)
    wire a_txreq, a_rxack, b_txreq, b_rxack, a_sact, b_sact;

    chi_rn_xtor #(.P(P)) u_rn (.clock, .reset,
        `FWVIP_CHI_TX(TXREQ, req_up), `FWVIP_CHI_TX(TXRSP, rsp_up), `FWVIP_CHI_TX(TXDAT, dat_up),
        `FWVIP_CHI_TX(RXRSP, rsp_dn), `FWVIP_CHI_TX(RXDAT, dat_dn), `FWVIP_CHI_TX(RXSNP, snp_dn),
        .TXLINKACTIVEREQ(a_txreq), .TXLINKACTIVEACK(b_rxack),
        .RXLINKACTIVEREQ(b_txreq), .RXLINKACTIVEACK(a_rxack),
        .TXSACTIVE(a_sact), .RXSACTIVE(b_sact));

    chi_icn_rn_xtor #(.P(P)) u_icn (.clock, .reset,
        `FWVIP_CHI_TX(TXRSP, rsp_dn), `FWVIP_CHI_TX(TXDAT, dat_dn), `FWVIP_CHI_TX(TXSNP, snp_dn),
        `FWVIP_CHI_TX(RXREQ, req_up), `FWVIP_CHI_TX(RXRSP, rsp_up), `FWVIP_CHI_TX(RXDAT, dat_up),
        .TXLINKACTIVEREQ(b_txreq), .TXLINKACTIVEACK(a_rxack),
        .RXLINKACTIVEREQ(a_txreq), .RXLINKACTIVEACK(b_rxack),
        .TXSACTIVE(b_sact), .RXSACTIVE(a_sact));

    `FWVIP_CHI_CHK(req_up, a_txreq, b_rxack)
    `FWVIP_CHI_CHK(rsp_up, a_txreq, b_rxack)
    `FWVIP_CHI_CHK(dat_up, a_txreq, b_rxack)
    `FWVIP_CHI_CHK(rsp_dn, b_txreq, a_rxack)
    `FWVIP_CHI_CHK(dat_dn, b_txreq, a_rxack)
    `FWVIP_CHI_CHK(snp_dn, b_txreq, a_rxack)
    chi_link_ctrl_checker u_cchk_rn  (.clock, .reset, .txlinkactivereq(a_txreq), .rxlinkactiveack(a_rxack));
    chi_link_ctrl_checker u_cchk_icn (.clock, .reset, .txlinkactivereq(b_txreq), .rxlinkactiveack(b_rxack));

    chi_link_mon_xtor #(.P(P), .LINK("rn")) u_mon (.clock, .reset,
        .up_req_v(req_up_v), .up_req_flit(req_up_flit),
        .up_rsp_v(rsp_up_v), .up_rsp_flit(rsp_up_flit),
        .up_dat_v(dat_up_v), .up_dat_flit(dat_up_flit),
        .dn_req_v(1'b0),     .dn_req_flit('0),
        .dn_rsp_v(rsp_dn_v), .dn_rsp_flit(rsp_dn_flit),
        .dn_snp_v(snp_dn_v), .dn_snp_flit(snp_dn_flit),
        .dn_dat_v(dat_dn_v), .dn_dat_flit(dat_dn_flit));
endmodule
