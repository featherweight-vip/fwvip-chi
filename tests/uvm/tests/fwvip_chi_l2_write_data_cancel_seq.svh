// WriteDataCancel (B13.10): a cancelled partial write completes and changes
// nothing, whichever shape the Home picks (DWT included: the cancel then
// goes from the RN straight to the SN).
class fwvip_chi_l2_write_data_cancel_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_write_data_cancel_seq)
    function new(string name = "fwvip_chi_l2_write_data_cancel_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        env.m_log.clear();
        for (int i = 0; i < 24; i++) begin
            chi_addr_t a = rand_addr();
            write(t, (i % 2 == 1) ? CHI_REQ_WRITE_NO_SNP_PTL : CHI_REQ_WRITE_UNIQUE_PTL,
                  a, chi_size_t'($urandom_range(6)), rand_line(), '1, 0, 1);
            check(t.resp_err == CHI_RESPERR_OK, "a cancelled write completes OK");
            read(t, CHI_REQ_READ_NO_SNP, line_of(a));
        end
        settle();
        check(env.m_log.n_dat(CHI_DAT_WRITE_DATA_CANCEL) >= 24, "WriteDataCancel on the links");
    endtask
endclass
