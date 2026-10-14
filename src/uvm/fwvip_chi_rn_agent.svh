// Requester agent (design §10.3): sequences of fwvip_chi_xact items, driven
// into a chi_xact_if through the config. Fetches "cfg" (a
// fwvip_chi_rn_config) from the config DB. `ap` publishes every completed
// transaction, response fields filled in.
class fwvip_chi_rn_agent extends uvm_agent;
    `uvm_component_utils(fwvip_chi_rn_agent)

    fwvip_chi_rn_config                  m_cfg;
    fwvip_chi_rn_sequencer               m_seqr;
    fwvip_chi_rn_driver                  m_driver;
    uvm_analysis_port #(fwvip_chi_xact)  ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(fwvip_chi_rn_config)::get(this, "", "cfg", m_cfg))
            `uvm_fatal(get_type_name(), "no fwvip_chi_rn_config \"cfg\" in the config DB")
        m_seqr   = fwvip_chi_rn_sequencer::type_id::create("m_seqr", this);
        m_driver = fwvip_chi_rn_driver::type_id::create("m_driver", this);
        m_driver.m_cfg = m_cfg;
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_driver.seq_item_port.connect(m_seqr.seq_item_export);
        m_driver.ap.connect(ap);
    endfunction
endclass
