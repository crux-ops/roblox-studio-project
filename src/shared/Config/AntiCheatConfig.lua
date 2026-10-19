--!strict
-- AntiCheatConfig.lua - Semua threshold & rate limit terpusat
-- Gampang tuning tanpa edit logic!

local AntiCheatConfig = {
	-- Rate Limits: maxTokens, refillPerSec
	RateLimits = {
		HarvestPlant = { maxTokens = 5, refillPerSec = 5 },
		PlantSeed = { maxTokens = 10, refillPerSec = 3 },
		BuySeed = { maxTokens = 10, refillPerSec = 2 },
		SellCrop = { maxTokens = 10, refillPerSec = 5 },
		StealAttempt = { maxTokens = 3, refillPerSec = 0.05 }, -- 3 per menit MAX
		FusePlants = { maxTokens = 5, refillPerSec = 0.5 },
		TradeRequest = { maxTokens = 5, refillPerSec = 0.2 },
		ChatMessage = { maxTokens = 5, refillPerSec = 1 },
	},

	-- Distance checks
	MaxHarvestDistance = 50, -- studs
	MaxStealDistance = 30,
	MaxShopDistance = 30, -- Jika ada shop fisik

	-- Behavioral thresholds
	MaxIncomePerMinute = 5000, -- Dihitung dari PlantConfig max IPS * slots * 60
	MaxHarvestPer5Sec = 10,
	MaxTradesPerMinute = 3,

	-- Punishment thresholds (score)
	Thresholds = {
		Warn = 20,
		Kick = 50,
		TempBan1Day = 80,
		PermBan = 120,
	},

	-- Flag scores
	FlagScores = {
		HONEYPOT = 100, -- Instant perm ban
		INVALID_REMOTE = 10,
		TYPE_MISMATCH = 10,
		RATE_LIMIT = 5,
		EARLY_HARVEST = 10,
		FAR_HARVEST = 10,
		FAR_STEAL = 15,
		INSUFFICIENT_FUNDS = 5,
		IMPOSSIBLE_INCOME = 20,
		HARVEST_SPAM = 15,
		PLOT_NOT_OWNED = 15,
		INVALID_SLOT = 10,
		STEAL_COOLDOWN_BYPASS = 15,
		TRADE_DUPE_ATTEMPT = 25,
	},

	-- Decay: score berkurang tiap interval
	Decay = {
		IntervalSec = 600, -- 10 menit
		Amount = 5,
	},

	-- Evidence
	MaxEvidencePerPlayer = 200,
}

return AntiCheatConfig
