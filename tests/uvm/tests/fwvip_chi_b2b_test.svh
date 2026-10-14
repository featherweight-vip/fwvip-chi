// The back-to-back test: one case, chosen by +SEQ=<case sequence>, on the
// RN agent, with the memory responder on the SN agent. At the end the kit's
// L2 classes must have counted no protocol error and the monitor agent's
// flow checker must have seen transactions complete (it checks quiescence
// itself, in check_phase).
class fwvip_chi_b2b_test extends uvm_test;
    `uvm_component_utils(fwvip_chi_b2b_test)

    fwvip_chi_b2b_env m_env;
    int unsigned      m_n_txns;      // completed transactions the checker classified

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_env = fwvip_chi_b2b_env::type_id::create("m_env", this);
    endfunction

    // The case to run: +SEQ=<name>, the smoke case by default.
    virtual function fwvip_chi_b2b_seq_base make_seq();
        string      name = "fwvip_chi_l2_write_read_seq";
        uvm_object  obj;
        fwvip_chi_b2b_seq_base seq;
        void'($value$plusargs("SEQ=%s", name));
        obj = uvm_factory::get().create_object_by_name(name, "", "seq");
        if (obj == null || !$cast(seq, obj))
            `uvm_fatal(get_type_name(), $sformatf("+SEQ=%s is not a fwvip_chi_b2b_seq_base", name))
        return seq;
    endfunction

    task run_phase(uvm_phase phase);
        fwvip_chi_b2b_seq_base seq = make_seq();
        phase.raise_objection(this);
        m_env.wait_ready();
        m_env.start_responder();
        seq.env = m_env;
        seq.sys = fwvip_chi_b2b_sys::inst;
        seq.defaults();
        `uvm_info(get_type_name(), $sformatf("running %s", seq.get_type_name()), UVM_LOW)
        seq.start(m_env.m_rn.m_seqr);
        seq.settle();
        m_n_txns = m_env.m_mon.chk.n_txns_done;
        post_case();
        phase.drop_objection(this);
    endtask

    // After the case, before the end of the run: for tests that add a step.
    virtual task post_case();
    endtask

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (fwvip_chi_b2b_sys::inst.n_errors() != 0)
            `uvm_error(get_type_name(), $sformatf("the kit's L2 classes counted %0d protocol errors",
                                                  fwvip_chi_b2b_sys::inst.n_errors()))
        if (m_n_txns == 0)
            `uvm_error(get_type_name(), "the flow checker saw no transaction complete")
    endfunction
endclass
