--!strict
-- Purpose: reject malformed or unknown-version saves without replacing player progress.
-- Dependencies: shared configs. Remotes: none. Security: bounded nested structures and IDs.
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config.EconomyConfig)
local Plants = require(Shared.Config.PlantConfig)
local SeasonConfig = require(Shared.Config.SeasonConfig)
local Schema = {}
local function integer(value: unknown, minimum: number, maximum: number): boolean
	return type(value) == "number" and value == value and value % 1 == 0 and value >= minimum and value <= maximum
end
function Schema.Validate(value: unknown): boolean
	if type(value) ~= "table" then return false end
	-- Persisted tables have unknown shape; dynamic indexing is isolated to schema validation.
	local data = value :: { [string]: any }
	if data.Version ~= 1 or type(data.TutorialDone) ~= "boolean" then return false end
	for _, key in { "Coins", "Gems", "XP", "Harvests", "Steals", "Fusions" } do
		if not integer(data[key], 0, Config.MaxCurrency) then return false end
	end
	for _, key in { "LastSeen", "ShieldUntil", "LastSteal" } do
		if not integer(data[key], 0, 9999999999) then return false end
	end
	for _, key in { "LastDaily", "QuestDay", "SeasonId" } do
		if not integer(data[key], -1, 9999999) then return false end
	end
	if not integer(data.Streak, 0, #Config.DailyCoins) then return false end
	for _, key in { "Seeds", "Crops", "Slots", "Collection", "CollectionRewards", "Quests", "QuestClaims", "SeasonClaims", "Ledger" } do
		if type(data[key]) ~= "table" then return false end
	end
	local seedTotal = 0
	for id, count in data.Seeds do
		if type(id) ~= "string" or not Plants[id] or not integer(count, 0, Config.MaxInventory) then return false end
		seedTotal += count
	end
	if seedTotal > Config.MaxInventory then return false end
	local cropCount = 0
	local cropIds: { [string]: boolean } = {}
	for index, crop in data.Crops do
		cropCount += 1
		if not integer(index, 1, #data.Crops) or type(crop) ~= "table" then return false end
		if type(crop.Id) ~= "string" or #crop.Id < 1 or #crop.Id > 64 or cropIds[crop.Id] then return false end
		if type(crop.PlantId) ~= "string" or not Plants[crop.PlantId] or type(crop.Mutant) ~= "boolean" then return false end
		cropIds[crop.Id] = true
	end
	if cropCount ~= #data.Crops or cropCount > Config.MaxInventory then return false end
	for key, growing in data.Slots do
		if type(key) ~= "string" then return false end
		local slot = tonumber(key)
		if not slot or not integer(slot, 1, Config.Slots) or tostring(slot) ~= key or type(growing) ~= "table" then return false end
		if type(growing.PlantId) ~= "string" or not Plants[growing.PlantId] or not integer(growing.PlantedAt, 0, 9999999999) then return false end
	end
	for id, unlocked in data.Collection do
		if type(id) ~= "string" or not Plants[id] or unlocked ~= true then return false end
	end
	for name, progress in data.Quests do
		if name ~= "Harvest" and name ~= "Steal" and name ~= "Fuse" then return false end
		if not integer(progress, 0, Config.MaxCurrency) then return false end
	end
	for name, claimed in data.QuestClaims do
		if (name ~= "Harvest" and name ~= "Steal" and name ~= "Fuse") or claimed ~= true then return false end
	end
	for tier, claimed in data.SeasonClaims do
		if type(tier) ~= "string" or not integer(tonumber(tier), 1, SeasonConfig.Tiers) or tostring(tonumber(tier)) ~= tier or claimed ~= true then return false end
	end
	for key, unlocked in data.CollectionRewards do
		if type(key) ~= "string" or #key > 64 or type(unlocked) ~= "boolean" then return false end
	end
	local ledgerCount = 0
	for index, entry in data.Ledger do
		ledgerCount += 1
		if not integer(index, 1, #data.Ledger) or type(entry) ~= "table" then return false end
		if not integer(entry.At, 0, 9999999999) or not integer(entry.Amount, -Config.MaxCurrency, Config.MaxCurrency) or not integer(entry.Balance, 0, Config.MaxCurrency) then return false end
		if type(entry.Reason) ~= "string" or #entry.Reason > 128 then return false end
	end
	return ledgerCount == #data.Ledger and ledgerCount <= Config.LedgerSize
end
return Schema
