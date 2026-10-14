// Base for requester sequences: helpers that run one transaction and
// return it completed. Several may run at once from forked threads of one
// sequence (the driver keeps them in flight together).
class fwvip_chi_rn_seq_base extends uvm_sequence #(fwvip_chi_xact);
    `uvm_object_utils(fwvip_chi_rn_seq_base)

    function new(string name = "fwvip_chi_rn_seq_base");
        super.new(name);
    endfunction

    // Issue `t` and wait for it to complete.
    task do_xact(fwvip_chi_xact t);
        start_item(t);
        finish_item(t);
        t.wait_done();
    endtask

    // A read of `size` bytes at `addr`; t.rsp_data holds the line.
    task read(output fwvip_chi_xact t,
              input chi_req_opcode_e op, input chi_addr_t addr, input chi_size_t size = 3'd6,
              input chi_order_e order = CHI_ORDER_NONE, input bit exp_comp_ack = 0);
        t = fwvip_chi_xact::type_id::create("rd");
        t.opcode = op;  t.addr = addr;  t.size = size;
        t.order  = order;  t.exp_comp_ack = exp_comp_ack;
        t.data   = '0;  t.be = '0;  t.poison = '0;  t.cancel = 0;
        do_xact(t);
    endtask

    // A write. `data`, `be` and `poison` are line-positioned; BE is masked
    // to the window (and ignored for a Full write, which writes all of it).
    task write(output fwvip_chi_xact t,
               input chi_req_opcode_e op, input chi_addr_t addr, input chi_size_t size,
               input logic [511:0] data, input logic [63:0] be = '1,
               input bit exp_comp_ack = 0, input bit cancel = 0,
               input logic [7:0] poison = '0, input chi_order_e order = CHI_ORDER_NONE);
        t = fwvip_chi_xact::type_id::create("wr");
        t.opcode = op;  t.addr = addr;  t.size = size;
        t.data   = data;  t.be = be;  t.poison = poison;  t.cancel = cancel;
        t.order  = order;  t.exp_comp_ack = exp_comp_ack;
        do_xact(t);
    endtask
endclass
