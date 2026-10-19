--!strict
-- Purpose: lifecycle, validated command dispatch and private state replication.
-- Dependencies: services, Comm, Janitor. Remotes: ClientReady/GardenAction -> state/notice.
-- Security: data readiness gate; no yielding mutation, no client currency or reward inputs.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Comm = require(Shared.Modules.Comm)
local Janitor = require(Shared.Modules.Janitor)
local Constants = require(Shared.Constants)
local RemoteConfig = require(Shared.Config.AntiCheatConfig)
local Config = require(Shared.Config.EconomyConfig)
local SeasonConfig = require(Shared.Config.SeasonConfig)
local Data = require(script.Parent.Services.DataService)
local Economy = require(script.Parent.Services.EconomyService)
local Plot = require(script.Parent.Services.PlotService)
local Plant = require(script.Parent.Services.PlantService)
local Fusion = require(script.Parent.Services.FusionService)
local Quest = require(script.Parent.Services.QuestService)
local Season = require(script.Parent.Services.SeasonPassService)
local World = require(script.Parent.Services.WorldService)
local Analytics = require(script.Parent.Services.AnalyticsService)
local Validator = require(script.Parent.AntiCheat.RemoteValidator)
local Evidence = require(script.Parent.AntiCheat.EvidenceLocker)
local state = Comm.CreateOutbound(RemoteConfig.StateRemote)
local notice = Comm.CreateOutbound(RemoteConfig.NoticeRemote)
local cleanup = Janitor.new()
local playerCleanups: { [Player]: Janitor.Janitor } = {}
local joined: { [Player]: number } = {}
local Movement = require(script.Parent.AntiCheat.MovementValidator)
local closing = false
Plot.Init()
local function go(player: Player): (boolean, string)
	local id = Plot.Id(player)
	local character = player.Character
	if not id or not character then return false, "Klaim petak dahulu." end
	character:PivotTo(CFrame.new(Plot.Origin(id) + Vector3.new(0, 5, 19)))
	Movement.Authorize(player)
	return true, "Selamat datang di kebun Anda!"
end
local function dispatch(player: Player, parts: { string }): (boolean, string)
	local action = parts[1]
	if action == "Claim" then
		if not Plot.Claim(player) then return false, "Semua petak penuh." end
		return go(player)
	elseif action == "Go" then return go(player)
	elseif action == "Buy" then return Plant.Buy(player, parts[2])
	elseif action == "Plant" then
		local slot = Validator.Integer(parts[3])
		if slot then return Plant.Plant(player, parts[2], slot) end
	elseif action == "Harvest" then
		local slot = Validator.Integer(parts[2])
		if slot then return Plant.Harvest(player, slot) end
	elseif action == "Sell" then return Plant.Sell(player, parts[2])
	elseif action == "Fuse" then return Fusion.Fuse(player, parts[2])
	elseif action == "Daily" then return Quest.Daily(player)
	elseif action == "Quest" then return Quest.Claim(player, parts[2])
	elseif action == "Season" then
		local tier = Validator.Integer(parts[2])
		if tier then return Season.Claim(player, tier) end
	elseif action == "Tutorial" then
		local data = Data.Get(player)
		if data then data.TutorialDone = true return true, "Tutorial dilewati." end
	end
	return false, "Perintah tidak valid."
end
local handshakeBinding = Comm.Bind(RemoteConfig.HandshakeRemote, function(_player: Player, payload: unknown): boolean
	return payload == tostring(Constants.ProtocolVersion)
end, function(player: Player, _payload: unknown): () player:SetAttribute("GardenReady", true) end)
cleanup:Add(function(): () handshakeBinding:Destroy() end)
local actionBinding = Comm.Bind(RemoteConfig.ActionRemote, function(player: Player, payload: unknown): boolean
	if not Data.Get(player) or typeof(payload) ~= "string" then return false end
	Movement.Check(player)
	if not Validator.Parse(payload) then Evidence.Flag(player, "Malformed action") return false end
	return true
end, function(player: Player, payload: unknown): ()
	if typeof(payload) ~= "string" then return end
	local parts = Validator.Parse(payload)
	if not parts then return end
	Season.Refresh(player)
	local ok, message = dispatch(player, parts)
	notice:FireClient(player, { Ok = ok, Message = message })
	if ok then Analytics.Log(player, parts[1]) end
end)
cleanup:Add(function(): () actionBinding:Destroy() end)
local function onAdded(player: Player): ()
	if playerCleanups[player] then return end
	local janitor = Janitor.new()
	playerCleanups[player] = janitor
	joined[player] = os.clock()
	janitor:Add(player.CharacterAdded:Connect(function(character: Model): ()
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and player.Parent == Players then go(player) end
	end))
	local ok, loaded = pcall(Data.Load, player)
	if not ok then warn("Profile load failed", loaded) player:Kick("Data tidak bisa dimuat. Silakan masuk lagi.") return end
	if not loaded or closing or player.Parent ~= Players then Data.Release(player) return end
	Economy.InitDisplay(player)
	Quest.Refresh(player)
	Season.Refresh(player)
	Analytics.Log(player, "Join")
end
cleanup:Add(Players.PlayerAdded:Connect(onAdded))
cleanup:Add(Players.PlayerRemoving:Connect(function(player: Player): ()
	Analytics.Log(player, "Leave", os.clock() - (joined[player] or os.clock()))
	joined[player] = nil
	Plot.Release(player)
	Evidence.Release(player)
	Movement.Release(player)
	local janitor = playerCleanups[player]
	playerCleanups[player] = nil
	if janitor then janitor:Destroy() end
	Data.Release(player)
end))
for _, player in Players:GetPlayers() do task.spawn(onAdded, player) end
local updateTask = task.spawn(function(): ()
	while not closing do
		World.Update()
		for _, player in Players:GetPlayers() do
			Movement.Check(player)
			local data = Data.Get(player)
			if not data then continue end
			Quest.Refresh(player)
			Season.Refresh(player)
			Plant.Render(player)
			if player:GetAttribute("GardenReady") then
				-- Explicit allowlist: never replicate ledger, session or other players' data.
				state:FireClient(player, {
					Persistent = player:GetAttribute("GardenPersistence") == true,
					Coins = data.Coins, Gems = data.Gems, Seeds = data.Seeds, Crops = data.Crops,
					Slots = data.Slots, Collection = data.Collection,
					PlotId = Plot.Id(player), Night = World.IsNight(), Remaining = World.Remaining(),
					Quests = data.Quests, QuestClaims = data.QuestClaims, XP = data.XP,
					SeasonClaims = data.SeasonClaims, MaxTier = SeasonConfig.Tiers,
					TutorialDone = data.TutorialDone, LastDaily = data.LastDaily, Streak = data.Streak,
				})
			end
		end
		task.wait(Config.SnapshotInterval)
	end
end)
cleanup:Add(function(): () task.cancel(updateTask) end)
game:BindToClose(function(): ()
	closing = true
	cleanup:Destroy()
	for player, janitor in playerCleanups do janitor:Destroy() Data.Release(player) end
end)
print(Constants.GameTitle .. " | Garden server ready")
