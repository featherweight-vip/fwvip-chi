// Every write request with each RN-to-HN Order (B2.7.5.1 permits it on all
// of them), with and without CompAck, checked by reading back.
class fwvip_chi_l2_ordered_writes_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_ordered_writes_seq)
    function new(string name = "fwvip_chi_l2_ordered_writes_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        chi_req_opcode_e ops[4] = '{CHI_REQ_WRITE_NO_SNP_FULL, CHI_REQ_WRITE_NO_SNP_PTL,
                                    CHI_REQ_WRITE_UNIQUE_FULL, CHI_REQ_WRITE_UNIQUE_PTL};
        for (int i = 0; i < 16; i++) begin
            chi_addr_t a = rand_addr();
            chi_size_t s = chi_size_t'($urandom_range(6));
            if (i % 2 == 0) begin a = line_of(a); s = 3'd6; end      // Full writes: a whole line
            write(t, ops[i % 4], a, s, rand_line(), {$urandom, $urandom},
                  i % 3 == 0, 0, '0, (i % 8 < 4) ? CHI_ORDER_REQ : CHI_ORDER_ENDPOINT);
            read(t, CHI_REQ_READ_NO_SNP, line_of(a));
        end
    endtask
endclass
