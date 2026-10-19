--!strict
-- EconomyConfig.lua - Semua harga, reward, balancing ekonomi

local EconomyConfig = {
	-- Starting
	StartingCoins = 100,
	StartingGems = 10,

	-- Currency
	CoinName = "Coins",
	GemName = "Gems",

	-- Shop Seeds (subset dari PlantConfig, tapi dengan stock & restock logic)
	SeedShop = {
		-- seedId, stock ( -1 = unlimited ), restockTime (detik, -1 = no restock)
		{ seedId = "Sunflower", stock = -1, restockTime = -1 },
		{ seedId = "Tomato", stock = -1, restockTime = -1 },
		{ seedId = "Carrot", stock = 20, restockTime = 300 },
		{ seedId = "Blueberry", stock = 10, restockTime = 600 },
		{ seedId = "Grape", stock = 5, restockTime = 900 },
		{ seedId = "DragonFruit", stock = 3, restockTime = 1800 },
		-- Legendary+ tidak dijual di shop biasa, hanya via event/fusion
	},

	-- Upgrades
	PlotSlots = {
		BaseSlots = 6,
		MaxSlots = 24,
		SlotPrices = { 500, 1500, 4000, 10000, 25000, 50000 }, -- Harga expand per slot
	},

	-- Shield (anti-steal)
	Shield = {
		Duration = 600, -- 10 menit
		PriceCoins = 500,
		PriceRobux = 29, -- DevProduct
		Cooldown = 300, -- 5 menit cooldown setelah shield habis
	},

	-- Steal
	Steal = {
		Cooldown = 60, -- 60 detik per thief
		MaxDistance = 30, -- studs
		RewardMultiplier = 1.0, -- Steal dapat 100% value tanaman
		FailPenalty = 0, -- Tidak ada penalty jika gagal (biar tidak frustasi)
	},

	-- Fusion
	Fusion = {
		CostCoins = 100, -- Biaya fuse 3 -> 1
		SuccessRate = 1.0, -- 100% sukses (jangan bikin gambling frustasi)
		MutantBonusMin = 1.5, -- Multiplier income mutant
		MutantBonusMax = 3.0,
	},

	-- Daily Reward
	DailyReward = {
		Day1 = { Coins = 50, Gems = 0 },
		Day2 = { Coins = 100, Gems = 5 },
		Day3 = { Coins = 200, Gems = 0 },
		Day4 = { Coins = 300, Gems = 10 },
		Day5 = { Coins = 500, Gems = 0 },
		Day6 = { Coins = 750, Gems = 15 },
		Day7 = { Coins = 0, Gems = 0, SeedId = "DragonFruit", Amount = 1 }, -- Rare seed!
		-- Setelah Day7 reset atau lanjut dengan reward lebih besar
	},

	-- Season Pass
	SeasonPass = {
		DurationDays = 30,
		MaxTier = 50,
		XpPerTier = 1000,
		PremiumPriceRobux = 499,
		Rewards = {
			-- Tier = { Free = {}, Premium = {} }
			-- Diisi detail di SeasonConfig.lua
		},
	},

	-- Monetization - DevProduct IDs (ganti dengan ID asli dari Creator Dashboard!)
	DeveloperProducts = {
		Gems100 = 0, -- Isi ID setelah buat di dashboard
		Gems500 = 0,
		Gems1200 = 0,
		Shield10m = 0,
		ExtraSlot = 0,
		SkipGrowth = 0, -- Instant grow 1 plant
		LuckySpin = 0,
	},
	Gamepasses = {
		VIPPlot = 0,
		AutoCollect = 0,
		DoubleGrowth = 0,
		ExtraPlots = 0,
	},
}

return EconomyConfig
