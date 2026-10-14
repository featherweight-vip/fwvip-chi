// Data scoreboard over the RN agent's completed transactions: a byte-level
// reference of every line, starting from what the kit's chi_mem_model
// holds before it is written (init_line). A completed write updates the
// reference unless it was cancelled or answered NDERR (nothing was
// written); a completed read is checked over its window unless it was
// answered NDERR (no data). DERR data is still checked: the memory returns
// it unchanged.
//
// Completion order is the reference order, so the bench's tests never have
// a read and a write to one line in flight together.
class fwvip_chi_b2b_sb extends uvm_subscriber #(fwvip_chi_xact);
    `uvm_component_utils(fwvip_chi_b2b_sb)

    logic [511:0] ref_line[chi_addr_t];
    int unsigned  n_writes, n_reads, n_bad;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    static function chi_addr_t line_of(chi_addr_t a);
        return {a[CHI_ADDR_W_MAX-1:6], 6'b0};
    endfunction

    function logic [511:0] expect_line(chi_addr_t a);
        chi_addr_t la = line_of(a);
        return ref_line.exists(la) ? ref_line[la] : chi_mem_model::init_line(la);
    endfunction

    virtual function void write(fwvip_chi_xact t);
        logic [511:0] e = expect_line(t.addr);
        if (t.is_write()) begin
            logic [63:0] be = t.write_be();
            n_writes++;
            if (t.cancel || t.resp_err == CHI_RESPERR_NDERR) return;
            for (int i = 0; i < 64; i++) if (be[i]) e[8*i +: 8] = t.data[8*i +: 8];
            ref_line[line_of(t.addr)] = e;
        end else begin
            logic [63:0] w = t.window();
            int unsigned bad = 0;
            n_reads++;
            if (t.resp_err == CHI_RESPERR_NDERR) return;
            for (int i = 0; i < 64; i++)
                if (w[i] && t.rsp_data[8*i +: 8] !== e[8*i +: 8]) begin
                    if (bad < 4)
                        `uvm_info("SB", $sformatf("  byte %0d: got %02h want %02h", i,
                                                  t.rsp_data[8*i +: 8], e[8*i +: 8]), UVM_NONE)
                    bad++;
                end
            if (bad != 0) begin
                n_bad++;
                `uvm_error("SB", $sformatf("%s: %0d bytes wrong", t.convert2string(), bad))
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", $sformatf("%0d writes, %0d reads checked, %0d wrong", n_writes, n_reads, n_bad), UVM_LOW)
    endfunction
endclass
