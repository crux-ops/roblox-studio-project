--!strict
-- ServerMain.server.lua - Entry point server
-- Load semua Service berurutan sesuai Fase

print("🌱 [ServerMain] Starting Grow & Steal: Mystic Garden Tycoon...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tunggu Shared load
local Shared = ReplicatedStorage:WaitForChild("Shared")

-- Init Anti-Cheat dulu (paling penting!)
local EvidenceLocker = require(script.Parent.AntiCheat.EvidenceLocker)
EvidenceLocker.Init()

-- Init Services
local DataService = require(script.Parent.Services.DataService)
DataService.Init()

-- TODO: Tambahkan Service lain sesuai Fase:
-- local EconomyService = require(script.Parent.Services.EconomyService)
-- EconomyService.Init()
-- local PlotService = require(script.Parent.Services.PlotService)
-- PlotService.Init()
-- local PlantService = require(script.Parent.Services.PlantService)
-- PlantService.Init()
-- local WorldService = require(script.Parent.Services.WorldService)
-- WorldService.Init()
-- local StealService = require(script.Parent.Services.StealService)
-- StealService.Init()

print("✅ [ServerMain] All services initialized! Game ready. 🌙🌱")
