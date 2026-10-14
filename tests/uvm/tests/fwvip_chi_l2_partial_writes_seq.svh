// Partial writes of every size, random byte enables, WriteNoSnpPtl and
// WriteUniquePtl; full-line reads see exactly the enabled bytes changed.
class fwvip_chi_l2_partial_writes_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_partial_writes_seq)
    function new(string name = "fwvip_chi_l2_partial_writes_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        for (int i = 0; i < 32; i++) begin
            chi_addr_t a = rand_addr();
            write(t, (i % 2 == 1) ? CHI_REQ_WRITE_UNIQUE_PTL : CHI_REQ_WRITE_NO_SNP_PTL,
                  a, chi_size_t'($urandom_range(6)), rand_line(), {$urandom, $urandom});
            read(t, CHI_REQ_READ_NO_SNP, line_of(a));
        end
    endtask
endclass
