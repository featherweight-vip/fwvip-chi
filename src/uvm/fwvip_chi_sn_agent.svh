// Completer agent (design §10.3): its responder sequence answers every
// request the kit's SN adapter serves. Fetches "cfg" (a
// fwvip_chi_sn_config) and, optionally, "clock" (fwvip-core's
// fwvip_clock_config, which responders use to count latency in cycles).
// `ap` publishes every served request, completed.
class fwvip_chi_sn_agent extends uvm_agent;
    `uvm_component_utils(fwvip_chi_sn_agent)

    fwvip_chi_sn_config                  m_cfg;
    fwvip_clock_if                       m_clock;     // null: no clock provider
    fwvip_chi_sn_sequencer               m_seqr;
    fwvip_chi_sn_driver                  m_driver;
    uvm_analysis_port #(fwvip_chi_xact)  ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        fwvip_clock_config clk;
        super.build_phase(phase);
        if (!uvm_config_db #(fwvip_chi_sn_config)::get(this, "", "cfg", m_cfg))
            `uvm_fatal(get_type_name(), "no fwvip_chi_sn_config \"cfg\" in the config DB")
        if (uvm_config_db #(fwvip_clock_config)::get(this, "", "clock", clk))
            m_clock = clk;
        m_seqr   = fwvip_chi_sn_sequencer::type_id::create("m_seqr", this);
        m_driver = fwvip_chi_sn_driver::type_id::create("m_driver", this);
        m_driver.m_cfg = m_cfg;
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_driver.seq_item_port.connect(m_seqr.seq_item_export);
        m_driver.ap.connect(ap);
    endfunction
endclass
