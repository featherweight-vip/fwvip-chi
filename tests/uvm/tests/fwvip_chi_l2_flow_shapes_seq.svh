// Every flow shape the Home can produce (the goal in the kit's generated
// tables) is seen and classified by the monitor agent's flow checker, and
// the messages that are not part of a shape -- RetryAck with its
// PCrdGrant, ReadReceipt, CompAck -- show up on the monitor's analysis port.
class fwvip_chi_l2_flow_shapes_seq extends fwvip_chi_b2b_seq_base;
    `uvm_object_utils(fwvip_chi_l2_flow_shapes_seq)
    function new(string name = "fwvip_chi_l2_flow_shapes_seq"); super.new(name); endfunction

    task body();
        fwvip_chi_xact t;
        string missing[$], unexpected[$];
        int unsigned n_retry, n_pcrd, n_rr, n_ack;
        sys.home.pol.retry_pct = 25;
        env.m_log.clear();
        for (int i = 0; i < 64; i++) begin
            chi_addr_t a = rand_addr();
            case (i % 4)
                0: write(t, CHI_REQ_WRITE_NO_SNP_FULL, line_of(a), 3'd6, rand_line());
                1: read(t, CHI_REQ_READ_NO_SNP, a);
                2: read(t, CHI_REQ_READ_ONCE, a, 3'd6, CHI_ORDER_REQ, 1);
                3: write(t, CHI_REQ_WRITE_UNIQUE_PTL, a, chi_size_t'($urandom_range(6)), rand_line(),
                         {$urandom, $urandom}, i % 8 == 3);
            endcase
        end
        settle();
        n_retry = env.m_log.n_rsp("rn", CHI_RSP_RETRY_ACK);
        n_pcrd  = env.m_log.n_rsp("rn", CHI_RSP_PCRD_GRANT);
        n_rr    = env.m_log.n_rsp("rn", CHI_RSP_READ_RECEIPT);
        n_ack   = env.m_log.n_rsp("rn", CHI_RSP_COMP_ACK);
        env.m_mon.chk.shapes_missing(missing);
        env.m_mon.chk.shapes_unexpected(unexpected);
        `uvm_info(get_type_name(), $sformatf("retried=%0d retry=%0d pcrd=%0d receipt=%0d compack=%0d",
                  env.m_mon.chk.n_retried, n_retry, n_pcrd, n_rr, n_ack), UVM_LOW)
        foreach (missing[k])    `uvm_error(get_type_name(), {"shape never seen: ", missing[k]})
        foreach (unexpected[k]) `uvm_error(get_type_name(), {"shape seen but not a goal: ", unexpected[k]})
        check(n_retry > 0 && n_pcrd == n_retry, "RetryAcks, each with its PCrdGrant");
        check(env.m_mon.chk.n_retried > 0, "the checker classified retried transactions");
        check(n_rr > 0, "ReadReceipts");
        check(n_ack > 0, "CompAcks");
    endtask
endclass
