// The L1 bench's UVM env: an L1 agent at each end of both links, a
// scoreboard per link direction, and the monitor agent -- publishing only:
// raw random flits are not transactions, so its flow checker is off.
class fwvip_chi_l1_env extends uvm_env;
    `uvm_component_utils(fwvip_chi_l1_env)

    fwvip_chi_l1_agent    m_rn, m_icn_rn, m_sn, m_icn_sn;
    fwvip_chi_mon_agent   m_mon;
    fwvip_chi_l1_sb       m_sb_rn_up, m_sb_rn_dn, m_sb_sn_up, m_sb_sn_dn;
    fwvip_reset_config    m_reset;
    fwvip_clock_config    m_clock;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_rn      = fwvip_chi_l1_agent::type_id::create("m_rn", this);
        m_icn_rn  = fwvip_chi_l1_agent::type_id::create("m_icn_rn", this);
        m_sn      = fwvip_chi_l1_agent::type_id::create("m_sn", this);
        m_icn_sn  = fwvip_chi_l1_agent::type_id::create("m_icn_sn", this);
        m_mon     = fwvip_chi_mon_agent::type_id::create("m_mon", this);
        m_mon.check_enable = 0;
        m_sb_rn_up = fwvip_chi_l1_sb::type_id::create("m_sb_rn_up", this);
        m_sb_rn_dn = fwvip_chi_l1_sb::type_id::create("m_sb_rn_dn", this);
        m_sb_sn_up = fwvip_chi_l1_sb::type_id::create("m_sb_sn_up", this);
        m_sb_sn_dn = fwvip_chi_l1_sb::type_id::create("m_sb_sn_dn", this);
        if (!uvm_config_db #(fwvip_reset_config)::get(this, "", "reset", m_reset))
            `uvm_fatal(get_type_name(), "no reset provider (fwvip_reset_config) in the config DB")
        if (!uvm_config_db #(fwvip_clock_config)::get(this, "", "clock", m_clock))
            `uvm_fatal(get_type_name(), "no clock provider (fwvip_clock_config) in the config DB")
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_rn.sent_ap.connect(m_sb_rn_up.sent_export);      m_icn_rn.ap.connect(m_sb_rn_up.recv_export);
        m_icn_rn.sent_ap.connect(m_sb_rn_dn.sent_export);  m_rn.ap.connect(m_sb_rn_dn.recv_export);
        m_sn.sent_ap.connect(m_sb_sn_up.sent_export);      m_icn_sn.ap.connect(m_sb_sn_up.recv_export);
        m_icn_sn.sent_ap.connect(m_sb_sn_dn.sent_export);  m_sn.ap.connect(m_sb_sn_dn.recv_export);
    endfunction

    task wait_ready();
        m_reset.wait_reset();
        fwvip_chi_l1_sys::wait_ready();
    endtask

    function int unsigned n_sent();
        return m_rn.m_driver.n_sent + m_icn_rn.m_driver.n_sent + m_sn.m_driver.n_sent + m_icn_sn.m_driver.n_sent;
    endfunction

    function int unsigned n_matched();
        return m_sb_rn_up.n_matched() + m_sb_rn_dn.n_matched() + m_sb_sn_up.n_matched() + m_sb_sn_dn.n_matched();
    endfunction
endclass
