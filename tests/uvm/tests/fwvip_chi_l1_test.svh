// L1 back-to-back (plan V.03): an L1 agent at each end of an RN link and an
// SN link sends random flits on every channel it owns, all at once. Every
// flit must arrive at the other end unchanged and in order per channel (the
// scoreboards), and the links' monitor must publish every one.
class fwvip_chi_l1_test extends uvm_test;
    `uvm_component_utils(fwvip_chi_l1_test)

    fwvip_chi_l1_env m_env;
    int unsigned     n_per_channel = 32;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_env = fwvip_chi_l1_env::type_id::create("m_env", this);
    endfunction

    function fwvip_chi_l1_rand_seq mk_seq(string name);
        fwvip_chi_l1_rand_seq s = fwvip_chi_l1_rand_seq::type_id::create(name);
        s.n_per_channel = n_per_channel;
        return s;
    endfunction

    // All four ends at once.
    virtual task run_case();
        fwvip_chi_l1_agent agents[4] = '{m_env.m_rn, m_env.m_icn_rn, m_env.m_sn, m_env.m_icn_sn};
        int unsigned n_done = 0;
        foreach (agents[i]) fork
            automatic int k = i;
            begin
                fwvip_chi_l1_rand_seq s = mk_seq($sformatf("rand_%0d", k));
                s.start(agents[k].m_seqr);
                n_done++;
            end
        join_none
        wait (n_done == 4);
    endtask

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        m_env.wait_ready();
        run_case();
        m_env.m_clock.tick(50);
        `uvm_info(get_type_name(), $sformatf("%0d flits sent, %0d received as sent, %0d seen by the monitor",
                  m_env.n_sent(), m_env.n_matched(), m_env.m_mon.n_msgs), UVM_LOW)
        if (m_env.n_sent() == 0)
            `uvm_error(get_type_name(), "nothing was sent")
        if (m_env.n_matched() != m_env.n_sent())
            `uvm_error(get_type_name(), "not every flit sent was received as sent")
        if (m_env.m_mon.n_msgs != m_env.n_sent())
            `uvm_error(get_type_name(), "the monitor did not see every flit")
        phase.drop_objection(this);
    endtask
endclass
