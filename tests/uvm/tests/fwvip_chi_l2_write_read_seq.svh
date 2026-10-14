// Full-line writes, then reads of the same lines. (Smoke.)
class fwvip_chi_l2_write_read_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_write_read_seq)
    function new(string name = "fwvip_chi_l2_write_read_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        chi_addr_t a[$];
        for (int i = 0; i < 16; i++) a.push_back(line_of(rand_addr()));
        foreach (a[i]) write(t, CHI_REQ_WRITE_NO_SNP_FULL, a[i], 3'd6, rand_line());
        foreach (a[i]) begin
            read(t, CHI_REQ_READ_NO_SNP, a[i]);
            check(t.resp_err == CHI_RESPERR_OK, "read answered OK");
        end
        check(env.m_sb.n_reads == 16, "16 reads checked");
    endtask
endclass
