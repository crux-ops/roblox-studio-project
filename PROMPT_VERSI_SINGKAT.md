# ⚡ PROMPT SINGKAT - COPY PASTE CEPAT
### Untuk AI Agent yang sudah paham Roblox (Cursor / Copilot Agent)

```
Kamu adalah Lead Roblox Technical Director expert Luau --!strict, Rojo, ProfileStore, Knit, Server Authority.

BANGUN GAME: "GROW & STEAL: MYSTIC GARDEN TYCOON" - Hybrid Grow a Garden + Steal a Brainrot dengan Day(25m)/Night(5m) cycle.

CORE LOOP: Tanam (idle+offline) -> Panen -> Jual/Fuse Mutant -> Night Steal PVP -> Upgrade Base -> Collect 150+ tanaman -> Trade.

WAJIB IMPLEMENT URUTAN 15 FASE:
F0 Scaffolding (Rojo, Wally, Comm.lua, Config)
F1 DataService (ProfileStore + session lock) + EconomyService (server ledger, JANGAN trust client)
F2 PlotService + PlantService (growth pakai os.time() server, bukan wait)
F3 Shop + Inventory + MonetizationService (ProcessReceipt aman)
F4 WorldService (Day/Night global timer) + StealService (hanya Night, cek jarak+cooldown+shield)
F5 FusionService (random SERVER) + CollectionService (150 tanaman)
F6 QuestService (Daily/Weekly) + Daily Reward streak + Season Pass 50 tier
F7 TradingService (anti dupe, confirmation) + Auction House (MemoryStore)
F8 GuildService + Leaderboard (MemoryStore SortedMap)
F9 ANTI-CHEAT 5 LAYER: Server Authority + RemoteValidator (type/whitelist/rateLimit/distance/ownership) + Server Ledger + Token Bucket + DataStore session lock + Honeypot remote
F10 FTUE Tutorial <60 detik + Mobile support + HUD polish
F11 Monetization Ladder (19-1999 R$) - jangan P2W
F12 Performance (StreamingEnabled, LOD, batch remote, Janitor leak check)
F13 AnalyticsService + Admin Cmdr (give, ban, evidence, announce via MessagingService)
F14 Security test + Publish checklist (thumbnail, SEO desc, max 30 players)

ATURAN KERAS:
- --!strict + type annotation di semua file, DILARANG any
- Semua balancing di Config/ files, DILARANG hardcode
- Semua Remote lewat RemoteValidator middleware (type+whitelist+rateLimit+distance+sanity)
- Economy 100% server ledger, leaderstats hanya display
- DILARANG placeholder/TODO, semua fungsi harus 100% jadi
- Jangan loncat fase, lapor tiap fase selesai

STACK: Luau Strict, Rojo, ProfileStore, Janitor, Signal, Promise, Fusion, Cmdr
ANTI-CHEAT: Workspace.AuthorityMode=Server, Honeypot remote _HoneypotAdminGiveCoins (auto ban jika difire), EvidenceLocker 200 flag/player, auto WARN->KICK->BAN
TARGET: D1 ≥20%, D7 ≥10%, 50+ player/server, monetization D7>15% baru push

MULAI FASE 0 SEKARANG: Buat default.project.json, wally.toml, folder src/shared|server|client, Comm.lua wrapper, PlantConfig 10 sample.
Lapor "✅ Fase 0 selesai" baru lanjut F1.
```

### Tips Pakai Prompt Singkat:
- Cocok untuk AI yang sudah pernah bikin game Roblox
- Jika AI bingung, ganti ke PROMPT_MASTER_ROBLOX_FULL_SYSTEM.md yang lengkap
- Selalu paste di chat BARU, bukan lanjutan chat lama

### Variasi Prompt untuk AI Berbeda:

**Untuk ChatGPT / Claude Chat (bukan Agent):**
> Tambahkan di akhir: "Jawab dengan CODE LENGKAP untuk setiap file, bukan pseudocode. Beri nama file di atas setiap code block."

**Untuk Grok / Gemini:**
> Tambahkan: "Gunakan bahasa Indonesia untuk penjelasan, English untuk code & comment."

**Untuk Copilot di VSCode:**
> Buka folder kosong -> Paste prompt di Copilot Chat Agent Mode -> Pilih "Ask" -> Enter
