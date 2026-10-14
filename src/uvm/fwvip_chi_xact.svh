// One CHI transaction as a requester sees it: the kit's chi_xact_req_t as
// rand fields, plus the chi_xact_rsp_t the completer gave back. The RN agent
// drives it into a chi_xact_if (the kit's RN adapter); the SN agent hands
// one to its responder for every request the kit's SN adapter serves.
//
// Data, BE and poison are LINE-positioned, as in the kit: byte k of the
// 64-byte line holding `addr` is data[8k +: 8]. to_req() masks BE to the
// Size-aligned window, so a sequence may leave BE all ones.
//
// The constraints keep a randomized item inside what the kit's L2 adapters
// implement (ReadNoSnp, ReadOnce, WriteNoSnp*, WriteUnique*) and what a
// requester may legally send (IHI0050H B2.7.5.1: no Order = ReqAccepted
// from an RN; a Full write is a whole line; WriteDataCancel only for a
// Ptl write, B13.10).
class fwvip_chi_xact extends uvm_sequence_item;
    `uvm_object_utils(fwvip_chi_xact)

    // ---- request ----
    rand chi_req_opcode_e opcode;
    rand chi_addr_t       addr;
    rand chi_size_t       size;           // bytes = 1 << size
    rand chi_order_e      order;
    rand bit              exp_comp_ack;
    rand bit [3:0]        qos;
    rand bit [2:0]        pas;
    rand bit [3:0]        mem_attr;
    rand bit              snp_attr;
    rand bit [511:0]      data;           // writes
    rand bit [63:0]       be;             // writes: bytes to update (masked to the window)
    rand bit [7:0]        poison;         // writes: per 8-byte chunk of the line
    rand bit              cancel;         // writes: WriteDataCancel instead of data

    // ---- response (filled in when the transaction completes) ----
    logic [511:0]         rsp_data;       // reads: the line, valid within the window
    logic [7:0]           rsp_poison;
    logic [2:0]           resp;
    chi_resperr_e         resp_err;
    int unsigned          n_retries;

    // Set by whoever completes the transaction (the RN driver).
    local bit             m_done;

    constraint c_supported {
        opcode inside {CHI_REQ_READ_NO_SNP, CHI_REQ_READ_ONCE,
                       CHI_REQ_WRITE_NO_SNP_FULL, CHI_REQ_WRITE_NO_SNP_PTL,
                       CHI_REQ_WRITE_UNIQUE_FULL, CHI_REQ_WRITE_UNIQUE_PTL};
    }
    constraint c_size   { size <= 3'd6; }
    constraint c_order  { order != CHI_ORDER_REQ_ACCEPTED; }
    constraint c_full   {
        (opcode inside {CHI_REQ_WRITE_NO_SNP_FULL, CHI_REQ_WRITE_UNIQUE_FULL}) ->
            (size == 3'd6 && addr[5:0] == 6'd0);
    }
    constraint c_cancel {
        cancel -> (opcode inside {CHI_REQ_WRITE_NO_SNP_PTL, CHI_REQ_WRITE_UNIQUE_PTL});
    }
    constraint c_read_fields {
        (opcode inside {CHI_REQ_READ_NO_SNP, CHI_REQ_READ_ONCE}) -> (poison == 8'h00);
    }
    // Normal, non-snoopable, non-secure memory unless a test says otherwise.
    constraint c_attr_default {
        soft qos      == 4'h0;
        soft pas      == 3'h0;
        soft mem_attr == 4'h0;
        soft snp_attr == 1'b0;
    }

    function new(string name = "fwvip_chi_xact");
        super.new(name);
        opcode   = CHI_REQ_READ_NO_SNP;
        order    = CHI_ORDER_NONE;
        resp_err = CHI_RESPERR_OK;
    endfunction

    // A legal transaction drawn procedurally, honouring the constraints
    // above: what randomize() gives, without depending on the simulator's
    // solver (Verilator 5.05x skews these draws, and fails outright with no
    // SMT solver on PATH). `read_pct` of them are reads; with
    // `allow_cancel`, one Ptl write in eight is cancelled.
    function void draw(int unsigned read_pct = 50, bit allow_cancel = 0);
        chi_req_opcode_e rd_ops[2] = '{CHI_REQ_READ_NO_SNP, CHI_REQ_READ_ONCE};
        chi_req_opcode_e wr_ops[4] = '{CHI_REQ_WRITE_NO_SNP_FULL, CHI_REQ_WRITE_NO_SNP_PTL,
                                       CHI_REQ_WRITE_UNIQUE_FULL, CHI_REQ_WRITE_UNIQUE_PTL};
        chi_order_e      orders[3] = '{CHI_ORDER_NONE, CHI_ORDER_REQ, CHI_ORDER_ENDPOINT};
        opcode       = ($urandom_range(99) < read_pct) ? rd_ops[$urandom_range(1)] : wr_ops[$urandom_range(3)];
        addr         = chi_addr_t'({$urandom, $urandom});
        size         = chi_size_t'($urandom_range(6));
        order        = orders[$urandom_range(2)];
        exp_comp_ack = 1'($urandom_range(1));
        qos = '0;  pas = '0;  mem_attr = '0;  snp_attr = 0;
        for (int i = 0; i < 16; i++) data[32*i +: 32] = $urandom;
        be           = {$urandom, $urandom};
        poison       = '0;
        cancel       = 0;
        if (is_full_write()) begin
            size       = 3'd6;
            addr[5:0]  = '0;
        end else if (is_write() && allow_cancel) begin
            cancel = ($urandom_range(7) == 0);
        end
    endfunction

    function bit is_read();        return chi_is_read(opcode);       endfunction
    function bit is_write();       return chi_is_write(opcode);      endfunction
    function bit is_full_write();  return chi_is_full_write(opcode); endfunction

    // The bytes of the line this transaction's Size-aligned window covers.
    function logic [63:0] window();
        return chi_window_be(addr, size);
    endfunction

    // The bytes a write updates: the whole window for a Full write, else BE
    // within the window.
    function logic [63:0] write_be();
        return is_full_write() ? window() : (be & window());
    endfunction

    // ---- to and from the kit's L2 types ----
    function chi_xact_req_t to_req();
        chi_xact_req_t r = chi_xact_req_init();
        r.opcode       = opcode;
        r.addr         = addr;
        r.size         = size;
        r.pas          = pas;
        r.mem_attr     = mem_attr;
        r.snp_attr     = snp_attr;
        r.order        = order;
        r.exp_comp_ack = exp_comp_ack;
        r.qos          = qos;
        if (is_write()) begin
            r.data   = data;
            r.be     = write_be();
            r.poison = poison;
            r.cancel = cancel;
        end
        return r;
    endfunction

    function void from_req(chi_xact_req_t r);
        opcode       = r.opcode;
        addr         = r.addr;
        size         = r.size;
        pas          = r.pas;
        mem_attr     = r.mem_attr;
        snp_attr     = r.snp_attr;
        order        = r.order;
        exp_comp_ack = r.exp_comp_ack;
        qos          = r.qos;
        data         = r.data;
        be           = r.be;
        poison       = r.poison;
        cancel       = r.cancel;
    endfunction

    function void set_rsp(chi_xact_rsp_t r);
        rsp_data   = r.data;
        rsp_poison = r.poison;
        resp       = r.resp;
        resp_err   = r.resp_err;
        n_retries  = r.n_retries;
    endfunction

    function chi_xact_rsp_t to_rsp();
        chi_xact_rsp_t r = chi_xact_rsp_init();
        r.data      = rsp_data;
        r.poison    = rsp_poison;
        r.resp      = resp;
        r.resp_err  = resp_err;
        r.n_retries = n_retries;
        return r;
    endfunction

    // ---- completion ----
    function void clear_done();  m_done = 0; endfunction
    function void mark_done();   m_done = 1; endfunction
    function bit  done();        return m_done; endfunction
    task wait_done();
        wait (m_done);
    endtask

    virtual function void do_copy(uvm_object rhs);
        fwvip_chi_xact o;
        super.do_copy(rhs);
        if (!$cast(o, rhs)) `uvm_fatal("COPY", "not a fwvip_chi_xact")
        opcode = o.opcode;  addr = o.addr;  size = o.size;  order = o.order;
        exp_comp_ack = o.exp_comp_ack;  qos = o.qos;  pas = o.pas;
        mem_attr = o.mem_attr;  snp_attr = o.snp_attr;  data = o.data;  be = o.be;
        poison = o.poison;  cancel = o.cancel;
        set_rsp(o.to_rsp());
    endfunction

    virtual function string convert2string();
        string s = $sformatf("%s @%0h size=%0d", opcode.name(), addr, 1 << size);
        if (order != CHI_ORDER_NONE) s = {s, $sformatf(" order=%s", order.name())};
        if (exp_comp_ack)            s = {s, " ack"};
        if (cancel)                  s = {s, " cancel"};
        if (resp_err != CHI_RESPERR_OK) s = {s, $sformatf(" -> %s", resp_err.name())};
        if (n_retries != 0)          s = {s, $sformatf(" retries=%0d", n_retries)};
        return s;
    endfunction
endclass
