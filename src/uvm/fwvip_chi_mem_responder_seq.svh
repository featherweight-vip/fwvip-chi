typedef class fwvip_chi_sn_agent;

// A memory behind the SN: the kit's chi_mem_model (reads return the line;
// writes update the enabled bytes; unwritten bytes read as a fixed function
// of their address; per-chunk poison; RespErr faults per line), answered
// after `policy.draw()` cycles of the agent's clock provider.
//
// Faults for error tests: mem.set_error(addr, CHI_RESPERR_DERR or NDERR).
class fwvip_chi_mem_responder_seq extends fwvip_chi_sn_seq;
    `uvm_object_utils(fwvip_chi_mem_responder_seq)

    chi_mem_model         mem;
    fwvip_chi_sn_policy   policy;
    fwvip_clock_if        clock;          // from the agent, if it has one

    function new(string name = "fwvip_chi_mem_responder_seq");
        super.new(name);
        mem    = new("mem", null);
        policy = fwvip_chi_sn_policy::type_id::create("policy");
    endfunction

    virtual task handle_request(fwvip_chi_xact t);
        chi_xact_rsp_t r;
        int unsigned   lat = policy.draw();
        if (lat != 0) begin
            if (clock == null)
                `uvm_fatal("FWVIP_CHI", "fwvip_chi_mem_responder_seq: latency needs the agent's clock provider")
            clock.tick(lat);
        end
        mem.xact(r, t.to_req());
        t.set_rsp(r);
    endtask

    task body();
        fwvip_chi_sn_agent agent;
        if (clock == null && m_sequencer != null && $cast(agent, m_sequencer.get_parent()))
            clock = agent.m_clock;
        super.body();
    endtask
endclass
