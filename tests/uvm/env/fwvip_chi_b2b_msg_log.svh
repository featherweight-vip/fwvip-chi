// Every chi_msg the monitor agent publishes, kept for tests that count
// messages (RetryAck, PCrdGrant, ReadReceipt, CompAck, WriteDataCancel).
class fwvip_chi_b2b_msg_log extends uvm_subscriber #(chi_msg);
    `uvm_component_utils(fwvip_chi_b2b_msg_log)

    chi_msg msgs[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void write(chi_msg t);
        msgs.push_back(t);
    endfunction

    function void clear(); msgs.delete(); endfunction

    function int unsigned n_rsp(string link, chi_rsp_opcode_e op);
        int unsigned n = 0;
        foreach (msgs[i])
            if (msgs[i].link == link && msgs[i].ch == CHI_CH_RSP && msgs[i].rsp.opcode == op) n++;
        return n;
    endfunction

    function int unsigned n_dat(chi_dat_opcode_e op);
        int unsigned n = 0;
        foreach (msgs[i])
            if (msgs[i].ch == CHI_CH_DAT && msgs[i].dat.opcode == op) n++;
        return n;
    endfunction
endclass
