// One read. Set the fields (or randomize the sequence) before start();
// `t` holds the completed transaction afterwards.
class fwvip_chi_read_seq extends fwvip_chi_rn_seq_base;
    `uvm_object_utils(fwvip_chi_read_seq)

    rand chi_req_opcode_e opcode;
    rand chi_addr_t       addr;
    rand chi_size_t       size;
    rand chi_order_e      order;
    rand bit              exp_comp_ack;
    fwvip_chi_xact        t;

    constraint c_read  { opcode inside {CHI_REQ_READ_NO_SNP, CHI_REQ_READ_ONCE}; }
    constraint c_size  { size <= 3'd6; }
    constraint c_order { order != CHI_ORDER_REQ_ACCEPTED; }

    function new(string name = "fwvip_chi_read_seq");
        super.new(name);
        opcode = CHI_REQ_READ_NO_SNP;
        size   = 3'd6;
        order  = CHI_ORDER_NONE;
    endfunction

    task body();
        read(t, opcode, addr, size, order, exp_comp_ack);
    endtask
endclass
