typedef class fwvip_chi_sn_config;

// The SN agent's driver. It never polls anything: the kit's SN adapter
// calls the config (chi_xact_if) once per request, the config calls
// service(), and service() takes the responder from the sequencer and
// calls it. Requests are served concurrently -- the adapter serves every
// request in its own process -- so only the hand-over from the sequencer
// is serialized; the responder runs outside it.
class fwvip_chi_sn_driver extends uvm_driver #(fwvip_chi_sn_item);
    `uvm_component_utils(fwvip_chi_sn_driver)

    fwvip_chi_sn_config                  m_cfg;
    uvm_analysis_port #(fwvip_chi_xact)  ap;          // every served request, completed
    int unsigned                         n_served;
    local semaphore                      m_lock;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        m_lock = new(1);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        m_cfg.attach(this);
    endtask

    task service(fwvip_chi_xact t);
        fwvip_chi_sn_item it;
        fwvip_chi_sn_if   h;
        m_lock.get(1);
        seq_item_port.get_next_item(it);
        h = it.handler;
        seq_item_port.item_done();
        m_lock.put(1);
        if (h == null) `uvm_fatal(get_type_name(), "SN item with no handler")
        h.access(t);
        n_served++;
        ap.write(t);
    endtask
endclass
