// What an SN responder implements: complete one request -- fill in the
// response fields of `t` (rsp_data and rsp_poison for a read, resp_err).
// May take time.
interface class fwvip_chi_sn_if;
    pure virtual task access(fwvip_chi_xact t);
endclass
