// Wires and checkers for one channel of a link, for fwvip_chi_rn_link and
// fwvip_chi_sn_link.
`ifndef FWVIP_CHI_LINK_MACROS_SVH
`define FWVIP_CHI_LINK_MACROS_SVH
`define FWVIP_CHI_CH(N, W) \
    wire N``_pend, N``_v, N``_lcrdv; \
    wire [W-1:0] N``_flit;
`define FWVIP_CHI_TX(PFX, N) .PFX``FLITPEND(N``_pend), .PFX``FLITV(N``_v), .PFX``FLIT(N``_flit), .PFX``LCRDV(N``_lcrdv)
`define FWVIP_CHI_CHK(N, REQ, ACK) \
    chi_link_checker u_chk_``N (.clock, .reset, .linkactivereq(REQ), .linkactiveack(ACK), \
        .flitpend(N``_pend), .flitv(N``_v), .lcrdv(N``_lcrdv), .credits());
`endif
