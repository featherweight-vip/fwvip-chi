// L1 (raw flit) agent: plays one end of a link at flit level, over one of
// the kit's scripted L1 endpoints (see fwvip_chi_l1_config). Sequences of
// fwvip_chi_l1_item go out through the driver, each channel independently;
// every flit the end receives comes out on `ap`, in arrival order per
// channel. For link-level, negative and component tests -- nothing here
// knows about transactions.
class fwvip_chi_l1_agent extends uvm_agent;
    `uvm_component_utils(fwvip_chi_l1_agent)

    fwvip_chi_l1_config                     m_cfg;
    uvm_sequencer #(fwvip_chi_l1_item)      m_seqr;
    fwvip_chi_l1_driver                     m_driver;
    uvm_analysis_port #(fwvip_chi_l1_item)  ap;         // received
    uvm_analysis_port #(fwvip_chi_l1_item)  sent_ap;    // sent
    int unsigned                            n_recv;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(fwvip_chi_l1_config)::get(this, "", "cfg", m_cfg))
            `uvm_fatal(get_type_name(), "no fwvip_chi_l1_config \"cfg\" in the config DB")
        m_seqr   = uvm_sequencer #(fwvip_chi_l1_item)::type_id::create("m_seqr", this);
        m_driver = fwvip_chi_l1_driver::type_id::create("m_driver", this);
        m_driver.m_cfg = m_cfg;
        ap      = new("ap", this);
        sent_ap = new("sent_ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_driver.seq_item_port.connect(m_seqr.seq_item_export);
        m_driver.sent_ap.connect(sent_ap);
    endfunction

    task run_phase(uvm_phase phase);
        chi_channel_e chs[4] = '{CHI_CH_REQ, CHI_CH_RSP, CHI_CH_SNP, CHI_CH_DAT};
        foreach (chs[i]) if (m_cfg.receives(chs[i])) fork
            automatic chi_channel_e ch = chs[i];
            forever begin
                fwvip_chi_l1_item it;
                m_cfg.recv(ch, it);
                n_recv++;
                ap.write(it);
            end
        join_none
    endtask
endclass
