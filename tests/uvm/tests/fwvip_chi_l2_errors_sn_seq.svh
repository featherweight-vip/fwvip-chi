// Errors from the target (B9): DERR and NDERR on reads in every shape, and
// on writes reported in the Comp. DERR data is still delivered; an NDERR
// write changes nothing. The faults are the SN agent's memory's; the
// separate write responses that carry them are the kit SN adapter's
// completer policy, set through the SN agent's config.
class fwvip_chi_l2_errors_sn_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_errors_sn_seq)
    function new(string name = "fwvip_chi_l2_errors_sn_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact       t;
        chi_completer_policy p = new();
        chi_addr_t a_derr = 52'h2000, a_nderr = 52'h2040;
        sys.home.pol.comb_pct = 0;
        p.comb_write_rsp = 0;
        p.delay          = 0;
        env.m_sn.m_cfg.completer_policy(0, p);
        write(t, CHI_REQ_WRITE_NO_SNP_FULL, a_derr, 3'd6, rand_line());
        env.m_resp.mem.set_error(a_derr,  CHI_RESPERR_DERR);
        env.m_resp.mem.set_error(a_nderr, CHI_RESPERR_NDERR);
        for (int i = 0; i < 12; i++) begin
            read(t, (i % 2 == 1) ? CHI_REQ_READ_ONCE : CHI_REQ_READ_NO_SNP, a_derr + chi_addr_t'(16 * (i % 4)),
                 chi_size_t'(i % 7), (i % 3 == 0) ? CHI_ORDER_REQ : CHI_ORDER_NONE, i % 2 == 1);
            check(t.resp_err == CHI_RESPERR_DERR, "DERR read");
            read(t, CHI_REQ_READ_NO_SNP, a_nderr, chi_size_t'(i % 7));
            check(t.resp_err == CHI_RESPERR_NDERR, "NDERR read");
        end
        for (int i = 0; i < 8; i++) begin
            write(t, (i % 2 == 1) ? CHI_REQ_WRITE_UNIQUE_PTL : CHI_REQ_WRITE_NO_SNP_FULL, a_derr, 3'd6,
                  rand_line(), {$urandom, $urandom});
            check(t.resp_err == CHI_RESPERR_DERR, "DERR write");
            write(t, CHI_REQ_WRITE_NO_SNP_FULL, a_nderr, 3'd6, rand_line());
            check(t.resp_err == CHI_RESPERR_NDERR, "NDERR write");
        end
        env.m_resp.mem.faults.delete();
        read(t, CHI_REQ_READ_NO_SNP, a_derr);
        read(t, CHI_REQ_READ_NO_SNP, a_nderr);          // the NDERR writes did nothing
    endtask
endclass
