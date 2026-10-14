# Verification

`dfm run tests`: 18 cases × 2 views (`tlm`, `xtor`). All 36 pass.

## The L2 back-to-back bench

The kit's `l2_rn_sn` suite, as UVM sequences on the RN agent. The data
scoreboard checks every read against a byte-level reference. The monitor
agent's flow checker checks every flit on both links, and must be quiescent
at the end. The kit's L2 classes must count no protocol error.

| Case | What |
|---|---|
| `smoke` | full-line writes, then reads of them |
| `l2_partial_writes` | Ptl writes of every size, random BE |
| `l2_read_every_size` | reads of every Size at random offsets |
| `l2_ordered_reads` | Request and Endpoint Order, with and without CompAck |
| `l2_ordered_writes` | every write opcode with each Order |
| `l2_concurrent` | 32 transactions in flight |
| `l2_retry_storm` | half the requests retried |
| `l2_flow_shapes` | every flow shape the Home can produce, classified by the flow checker; RetryAck, PCrdGrant, ReadReceipt and CompAck counted on the monitor's port |
| `l2_dwt_writes` | every write by DWT |
| `l2_write_comp_ack` | writes with ExpCompAck; never DWT |
| `l2_write_data_cancel` | WriteDataCancel in every shape |
| `l2_errors_from_sn` | DERR and NDERR from the SN agent's memory, reads and writes |
| `l2_errors_from_home` | the Home's own NDERR; no DMT, SN untouched |
| `l2_poison` | poison stored and returned per 8-byte chunk |
| `rand_traffic` | `fwvip_chi_rand_seq` on four regions at once, 10 % retries, responder latency 0–8 cycles |
| `mon_teeth` | a CompData no transaction explains, fed to the monitor agent: flagged (R2) and reported |

The kit suite's `fw_mem_if_access` case is not ported: it tests the kit's
L3, which is not the VIP's.

## The L1 bench

`l1_b2b` and `l1_stall`: see {doc}`l1-agent`.

## What testing found

- **A kit bug (fw-ic-chi plan K.13).** `rand_traffic` in `tlm` failed rule
  R8: a request re-sent with AllowRetry = 0 and no P-credit. When one
  PCrdGrant woke several retried requests, the kit's `chi_rn_adapter` let
  each of them take it. The count wrapped, and every later resend went out
  without a credit (B2.10). The kit's own suite never had two retried
  requests waiting at once. The fix assigns each grant to one waiting
  request, deterministically. A new kit case, `retry_concurrent`, fails
  without it.
- **Verilator 5.05x `randomize()`.** Random traffic drawn by `randomize()`
  came out 190 writes to 2 reads. The sequences now draw procedurally
  (`fwvip_chi_xact::draw`).
