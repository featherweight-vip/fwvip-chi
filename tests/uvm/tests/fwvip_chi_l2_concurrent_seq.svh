// Many transactions in flight at once, each to its own line: 32 threads,
// each a write then a read of its line.
class fwvip_chi_l2_concurrent_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_concurrent_seq)
    function new(string name = "fwvip_chi_l2_concurrent_seq"); super.new(name); endfunction

    task body();
        chi_addr_t    a[$];
        logic [511:0] d[$];
        int unsigned  n_done = 0;
        for (int i = 0; i < 32; i++) begin
            a.push_back({38'd0, 8'(i), 6'b0} + 52'h10000);
            d.push_back(rand_line());
        end
        foreach (a[i]) fork
            automatic int k = i;
            begin
                fwvip_chi_xact t;
                write(t, CHI_REQ_WRITE_NO_SNP_FULL, a[k], 3'd6, d[k]);
                read(t, CHI_REQ_READ_NO_SNP, a[k]);
                n_done++;
            end
        join_none
        wait (n_done == 32);
        check(env.m_sb.n_reads == 32, "32 reads checked");
    endtask
endclass
