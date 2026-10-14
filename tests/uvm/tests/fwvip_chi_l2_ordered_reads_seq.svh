// Ordered reads (ReadReceipt), Request and Endpoint Order, with and without
// CompAck. (Order = ReqAccepted is reserved from an RN, Table B2.9.)
class fwvip_chi_l2_ordered_reads_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_ordered_reads_seq)
    function new(string name = "fwvip_chi_l2_ordered_reads_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        for (int i = 0; i < 16; i++)
            read(t, (i % 4 < 2) ? CHI_REQ_READ_NO_SNP : CHI_REQ_READ_ONCE, rand_addr(),
                 chi_size_t'($urandom_range(6)),
                 (i % 3 == 0) ? CHI_ORDER_ENDPOINT : CHI_ORDER_REQ, i % 2 == 1);
    endtask
endclass
