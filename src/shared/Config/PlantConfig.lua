--!strict
-- PlantConfig.lua
-- Config terpusat untuk semua tanaman - Balancing sheet
-- AI Agent: Tambahkan 150 tanaman di sini, JANGAN hardcode di Service!
-- Format: [SeedId] = { DisplayName, Rarity, Price, Income, GrowthTime (detik), SellPrice, Color }

export type PlantData = {
	DisplayName: string,
	Rarity: string, -- Common | Uncommon | Rare | Epic | Legendary | Mythic | Secret
	Price: number, -- Harga beli benih (Coins)
	Income: number, -- Uang saat panen
	GrowthTime: number, -- Detik (pakai os.time() server!)
	SellPrice: number,
	Color: Color3,
	IncomePerSecond: number, -- Auto computed
}

local PlantConfig: { [string]: PlantData } = {
	-- COMMON (Starter - Growth cepat, income kecil)
	["Sunflower"] = {
		DisplayName = "Sunflower",
		Rarity = "Common",
		Price = 10,
		Income = 15,
		GrowthTime = 10,
		SellPrice = 15,
		Color = Color3.fromRGB(255, 221, 0),
		IncomePerSecond = 0,
	},
	["Tomato"] = {
		DisplayName = "Tomato",
		Rarity = "Common",
		Price = 25,
		Income = 40,
		GrowthTime = 20,
		SellPrice = 40,
		Color = Color3.fromRGB(255, 80, 80),
		IncomePerSecond = 0,
	},
	["Carrot"] = {
		DisplayName = "Carrot",
		Rarity = "Common",
		Price = 50,
		Income = 90,
		GrowthTime = 30,
		SellPrice = 90,
		Color = Color3.fromRGB(255, 140, 0),
		IncomePerSecond = 0,
	},

	-- UNCOMMON
	["Blueberry"] = {
		DisplayName = "Blueberry",
		Rarity = "Uncommon",
		Price = 120,
		Income = 250,
		GrowthTime = 45,
		SellPrice = 250,
		Color = Color3.fromRGB(80, 120, 255),
		IncomePerSecond = 0,
	},
	["Grape"] = {
		DisplayName = "Grape",
		Rarity = "Uncommon",
		Price = 300,
		Income = 700,
		GrowthTime = 60,
		SellPrice = 700,
		Color = Color3.fromRGB(140, 40, 200),
		IncomePerSecond = 0,
	},

	-- RARE
	["DragonFruit"] = {
		DisplayName = "Dragon Fruit",
		Rarity = "Rare",
		Price = 800,
		Income = 2000,
		GrowthTime = 90,
		SellPrice = 2000,
		Color = Color3.fromRGB(255, 50, 150),
		IncomePerSecond = 0,
	},
	["GoldenApple"] = {
		DisplayName = "Golden Apple",
		Rarity = "Rare",
		Price = 2000,
		Income = 5500,
		GrowthTime = 120,
		SellPrice = 5500,
		Color = Color3.fromRGB(255, 215, 0),
		IncomePerSecond = 0,
	},

	-- EPIC
	["VoidShroom"] = {
		DisplayName = "Void Shroom",
		Rarity = "Epic",
		Price = 5000,
		Income = 15000,
		GrowthTime = 180,
		SellPrice = 15000,
		Color = Color3.fromRGB(60, 0, 90),
		IncomePerSecond = 0,
	},
	["CrystalBloom"] = {
		DisplayName = "Crystal Bloom",
		Rarity = "Epic",
		Price = 12000,
		Income = 40000,
		GrowthTime = 300,
		SellPrice = 40000,
		Color = Color3.fromRGB(100, 255, 255),
		IncomePerSecond = 0,
	},

	-- LEGENDARY (Jarang - Harus grind / steal)
	["RainbowTree"] = {
		DisplayName = "Rainbow Tree",
		Rarity = "Legendary",
		Price = 35000,
		Income = 120000,
		GrowthTime = 600,
		SellPrice = 120000,
		Color = Color3.fromRGB(255, 100, 255),
		IncomePerSecond = 0,
	},

	-- MYTHIC (Super Langka - 1% chance dari Fusion)
	["BrainrotRose"] = {
		DisplayName = "Brainrot Rose 🌹🧠",
		Rarity = "Mythic",
		Price = 100000, -- Tidak dijual, hanya dari Fusion/Steal
		Income = 500000,
		GrowthTime = 1200,
		SellPrice = 500000,
		Color = Color3.fromRGB(255, 20, 20),
		IncomePerSecond = 0,
	},

	-- SECRET (0.01% - Tidak ada di shop, hanya event/steal)
	["AdminEye"] = {
		DisplayName = "👁️ ADMIN EYE 👁️",
		Rarity = "Secret",
		Price = 999999,
		Income = 2500000,
		GrowthTime = 3600,
		SellPrice = 2500000,
		Color = Color3.fromRGB(0, 0, 0),
		IncomePerSecond = 0,
	},
}

-- Auto compute IncomePerSecond untuk balancing check
for _, data in PlantConfig do
	data.IncomePerSecond = data.Income / data.GrowthTime
end

-- Helper untuk AI Agent & balancing
function PlantConfig.GetByRarity(rarity: string): { string }
	local result: { string } = {}
	for id, data in PlantConfig do
		if data.Rarity == rarity then
			table.insert(result, id)
		end
	end
	return result
end

function PlantConfig.GetMaxIncomePerSecond(): number
	local max = 0
	for _, data in PlantConfig do
		if data.IncomePerSecond > max then
			max = data.IncomePerSecond
		end
	end
	return max
end

return PlantConfig
