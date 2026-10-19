--!strict
-- Purpose: session-locked persistence. Dependencies: vendored ProfileStore, config.
-- Remotes: none. Security: fail closed on load/schema failure; never reset corrupt saves.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config.EconomyConfig)
local Types = require(ReplicatedStorage.Shared.Types.PlayerData)
type Data = Types.Data
-- Upstream ProfileStore exposes a dynamic API; any is confined to this boundary.
local ProfileStore: any = require(script.Parent.Parent.Vendor.ProfileStore)
ProfileStore.SetConstant("AUTO_SAVE_PERIOD", Config.AutosaveInterval)
local template: Data = {
	Version = 1, Coins = Config.StartingCoins, Gems = 0, Seeds = {}, Crops = {}, Slots = {},
	Collection = {}, CollectionRewards = {}, LastSeen = 0, LastDaily = -1, Streak = 0,
	QuestDay = -1, Quests = {}, QuestClaims = {}, SeasonId = -1, XP = 0, SeasonClaims = {},
	ShieldUntil = 0, LastSteal = 0, Harvests = 0, Steals = 0, Fusions = 0,
	Ledger = {}, TutorialDone = false,
}
local Store = ProfileStore.New("MysticGarden_v1", template)
local profiles: { [Player]: any } = {}
local DataService = {}
local Schema = require(script.Parent.DataSchema)
function DataService.Load(player: Player): boolean
	local profile = Store:StartSessionAsync(tostring(player.UserId), {
		Cancel = function(): boolean return player.Parent ~= Players end,
	})
	if not profile then player:Kick("Data belum tersedia. Silakan masuk lagi.") return false end
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	if not Schema.Validate(profile.Data) then
		profile:EndSession()
		player:Kick("Data perlu diperiksa. Hubungi pengembang; data tidak direset.")
		return false
	end
	profile.OnSessionEnd:Connect(function(): ()
		profiles[player] = nil
		if player.Parent == Players then player:Kick("Sesi data berakhir. Silakan masuk lagi.") end
	end)
	if player.Parent ~= Players then profile:EndSession() return false end
	profiles[player] = profile
	player:SetAttribute("GardenPersistence", ProfileStore.DataStoreState == "Access")
	return true
end
function DataService.Get(player: Player): Data?
	local profile = profiles[player]
	if profile and profile:IsActive() then return profile.Data :: Data end
	return nil
end
function DataService.Release(player: Player): ()
	local profile = profiles[player]
	if profile then
		profile.Data.LastSeen = os.time()
		profiles[player] = nil
		profile:EndSession()
	end
end
return DataService
