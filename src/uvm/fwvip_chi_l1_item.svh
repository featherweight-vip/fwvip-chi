// One flit on one channel of a link, for the L1 agent: raw link-level
// traffic with no transaction behind it -- for link-level tests, negative
// tests, and testing a component one port at a time. Exactly one of
// req/rsp/snp/dat is meaningful, per `ch`. On an inbound item, `side` is
// the agent that received it.
class fwvip_chi_l1_item extends uvm_sequence_item;
    `uvm_object_utils(fwvip_chi_l1_item)

    chi_channel_e   ch;
    chi_req_flit_t  req;
    chi_rsp_flit_t  rsp;
    chi_snp_flit_t  snp;
    chi_dat_flit_t  dat;

    local bit       m_done;

    function new(string name = "fwvip_chi_l1_item");
        super.new(name);
        ch  = CHI_CH_REQ;
        req = '0;  rsp = '0;  snp = '0;  dat = '0;
    endfunction

    static function fwvip_chi_l1_item of_req(chi_req_flit_t f);
        fwvip_chi_l1_item it = new("req");  it.ch = CHI_CH_REQ;  it.req = f;  return it;
    endfunction
    static function fwvip_chi_l1_item of_rsp(chi_rsp_flit_t f);
        fwvip_chi_l1_item it = new("rsp");  it.ch = CHI_CH_RSP;  it.rsp = f;  return it;
    endfunction
    static function fwvip_chi_l1_item of_snp(chi_snp_flit_t f);
        fwvip_chi_l1_item it = new("snp");  it.ch = CHI_CH_SNP;  it.snp = f;  return it;
    endfunction
    static function fwvip_chi_l1_item of_dat(chi_dat_flit_t f);
        fwvip_chi_l1_item it = new("dat");  it.ch = CHI_CH_DAT;  it.dat = f;  return it;
    endfunction

    // The protocol opcodes of each channel: every defined one but the link
    // flit (LCrdReturn never crosses L1).
    static chi_req_opcode_e m_req_ops[$];
    static chi_rsp_opcode_e m_rsp_ops[$];
    static chi_snp_opcode_e m_snp_ops[$];
    static chi_dat_opcode_e m_dat_ops[$];

    static function void init_ops();
        chi_req_opcode_e q;  chi_rsp_opcode_e r;  chi_snp_opcode_e s;  chi_dat_opcode_e d;
        if (m_req_ops.size() != 0) return;
        q = q.first(); do begin if (q != CHI_REQ_LCRD_RETURN) m_req_ops.push_back(q); q = q.next(); end while (q != q.first());
        r = r.first(); do begin if (r != CHI_RSP_LCRD_RETURN) m_rsp_ops.push_back(r); r = r.next(); end while (r != r.first());
        s = s.first(); do begin if (s != CHI_SNP_LCRD_RETURN) m_snp_ops.push_back(s); s = s.next(); end while (s != s.first());
        d = d.first(); do begin if (d != CHI_DAT_LCRD_RETURN) m_dat_ops.push_back(d); d = d.next(); end while (d != d.first());
    endfunction

    // A random protocol flit on `c`: random fields, a random protocol
    // opcode, masked to the link so that what arrives is exactly what was
    // sent (chi_link_cfg::mask_*).
    function void draw(chi_channel_e c, chi_link_cfg cfg);
        logic [1023:0] v;
        init_ops();
        for (int i = 0; i < 32; i++) v[i*32 +: 32] = $urandom;
        ch = c;
        case (c)
            CHI_CH_REQ: begin
                req = chi_req_flit_t'(v);
                req.opcode = m_req_ops[$urandom_range(m_req_ops.size() - 1)];
                req = cfg.mask_req(req);
            end
            CHI_CH_RSP: begin
                rsp = chi_rsp_flit_t'(v);
                rsp.opcode = m_rsp_ops[$urandom_range(m_rsp_ops.size() - 1)];
                rsp = cfg.mask_rsp(rsp);
            end
            CHI_CH_SNP: begin
                snp = chi_snp_flit_t'(v);
                snp.opcode = m_snp_ops[$urandom_range(m_snp_ops.size() - 1)];
                snp = cfg.mask_snp(snp);
            end
            default: begin
                dat = chi_dat_flit_t'(v);
                dat.opcode = m_dat_ops[$urandom_range(m_dat_ops.size() - 1)];
                dat = cfg.mask_dat(dat);
            end
        endcase
    endfunction

    // Same channel, same flit.
    function bit same(fwvip_chi_l1_item o);
        if (o == null || o.ch != ch) return 0;
        case (ch)
            CHI_CH_REQ: return req === o.req;
            CHI_CH_RSP: return rsp === o.rsp;
            CHI_CH_SNP: return snp === o.snp;
            default:    return dat === o.dat;
        endcase
    endfunction

    function void clear_done();  m_done = 0; endfunction
    function void mark_done();   m_done = 1; endfunction
    task wait_done();
        wait (m_done);
    endtask

    virtual function void do_copy(uvm_object rhs);
        fwvip_chi_l1_item o;
        super.do_copy(rhs);
        if (!$cast(o, rhs)) `uvm_fatal("COPY", "not a fwvip_chi_l1_item")
        ch = o.ch;  req = o.req;  rsp = o.rsp;  snp = o.snp;  dat = o.dat;
    endfunction

    virtual function string convert2string();
        case (ch)
            CHI_CH_REQ: return $sformatf("REQ %s tgt=%0d src=%0d txn=%0h", req.opcode.name(), req.tgt_id, req.src_id, req.txn_id);
            CHI_CH_RSP: return $sformatf("RSP %s tgt=%0d src=%0d txn=%0h", rsp.opcode.name(), rsp.tgt_id, rsp.src_id, rsp.txn_id);
            CHI_CH_SNP: return $sformatf("SNP %s src=%0d txn=%0h", snp.opcode.name(), snp.src_id, snp.txn_id);
            default:    return $sformatf("DAT %s tgt=%0d src=%0d txn=%0h id=%0d", dat.opcode.name(), dat.tgt_id, dat.src_id, dat.txn_id, dat.data_id);
        endcase
    endfunction
endclass
