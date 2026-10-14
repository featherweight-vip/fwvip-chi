// The VIP's own random sequence (fwvip_chi_rand_seq), on distinct lines per
// parallel slot so the scoreboard's completion order is the memory's, with
// the SN responder answering after a random latency.
class fwvip_chi_rand_traffic_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_rand_traffic_seq)
    function new(string name = "fwvip_chi_rand_traffic_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_rand_seq s[4];
        int unsigned n_done = 0;
        sys.home.pol.retry_pct = 10;
        env.m_resp.policy.lat_min = 0;
        env.m_resp.policy.lat_max = 8;
        foreach (s[i]) begin
            s[i] = fwvip_chi_rand_seq::type_id::create($sformatf("rand%0d", i));
            s[i].n_xacts      = 48;
            s[i].n_parallel   = 1;
            s[i].base         = chi_addr_t'(52'h40000 + 52'h4000 * i);
            s[i].span         = 'h400;
            s[i].allow_cancel = 1;
        end
        foreach (s[i]) fork
            automatic int k = i;
            begin
                s[k].start(m_sequencer, this);
                n_done++;
            end
        join_none
        wait (n_done == 4);
        check(env.m_rn.m_driver.n_done == 4 * 48, "every transaction completed");
    endtask
endclass
