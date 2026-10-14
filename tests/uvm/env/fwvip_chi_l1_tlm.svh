// The L1 bench's tlm view: each link bound end to end through a TLM tap.
class fwvip_chi_l1_tlm extends fwvip_chi_l1_sys;
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
        tap_rn.icn.connect(icn_rn.chi);
        sn.chi.connect(tap_sn.node);
        tap_sn.icn.connect(icn_sn.chi);
        tap_rn.mon.connect(fan.in);
        tap_sn.mon.connect(fan.in);
    endfunction
endclass
