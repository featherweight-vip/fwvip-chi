typedef class fwvip_chi_sn_driver;

// The SN agent's seam (design §10.2): it IS the chi_xact_if behind the
// kit's SN adapter. The bench builds the adapter and connects its `mem`
// port to an export provided by this config:
//
//     sn_x = new("sn_x", this, cfg);      // fw_export #(chi_xact_if)
//     sn.mem.connect(sn_x);
//
// Each request the adapter serves becomes a fwvip_chi_xact handed to the
// agent's responder sequence; its response fields go back to the adapter.
// Requests that arrive before the agent's driver has attached wait for it.
//
// The adapter's own choices (combined write response, response delay) are
// the kit's chi_completer_policy. A bench that hands this config the
// adapter (`adapter`, re-set on every rebuild) lets a test set them through
// completer_policy().
class fwvip_chi_sn_config extends uvm_object implements chi_xact_if;
    `uvm_object_utils(fwvip_chi_sn_config)

    chi_sn_adapter          adapter;      // optional; for completer_policy()

    protected fwvip_chi_sn_driver m_drv;
    protected int unsigned        m_n_attach;

    function new(string name = "fwvip_chi_sn_config");
        super.new(name);
    endfunction

    static function fwvip_chi_sn_config set(uvm_component ctxt, string inst,
                                            string field = "cfg");
        fwvip_chi_sn_config cfg = new();
        uvm_config_db #(fwvip_chi_sn_config)::set(ctxt, inst, field, cfg);
        return cfg;
    endfunction

    function void attach(fwvip_chi_sn_driver drv);
        m_drv = drv;
        m_n_attach++;
    endfunction

    // The kit adapter's completer policy: per_request = 1 draws a fresh
    // random chi_completer_policy for every request (the kit's default);
    // per_request = 0 uses `p` for every request.
    function void completer_policy(bit per_request, chi_completer_policy p = null);
        if (adapter == null)
            `uvm_fatal("FWVIP_CHI", "fwvip_chi_sn_config::completer_policy: the bench did not set `adapter`")
        adapter.randomize_policy = per_request;
        if (p != null) adapter.pol = p;
    endfunction

    virtual task xact(output chi_xact_rsp_t rsp, input chi_xact_req_t req);
        fwvip_chi_xact t = fwvip_chi_xact::type_id::create("sn_req");
        wait (m_n_attach != 0);
        t.from_req(req);
        t.resp_err = CHI_RESPERR_OK;
        m_drv.service(t);
        rsp = t.to_rsp();
    endtask
endclass
