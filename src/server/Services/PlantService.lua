--!strict
-- Purpose: seed purchase, server-timed growth, inventory and crop sales.
-- Dependencies: data/economy/plot/quest/config. Remotes: Buy/Plant/Harvest/Sell dispatcher.
-- Security: whitelist IDs, integer slots, proximity, ownership; mutations never yield.
local HttpService = game:GetService("HttpService")
local Shared = game:GetService("ReplicatedStorage").Shared
local Plants = require(Shared.Config.PlantConfig)
local Config = require(Shared.Config.EconomyConfig)
local Data = require(script.Parent.DataService)
local Economy = require(script.Parent.EconomyService)
local Plot = require(script.Parent.PlotService)
local Quest = require(script.Parent.QuestService)
local Plant = {}
function Plant.ValidSlot(slot: number): boolean return slot % 1 == 0 and slot >= 1 and slot <= Config.Slots end
function Plant.Buy(player: Player, id: string): (boolean, string)
	local data, definition = Data.Get(player), Plants[id]
	if not data or not definition then return false, "Benih tidak dikenal." end
	local total = 0
	for _, count in data.Seeds do total += count end
	if total >= Config.MaxInventory then return false, "Tas benih penuh." end
	if not Economy.Change(player, -definition.Price, "Buy:" .. id) then return false, "Coins belum cukup." end
	data.Seeds[id] = (data.Seeds[id] or 0) + 1
	return true, "Benih dibeli. Dekati petak Anda untuk menanam."
end
function Plant.Plant(player: Player, id: string, slot: number): (boolean, string)
	local data, plotId = Data.Get(player), Plot.Id(player)
	if not data or not plotId or not Plants[id] or not Plant.ValidSlot(slot) then return false, "Petak atau benih tidak valid." end
	if not Plot.Near(player, plotId, slot) then return false, "Dekati petak Anda dahulu." end
	local key = tostring(slot)
	if data.Slots[key] or (data.Seeds[id] or 0) < 1 then return false, "Slot terisi atau benih habis." end
	data.Seeds[id] -= 1
	data.Slots[key] = { PlantId = id, PlantedAt = os.time() }
	return true, "Benih ditanam!"
end
function Plant.Harvest(player: Player, slot: number): (boolean, string)
	local data, plotId = Data.Get(player), Plot.Id(player)
	if not data or not plotId or not Plant.ValidSlot(slot) or not Plot.Near(player, plotId, slot) then return false, "Dekati petak yang valid." end
	local key = tostring(slot)
	local growing = data.Slots[key]
	if not growing then return false, "Slot kosong." end
	local definition = Plants[growing.PlantId]
	if not definition or os.time() < growing.PlantedAt + definition.GrowthTime then return false, "Tanaman belum matang." end
	if #data.Crops >= Config.MaxInventory then return false, "Tas panen penuh. Jual dahulu." end
	table.insert(data.Crops, { Id = HttpService:GenerateGUID(false), PlantId = growing.PlantId, Mutant = false })
	data.Collection[growing.PlantId] = true
	data.Slots[key] = nil
	data.Harvests = math.min(Config.MaxCurrency, data.Harvests + 1)
	data.XP = math.min(Config.MaxCurrency, data.XP + Config.HarvestXP)
	Quest.Progress(player, "Harvest")
	return true, "Panen berhasil! Jual atau simpan untuk fusion."
end
function Plant.Sell(player: Player, cropId: string): (boolean, string)
	local data = Data.Get(player)
	if not data then return false, "Data belum siap." end
	for index, crop in data.Crops do
		if crop.Id == cropId then
			local definition = Plants[crop.PlantId]
			if not definition then return false, "Tanaman tidak dikenal." end
			local reward = definition.SellValue * (if crop.Mutant then Config.MutationMultiplier else 1)
			if not Economy.Change(player, reward, "Sell:" .. crop.PlantId) then return false, "Saldo penuh." end
			table.remove(data.Crops, index)
			return true, "Terjual +" .. reward .. " Coins!"
		end
	end
	return false, "Item bukan milik Anda."
end
function Plant.Render(player: Player): ()
	local data, id = Data.Get(player), Plot.Id(player)
	if not data or not id then return end
	local model = Plot.Model(id)
	if not model then return end
	local folder = model:FindFirstChild("Plants")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Plants"
		folder.Parent = model
	end
	for slot = 1, Config.Slots do
		local key = tostring(slot)
		local growing = data.Slots[key]
		local visual = folder:FindFirstChild(key)
		if not growing then if visual then visual:Destroy() end continue end
		local definition = Plants[growing.PlantId]
		if not definition then continue end
		local mature = os.time() >= growing.PlantedAt + definition.GrowthTime
		if not visual then
			local stem = Instance.new("Part")
			stem.Name = key
			stem.Shape = Enum.PartType.Ball
			stem.Anchored = true
			stem.CanCollide = false
			stem.Color = definition.Color
			stem.Parent = folder
			visual = stem
		end
		if visual:IsA("BasePart") then
			local size = if mature then 5 else 2
			visual.Size = Vector3.new(size, size, size)
			visual.Position = Plot.SlotPosition(id, slot) + Vector3.new(0, size / 2 + 1, 0)
			visual.Material = if mature then Enum.Material.Neon else Enum.Material.SmoothPlastic
			visual:SetAttribute("PlantId", growing.PlantId)
			visual:SetAttribute("ReadyAt", growing.PlantedAt + definition.GrowthTime)
		end
	end
end
return Plant
