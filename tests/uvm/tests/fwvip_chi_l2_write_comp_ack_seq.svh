// Writes with ExpCompAck: the RN sends CompAck after its data, and the Home
// never uses DWT for them (the DWT flow has no CompAck).
class fwvip_chi_l2_write_comp_ack_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_write_comp_ack_seq)
    function new(string name = "fwvip_chi_l2_write_comp_ack_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        int unsigned dwt0 = env.m_mon.chk.shape_hits[CHI_FT_WR_DWT];
        sys.home.pol.dwt_pct = 100;
        env.m_log.clear();
        for (int i = 0; i < 16; i++) begin
            chi_addr_t a = rand_addr();
            chi_size_t s = chi_size_t'($urandom_range(6));
            if (i % 2 == 1) begin a = line_of(a); s = 3'd6; end
            write(t, (i % 2 == 1) ? CHI_REQ_WRITE_UNIQUE_FULL : CHI_REQ_WRITE_UNIQUE_PTL,
                  a, s, rand_line(), {$urandom, $urandom}, 1);
            read(t, CHI_REQ_READ_NO_SNP, line_of(a));
        end
        settle();
        check(env.m_log.n_rsp("rn", CHI_RSP_COMP_ACK) == 16, "16 CompAcks");
        check(env.m_mon.chk.shape_hits[CHI_FT_WR_DWT] == dwt0, "no DWT");
    endtask
endclass
