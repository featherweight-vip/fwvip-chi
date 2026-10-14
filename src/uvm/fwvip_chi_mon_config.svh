typedef class fwvip_chi_mon_agent;

// The monitor agent's seam: a chi_mon_if subscriber. The bench subscribes it
// to whatever publishes the links' flits -- the kit's TLM taps (tlm view)
// or pin monitors (chi_link_mon_xtor + chi_link_mon_xtor_bridge, xtor view)
// -- usually through a chi_mon_fanout:
//
//     fan.subscribe(cfg);
//
// `link_cfg` tells the agent's flow checker the links' Data_Width.
class fwvip_chi_mon_config extends uvm_object implements chi_mon_if;
    `uvm_object_utils(fwvip_chi_mon_config)

    chi_link_cfg                  link_cfg;
    protected fwvip_chi_mon_agent m_agent;

    function new(string name = "fwvip_chi_mon_config");
        super.new(name);
    endfunction

    static function fwvip_chi_mon_config set(uvm_component ctxt, string inst,
                                             string field = "cfg",
                                             chi_link_cfg link_cfg = null);
        fwvip_chi_mon_config cfg = new();
        cfg.link_cfg = link_cfg;
        uvm_config_db #(fwvip_chi_mon_config)::set(ctxt, inst, field, cfg);
        return cfg;
    endfunction

    function void attach(fwvip_chi_mon_agent agent);
        m_agent = agent;
    endfunction

    virtual function void observe(chi_msg m);
        if (m_agent != null) m_agent.observe(m);
    endfunction
endclass
