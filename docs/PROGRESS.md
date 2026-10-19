# Status implementasi

Tidak ada fase yang boleh dianggap lolos acceptance Studio sebelum diuji di Studio.
Permintaan pengguna mencakup seluruh fase, tetapi build saat ini adalah increment
alur kebun, bukan seluruh game. Tidak ada proses pengembangan yang berjalan sendiri
setelah respons agen berakhir.

| Fase | Source saat ini | Kekurangan / gerbang berikutnya |
| --- | --- | --- |
| 0 — scaffold | Ada; diperluas | Rojo serve/Studio, integrasi semua Wally libs, type analysis |
| 1 — data/economy | ProfileStore, schema, ledger, stats, analytics best effort | Rejoin/concurrent session/failure tests; D1 funnel & first-event analytics |
| 2 — plot/plant | 30 petak, 8 slot, growth timestamp, panen | Studio proximity/multiplayer; progress bar & model art |
| 3 — shop/inventory | Beli benih, tas panen, jual | Rotation/stock, receipts, gamepasses belum ada |
| 4 — world/steal | UTC cycle/lighting | PvP **disabled**; durable cross-profile transfer/recovery, shield & notifikasi belum diintegrasikan |
| 5 — fusion/collection | 3→1 deterministic mutant x2, index | 10 bukan 150 tanaman; random traits/milestone pet/skin/animation belum ada |
| 6 — daily/quest/season | UTC streak, 3 counter definitions (steal hidden), 50-tier free claim | Weekly, premium, Studio reset tests |
| 7 — trade/auction | Belum dimulai | Durable transaction journal, recovery worker, escrow, confirmation revision/timeout |
| 8 — guild/leaderboard | leaderstats Coins display saja | Guild persistence/chat/vault/weekly quests/global/friends boards |
| 9 — anti-cheat | String grammar, whitelist/domain checks, token bucket, bounded evidence, horizontal fallback | Flight/noclip, anomaly/behavior analysis, persistence of evidence, enforcement review; no claim five layers complete |
| 10 — UI/onboarding | Touch-sized prototype tabs and instructions | Fusion reactive UI, arrows, sound, settings/localization, mobile/device tests |
| 11 — monetization | Disabled | Creator Dashboard IDs, receipt idempotency, policy review, VIP, starter pack |
| 12 — performance | Streaming, bounded inventories, lifecycle cleanup; view rebuild only on change | Delta snapshots/LOD/batching/profiling/20–50 player tests; currently full private snapshot each second |
| 13 — liveops | Best-effort server AnalyticsService events | Cmdr permissions, moderation, cross-server announcements, dashboards |
| 14 — QA/publish | Automated syntax/logic/XML checks and manual checklist | Studio QA/security/load/persistence/mobile tests; assets and publishing config |

## Prioritas implementasi berikutnya

1. Selesaikan validasi Studio dan type analysis, lalu perbaiki temuan konkret.
2. Tambah journal transaksi lintas profile dengan escrow dan crash recovery
   sebelum membuka steal/trading/auction. Session lock satu profile saja tidak
   membuat perubahan pada dua profile menjadi transaksi atomik.
3. Integrasikan stock/rotation, koleksi lengkap, milestone, weekly/premium flows.
4. Guild/leaderboard dan admin, lalu polish UI/art/audio serta pengujian beban.
5. Masukkan ID produk Roblox asli dan verifikasi receipts/policy sebelum Robux.

Tidak ada angka statistik/retensi dari lampiran yang dipakai sebagai fakta terverifikasi
atau jaminan kesuksesan game. Tidak ada jaminan game menjadi #1 atau memperoleh CCU tertentu.
