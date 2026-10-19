--!strict
local Types = require(script.Parent.Parent.Types)
type PlantDefinition = Types.PlantDefinition
local plants: { [string]: PlantDefinition } = {}
local function define(id: string, name: string, rarity: string, price: number, growth: number, value: number, color: Color3): ()
	plants[id] = table.freeze({ Id = id, Name = name, Rarity = rarity, Price = price, GrowthTime = growth, SellValue = value, Color = color })
end

define("sprout", "Happy Sprout", "Common", 10, 10, 15, Color3.fromRGB(100, 220, 100))
define("carrot", "Dancing Carrot", "Common", 25, 30, 40, Color3.fromRGB(255, 150, 40))
define("mushroom", "Sleepy Mushroom", "Common", 50, 60, 85, Color3.fromRGB(220, 100, 90))
define("cactus", "Disco Cactus", "Uncommon", 100, 90, 180, Color3.fromRGB(40, 180, 120))
define("moonflower", "Moon Flower", "Uncommon", 200, 120, 380, Color3.fromRGB(150, 160, 255))
define("crystal", "Crystal Bloom", "Rare", 500, 180, 1000, Color3.fromRGB(80, 230, 250))
define("dragon", "Dragon Fruit", "Rare", 1000, 240, 2100, Color3.fromRGB(240, 80, 180))
define("phoenix", "Phoenix Fern", "Legendary", 2500, 360, 5500, Color3.fromRGB(255, 190, 50))
define("nebula", "Nebula Lotus", "Mythical", 10000, 600, 23000, Color3.fromRGB(160, 80, 240))
define("brainbloom", "Brain Bloom", "BrainrotSecret", 50000, 1200, 120000, Color3.fromRGB(255, 100, 200))
return table.freeze(plants)
