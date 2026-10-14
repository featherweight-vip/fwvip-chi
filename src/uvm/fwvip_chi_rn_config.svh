// The RN agent's seam (design §10.2): what its driver calls to run one
// transaction. The agent depends only on this abstract config; the bench
// sets a specialization in the config DB under "cfg".
class fwvip_chi_rn_config extends uvm_object;
    `uvm_object_utils(fwvip_chi_rn_config)

    // How many transactions the driver keeps in flight at once.
    int unsigned max_outstanding = 16;

    function new(string name = "fwvip_chi_rn_config");
        super.new(name);
    endfunction

    // Run one transaction to completion: issue it, wait for it, fill in its
    // response fields.
    virtual task xact(fwvip_chi_xact t);
        `uvm_fatal("FWVIP_CHI", "fwvip_chi_rn_config::xact: no implementation (set a fwvip_chi_rn_config_ap)")
    endtask
endclass

// API-handle specialization: holds a chi_xact_if -- in practice the `xact`
// export of the kit's chi_rn_adapter, which the bench builds and binds to a
// link (pins in the xtor view, the interconnect directly in the tlm view).
// The kit's L2 does everything CHI-specific (TxnIDs, retry and P-credits,
// CompAck, DMT/DWT, beats); this config only converts the item.
//
// The bench owns the fw-hdl tree, which is built after reset and rebuilt
// on every reset, so the handle is bound late: set() puts the config in the
// DB at time 0 and the bench calls bind_if() each time it builds the
// adapter. xact() waits for a binding.
class fwvip_chi_rn_config_ap extends fwvip_chi_rn_config;
    `uvm_object_utils(fwvip_chi_rn_config_ap)

    protected chi_xact_if  m_if;
    protected int unsigned m_n_bind;

    function new(string name = "fwvip_chi_rn_config_ap");
        super.new(name);
    endfunction

    // Make a config, set it in the DB for `inst` (a component path glob)
    // under `field`, and return it so the bench can bind it later.
    static function fwvip_chi_rn_config_ap set(uvm_component ctxt, string inst,
                                               string field = "cfg", chi_xact_if h = null);
        fwvip_chi_rn_config_ap cfg = new();
        if (h != null) cfg.bind_if(h);
        uvm_config_db #(fwvip_chi_rn_config)::set(ctxt, inst, field, cfg);
        return cfg;
    endfunction

    function void bind_if(chi_xact_if h);
        m_if = h;
        m_n_bind++;
    endfunction

    function bit is_bound();
        return m_if != null;
    endfunction

    virtual task xact(fwvip_chi_xact t);
        chi_xact_rsp_t rsp;
        wait (m_n_bind != 0);
        m_if.xact(rsp, t.to_req());
        t.set_rsp(rsp);
    endtask
endclass
