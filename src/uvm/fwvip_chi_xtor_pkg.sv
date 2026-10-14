// fwvip_chi_xtor_pkg -- the consumer-side constants every fwvip-<proto> has
// (fwvip-core checklist, "width policy"). CHI needs no widths of its own:
// the kit's class-level flits are already maximum width, and a link's
// actual widths are a chi_link_param_t. This package re-exports both under
// the names the VIP and its benches use.
package fwvip_chi_xtor_pkg;
    import chi_types_pkg::*;

    // Maximum widths (IHI0050H B16.1): every VIP class field is this wide.
    localparam int ADDR_WIDTH_MAX   = CHI_ADDR_W_MAX;     // 52
    localparam int DATA_WIDTH_MAX   = CHI_DATA_W_MAX;     // 512
    localparam int NODEID_WIDTH_MAX = CHI_NODEID_W_MAX;   // 16
    localparam int RSVDC_WIDTH_MAX  = CHI_RSVDC_W_MAX;    // 32
    localparam int LINE_BYTES       = 64;

    typedef chi_link_param_t fwvip_chi_link_param_t;

    // Link presets. A bench passes one to the kit's transactors (.P) and to
    // chi_link_cfg::from_param, so both ends of a link and the class side
    // agree.
    //
    // The kit's default: 7-bit node IDs, 48-bit addresses, 256-bit data,
    // no optional fields.
    localparam chi_link_param_t FWVIP_CHI_LINK_DEFAULT = CHI_LINK_PARAM_DEFAULT;

    // The default plus Data_Poison, so poison is carried end to end.
    localparam chi_link_param_t FWVIP_CHI_LINK_POISON = '{
        node_id_w: 7, addr_w: 48, data_w: 256,
        req_rsvdc_w: 0, dat_rsvdc_w: 0, mpam_w: 0, mecid_w: 0, stream_id_w: 0,
        pbha: 1'b0, sec_sid1: 1'b0, data_check: 1'b0, poison: 1'b1};

    // The other two data widths (B16.1.13).
    localparam chi_link_param_t FWVIP_CHI_LINK_D128 = '{
        node_id_w: 7, addr_w: 48, data_w: 128,
        req_rsvdc_w: 0, dat_rsvdc_w: 0, mpam_w: 0, mecid_w: 0, stream_id_w: 0,
        pbha: 1'b0, sec_sid1: 1'b0, data_check: 1'b0, poison: 1'b0};

    localparam chi_link_param_t FWVIP_CHI_LINK_D512 = '{
        node_id_w: 7, addr_w: 48, data_w: 512,
        req_rsvdc_w: 0, dat_rsvdc_w: 0, mpam_w: 0, mecid_w: 0, stream_id_w: 0,
        pbha: 1'b0, sec_sid1: 1'b0, data_check: 1'b0, poison: 1'b0};
endpackage
