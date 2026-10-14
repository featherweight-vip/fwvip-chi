// The tlm view: both links bound directly, socket to mirror, through the
// kit's TLM taps, which publish every flit to the fanout.
class fwvip_chi_b2b_tlm extends fwvip_chi_b2b_sys;
    chi_rn_link_tap tap_rn;
    chi_sn_link_tap tap_sn;

    function new(string name, fw_component parent);
        super.new(name, parent);
    endfunction

    function void build();
        super.build();
        tap_rn = new("tap_rn", this, "rn");
        tap_sn = new("tap_sn", this, "sn");
    endfunction

    function void connect();
        super.connect();
        rn.chi.connect(tap_rn.node);
        tap_rn.icn.connect(home.rn);
        sn.chi.connect(tap_sn.node);
        tap_sn.icn.connect(home.sn);
        tap_rn.mon.connect(fan.in);
        tap_sn.mon.connect(fan.in);
    endfunction
endclass
