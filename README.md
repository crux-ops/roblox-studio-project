# 🌱 Grow & Steal: Mystic Garden Tycoon

**Game Roblox Full System - Hybrid Viral 2026**
> Siang tanam mutant plants, malam curi dari base orang lain! Koleksi 150+ tanaman meme.

Dibuat dengan Prompt Master AI Agent - Stack Mutakhir 2026: Luau Strict + Rojo + ProfileStore + Server Authority + 5-Layer Anti-Cheat

## 🎯 Formula Viral (Riset 26B+ Visits)

Menggabungkan **Grow a Garden (22.3M CCU)** + **Steal a Brainrot (25.8M CCU - Rekor Dunia)** + Day/Night Cycle (meta 2026 dari Grow a Garden 2).

5 Retention Loop biar tidak bosan: Panen dopamine, Night Steal tiap 30 menit, Collection 150 tanaman, Season Pass 50 tier, Trading & Guild.

## 📂 Struktur Project

```
src/shared/Config/       # Balancing (Plant, Economy, World, AntiCheat)
src/shared/Modules/      # Comm, Signal, Janitor
src/shared/Types/        # PlayerData types
src/server/Services/     # Data, Economy, Plant, Plot, Steal, Trade, dll
src/server/AntiCheat/    # RemoteValidator, EvidenceLocker (5 Layer)
src/client/Controllers/  # UI, Plant, Plot, Steal (hanya visual!)
```

## 🚀 Cara Install (Untuk AI Agent & Developer)

### 1. Install Rojo & Wally
```bash
# Rojo (sync ke Roblox Studio)
foreman install  # atau aftman

# Wally (package manager)
wally install
```

### 2. Jalankan Rojo
```bash
rojo serve
```
Buka Roblox Studio -> Plugin Rojo -> Connect `localhost:34872`

### 3. Aktifkan di Studio
- `Workspace.AuthorityMode = Server` (Studio Beta 2025/2026)
- Enable `PlayerScriptsUseInputActionSystem`
- Aktifkan API: Game Settings -> Security -> Enable Studio Access to API Services (untuk DataStore test)

### 4. Test Anti-Cheat
```lua
-- Di console server, test honeypot (harus auto-ban):
game.ReplicatedStorage.Remotes._HoneypotAdminGiveCoins:FireServer()

-- Spam test (harus kena rate limit):
for i=1,100 do game.ReplicatedStorage.Remotes.HarvestPlant:FireServer("plot1", 1) end
```

## 📖 Dokumentasi

- `PROMPT_MASTER_ROBLOX_FULL_SYSTEM.md` - **PROMPT LENGKAP** untuk AI Agent (15 Fase, GDD, Tech Stack, Anti-Cheat 5 Layer)
- `PROMPT_VERSI_SINGKAT.md` - Prompt singkat copy-paste cepat
- `ANTI_CHEAT_CHEATSHEET.md` - Panduan implementasi anti-cheat lengkap dengan code template

## 🛡️ Anti-Cheat 5 Layer

1. **Server Authority** - Auto block speed/fly/teleport (Roblox engine)
2. **Remote Validation** - Type, whitelist, rate limit tiap RemoteEvent
3. **Server Ledger** - Economy 100% server-side, honeypot trap
4. **Behavioral Heuristics** - Income/harvest anomaly detection
5. **DataStore Security** - ProfileStore session lock, anti-dupe trade

## 💰 Monetization Ladder

Entry 19-49 R$ -> Standard 99-299 R$ -> Premium 499-799 R$ -> Elite 1299-1999 R$
Target: D1 20%+, D7 10%+, ARPPU $0.50+, tidak P2W

## 📊 Target KPI

- CCU: 20K+ (awal), scale ke 100K+
- D1 Retention: 30%+
- Session: 7-15 menit, return 4-6x/hari
- Monetization: Mulai push di D7 >15%

## 🤖 Cara Pakai Prompt

1. Copy isi `PROMPT_MASTER_ROBLOX_FULL_SYSTEM.md` dari `## ROLE` sampai akhir
2. Paste ke Cursor AI / Claude Code / Windsurf Agent sebagai prompt pertama
3. Agent akan kerjakan Fase 0-14 berurutan
4. Jangan suruh loncat fase!

---
*Built for Roblox Algorithm 2026 (28-Day Retention) | Tech: Luau Strict + Rojo + ProfileStore + Knit + Fusion*
