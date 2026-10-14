// The item an SN responder sequence sends, over and over: it carries the
// responder itself (UVM does not let a sequence be sent through
// start_item). The driver takes the handler from it and calls it.
class fwvip_chi_sn_item extends uvm_sequence_item implements fwvip_chi_sn_if;
    `uvm_object_utils(fwvip_chi_sn_item)

    fwvip_chi_sn_if handler;

    function new(string name = "fwvip_chi_sn_item");
        super.new(name);
    endfunction

    virtual task access(fwvip_chi_xact t);
        if (handler != null) handler.access(t);
    endtask
endclass
