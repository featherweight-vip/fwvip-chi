// Random traffic: `n_xacts` randomized fwvip_chi_xact items, up to
// `n_parallel` in flight at once, addresses within [base, base + span),
// `read_pct` percent reads. Each item obeys the item's constraints (only what
// the kit's L2 implements, only what a requester may send): drawn by
// fwvip_chi_xact::draw(), or by randomize() with `use_randomize`.
class fwvip_chi_rand_seq extends fwvip_chi_rn_seq_base;
    `uvm_object_utils(fwvip_chi_rand_seq)

    int unsigned n_xacts    = 32;
    int unsigned n_parallel = 4;
    chi_addr_t   base       = '0;
    chi_addr_t   span       = 'h4000;
    int unsigned read_pct   = 50;
    bit          allow_cancel = 0;
    bit          use_randomize = 0;

    function new(string name = "fwvip_chi_rand_seq");
        super.new(name);
    endfunction

    task body();
        int unsigned issued = 0;
        int unsigned running = 0;
        while (issued < n_xacts) begin
            fwvip_chi_xact t = fwvip_chi_xact::type_id::create($sformatf("x%0d", issued));
            chi_addr_t off;
            if (!use_randomize)
                t.draw(read_pct, allow_cancel);
            else if (!t.randomize() with { !allow_cancel -> !cancel; })
                `uvm_fatal("FWVIP_CHI", "fwvip_chi_rand_seq: randomize failed")
            off    = t.addr % span;
            t.addr = base + (t.is_full_write() ? (off & ~chi_addr_t'(63)) : off);
            wait (running < n_parallel);
            running++;
            issued++;
            fork
                automatic fwvip_chi_xact tt = t;
                begin
                    do_xact(tt);
                    running--;
                end
            join_none
        end
        wait (running == 0);
    endtask
endclass
