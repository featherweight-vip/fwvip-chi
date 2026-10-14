// Reads of every Size at random offsets: the right packets (DataID) and
// the right bytes inside the window.
class fwvip_chi_l2_read_every_size_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_read_every_size_seq)
    function new(string name = "fwvip_chi_l2_read_every_size_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        for (int s = 0; s <= 6; s++)
            for (int i = 0; i < 6; i++)
                read(t, (i % 2 == 1) ? CHI_REQ_READ_ONCE : CHI_REQ_READ_NO_SNP, rand_addr(), chi_size_t'(s));
    endtask
endclass
