// Random flits: `n_per_channel` on every channel the agent's end sends,
// all channels at once (fwvip_chi_l1_item::draw: random fields and opcode,
// masked to the link). Run on an fwvip_chi_l1_agent's sequencer.
class fwvip_chi_l1_rand_seq extends fwvip_chi_l1_seq;
    `uvm_object_utils(fwvip_chi_l1_rand_seq)

    int unsigned        n_per_channel = 16;
    fwvip_chi_l1_config cfg;            // the agent's; found from the sequencer if null

    function new(string name = "fwvip_chi_l1_rand_seq");
        super.new(name);
    endfunction

    task body();
        chi_channel_e chs[4] = '{CHI_CH_REQ, CHI_CH_RSP, CHI_CH_SNP, CHI_CH_DAT};
        int unsigned  n_done = 0, n_ch = 0;
        if (cfg == null) begin
            fwvip_chi_l1_agent agent;
            if (m_sequencer == null || !$cast(agent, m_sequencer.get_parent()))
                `uvm_fatal(get_type_name(), "not on an fwvip_chi_l1_agent's sequencer, and no cfg")
            cfg = agent.m_cfg;
        end
        foreach (chs[i]) if (cfg.sends(chs[i])) begin
            n_ch++;
            fork
                automatic chi_channel_e ch = chs[i];
                begin
                    for (int k = 0; k < n_per_channel; k++) begin
                        fwvip_chi_l1_item it = fwvip_chi_l1_item::type_id::create("flit");
                        it.draw(ch, cfg.link_cfg);
                        send(it, 0);
                    end
                    n_done++;
                end
            join_none
        end
        wait (n_done == n_ch);
    endtask
endclass
