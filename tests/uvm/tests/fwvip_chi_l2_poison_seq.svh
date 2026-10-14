// Poison (B9.2.1) is stored with the data and returned with it, per 8-byte
// chunk; a write of a whole chunk cleans it.
class fwvip_chi_l2_poison_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_poison_seq)
    function new(string name = "fwvip_chi_l2_poison_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        for (int i = 0; i < 8; i++) begin
            chi_addr_t  a  = line_of(rand_addr()) + 52'h8000;
            logic [7:0] pz = 8'($urandom) | 8'h01;
            write(t, CHI_REQ_WRITE_NO_SNP_FULL, a, 3'd6, rand_line(), '1, 0, 0, pz);
            read(t, CHI_REQ_READ_NO_SNP, a);
            check(t.rsp_poison == pz, "poison returned with the data");
            write(t, CHI_REQ_WRITE_NO_SNP_PTL, a, 3'd3, rand_line());      // cleans chunk 0
            read(t, CHI_REQ_READ_ONCE, a);
            check(t.rsp_poison == (pz & 8'hfe), "a whole-chunk write cleans its poison");
        end
    endtask
endclass
