// Channel independence (B13.4.1): the ICN end of the RN link holds its REQ
// channel; the RN's RSP and DAT flits still all arrive while not one REQ
// does, and the RN cannot send them all (tlm: the first call blocks; pins:
// no more than the receiver's credits). Released, the REQs arrive too.
class fwvip_chi_l1_stall_test extends fwvip_chi_l1_test;
    `uvm_component_utils(fwvip_chi_l1_stall_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_case();
        fwvip_chi_l1_rand_seq s = mk_seq("rand_rn");
        fwvip_chi_l1_sb       sb = m_env.m_sb_rn_up;
        bit                   done = 0;
        fwvip_chi_l1_driver   drv = m_env.m_rn.m_driver;
        int unsigned          waited = 0;
        m_env.m_icn_rn.m_cfg.stall(CHI_CH_REQ, 1);
        fork
            begin s.start(m_env.m_rn.m_seqr); done = 1; end
        join_none
        while ((sb.n_match[CHI_CH_RSP] != n_per_channel || sb.n_match[CHI_CH_DAT] != n_per_channel)
               && waited < 10000) begin
            m_env.m_clock.tick(10);
            waited += 10;
        end
        if (sb.n_match[CHI_CH_RSP] != n_per_channel || sb.n_match[CHI_CH_DAT] != n_per_channel)
            `uvm_error(get_type_name(), "RSP and DAT did not all arrive while REQ was held")
        if (sb.n_match[CHI_CH_REQ] != 0)
            `uvm_error(get_type_name(), $sformatf("%0d REQ flits arrived while REQ was held", sb.n_match[CHI_CH_REQ]))
        if (drv.n_sent_ch[CHI_CH_REQ] >= n_per_channel)
            `uvm_error(get_type_name(), "the RN sent every REQ while its REQ channel was held")
        `uvm_info(get_type_name(), $sformatf("held: %0d of %0d REQs sent, none received; RSP and DAT all received",
                  drv.n_sent_ch[CHI_CH_REQ], n_per_channel), UVM_LOW)
        m_env.m_icn_rn.m_cfg.stall(CHI_CH_REQ, 0);
        wait (done);
        wait (sb.n_match[CHI_CH_REQ] == n_per_channel);
    endtask
endclass
