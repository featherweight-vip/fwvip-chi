# Items and sequences

## `fwvip_chi_xact`

One transaction, as the requester sees it. The request fields are the kit's
`chi_xact_req_t`, as `rand` fields: `opcode`, `addr`, `size`, `order`,
`exp_comp_ack`, `qos`, `pas`, `mem_attr`, `snp_attr`, `data`, `be`, `poison`,
`cancel`. The response fields are filled in on completion: `rsp_data`,
`rsp_poison`, `resp`, `resp_err`, `n_retries`.

Data, BE and poison are **line-positioned**, as in the kit: byte *k* of the
64-byte line that holds `addr` is `data[8k +: 8]`. `to_req()` masks BE to
the Size-aligned window, so BE may be left all ones.

The constraints keep an item to what the kit implements and what a
requester may send. Only supported opcodes are allowed, and Order is never
ReqAccepted from an RN (B2.7.5.1). A Full write is a whole aligned line, and
WriteDataCancel is only for a Ptl write. Attributes default (softly) to
Normal, Non-snoopable, Non-secure.

`draw(read_pct, allow_cancel)` makes the same legal item procedurally. Use
it on Verilator 5.05x: its `randomize()` skews these draws, and fails
outright with no SMT solver on PATH.

## Requester sequences

| Class | What |
|---|---|
| `fwvip_chi_rn_seq_base` | helpers: `do_xact(t)` (issue, wait for completion), `read(t, op, addr, size, order, exp_comp_ack)`, `write(t, op, addr, size, data, be, exp_comp_ack, cancel, poison, order)` |
| `fwvip_chi_read_seq` | one read; set or randomize its fields, read `t` afterwards |
| `fwvip_chi_write_seq` | one write |
| `fwvip_chi_rand_seq` | `n_xacts` random transactions, `n_parallel` in flight, addresses in `[base, base + span)`, `read_pct` reads |

The driver calls `item_done()` as soon as an item is issued, and
`do_xact()` waits for `wait_done()`. So one sequence can keep several
transactions in flight by calling the helpers from forked threads:

```systemverilog
class my_seq extends fwvip_chi_rn_seq_base;
    task body();
        fwvip_chi_xact t;
        write(t, CHI_REQ_WRITE_NO_SNP_FULL, 'h1000, 3'd6, '1);
        read(t, CHI_REQ_READ_ONCE, 'h1000, 3'd3, CHI_ORDER_REQ, 1);
        if (t.resp_err != CHI_RESPERR_OK) `uvm_error("SEQ", t.convert2string())
    endtask
endclass
```

## Responders

| Class | What |
|---|---|
| `fwvip_chi_sn_seq` | base responder: override `handle_request(fwvip_chi_xact t)` and fill in `rsp_data`, `rsp_poison`, `resp_err`; `body()` runs forever |
| `fwvip_chi_mem_responder_seq` | a memory: the kit's `chi_mem_model` (`mem`: lines, poison per 8-byte chunk, `set_error(addr, DERR/NDERR)`), answering after `policy.draw()` cycles |
| `fwvip_chi_sn_policy` | the responder's latency, drawn per request from `[lat_min, lat_max]` |

The SN adapter's own choices are the kit's `chi_completer_policy`; see
{doc}`integration`.

## L1

`fwvip_chi_l1_item`, `fwvip_chi_l1_seq` and `fwvip_chi_l1_rand_seq`: see
{doc}`l1-agent`.
