# The L1 agent

`fwvip_chi_l1_agent` plays one end of a link at **flit level**. It sends
whatever flits its sequences give it, and publishes every flit its end
receives. Nothing in it knows about transactions. It is for link-level
tests, for negative tests (flits no transaction explains), and for testing
a component one port at a time.

It runs over one of the kit's scripted L1 endpoints. The bench builds the
endpoint in its tree and binds it to the agent's config
(`fwvip_chi_l1_config`):

| `side` | Endpoint | Sends | Receives |
|---|---|---|---|
| `FWVIP_CHI_L1_RN` | `chi_l1_rn_ep` (the RN link's socket) | REQ RSP DAT | RSP DAT SNP |
| `FWVIP_CHI_L1_ICN_RN` | `chi_l1_icn_rn_ep` (its mirror) | RSP DAT SNP | REQ RSP DAT |
| `FWVIP_CHI_L1_SN` | `chi_l1_sn_ep` (the SN link's socket) | RSP DAT | REQ DAT |
| `FWVIP_CHI_L1_ICN_SN` | `chi_l1_icn_sn_ep` (its mirror) | REQ DAT | RSP DAT |

## Sending

The driver has a queue and a sending process for each channel, so a channel
held by its receiver never holds up another (the L1 contract). A send
returns when the other end has accepted the flit (TLM), or once the flit has
been credited and sent (pins). Sent items are published on `sent_ap`.

```systemverilog
fwvip_chi_l1_item it = fwvip_chi_l1_item::of_req(f);    // or of_rsp/of_snp/of_dat
// in an fwvip_chi_l1_seq:
send(it);                     // waits until sent; send(it, 0) only queues it
```

`fwvip_chi_l1_item::draw(ch, link_cfg)` makes a random protocol flit:
random fields and a random opcode other than the link flit, masked to the
link (`chi_link_cfg::mask_*`), so that what arrives is exactly what was
sent. `fwvip_chi_l1_rand_seq` sends `n_per_channel` of these on every
channel its end sends, all channels at once.

## Receiving

The agent has a process for each channel its end receives. Each flit comes
out on `ap`, in arrival order per channel. `cfg.stall(ch, 1)` holds a
channel: the endpoint stops accepting it, and on pins the receiver withholds
its credits. `cfg.stall(ch, 0)` releases it.

## The L1 bench

`tests/uvm` builds a second bench: the four kit endpoints, an L1 agent at
each end of an RN link and an SN link, and a scoreboard for each link
direction. Every flit sent must arrive unchanged and in order per channel.

- `l1_b2b`: all four ends send random flits on every channel at once. Every
  flit arrives as sent, and the monitor publishes every one.
- `l1_stall`: the ICN end holds REQ. The RN's RSP and DAT flits all arrive
  and no REQ does; the RN cannot send all its REQs (in `tlm` the first call
  blocks; on pins, it sends only as many as the receiver has credits).
  Released, the REQs arrive.
