// The back-to-back UVM env: the VIP's three agents on the bench's fw-hdl
// tree, a data scoreboard on the RN agent's completions, and a log of the
// monitor's messages. The memory responder runs on the SN agent from the
// start of the run (start_responder()).
class fwvip_chi_b2b_env extends uvm_env;
    `uvm_component_utils(fwvip_chi_b2b_env)

    fwvip_chi_rn_agent           m_rn;
    fwvip_chi_sn_agent           m_sn;
    fwvip_chi_mon_agent          m_mon;
    fwvip_chi_b2b_sb             m_sb;
    fwvip_chi_b2b_msg_log        m_log;
    fwvip_chi_mem_responder_seq  m_resp;
    fwvip_reset_config           m_reset;
    fwvip_clock_config           m_clock;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_rn  = fwvip_chi_rn_agent::type_id::create("m_rn", this);
        m_sn  = fwvip_chi_sn_agent::type_id::create("m_sn", this);
        m_mon = fwvip_chi_mon_agent::type_id::create("m_mon", this);
        m_sb  = fwvip_chi_b2b_sb::type_id::create("m_sb", this);
        m_log = fwvip_chi_b2b_msg_log::type_id::create("m_log", this);
        if (!uvm_config_db #(fwvip_reset_config)::get(this, "", "reset", m_reset))
            `uvm_fatal(get_type_name(), "no reset provider (fwvip_reset_config) in the config DB")
        if (!uvm_config_db #(fwvip_clock_config)::get(this, "", "clock", m_clock))
            `uvm_fatal(get_type_name(), "no clock provider (fwvip_clock_config) in the config DB")
        m_resp = fwvip_chi_mem_responder_seq::type_id::create("m_resp");
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_rn.ap.connect(m_sb.analysis_export);
        m_mon.ap.connect(m_log.analysis_export);
    endfunction

    task start_responder();
        fork
            m_resp.start(m_sn.m_seqr);
        join_none
    endtask

    // Out of reset, the bench's tree built and running.
    task wait_ready();
        m_reset.wait_reset();
        fwvip_chi_b2b_sys::wait_ready();
    endtask
endclass
