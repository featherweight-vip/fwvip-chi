// The back-to-back bench's fw-hdl tree (design §10.2: the bench owns it):
//
//   RN agent -> rn (chi_rn_adapter) <-- RN link --> home (chi_test_home)
//               home <-- SN link --> sn (chi_sn_adapter) -> sn_x -> SN agent
//   every flit on both links -> fan -> monitor agent
//
// The kit's L2 classes do all of CHI; the VIP's agents reach them only
// through API handles: the RN agent's config is bound to rn.xact, the SN
// agent's config is the export behind sn.mem, the monitor agent's config is
// subscribed to the fanout. How the links are bound is the view: taps
// (fwvip_chi_b2b_tlm) or the kit's transactors on pins (hvl_top_xtor binds
// them with the fw_root_bind_* macros).
//
// The tree is built on every reset release, so the VIP configs are static
// slots the HVL top fills before the first build, and every build re-binds
// them.
class fwvip_chi_b2b_sys extends fw_component implements fw_runnable;
    static fwvip_chi_b2b_sys       inst;
    static fwvip_chi_rn_config_ap  vip_rn;
    static fwvip_chi_sn_config     vip_sn;
    static fwvip_chi_mon_config    vip_mon;
    static chi_link_param_t        link_p = FWVIP_CHI_LINK_POISON;

    chi_link_cfg               rn_cfg, sn_cfg;
    chi_rn_adapter             rn;
    chi_test_home              home;
    chi_sn_adapter             sn;
    chi_mon_fanout             fan;
    fw_export #(chi_xact_if)   sn_x;
    bit                        ready;

    function new(string name, fw_component parent);
        super.new(name, parent);
        rn_cfg = chi_link_cfg::from_param(link_p);
        sn_cfg = chi_link_cfg::from_param(link_p);
        inst   = this;
        add_runnable(this);
    endfunction

    function void build();
        if (vip_rn == null || vip_sn == null || vip_mon == null)
            $fatal(1, "fwvip_chi_b2b_sys: the HVL top did not set the VIP configs");
        rn   = new("rn", this, rn_cfg);
        home = new("home", this, rn_cfg);
        sn   = new("sn", this, sn_cfg);
        fan  = new("fan", this);
        sn_x = new("sn_x", this, vip_sn);
    endfunction

    function void connect();
        sn.mem.connect(sn_x);
        fan.subscribe(vip_mon);
        vip_rn.bind_if(rn.xact);
        vip_sn.adapter = sn;
    endfunction

    virtual task run();
        ready = 1;
    endtask

    // Wait for the (current) tree to be built and running.
    static task wait_ready();
        wait (inst != null);
        wait (inst.ready);
    endtask

    // Protocol errors the kit's L2 classes counted.
    function int unsigned n_errors();
        return rn.n_errors + home.n_errors + sn.n_errors;
    endfunction
endclass
