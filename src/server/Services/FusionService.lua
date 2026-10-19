--!strict
-- Purpose: consume three identical normal crops for one doubled-value mutant.
-- Dependencies: DataService, EconomyService, QuestService. Remotes: Fuse dispatcher.
-- Security: server selects owned inputs; no client-provided traits or item values; no yield.
local HttpService = game:GetService("HttpService")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config.EconomyConfig)
local Plants = require(Shared.Config.PlantConfig)
local Data = require(script.Parent.DataService)
local Economy = require(script.Parent.EconomyService)
local Quest = require(script.Parent.QuestService)
local Fusion = {}
function Fusion.Fuse(player: Player, id: string): (boolean, string)
	local data = Data.Get(player)
	if not data or not Plants[id] then return false, "Tanaman tidak valid." end
	local indices: { number } = {}
	for index, crop in data.Crops do
		if crop.PlantId == id and not crop.Mutant then table.insert(indices, index) end
		if #indices == 3 then break end
	end
	if #indices ~= 3 then return false, "Butuh 3 hasil panen biasa yang sama." end
	if not Economy.Change(player, -Config.FusionCost, "Fusion") then return false, "Coins belum cukup." end
	for i = #indices, 1, -1 do table.remove(data.Crops, indices[i]) end
	table.insert(data.Crops, { Id = HttpService:GenerateGUID(false), PlantId = id, Mutant = true })
	data.Fusions = math.min(Config.MaxCurrency, data.Fusions + 1)
	Quest.Progress(player, "Fuse")
	return true, "Mutant tercipta! Nilai jual x" .. Config.MutationMultiplier
end
return Fusion
