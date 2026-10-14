// Base SN responder: extend it and override handle_request(). body() runs
// forever, offering the responder to the driver; start it in the
// background (fork ... join_none) on the SN agent's sequencer.
class fwvip_chi_sn_seq extends uvm_sequence #(fwvip_chi_sn_item) implements fwvip_chi_sn_if;
    `uvm_object_utils(fwvip_chi_sn_seq)

    function new(string name = "fwvip_chi_sn_seq");
        super.new(name);
    endfunction

    // Complete one request: fill in t's response fields.
    virtual task handle_request(fwvip_chi_xact t);
        t.resp_err = CHI_RESPERR_OK;
    endtask

    virtual task access(fwvip_chi_xact t);
        handle_request(t);
    endtask

    task body();
        fwvip_chi_sn_item it = fwvip_chi_sn_item::type_id::create("it");
        it.handler = this;
        forever begin
            start_item(it);
            finish_item(it);
        end
    endtask
endclass
