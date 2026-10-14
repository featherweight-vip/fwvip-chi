// Base for L1 sequences: send one flit and wait until it is sent.
class fwvip_chi_l1_seq extends uvm_sequence #(fwvip_chi_l1_item);
    `uvm_object_utils(fwvip_chi_l1_seq)

    function new(string name = "fwvip_chi_l1_seq");
        super.new(name);
    endfunction

    task send(fwvip_chi_l1_item it, bit wait_sent = 1);
        start_item(it);
        finish_item(it);
        if (wait_sent) it.wait_done();
    endtask

    task send_req(chi_req_flit_t f); send(fwvip_chi_l1_item::of_req(f)); endtask
    task send_rsp(chi_rsp_flit_t f); send(fwvip_chi_l1_item::of_rsp(f)); endtask
    task send_snp(chi_snp_flit_t f); send(fwvip_chi_l1_item::of_snp(f)); endtask
    task send_dat(chi_dat_flit_t f); send(fwvip_chi_l1_item::of_dat(f)); endtask
endclass
