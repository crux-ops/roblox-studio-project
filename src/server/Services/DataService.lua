--!strict
-- DataService.lua
-- PURPOSE: ProfileStore wrapper - Jantung game! Semua data player lewat sini.
-- DEPENDENCIES: ProfileStore, PlayerData Types
-- SECURITY: Session locking anti-dupe, sanitize on load, versioning

local Players = game:GetService("Players")

-- GANTI dengan ProfileStore setelah wally install:
-- local ProfileStore = require(game.ReplicatedStorage.Packages.ProfileStore)
-- Untuk scaffold, pakai mock yang aman:

local DataService = {}
local profiles: { [Player]: any } = {}

-- Default data
local DEFAULT_DATA = {
	Coins = 100,
	Gems = 10,
	Level = 1,
	Xp = 0,
	PlotsOwned = {},
	Inventory = { Seeds = {}, Crops = {} },
	Collection = {},
	DailyStreak = 0,
	LastDailyClaimDay = 0,
	Quests = {},
	SeasonXp = 0,
	SeasonTier = 0,
	HasPremiumPass = false,
	GuildId = nil,
	Stats = {
		TotalHarvests = 0,
		TotalSteals = 0,
		TotalStealVictims = 0,
		TotalFusions = 0,
		TotalTrades = 0,
		TotalIncome = 0,
	},
	DataVersion = 1,
}

function DataService.GetProfile(player: Player): any
	return profiles[player]
end

function DataService.GetData(player: Player): any
	local profile = profiles[player]
	if profile then
		return profile.Data or profile -- Handle mock vs real ProfileStore
	end
	return nil
end

function DataService.Init()
	-- TODO: Ganti dengan ProfileStore implementation production:
	--[[
	local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
	local PlayerStore = ProfileStore.New("PlayerData_V1", DEFAULT_DATA)

	Players.PlayerAdded:Connect(function(player)
	    local profile = PlayerStore:StartSessionAsync(tostring(player.UserId))
	    if profile then
	        profile:AddUserId(player.UserId)
	        profile:Reconcile() -- Isi field yang hilang dari DEFAULT_DATA
	        -- Sanitize
	        DataService.Sanitize(profile.Data)
	        -- Check ban
	        if profile.Data.BanInfo and profile.Data.BanInfo.IsBanned then
	            local ban = profile.Data.BanInfo
	            if not ban.ExpiresAt or os.time() < ban.ExpiresAt then
	                player:Kick(`[BANNED] {ban.Reason}`)
	                profile:EndSession()
	                return
	            else
	                -- Ban expired, clear
	                profile.Data.BanInfo = nil
	            end
	        end
	        profiles[player] = profile
	        print(`[DataService] Loaded {player.Name}`)
	    else
	        player:Kick("Data load failed - Rejoin!")
	    end
	end)

	Players.PlayerRemoving:Connect(function(player)
	    local profile = profiles[player]
	    if profile then
	        profile:EndSession()
	        profiles[player] = nil
	    end
	end)
	]]

	-- MOCK untuk development (HAPUS saat production!)
	Players.PlayerAdded:Connect(function(player: Player)
		local data = table.clone(DEFAULT_DATA) :: any
		data.UserId = player.UserId
		data.Username = player.Name
		data.FirstJoinAt = os.time()
		data.LastJoinAt = os.time()
		-- Deep clone nested
		data.Inventory = { Seeds = {}, Crops = {} }
		data.Collection = {}
		data.Stats = table.clone(DEFAULT_DATA.Stats) :: any
		profiles[player] = { Data = data, _mock = true }
		print(`[DataService MOCK] Loaded {player.Name}`)

		-- Create leaderstats DISPLAY ONLY (mirror, bukan source!)
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = data.Coins
		coins.Parent = leaderstats

		local gems = Instance.new("IntValue")
		gems.Name = "Gems"
		gems.Value = data.Gems
		gems.Parent = leaderstats

		local level = Instance.new("IntValue")
		level.Name = "Level"
		level.Value = data.Level
		level.Parent = leaderstats
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local profile = profiles[player]
		if profile then
			print(`[DataService MOCK] Saved {player.Name}: Coins={profile.Data.Coins}`)
			profiles[player] = nil
		end
	end)

	print("[DataService] Initialized (MOCK MODE - Ganti dengan ProfileStore untuk production!)")
end

function DataService.Sanitize(data: any)
	-- Cegah data corrupt / exploit yang inject nilai aneh
	if data.Coins < 0 or data.Coins > 1_000_000_000 then
		warn(`[DataService] Sanitize Coins {data.Coins} -> reset to 100`)
		data.Coins = 100
	end
	if data.Gems < 0 or data.Gems > 10_000_000 then
		warn(`[DataService] Sanitize Gems {data.Gems} -> reset to 10`)
		data.Gems = 10
	end
	if data.Level < 1 or data.Level > 1000 then
		data.Level = 1
	end
end

function DataService.UpdateLeaderstats(player: Player)
	local data = DataService.GetData(player)
	if not data then return end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins") :: IntValue?
		if coins then coins.Value = data.Coins end
		local gems = leaderstats:FindFirstChild("Gems") :: IntValue?
		if gems then gems.Value = data.Gems end
		local level = leaderstats:FindFirstChild("Level") :: IntValue?
		if level then level.Value = data.Level end
	end
end

return DataService
