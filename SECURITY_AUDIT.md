# Security audit — Phase 0 only

This is a design/source review, not a completed exploit or runtime audit.

| Remote | Direction | Validation | Effect |
| --- | --- | --- | --- |
| ClientReady | client → server | server-created allowlist; one string argument; max 64 bytes; exact protocol version; per-player token bucket (3 burst, 0.2/sec) | Sets caller's GardenReady attribute |

All traffic goes through `Comm.lua`. Per-player buckets are removed on leave;
connections and server-created remote are destroyed at shutdown. No client
currency, item, position, or ownership claims are accepted. Handler exceptions
are caught. No RemoteFunctions or yielding request handlers are used.

The readiness attribute is diagnostic only, never authorization. Domain checks
(distance, ownership, ledger, maturity) must be added with gameplay services.
No ban/honeypot or movement heuristics exist yet; a single suspicious remote
must not be described as infallible proof of exploitation. No authority beta
property is assumed or activated by this scaffold.

Outstanding gates: Luau analysis, Studio handshake, spam testing, dependency
installation/lockfile, persistence, transactional trading, and receipt security.
