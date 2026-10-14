// One write. Set the fields (or randomize the sequence) before start();
// `t` holds the completed transaction afterwards.
class fwvip_chi_write_seq extends fwvip_chi_rn_seq_base;
    `uvm_object_utils(fwvip_chi_write_seq)

    rand chi_req_opcode_e opcode;
    rand chi_addr_t       addr;
    rand chi_size_t       size;
    rand bit [511:0]      data;
    rand bit [63:0]       be;
    rand bit [7:0]        poison;
    rand bit              cancel;
    rand chi_order_e      order;
    rand bit              exp_comp_ack;
    fwvip_chi_xact        t;

    constraint c_write {
        opcode inside {CHI_REQ_WRITE_NO_SNP_FULL, CHI_REQ_WRITE_NO_SNP_PTL,
                       CHI_REQ_WRITE_UNIQUE_FULL, CHI_REQ_WRITE_UNIQUE_PTL};
    }
    constraint c_size   { size <= 3'd6; }
    constraint c_full   {
        (opcode inside {CHI_REQ_WRITE_NO_SNP_FULL, CHI_REQ_WRITE_UNIQUE_FULL}) ->
            (size == 3'd6 && addr[5:0] == 6'd0);
    }
    constraint c_cancel { cancel -> (opcode inside {CHI_REQ_WRITE_NO_SNP_PTL, CHI_REQ_WRITE_UNIQUE_PTL}); }
    constraint c_order  { order != CHI_ORDER_REQ_ACCEPTED; }
    constraint c_plain  { soft poison == 8'h00; soft cancel == 1'b0; }

    function new(string name = "fwvip_chi_write_seq");
        super.new(name);
        opcode = CHI_REQ_WRITE_NO_SNP_FULL;
        size   = 3'd6;
        be     = '1;
        order  = CHI_ORDER_NONE;
    endfunction

    task body();
        write(t, opcode, addr, size, data, be, exp_comp_ack, cancel, poison, order);
    endtask
endclass
