// Half of all requests are retried; PCrdGrant sometimes overtakes the
// RetryAck (B2.10). Every transaction still completes, correctly.
class fwvip_chi_l2_retry_storm_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_retry_storm_seq)
    function new(string name = "fwvip_chi_l2_retry_storm_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        int unsigned retries = 0;
        sys.home.pol.retry_pct = 50;
        for (int i = 0; i < 32; i++) begin
            chi_addr_t a = rand_addr();
            if (i % 2 == 1) write(t, CHI_REQ_WRITE_NO_SNP_FULL, line_of(a), 3'd6, rand_line());
            else       read(t, CHI_REQ_READ_ONCE, a, chi_size_t'($urandom_range(6)));
            retries += t.n_retries;
        end
        check(retries > 0, "some requests were retried");
        check(retries == sys.home.n_retries, "the RN saw every retry the Home gave");
    endtask
endclass
