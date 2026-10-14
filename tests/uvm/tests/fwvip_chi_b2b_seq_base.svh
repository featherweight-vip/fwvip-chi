// Base for the back-to-back cases (the kit's l2_rn_sn suite, ported): a
// requester sequence on the RN agent with handles to the env (scoreboard,
// message log, memory responder, monitor) and to the bench's tree (the
// kit's test Home and adapters). Data is checked by the env's scoreboard;
// a case checks what is particular to it with check().
class fwvip_chi_b2b_seq_base extends fwvip_chi_rn_seq_base;
    `uvm_object_utils(fwvip_chi_b2b_seq_base)

    fwvip_chi_b2b_env  env;
    fwvip_chi_b2b_sys  sys;

    function new(string name = "fwvip_chi_b2b_seq_base");
        super.new(name);
    endfunction

    // The randomized defaults every case starts from (the kit suite's).
    virtual function void defaults();
        sys.home.pol.retry_pct = 0;
        sys.home.pol.comb_pct  = 50;
        sys.home.pol.dwt_pct   = 33;
        sys.home.clear_errors();
        env.m_sn.m_cfg.completer_policy(1);
        env.m_resp.mem.faults.delete();
    endfunction

    function void check(bit cond, string what);
        if (!cond) `uvm_error(get_type_name(), {"check failed: ", what})
    endfunction

    // Let the monitors (pins, in the xtor view) catch up.
    task settle();
        env.m_clock.tick(20);
    endtask

    static function chi_addr_t line_of(chi_addr_t a);
        return {a[CHI_ADDR_W_MAX-1:6], 6'b0};
    endfunction

    // A random address in a small region, so cases revisit lines.
    function chi_addr_t rand_addr();
        chi_addr_t a = '0;
        a[13:0] = 14'($urandom);
        return a;
    endfunction

    function logic [511:0] rand_line();
        logic [511:0] l;
        for (int i = 0; i < 16; i++) l[32*i +: 32] = $urandom;
        return l;
    endfunction
endclass
