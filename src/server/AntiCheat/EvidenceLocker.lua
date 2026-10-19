--!strict
-- EvidenceLocker.lua - Log flag & auto punishment
-- PURPOSE: Simpan 200 flag terakhir per player, auto WARN/KICK/BAN berdasar score

local DataStoreService = game:GetService("DataStoreService")
local AntiCheatConfig = require(game.ReplicatedStorage.Shared.Config.AntiCheatConfig)

local EvidenceLocker = {}

export type Evidence = {
	time: number,
	type: string,
	detail: string,
	score: number,
}

local evidence: { [number]: { Evidence } } = {} -- userId -> Evidence[]
local scores: { [number]: number } = {} -- userId -> total score
local banStore: DataStore? = nil

-- Init DataStore (wrap pcall karena bisa fail di Studio tanpa API enabled)
pcall(function()
	banStore = DataStoreService:GetDataStore("PlayerBans_V1")
end)

function EvidenceLocker.Init()
	-- Decay loop
	task.spawn(function()
		while true do
			task.wait(AntiCheatConfig.Decay.IntervalSec)
			for userId, score in scores do
				scores[userId] = math.max(0, score - AntiCheatConfig.Decay.Amount)
			end
		end
	end)

	-- Check ban on join
	game.Players.PlayerAdded:Connect(function(player: Player)
		if not banStore then return end
		local success, data = pcall(function()
			return (banStore :: DataStore):GetAsync(tostring(player.UserId))
		end)
		if success and data and (data :: any).banned then
			local banData: any = data
			-- Cek expired
			if banData.expiresAt and os.time() > banData.expiresAt then
				pcall(function()
					(banStore :: DataStore):RemoveAsync(tostring(player.UserId))
				end)
				print(`[EvidenceLocker] Ban expired for {player.Name}, unbanned`)
			else
				player:Kick(`[BANNED] {banData.reason}\nAppeal di Discord: discord.gg/yourserver`)
			end
		end
	end)

	print("[EvidenceLocker] Initialized")
end

function EvidenceLocker.Flag(player: Player, flagType: string, detail: string, scoreOverride: number?)
	local userId = player.UserId
	local score = scoreOverride or AntiCheatConfig.FlagScores[flagType] or 5

	if not evidence[userId] then
		evidence[userId] = {}
	end
	table.insert(evidence[userId], {
		time = os.time(),
		type = flagType,
		detail = detail,
		score = score,
	})
	-- Keep only last N
	if #evidence[userId] > AntiCheatConfig.MaxEvidencePerPlayer then
		table.remove(evidence[userId], 1)
	end

	scores[userId] = (scores[userId] or 0) + score
	local total: number = scores[userId] :: number

	print(`[AC] ⚠️ FLAG {player.Name} [{flagType}] +{score} (total:{total}): {detail}`)

	-- Auto action
	local t = AntiCheatConfig.Thresholds
	if flagType == "HONEYPOT_TRIGGERED" or total >= t.PermBan then
		EvidenceLocker.Ban(player, `Auto perm ban - {flagType} (score:{total})`)
	elseif total >= t.TempBan1Day then
		EvidenceLocker.TempBan(player, 86400, `Score {total} - {flagType}`)
	elseif total >= t.Kick then
		player:Kick(`[Anti-Cheat] Suspicious activity detected.\nScore: {total}\nJika salah, hubungi admin di Discord.`)
		print(`[AC] KICK {player.Name} score:{total}`)
	elseif total >= t.Warn then
		-- Fire warn ke client
		local warnRemote = game.ReplicatedStorage:FindFirstChild("Remotes") :: Folder?
		if warnRemote then
			local remote = warnRemote:FindFirstChild("WarnPlayer") :: RemoteEvent?
			if remote then
				remote:FireClient(player, `⚠️ Warning: Aktivitas mencurigakan terdeteksi! Score: {total}`)
			end
		end
	end
end

function EvidenceLocker.Ban(player: Player, reason: string)
	print(`[AC] 🔨 BAN {player.Name}: {reason}`)
	if banStore then
		pcall(function()
			(banStore :: DataStore):SetAsync(tostring(player.UserId), {
				banned = true,
				reason = reason,
				time = os.time(),
			})
		end)
	end
	-- Juga simpan di DataService jika ada
	player:Kick(`[BANNED PERMANEN] {reason}\nAppeal: discord.gg/yourserver`)
end

function EvidenceLocker.TempBan(player: Player, durationSec: number, reason: string)
	print(`[AC] 🔨 TEMP BAN {player.Name} ({durationSec}s): {reason}`)
	if banStore then
		pcall(function()
			(banStore :: DataStore):SetAsync(tostring(player.UserId), {
				banned = true,
				reason = reason,
				time = os.time(),
				expiresAt = os.time() + durationSec,
			})
		end)
	end
	player:Kick(`[BANNED {math.floor(durationSec / 3600)} JAM] {reason}\nCoba lagi nanti.`)
end

function EvidenceLocker.GetEvidence(player: Player): { Evidence }
	return evidence[player.UserId] or {}
end

function EvidenceLocker.GetScore(player: Player): number
	return scores[player.UserId] or 0
end

function EvidenceLocker.ClearPlayer(player: Player)
	-- Untuk admin unban
	evidence[player.UserId] = nil
	scores[player.UserId] = nil
	if banStore then
		pcall(function()
			(banStore :: DataStore):RemoveAsync(tostring(player.UserId))
		end)
	end
end

return EvidenceLocker
