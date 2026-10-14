// The RN agent's driver: takes items from the sequencer and runs each
// through the config, up to cfg.max_outstanding at once. item_done() is
// called as soon as an item is issued, so a sequence may keep several in
// flight; it waits for one with fwvip_chi_xact::wait_done(). Every
// completed item is also published on `ap`.
class fwvip_chi_rn_driver extends uvm_driver #(fwvip_chi_xact);
    `uvm_component_utils(fwvip_chi_rn_driver)

    fwvip_chi_rn_config                  m_cfg;
    uvm_analysis_port #(fwvip_chi_xact)  ap;
    int unsigned                         n_inflight;
    int unsigned                         n_done;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        fwvip_chi_xact t;
        forever begin
            seq_item_port.get_next_item(t);
            while (n_inflight >= m_cfg.max_outstanding) begin
                int unsigned seen = n_done;
                wait (n_done != seen);
            end
            n_inflight++;
            t.clear_done();
            fork
                automatic fwvip_chi_xact tt = t;
                begin
                    m_cfg.xact(tt);
                    n_inflight--;
                    n_done++;
                    tt.mark_done();
                    ap.write(tt);
                end
            join_none
            seq_item_port.item_done();
        end
    endtask
endclass
