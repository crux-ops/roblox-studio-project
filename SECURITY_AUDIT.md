# Security review — garden prototype

Source review and isolated logic tests only; not an independent audit or proof of
production safety. Roblox runtime, network spam and DataStore failure tests pending.

## Remote surface

| Remote | Direction | Validation | Effect |
| --- | --- | --- | --- |
| ClientReady | C→S | one string, length ≤96, exact protocol version, token bucket | readiness attribute only |
| GardenAction | C→S | one string, ≤96, token bucket, exact command arity/grammar, loaded active profile | dispatch below |
| GardenState | S→C only | no server listener; explicit private snapshot fields | view-only player state |
| GardenNotice | S→C only | no server listener | status message |

Bucket per player per request remote: 12 capacity, 4 tokens/sec. Player buckets
removed on leave. Malformed payload types/extra arguments are dropped after token
consumption. A pure production limiter test sends 1000 simultaneous requests;
actual RemoteEvent load tests remain pending.

| Action | Server checks |
| --- | --- |
| Claim / Go | one plot per player; available capacity; server-defined destination; resets movement sample |
| Buy | plant whitelist, seed bag capacity, integer server price, ledger balance |
| Plant | plant whitelist, integer slot 1–8, own claimed plot, distance, seed possession, empty slot |
| Harvest | own plot, distance, valid slot, server timestamp maturity, crop capacity |
| Sell | GUID must exist in caller's crop inventory; server value/trait multiplier; currency cap |
| Fuse | server-selected three identical nonmutant crops, server fusion price, debit before nonyielding mutation |
| Daily | UTC day monotonicity, streak, server reward, currency cap; bounded optional seed grant |
| Quest | server counter, known quest, day reset, claim bit, Coins/Gems caps |
| Season | server XP, tier range/integer, season rollover, claim bit, cap |
| Tutorial | only own preference bit |

No remote accepts reward amount, price, XP, a client timestamp, or a destination.
Mutation handlers do not yield between validation and writes. Bounded ledger is
stored in the same profile as Coins, not in a separate write that could diverge.
Coins leaderstats are display, never authorization.

## Persistence boundaries

ProfileStore upstream provides session locking/autosave/session termination.
Corrupt/unknown-version/nonnumeric/invalid-item/duplicate-crop-ID data is rejected;
there is no reset-to-starter fallback. See DataSchema and vendored dependency pin.
Studio API-disabled ProfileStore may use memory-only data: UI explicitly labels it.
Schema tests do not validate real DataStore availability or upstream failure recovery.

Single-profile session locking is **not** an atomic multi-profile transaction.
Steal, trade, auction and guild vault are not implemented/open. A durable escrow
journal and restart reconciliation must precede them. Robux prompts/catalog are
disabled; no receipt grants or fake product IDs are present.

## Remaining gaps

- No claim that all five anti-cheat layers or server-authority beta are integrated.
- Horizontal movement envelope is a conservative fallback only; clients retain
  character network ownership. Flight/noclip/burst exploits and false positives
  require further work. No irreversible ban is based on this heuristic.
- Evidence is bounded, session-local; not durable moderation evidence.
- No honeypot auto-ban; one unusual request is not infallible proof of cheating.
- Full-state private snapshots need bandwidth profiling/deltas before scale claims.
- Dependency installation, Luau type analysis, Studio runtime, rejoin, multi-session,
  shutdown/outage, mobile and real multiplayer acceptance remain release blockers.
