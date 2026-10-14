// Which end of which link an L1 agent plays. The node ends hold the link's
// socket; the interconnect ends hold its mirror.
typedef enum {
    FWVIP_CHI_L1_RN,        // an RN:                 sends REQ RSP DAT, receives RSP DAT SNP
    FWVIP_CHI_L1_ICN_RN,    // the ICN facing an RN:  sends RSP DAT SNP, receives REQ RSP DAT
    FWVIP_CHI_L1_SN,        // an SN:                 sends RSP DAT,     receives REQ DAT
    FWVIP_CHI_L1_ICN_SN     // the ICN facing an SN:  sends REQ DAT,     receives RSP DAT
} fwvip_chi_l1_side_e;

// The L1 agent's seam: one of the kit's scripted L1 endpoints
// (chi_l1_rn_ep, chi_l1_icn_rn_ep, chi_l1_sn_ep, chi_l1_icn_sn_ep), which
// the bench builds and binds to the link -- to the other end directly
// (tlm), or to a transactor on pins (xtor). Sending calls the endpoint's
// socket or mirror; receiving takes from its per-channel inboxes.
//
// set() puts the config in the DB at time 0; the bench binds the endpoint
// each time it builds its tree (bind_rn() and friends). Until then, send()
// and recv() wait.
class fwvip_chi_l1_config extends uvm_object;
    `uvm_object_utils(fwvip_chi_l1_config)

    fwvip_chi_l1_side_e     side;
    chi_link_cfg            link_cfg;       // the link's widths, for draw() and masking

    protected chi_l1_rn_ep      m_rn;
    protected chi_l1_icn_rn_ep  m_icn_rn;
    protected chi_l1_sn_ep      m_sn;
    protected chi_l1_icn_sn_ep  m_icn_sn;
    protected int unsigned      m_n_bind;

    function new(string name = "fwvip_chi_l1_config");
        super.new(name);
        link_cfg = new();
    endfunction

    static function fwvip_chi_l1_config set(uvm_component ctxt, string inst,
                                            fwvip_chi_l1_side_e side,
                                            string field = "cfg",
                                            chi_link_cfg link_cfg = null);
        fwvip_chi_l1_config cfg = new();
        cfg.side = side;
        if (link_cfg != null) cfg.link_cfg = link_cfg;
        uvm_config_db #(fwvip_chi_l1_config)::set(ctxt, inst, field, cfg);
        return cfg;
    endfunction

    local function void bound(fwvip_chi_l1_side_e s);
        if (s != side)
            `uvm_fatal("FWVIP_CHI", $sformatf("fwvip_chi_l1_config: a %s endpoint bound to a %s config",
                                              s.name(), side.name()))
        m_n_bind++;
    endfunction

    function void bind_rn(chi_l1_rn_ep ep);         m_rn = ep;      bound(FWVIP_CHI_L1_RN);     endfunction
    function void bind_icn_rn(chi_l1_icn_rn_ep ep); m_icn_rn = ep;  bound(FWVIP_CHI_L1_ICN_RN); endfunction
    function void bind_sn(chi_l1_sn_ep ep);         m_sn = ep;      bound(FWVIP_CHI_L1_SN);     endfunction
    function void bind_icn_sn(chi_l1_icn_sn_ep ep); m_icn_sn = ep;  bound(FWVIP_CHI_L1_ICN_SN); endfunction

    // The channels this end sends and receives.
    function bit sends(chi_channel_e ch);
        case (side)
            FWVIP_CHI_L1_RN:     return ch inside {CHI_CH_REQ, CHI_CH_RSP, CHI_CH_DAT};
            FWVIP_CHI_L1_ICN_RN: return ch inside {CHI_CH_RSP, CHI_CH_DAT, CHI_CH_SNP};
            FWVIP_CHI_L1_SN:     return ch inside {CHI_CH_RSP, CHI_CH_DAT};
            default:             return ch inside {CHI_CH_REQ, CHI_CH_DAT};
        endcase
    endfunction

    function bit receives(chi_channel_e ch);
        case (side)
            FWVIP_CHI_L1_RN:     return ch inside {CHI_CH_RSP, CHI_CH_DAT, CHI_CH_SNP};
            FWVIP_CHI_L1_ICN_RN: return ch inside {CHI_CH_REQ, CHI_CH_RSP, CHI_CH_DAT};
            FWVIP_CHI_L1_SN:     return ch inside {CHI_CH_REQ, CHI_CH_DAT};
            default:             return ch inside {CHI_CH_RSP, CHI_CH_DAT};
        endcase
    endfunction

    // Send one flit; returns when the other end has accepted it (tlm) or it
    // has been credited and sent (pins).
    virtual task send(fwvip_chi_l1_item it);
        wait (m_n_bind != 0);
        if (!sends(it.ch))
            `uvm_fatal("FWVIP_CHI", $sformatf("%s does not send on %s", side.name(), it.ch.name()))
        case (side)
            FWVIP_CHI_L1_RN: case (it.ch)
                CHI_CH_REQ: m_rn.chi.t.req(it.req);
                CHI_CH_RSP: m_rn.chi.t.rsp(it.rsp);
                default:    m_rn.chi.t.dat(it.dat);
            endcase
            FWVIP_CHI_L1_ICN_RN: case (it.ch)
                CHI_CH_RSP: m_icn_rn.chi.t.rsp(it.rsp);
                CHI_CH_SNP: m_icn_rn.chi.t.snp(it.snp);
                default:    m_icn_rn.chi.t.dat(it.dat);
            endcase
            FWVIP_CHI_L1_SN: case (it.ch)
                CHI_CH_RSP: m_sn.chi.t.rsp(it.rsp);
                default:    m_sn.chi.t.dat(it.dat);
            endcase
            default: case (it.ch)
                CHI_CH_REQ: m_icn_sn.chi.t.req(it.req);
                default:    m_icn_sn.chi.t.dat(it.dat);
            endcase
        endcase
    endtask

    // The next flit received on `ch` (blocks until there is one).
    virtual task recv(chi_channel_e ch, output fwvip_chi_l1_item it);
        chi_req_flit_t q;  chi_rsp_flit_t r;  chi_snp_flit_t s;  chi_dat_flit_t d;
        wait (m_n_bind != 0);
        if (!receives(ch))
            `uvm_fatal("FWVIP_CHI", $sformatf("%s does not receive on %s", side.name(), ch.name()))
        case (side)
            FWVIP_CHI_L1_RN: case (ch)
                CHI_CH_RSP: begin m_rn.rsp_in.get(r); it = fwvip_chi_l1_item::of_rsp(r); end
                CHI_CH_SNP: begin m_rn.snp_in.get(s); it = fwvip_chi_l1_item::of_snp(s); end
                default:    begin m_rn.dat_in.get(d); it = fwvip_chi_l1_item::of_dat(d); end
            endcase
            FWVIP_CHI_L1_ICN_RN: case (ch)
                CHI_CH_REQ: begin m_icn_rn.req_in.get(q); it = fwvip_chi_l1_item::of_req(q); end
                CHI_CH_RSP: begin m_icn_rn.rsp_in.get(r); it = fwvip_chi_l1_item::of_rsp(r); end
                default:    begin m_icn_rn.dat_in.get(d); it = fwvip_chi_l1_item::of_dat(d); end
            endcase
            FWVIP_CHI_L1_SN: case (ch)
                CHI_CH_REQ: begin m_sn.req_in.get(q); it = fwvip_chi_l1_item::of_req(q); end
                default:    begin m_sn.dat_in.get(d); it = fwvip_chi_l1_item::of_dat(d); end
            endcase
            default: case (ch)
                CHI_CH_RSP: begin m_icn_sn.rsp_in.get(r); it = fwvip_chi_l1_item::of_rsp(r); end
                default:    begin m_icn_sn.dat_in.get(d); it = fwvip_chi_l1_item::of_dat(d); end
            endcase
        endcase
    endtask

    // Hold (1) or release (0) a receiving channel: the endpoint stops
    // accepting it -- on pins, the receiver withholds its credits -- while
    // the other channels keep flowing (B13.4.1).
    function void stall(chi_channel_e ch, bit on);
        if (m_n_bind == 0 || !receives(ch)) return;
        case (side)
            FWVIP_CHI_L1_RN: case (ch)
                CHI_CH_RSP: m_rn.rsp_in.stall = on;
                CHI_CH_SNP: m_rn.snp_in.stall = on;
                default:    m_rn.dat_in.stall = on;
            endcase
            FWVIP_CHI_L1_ICN_RN: case (ch)
                CHI_CH_REQ: m_icn_rn.req_in.stall = on;
                CHI_CH_RSP: m_icn_rn.rsp_in.stall = on;
                default:    m_icn_rn.dat_in.stall = on;
            endcase
            FWVIP_CHI_L1_SN: case (ch)
                CHI_CH_REQ: m_sn.req_in.stall = on;
                default:    m_sn.dat_in.stall = on;
            endcase
            default: case (ch)
                CHI_CH_RSP: m_icn_sn.rsp_in.stall = on;
                default:    m_icn_sn.dat_in.stall = on;
            endcase
        endcase
    endfunction
endclass
