# 🛡️ ANTI-CHEAT MUTAKHIR - CHEAT SHEET LENGKAP
### Grow & Steal: Mystic Garden Tycoon - Security Implementation Guide

---

## 1. ARSITEKTUR KEAMANAN 5 LAYER

```
[ CLIENT (Tukang Gambar) ] --RemoteEvent--> [ LAYER 2: RemoteValidator ] --LULUS--> [ LAYER 3: Sanity Check ] --LULUS--> [ LAYER 4: RateLimit ] --LULUS--> [ GAME LOGIC ]
         |                                                                               |
         |                                                                             GAGAL
         |                                                                               v
         |                                                                    [ LAYER 5: EvidenceLocker + Auto Punish ]
         v
[ LAYER 1: Server Authority (Engine Level - Auto Block Speed/Fly/Teleport) ]
```

---

## 2. LAYER 1 - SERVER AUTHORITY (Roblox Official 2025/2026)

### Cara Aktifkan:
```lua
-- Di Roblox Studio:
-- Workspace Properties -> AuthorityMode -> Server
-- Atau via script:
Workspace.AuthorityMode = Enum.AuthorityMode.Server
Workspace.PlayerScriptsUseInputActionSystem = true -- untuk input prediction
```

### Yang Otomatis Diblok:
- ✅ Speed Hack (WalkSpeed > 16)
- ✅ Fly / Hover
- ✅ Teleport (jarak tidak masuk akal)
- ✅ Noclip (tembus tembok)
- ✅ JumpPower tamper

### Catatan:
> Server Authority HANYA untuk movement/physics. Economy, inventory, combat TETAP butuh validasi manual Layer 2-5!

---

## 3. LAYER 2 - REMOTE VALIDATOR (Middleware Wajib)

### Template Middleware:
```lua
--!strict
-- src/server/AntiCheat/RemoteValidator.lua

local RemoteValidator = {}
local RateLimiter = require(script.Parent.RateLimiter)
local EvidenceLocker = require(script.Parent.EvidenceLocker)
local PlantConfig = require(game.ReplicatedStorage.Shared.Config.PlantConfig)

local RATE_LIMITS = {
    HarvestPlant = { maxTokens = 5, refillPerSec = 5 },
    BuySeed = { maxTokens = 8, refillPerSec = 2 },
    PlantSeed = { maxTokens = 10, refillPerSec = 3 },
    StealAttempt = { maxTokens = 3, refillPerSec = 0.05 }, -- 3 per menit MAX
    FusePlants = { maxTokens = 5, refillPerSec = 0.5 },
    TradeRequest = { maxTokens = 5, refillPerSec = 0.2 },
}

local VALID_REMOTES = {
    HarvestPlant = true,
    BuySeed = true,
    PlantSeed = true,
    StealAttempt = true,
    -- HONEYPOT - JANGAN DAFTARKAN DI CLIENT, HANYA SERVER!
    -- Jika ada yang fire ini = 100% exploiter
    _HoneypotAdminGiveCoins = "HONEYPOT", 
}

function RemoteValidator.Validate(player: Player, remoteName: string, ...: any): (boolean, string?)
    -- 1. HONEYPOT CHECK (paling atas - instant ban)
    if VALID_REMOTES[remoteName] == "HONEYPOT" then
        EvidenceLocker:Flag(player, "HONEYPOT_TRIGGERED", `Fired honeypot remote: {remoteName}`, 100)
        EvidenceLocker:Ban(player, "Exploit detected [HONEYPOT]")
        return false, "HONEYPOT"
    end

    -- 2. WHITELIST
    if not VALID_REMOTES[remoteName] then
        EvidenceLocker:Flag(player, "INVALID_REMOTE", `Unknown remote: {remoteName}`, 10)
        return false, "Unknown remote"
    end

    -- 3. RATE LIMIT
    local canProceed, reason = RateLimiter:Consume(player, remoteName, RATE_LIMITS[remoteName])
    if not canProceed then
        EvidenceLocker:Flag(player, "RATE_LIMIT", `{remoteName}: {reason}`, 5)
        return false, reason
    end

    -- 4. TYPE VALIDATION (contoh untuk HarvestPlant)
    if remoteName == "HarvestPlant" then
        local plotId, slotIndex = ...
        if type(plotId) ~= "string" or type(slotIndex) ~= "number" then
            EvidenceLocker:Flag(player, "TYPE_MISMATCH", `HarvestPlant bad types`, 10)
            return false, "Bad types"
        end
        if slotIndex ~= math.floor(slotIndex) or slotIndex < 1 or slotIndex > 20 then
            EvidenceLocker:Flag(player, "INVALID_SLOT", `Slot out of range: {slotIndex}`, 10)
            return false, "Invalid slot"
        end
        -- Whitelist plotId
        -- Distance check akan dilakukan di Service (butuh posisi karakter)
    end

    return true, nil
end

return RemoteValidator
```

### Cara Pakai di Setiap Service:
```lua
-- Di PlantService.lua
local RemoteValidator = require(Server.AntiCheat.RemoteValidator)

Remotes.HarvestPlant.OnServerEvent:Connect(function(player, plotId, slotIndex)
    -- VALIDASI DULU SEBELUM LOGIC!
    local ok, err = RemoteValidator.Validate(player, "HarvestPlant", plotId, slotIndex)
    if not ok then
        warn(`[AC] Rejected {player.Name} HarvestPlant: {err}`)
        return
    end
    -- Baru jalankan logic...
    PlantService:HarvestPlant(player, plotId, slotIndex)
end)
```

---

## 4. LAYER 3 - SANITY CHECKS (Server Ledger)

### Economy - JANGAN PERCAYA CLIENT:
```lua
--!strict
-- src/server/Services/EconomyService.lua

local EconomyService = {}
local playerLedgers: { [Player]: { Coins: number, Gems: number } } = {}

function EconomyService.GetCoins(player: Player): number
    local ledger = playerLedgers[player]
    return ledger and ledger.Coins or 0
end

-- HANYA SERVER YANG BISA PANGGIL INI!
function EconomyService.SpendCoins(player: Player, amount: number, reason: string): boolean
    assert(amount > 0, "Spend amount must be positive")
    assert(typeof(player) == "Instance" and player:IsA("Player"), "Invalid player")
    
    local ledger = playerLedgers[player]
    if not ledger then return false end
    
    -- SANITY: Cek uang cukup di LEDGER SERVER (bukan leaderstats!)
    if ledger.Coins < amount then
        EvidenceLocker:Flag(player, "INSUFFICIENT_FUNDS", `Tried to spend {amount} but has {ledger.Coins}`, 5)
        return false
    end
    
    -- SANITY: Jumlah wajar?
    if amount > 1000000 then
        EvidenceLocker:Flag(player, "SUSPICIOUS_SPEND", `Huge spend: {amount}`, 15)
    end
    
    ledger.Coins -= amount
    -- Mirror ke leaderstats HANYA untuk display
    player.leaderstats.Coins.Value = ledger.Coins
    -- Log untuk audit
    print(`[ECONOMY] {player.Name} spent {amount} for {reason}. Balance: {ledger.Coins}`)
    return true
end

function EconomyService.AddCoins(player: Player, amount: number, source: string): ()
    -- VALIDASI SOURCE: Hanya source yang valid yang bisa kasih uang
    local VALID_SOURCES = { Harvest = true, Quest = true, DailyReward = true, Trade = true, Purchase = true }
    if not VALID_SOURCES[source] then
        EvidenceLocker:Flag(player, "INVALID_SOURCE", `AddCoins invalid source: {source}`, 20)
        return
    end
    -- Jika ada yang coba AddCoins dari client via Remote -> HARUS DITOLAK
    -- Client TIDAK PERNAH boleh request AddCoins!
    
    local ledger = playerLedgers[player]
    if ledger then
        ledger.Coins += amount
        player.leaderstats.Coins.Value = ledger.Coins
    end
end

return EconomyService
```

### Plant Harvest Sanity:
```lua
function PlantService.HarvestPlant(player: Player, plotId: string, slotIndex: number)
    local plot = PlotService.GetPlot(plotId)
    -- Ownership check
    if plot.OwnerId ~= player.UserId then
        EvidenceLocker:Flag(player, "PLOT_NOT_OWNED", `Tried to harvest unowned plot {plotId}`, 15)
        return
    end
    local plant = plot.Slots[slotIndex]
    if not plant then return end
    
    -- MATURITY CHECK - Pakai SERVER TIME!
    local now = os.time()
    local growthTime = PlantConfig[plant.SeedId].GrowthTime -- dari Config
    if now < plant.PlantedAt + growthTime then
        local remaining = (plant.PlantedAt + growthTime) - now
        EvidenceLocker:Flag(player, "EARLY_HARVEST", `Harvest {remaining}s too early`, 10)
        return
    end
    
    -- Distance check
    local char = player.Character
    if char and char.PrimaryPart then
        local dist = (char.PrimaryPart.Position - plot.Model:GetPivot().Position).Magnitude
        if dist > 50 then -- MAX_HARVEST_DISTANCE
            EvidenceLocker:Flag(player, "FAR_HARVEST", `Harvest from {dist} studs away`, 10)
            return
        end
    end
    
    -- SUKSES - Beri reward via EconomyService (server-side!)
    local income = PlantConfig[plant.SeedId].Income
    EconomyService.AddCoins(player, income, "Harvest")
    plot.Slots[slotIndex] = nil
    -- Replicate ke client
    Remotes.PlantHarvested:FireAllClients(plotId, slotIndex)
end
```

---

## 5. LAYER 4 - RATE LIMITING & BEHAVIORAL

### Token Bucket:
```lua
--!strict
-- src/server/AntiCheat/RateLimiter.lua

local RateLimiter = {}
local buckets: { [Player]: { [string]: { tokens: number, lastRefill: number } } } = {}

function RateLimiter.Consume(player: Player, remoteName: string, config: { maxTokens: number, refillPerSec: number }): (boolean, string?)
    local now = os.clock()
    if not buckets[player] then buckets[player] = {} end
    if not buckets[player][remoteName] then
        buckets[player][remoteName] = { tokens = config.maxTokens, lastRefill = now }
    end
    local bucket = buckets[player][remoteName]
    
    -- Refill
    local elapsed = now - bucket.lastRefill
    bucket.tokens = math.min(config.maxTokens, bucket.tokens + elapsed * config.refillPerSec)
    bucket.lastRefill = now
    
    if bucket.tokens < 1 then
        return false, `Rate limited: {remoteName}`
    end
    bucket.tokens -= 1
    return true, nil
end

game.Players.PlayerRemoving:Connect(function(player)
    buckets[player] = nil -- Cleanup
end)

return RateLimiter
```

### Behavioral Analyzer (Loop tiap 5 detik):
```lua
-- src/server/AntiCheat/BehaviorAnalyzer.lua

local BehaviorAnalyzer = {}
local playerStats: { [Player]: { harvestCount: number, incomePerMin: number, lastPos: Vector3 } } = {}

-- Jalankan tiap 5 detik
task.spawn(function()
    while true do
        task.wait(5)
        for player, stats in playerStats do
            -- Cek income tidak wajar
            -- MAX_THEORETICAL = tanaman termahal * slot max / growth time tercepat
            local MAX_THEORETICAL_PER_MIN = 5000 -- hitung dari balancing!
            if stats.incomePerMin > MAX_THEORETICAL_PER_MIN * 1.5 then
                EvidenceLocker:Flag(player, "IMPOSSIBLE_INCOME", `Income {stats.incomePerMin}/min exceeds max {MAX_THEORETICAL_PER_MIN}`, 20)
            end
            
            -- Cek harvest terlalu banyak
            if stats.harvestCount > 30 then -- max 30 harvest per 5 detik tidak masuk akal
                EvidenceLocker:Flag(player, "HARVEST_SPAM", `Harvested {stats.harvestCount} in 5s`, 15)
            end
            stats.harvestCount = 0
            stats.incomePerMin = 0
        end
    end
end)

return BehaviorAnalyzer
```

---

## 6. LAYER 5 - EVIDENCE & PUNISHMENT

### EvidenceLocker:
```lua
-- src/server/AntiCheat/EvidenceLocker.lua

local EvidenceLocker = {}
local DataStoreService = game:GetService("DataStoreService")
local banStore = DataStoreService:GetDataStore("PlayerBans_V1")
local evidence: { [number]: { { time: number, type: string, detail: string, score: number } } } = {}
local scores: { [number]: number } = {}

-- Threshold auto action
local THRESHOLDS = {
    WARN = 20,
    KICK = 50,
    BAN_1D = 80,
    BAN_PERM = 120,
}

function EvidenceLocker.Flag(player: Player, flagType: string, detail: string, score: number)
    local userId = player.UserId
    if not evidence[userId] then evidence[userId] = {} end
    table.insert(evidence[userId], {
        time = os.time(),
        type = flagType,
        detail = detail,
        score = score
    })
    -- Keep only last 200
    if #evidence[userId] > 200 then table.remove(evidence[userId], 1) end
    
    scores[userId] = (scores[userId] or 0) + score
    print(`[AC] FLAG {player.Name} [{flagType}] +{score} (total: {scores[userId]}): {detail}`)
    
    -- Auto action
    local total = scores[userId]
    if total >= THRESHOLDS.BAN_PERM then
        EvidenceLocker.Ban(player, `Auto perm ban - score {total}`)
    elseif total >= THRESHOLDS.BAN_1D then
        EvidenceLocker.TempBan(player, 86400, `Score {total}`)
    elseif total >= THRESHOLDS.KICK then
        player:Kick(`[Anti-Cheat] Suspicious activity detected. Score: {total}`)
    elseif total >= THRESHOLDS.WARN then
        -- Warn via Remote ke client
        game.ReplicatedStorage.Remotes.WarnPlayer:FireClient(player, `Warning: Suspicious activity! Score: {total}`)
    end
end

function EvidenceLocker.Ban(player: Player, reason: string)
    pcall(function()
        banStore:SetAsync(tostring(player.UserId), { banned = true, reason = reason, time = os.time() })
    end)
    player:Kick(`[BANNED] {reason} - Appeal di Discord`)
end

-- Check ban on join
game.Players.PlayerAdded:Connect(function(player)
    local data
    pcall(function()
        data = banStore:GetAsync(tostring(player.UserId))
    end)
    if data and data.banned then
        player:Kick(`[BANNED] {data.reason}`)
    end
end)

return EvidenceLocker
```

### Decay (Biar tidak permanen salah flag):
```lua
-- Score decay tiap 10 menit (jika tidak flag lagi)
task.spawn(function()
    while true do
        task.wait(600) -- 10 menit
        for userId, score in scores do
            scores[userId] = math.max(0, score - 5) -- kurang 5 tiap 10 menit
        end
    end
end)
```

---

## 7. CHECKLIST KEAMANAN SEBELUM PUBLISH

- [ ] `Workspace.AuthorityMode = Server` aktif
- [ ] Semua RemoteEvent di ReplicatedStorage.Remotes punya Validator
- [ ] Tidak ada Remote yang langsung kasih Coins/Item tanpa cek Server Ledger
- [ ] ProfileStore session lock aktif (anti dupe trade)
- [ ] Honeypot remote `_HoneypotAdminGiveCoins` terpasang
- [ ] Trade punya 3-detik confirmation + lock inventory
- [ ] ProcessReceipt cek `alreadyGranted` anti double
- [ ] Rate limit di semua Remote (test spam 1000x/detik)
- [ ] EvidenceLocker test: flag muncul di log
- [ ] Cmdr command `evidence <player>` bisa lihat flag
- [ ] Ban DataStore test: ban -> rejoin -> kick
- [ ] Test dengan exploit tool gratis (WeAreDevs) - optional tapi recommended

---

## 8. KESALAHAN FATAL YANG SERING TERJADI

❌ **JANGAN:**
```lua
-- JANGAN PERNAH LAKUKAN INI:
CoinsRemote.OnServerEvent:Connect(function(player, amount)
    player.leaderstats.Coins.Value += amount -- EXPLOITER BISA KIRIM amount = 999999999!
end)

-- JANGAN:
local price = clientSentPrice -- Client bisa kirim price = 0!
if player.Coins >= price then ...

-- JANGAN:
-- Simpan uang di StringValue/IntValue yang client bisa lihat & manipulasi
```

✅ **LAKUKAN:**
```lua
-- SELALU:
CoinsRemote.OnServerEvent:Connect(function(player, itemId)
    local ok, err = RemoteValidator.Validate(player, "BuyItem", itemId)
    if not ok then return end
    local price = EconomyConfig[itemId].Price -- HARGA DARI SERVER CONFIG!
    if not EconomyService.SpendCoins(player, price, "BuyItem:"..itemId) then return end
    InventoryService.AddItem(player, itemId)
end)
```

---

*Anti-Cheat bukan 1 script, tapi MINDSET: "Semua client adalah musuh sampai terbukti tidak." - Roblox Security Docs 2026*
