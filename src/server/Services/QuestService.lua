--!strict
-- Purpose: daily goals and streak rewards. Dependencies: DataService, EconomyService.
-- Remotes: Daily/Quest dispatcher. Security: UTC day, server counters, idempotent claims.
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config.EconomyConfig)
local Data = require(script.Parent.DataService)
local Economy = require(script.Parent.EconomyService)
local Quest = {}
local targets: { [string]: number } = { Harvest = Config.QuestHarvest, Steal = Config.QuestSteal, Fuse = Config.QuestFuse }
function Quest.Refresh(player: Player): ()
	local data = Data.Get(player)
	if not data then return end
	local day = math.floor(os.time() / 86400)
	if data.QuestDay ~= day then
		data.QuestDay, data.Quests, data.QuestClaims = day, {}, {}
	end
end
function Quest.Progress(player: Player, action: string): ()
	Quest.Refresh(player)
	local data = Data.Get(player)
	if data and targets[action] then data.Quests[action] = math.min(targets[action], (data.Quests[action] or 0) + 1) end
end
function Quest.Claim(player: Player, name: string): (boolean, string)
	Quest.Refresh(player)
	local data = Data.Get(player)
	local target = targets[name]
	if not data or not target or data.QuestClaims[name] or (data.Quests[name] or 0) < target then return false, "Misi belum selesai atau sudah diklaim." end
	if data.Gems + Config.QuestGems > Config.MaxCurrency then return false, "Gems penuh." end
	if not Economy.Change(player, Config.QuestCoins, "Quest:" .. name) then return false, "Saldo penuh." end
	data.Gems += Config.QuestGems
	data.XP = math.min(Config.MaxCurrency, data.XP + Config.QuestXP)
	data.QuestClaims[name] = true
	return true, "Hadiah misi diterima!"
end
function Quest.Daily(player: Player): (boolean, string)
	local data = Data.Get(player)
	local day = math.floor(os.time() / 86400)
	if not data or data.LastDaily >= day then return false, "Hadiah hari ini sudah diambil." end
	local streak = if data.LastDaily == day - 1 then data.Streak % #Config.DailyCoins + 1 else 1
	if not Economy.Change(player, Config.DailyCoins[streak], "Daily") then return false, "Saldo penuh." end
	data.Streak, data.LastDaily = streak, day
	if streak == #Config.DailyCoins then
		local total = 0
		for _, count in data.Seeds do total += count end
		if total < Config.MaxInventory then data.Seeds.crystal = (data.Seeds.crystal or 0) + 1 end
	end
	return true, "Hadiah harian diterima!"
end
return Quest
