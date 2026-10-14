// The Home's own NDERR (B9.1.1): answered without the SN, never by DMT
// (B9.1.3), NDERR in every packet.
class fwvip_chi_l2_errors_home_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_errors_home_seq)
    function new(string name = "fwvip_chi_l2_errors_home_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        chi_addr_t   a = 52'h3000;
        int unsigned dmt0, sn_reads0;
        sys.home.set_error(a, CHI_RESPERR_NDERR);
        dmt0      = env.m_mon.chk.shape_hits[CHI_FT_RD_DMT_COMPDATA];
        sn_reads0 = env.m_resp.mem.n_reads;
        for (int i = 0; i < 16; i++) begin
            read(t, (i % 2 == 1) ? CHI_REQ_READ_ONCE : CHI_REQ_READ_NO_SNP, a, chi_size_t'(i % 7),
                 (i % 4 == 1) ? CHI_ORDER_REQ : CHI_ORDER_NONE, i % 3 == 0);
            check(t.resp_err == CHI_RESPERR_NDERR, "NDERR read from the Home");
            write(t, CHI_REQ_WRITE_NO_SNP_PTL, a, chi_size_t'(i % 7), rand_line());
            check(t.resp_err == CHI_RESPERR_NDERR, "NDERR write from the Home");
        end
        settle();
        check(env.m_mon.chk.shape_hits[CHI_FT_RD_DMT_COMPDATA] == dmt0, "no DMT for a Home error");
        check(env.m_resp.mem.n_reads == sn_reads0, "the SN was never asked");
        sys.home.clear_errors();
        read(t, CHI_REQ_READ_NO_SNP, a);                 // nothing was written
    endtask
endclass
