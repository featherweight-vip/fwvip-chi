// The monitor agent has teeth: traffic first (which must be clean), then a
// flit no transaction explains -- a CompData to the RN for a TxnID nobody
// used -- fed to the agent as if it came off the link. The flow checker must
// flag it (R2) and the agent must report it as a UVM_ERROR; this test turns
// those errors into infos and checks that it saw them.
class fwvip_chi_mon_teeth_test extends fwvip_chi_b2b_test;
    `uvm_component_utils(fwvip_chi_mon_teeth_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task post_case();
        chi_msg      m;
        int unsigned n_err0;
        uvm_report_server srv = uvm_report_server::get_server();
        if (m_env.m_mon.n_errors() != 0)
            `uvm_error(get_type_name(), "traffic before the bad flit was not clean")
        m_env.m_mon.set_report_severity_id_override(UVM_ERROR, "CHI_FLOW", UVM_INFO);
        n_err0 = srv.get_id_count("CHI_FLOW");
        m = new("rn", CHI_DIR_DOWN, CHI_CH_DAT);
        m.dat        = '0;
        m.dat.opcode = CHI_DAT_COMP_DATA;
        m.dat.tgt_id = 1;
        m.dat.src_id = 2;
        m.dat.txn_id = 12'h0ab;
        m_env.m_mon.m_cfg.observe(m);
        if (m_env.m_mon.n_errors() == 0)
            `uvm_error(get_type_name(), "the flow checker did not flag a CompData for no transaction")
        if (srv.get_id_count("CHI_FLOW") == n_err0)
            `uvm_error(get_type_name(), "the monitor agent did not report the violation")
        `uvm_info(get_type_name(), $sformatf("flagged: %s", m_env.m_mon.chk.last_error), UVM_LOW)
        m_env.m_mon.clear();
    endtask
endclass
