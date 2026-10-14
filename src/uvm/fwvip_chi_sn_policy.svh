// The memory responder's own timing: how many cycles it takes to answer a
// request, drawn per request from [lat_min, lat_max]. (The SN adapter's
// choices -- combined write response, response delay -- are the kit's
// chi_completer_policy; see fwvip_chi_sn_config::completer_policy.)
class fwvip_chi_sn_policy extends uvm_object;
    `uvm_object_utils(fwvip_chi_sn_policy)

    int unsigned      lat_min = 0;
    int unsigned      lat_max = 0;
    rand int unsigned latency;

    constraint c_latency { latency inside {[lat_min:lat_max]}; }

    function new(string name = "fwvip_chi_sn_policy");
        super.new(name);
    endfunction

    // This request's latency. Drawn procedurally rather than by randomize(),
    // so the range is honoured exactly on every simulator.
    virtual function int unsigned draw();
        latency = (lat_max > lat_min) ? (lat_min + ($urandom % (lat_max - lat_min + 1))) : lat_min;
        return latency;
    endfunction
endclass
