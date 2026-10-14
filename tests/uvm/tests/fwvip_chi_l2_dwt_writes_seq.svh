// DWT (B2.3.2.1 alt 1): every write the Home may send DWT goes that way; the
// data reaches memory all the same.
class fwvip_chi_l2_dwt_writes_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_dwt_writes_seq)
    function new(string name = "fwvip_chi_l2_dwt_writes_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        int unsigned dwt0 = env.m_mon.chk.shape_hits[CHI_FT_WR_DWT];
        chi_req_opcode_e ops[4] = '{CHI_REQ_WRITE_NO_SNP_FULL, CHI_REQ_WRITE_NO_SNP_PTL,
                                    CHI_REQ_WRITE_UNIQUE_FULL, CHI_REQ_WRITE_UNIQUE_PTL};
        sys.home.pol.dwt_pct = 100;
        for (int i = 0; i < 24; i++) begin
            chi_addr_t a = rand_addr();
            chi_size_t s = chi_size_t'($urandom_range(6));
            if (i % 2 == 0) begin a = line_of(a); s = 3'd6; end
            write(t, ops[i % 4], a, s, rand_line(), {$urandom, $urandom});
            read(t, CHI_REQ_READ_NO_SNP, line_of(a));
        end
        settle();
        check(env.m_mon.chk.shape_hits[CHI_FT_WR_DWT] - dwt0 == 24, "24 DWT writes");
    endtask
endclass
