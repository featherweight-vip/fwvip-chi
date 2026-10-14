// The L1 bench's fw-hdl tree: the kit's four scripted L1 endpoints, one at
// each end of an RN link and an SN link, and a fanout for the links'
// monitors. Each endpoint is bound to an fwvip_chi_l1_agent's config (the
// static slots, filled by the HVL top). The view binds the links: TLM taps
// (fwvip_chi_l1_tlm) or the kit's transactors on pins (HVL top).
class fwvip_chi_l1_sys extends fw_component implements fw_runnable;
    static fwvip_chi_l1_sys        inst;
    static fwvip_chi_l1_config     vip_rn, vip_icn_rn, vip_sn, vip_icn_sn;
    static fwvip_chi_mon_config    vip_mon;
    static chi_link_param_t        link_p = FWVIP_CHI_LINK_POISON;

    chi_l1_rn_ep       rn;
    chi_l1_icn_rn_ep   icn_rn;
    chi_l1_sn_ep       sn;
    chi_l1_icn_sn_ep   icn_sn;
    chi_mon_fanout     fan;
    bit                ready;

    function new(string name, fw_component parent);
        super.new(name, parent);
        inst = this;
        add_runnable(this);
    endfunction

    function void build();
        rn     = new("rn", this);
        icn_rn = new("icn_rn", this);
        sn     = new("sn", this);
        icn_sn = new("icn_sn", this);
        fan    = new("fan", this);
    endfunction

    function void connect();
        vip_rn.bind_rn(rn);
        vip_icn_rn.bind_icn_rn(icn_rn);
        vip_sn.bind_sn(sn);
        vip_icn_sn.bind_icn_sn(icn_sn);
        fan.subscribe(vip_mon);
    endfunction

    virtual task run();
        ready = 1;
    endtask

    static task wait_ready();
        wait (inst != null);
        wait (inst.ready);
    endtask
endclass
