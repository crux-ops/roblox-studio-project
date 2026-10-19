# Manual acceptance — not yet executed

## First five minutes

Open exported place → Play → Claim → Buy sprout → plant slot 1 → wait 10s →
harvest → sell. Expect 100 → 90 → 105 Coins. Panen itself awards crop, not Coins.
Buy 3 sprouts, harvest them and fuse when balance covers 100 Coins. Expect exactly
three normals removed and one mutant added. Mutant sale should pay 30 Coins.

## Persistence (dedicated test experience only)

- Enable Studio API access only for a published test experience. Verify DATA UJI
  warning disappears. Record Coins/seeds/crops/slots, stop, restart and compare.
- Plant, stop for >10 seconds, restart: harvest should succeed without ticking offline.
- Attempt concurrent sessions from two servers. Only one may mutate the profile.
- Simulate API outage/load failure: no new template may overwrite existing save.
- Edit a test profile to malformed/unknown version: join must be rejected, no reset.
- Verify LastSeen updates on release and save survives server shutdown.
- Test session loss while player is connected: player is removed, no further rewards.

## Security and idempotency

- Early harvest, repeated harvest, foreign ownership, invalid seed/slot/GUID,
  negative/noninteger slots, arbitrary command, payload table/NaN, oversized string,
  additional arguments: no mutation/reward and no server crash.
- 1000 calls at same timestamp unit-test the production token bucket: only initial
  capacity is admitted; actual Roblox network spam is still a Studio test.
- Daily, quest and season double-click: single reward. Rejoin does not reset claims.
- Test UTC day boundaries, missed streak day and 30-day season boundary.
- Inventory full/currency cap: no charged purchase/lost item; verify daily rare seed
  behavior (coin reward still granted; extra seed skipped if seed bag is full).
- Far plant/harvest denied. Legitimate Go and respawn should not be rolled back.
- Movement fallback false positives: jump/fall/lag, then rapid horizontal teleport.
  This fallback does not prove protection against every movement exploit.
- Server → client remotes fired by client have no server reward handlers.
- Disabled features have no dispatch entries or purchase prompts.

## Multiplayer, mobile and scale

- Studio Start Server with 2 players: separate plots, private snapshots, inventories.
- Leave/rejoin releases plot; persisted growing plants re-render at new claimed plot.
- Leave during load/shutdown: no ghost profile/session or connections.
- Device emulator small/large screens; scrolling tabs, large button taps, camera,
  open/close UI, default Roblox controls unobstructed.
- Play through 25/5 minute boundary in a dedicated server; confirm UTC sync.
- Studio 20 dummy clients is not a valid substitute for live replication/load metrics;
  profile CPU, memory, outbound bandwidth, data budget and rendering on real devices.
- No release until runtime errors and all data safety gates are resolved.
