// One direction of one link at L1: every flit the sending agent sent must
// arrive at the receiving agent, unchanged and in order per channel (the
// L1 contract). Connect the sender's sent_ap to `sent_export` and the
// receiver's ap to `recv_export`.
class fwvip_chi_l1_sb extends uvm_component;
    `uvm_component_utils(fwvip_chi_l1_sb)

    uvm_analysis_imp_l1_sent #(fwvip_chi_l1_item, fwvip_chi_l1_sb) sent_export;
    uvm_analysis_imp_l1_recv #(fwvip_chi_l1_item, fwvip_chi_l1_sb) recv_export;

    int unsigned          n_match[4];     // per channel
    int unsigned          n_bad;
    local fwvip_chi_l1_item m_exp[4][$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sent_export = new("sent_export", this);
        recv_export = new("recv_export", this);
    endfunction

    virtual function void write_l1_sent(fwvip_chi_l1_item it);
        m_exp[int'(it.ch)].push_back(it);
    endfunction

    virtual function void write_l1_recv(fwvip_chi_l1_item it);
        int c = int'(it.ch);
        fwvip_chi_l1_item e;
        if (m_exp[c].size() == 0) begin
            n_bad++;
            `uvm_error("L1_SB", $sformatf("received %s, nothing was sent on %s", it.convert2string(), it.ch.name()))
            return;
        end
        e = m_exp[c].pop_front();
        if (!e.same(it)) begin
            n_bad++;
            `uvm_error("L1_SB", $sformatf("%s: sent %s, received %s", it.ch.name(), e.convert2string(), it.convert2string()))
        end else begin
            n_match[c]++;
        end
    endfunction

    function int unsigned n_matched();
        return n_match[0] + n_match[1] + n_match[2] + n_match[3];
    endfunction

    function int unsigned n_pending();
        return m_exp[0].size() + m_exp[1].size() + m_exp[2].size() + m_exp[3].size();
    endfunction

    function void check_phase(uvm_phase phase);
        if (n_pending() != 0)
            `uvm_error("L1_SB", $sformatf("%s: %0d flits sent and never received", get_name(), n_pending()))
    endfunction
endclass
