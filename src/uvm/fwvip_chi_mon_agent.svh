// Passive agent (design §10.3): every flit on the links its config is
// subscribed to goes through the kit's transaction-level flow checker
// (chi_flow_check: rules R1-R13 of IHI0050H, against the generated flow
// tables) and out on `ap` as a chi_msg.
//
// A protocol violation is a UVM_ERROR when it is seen. At check_phase the
// checker must be quiescent (R9: no transaction open, no P-credit unused).
// Set `check_enable = 0` to publish without checking. +fwvip_chi_mon_trace
// prints every message (UVM_LOW).
class fwvip_chi_mon_agent extends uvm_component;
    `uvm_component_utils(fwvip_chi_mon_agent)

    fwvip_chi_mon_config          m_cfg;
    uvm_analysis_port #(chi_msg)  ap;
    chi_flow_check                chk;
    bit                           check_enable = 1;
    bit                           check_quiescent_at_end = 1;
    bit                           trace;
    int unsigned                  n_msgs;
    local int unsigned            m_n_reported;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(fwvip_chi_mon_config)::get(this, "", "cfg", m_cfg))
            `uvm_fatal(get_type_name(), "no fwvip_chi_mon_config \"cfg\" in the config DB")
        trace = $test$plusargs("fwvip_chi_mon_trace");
        ap  = new("ap", this);
        // The checker is a plain observer: it needs no place in a fw-hdl tree.
        chk = new("chk", null, m_cfg.link_cfg);
        m_cfg.attach(this);
    endfunction

    function void observe(chi_msg m);
        n_msgs++;
        if (trace) `uvm_info("CHI_MON", m.sprint(), UVM_LOW)
        if (check_enable) begin
            chk.observe(m);
            if (chk.n_errors != m_n_reported) begin
                m_n_reported = chk.n_errors;
                `uvm_error("CHI_FLOW", chk.last_error)
            end
        end
        ap.write(m);
    endfunction

    // Violations the checker has counted (including R9, once checked).
    function int unsigned n_errors();
        return chk.n_errors;
    endfunction

    // Forget every open transaction and every count: after a reset, or
    // after a test that provoked violations on purpose.
    function void clear();
        chk.reset();
        m_n_reported = 0;
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (check_enable && check_quiescent_at_end && chk.check_quiescent() != 0)
            `uvm_error("CHI_FLOW", $sformatf("not quiescent at the end of the test: %s", chk.last_error))
    endfunction
endclass
