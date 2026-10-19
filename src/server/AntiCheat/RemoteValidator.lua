--!strict
-- RemoteValidator.lua - Middleware validasi semua RemoteEvent
-- PURPOSE: Cegah 95% exploit script kiddie
-- SECURITY: Type check, whitelist, rate limit, dipanggil SEBELUM logic apapun

local AntiCheatConfig = require(game.ReplicatedStorage.Shared.Config.AntiCheatConfig)

local RemoteValidator = {}

-- Whitelist Remote yang valid (client boleh fire)
local VALID_REMOTES: { [string]: boolean } = {
	HarvestPlant = true,
	PlantSeed = true,
	BuySeed = true,
	SellCrop = true,
	StealAttempt = true,
	FusePlants = true,
	TradeRequest = true,
	TradeAccept = true,
	TradeConfirm = true,
	TradeCancel = true,
	DailyRewardClaim = true,
}

-- Honeypot: Remote yang TIDAK PERNAH dipanggil game normal
-- Jika ada yang fire = 100% exploiter (dari scan RemoteEvent)
local HONEYPOT_REMOTES: { [string]: boolean } = {
	_HoneypotAdminGiveCoins = true,
	_HoneypotFreeMythic = true,
	_HoneypotUnlockAll = true,
}

-- Rate limit buckets: player -> remote -> { tokens, lastRefill }
local buckets: { [Player]: { [string]: { tokens: number, lastRefill: number } } } = {}

function RemoteValidator.Validate(player: Player, remoteName: string, ...: any): (boolean, string?)
	-- 1. HONEYPOT CHECK (prioritas tertinggi - instant ban signal)
	if HONEYPOT_REMOTES[remoteName] then
		-- Jangan langsung ban di sini, return flag khusus
		-- Biar EvidenceLocker yang handle ban + log
		return false, "HONEYPOT_TRIGGERED"
	end

	-- 2. WHITELIST
	if not VALID_REMOTES[remoteName] then
		return false, `Unknown remote: {remoteName}`
	end

	-- 3. RATE LIMIT (Token Bucket)
	local config = AntiCheatConfig.RateLimits[remoteName]
	if config then
		local ok, err = RemoteValidator.CheckRateLimit(player, remoteName, config)
		if not ok then
			return false, err
		end
	end

	-- 4. TYPE VALIDATION per remote
	if remoteName == "HarvestPlant" or remoteName == "PlantSeed" then
		local plotId, slotIndex = ...
		if type(plotId) ~= "string" then
			return false, "plotId must be string"
		end
		if type(slotIndex) ~= "number" or slotIndex ~= math.floor(slotIndex) then
			return false, "slotIndex must be integer"
		end
		if slotIndex < 1 or slotIndex > 24 then
			return false, "slotIndex out of range"
		end
		if #plotId > 50 or #plotId < 1 then
			return false, "plotId invalid length"
		end
		-- Cegah NaN/inf
		if slotIndex ~= slotIndex or math.abs(slotIndex) == math.huge then
			return false, "slotIndex NaN/inf"
		end
	elseif remoteName == "BuySeed" then
		local seedId, amount = ...
		if type(seedId) ~= "string" or #seedId > 50 then
			return false, "Invalid seedId"
		end
		if amount ~= nil then
			if type(amount) ~= "number" or amount ~= math.floor(amount) or amount < 1 or amount > 100 then
				return false, "Invalid amount"
			end
		end
	elseif remoteName == "StealAttempt" then
		local targetPlotId, slotIndex = ...
		if type(targetPlotId) ~= "string" or type(slotIndex) ~= "number" then
			return false, "Invalid steal args"
		end
	end

	return true, nil
end

function RemoteValidator.CheckRateLimit(player: Player, remoteName: string, config: { maxTokens: number, refillPerSec: number }): (boolean, string?)
	local now = os.clock()
	if not buckets[player] then
		buckets[player] = {}
	end
	if not buckets[player][remoteName] then
		buckets[player][remoteName] = { tokens = config.maxTokens, lastRefill = now }
	end
	local bucket = buckets[player][remoteName]
	local elapsed = now - bucket.lastRefill
	bucket.tokens = math.min(config.maxTokens, bucket.tokens + elapsed * config.refillPerSec)
	bucket.lastRefill = now

	if bucket.tokens < 1 then
		return false, `Rate limited: {remoteName}`
	end
	bucket.tokens -= 1
	return true, nil
end

function RemoteValidator.CleanupPlayer(player: Player)
	buckets[player] = nil
end

-- Cleanup saat player leave
game.Players.PlayerRemoving:Connect(function(player: Player)
	RemoteValidator.CleanupPlayer(player)
end)

return RemoteValidator
