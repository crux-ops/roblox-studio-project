--!strict
-- Purpose: fixed-capacity server-owned plots and slot coordinates.
-- Dependencies: EconomyConfig. Remotes: Claim via dispatcher. Security: one plot/user.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config.EconomyConfig)
local Plot = {}
local owners: { [number]: Player } = {}
local assigned: { [Player]: number } = {}
local models: { [number]: Model } = {}
local function part(name: string, size: Vector3, position: Vector3, color: Color3, parent: Instance): Part
	local object = Instance.new("Part")
	object.Name, object.Size, object.Position, object.Color = name, size, position, color
	object.Anchored = true
	object.Parent = parent
	return object
end
function Plot.Origin(id: number): Vector3
	return Vector3.new(((id - 1) % Config.PlotColumns - 2.5) * Config.PlotSpacing, 0, (math.floor((id - 1) / Config.PlotColumns) - 2) * Config.PlotSpacing)
end
function Plot.SlotPosition(id: number, slot: number): Vector3
	return Plot.Origin(id) + Vector3.new(((slot - 1) % 4 - 1.5) * 10, 1, (math.floor((slot - 1) / 4) - 0.5) * 12)
end
function Plot.Init(): ()
	local folder = Instance.new("Folder")
	folder.Name = "Gardens"
	folder.Parent = workspace
	for id = 1, Config.PlotCount do
		local model = Instance.new("Model")
		model.Name = "Garden_" .. id
		model:SetAttribute("PlotId", id)
		part("Base", Vector3.new(48, 1, 40), Plot.Origin(id), Color3.fromRGB(93, 146, 78), model)
		for slot = 1, Config.Slots do
			part("Soil_" .. slot, Vector3.new(8, 1, 8), Plot.SlotPosition(id, slot), Color3.fromRGB(100, 65, 40), model)
		end
		model.Parent = folder
		models[id] = model
	end
end
function Plot.Claim(player: Player): boolean
	if assigned[player] then return true end
	for id = 1, Config.PlotCount do
		if not owners[id] then
			owners[id], assigned[player] = player, id
			models[id]:SetAttribute("OwnerUserId", player.UserId)
			models[id]:SetAttribute("OwnerName", player.DisplayName)
			return true
		end
	end
	return false
end
function Plot.Id(player: Player): number? return assigned[player] end
function Plot.Owner(id: number): Player? return owners[id] end
function Plot.Near(player: Player, id: number, slot: number): boolean
	local root = if player.Character then player.Character:FindFirstChild("HumanoidRootPart") else nil
	return root ~= nil and root:IsA("BasePart") and (root.Position - Plot.SlotPosition(id, slot)).Magnitude <= Config.InteractionDistance
end
function Plot.Model(id: number): Model? return models[id] end
function Plot.Release(player: Player): ()
	local id = assigned[player]
	if id then
		owners[id], assigned[player] = nil, nil
		models[id]:SetAttribute("OwnerUserId", nil)
		models[id]:SetAttribute("OwnerName", nil)
		local plants = models[id]:FindFirstChild("Plants")
		if plants then plants:Destroy() end
	end
end
return Plot
