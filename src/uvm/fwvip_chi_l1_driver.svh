// The L1 agent's driver: one queue and one sending process per channel, so
// a channel held by its receiver never holds up another (the L1 contract:
// channels are independent). item_done() is called when an item is queued;
// a sequence waits for it to be sent with fwvip_chi_l1_item::wait_done().
// Every sent item is published on `sent_ap`.
class fwvip_chi_l1_driver extends uvm_driver #(fwvip_chi_l1_item);
    `uvm_component_utils(fwvip_chi_l1_driver)

    fwvip_chi_l1_config                     m_cfg;
    uvm_analysis_port #(fwvip_chi_l1_item)  sent_ap;
    int unsigned                            n_sent;
    int unsigned                            n_sent_ch[4];   // per channel
    local fwvip_chi_l1_item                 m_q[4][$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sent_ap = new("sent_ap", this);
    endfunction

    local task drain(int c);
        forever begin
            fwvip_chi_l1_item it;
            wait (m_q[c].size() != 0);
            it = m_q[c].pop_front();
            m_cfg.send(it);
            n_sent++;
            n_sent_ch[c]++;
            it.mark_done();
            sent_ap.write(it);
        end
    endtask

    task run_phase(uvm_phase phase);
        for (int c = 0; c < 4; c++) fork
            automatic int k = c;
            drain(k);
        join_none
        forever begin
            fwvip_chi_l1_item it;
            int c;
            seq_item_port.get_next_item(it);
            c = int'(it.ch);
            it.clear_done();
            m_q[c].push_back(it);
            seq_item_port.item_done();
        end
    endtask
endclass
