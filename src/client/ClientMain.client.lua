--!strict
-- ClientMain.client.lua - Entry point client
-- HANYA untuk UI & Input, JANGAN ada logic gameplay penting di sini!

print("🌱 [ClientMain] Starting client...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Tunggu Remotes siap
local remotes = ReplicatedStorage:WaitForChild("Remotes")
print(`[ClientMain] Remotes ready: {#remotes:GetChildren()} remotes`)

-- TODO: Init Controllers sesuai Fase:
-- local UIController = require(script.Parent.Controllers.UIController)
-- UIController.Init()
-- local PlantController = require(script.Parent.Controllers.PlantController)
-- PlantController.Init()
-- local PlotController = require(script.Parent.Controllers.PlotController)
-- PlotController.Init()

-- Contoh: Listen Day/Night
local worldStateChanged = remotes:FindFirstChild("WorldStateChanged") :: RemoteEvent?
if worldStateChanged then
	worldStateChanged.OnClientEvent:Connect(function(state: string, timeLeft: number)
		print(`[Client] World state: {state}, timeLeft: {timeLeft}s`)
		-- Update UI timer
	end)
end

-- Contoh: Warn dari Anti-Cheat
local warnPlayer = remotes:FindFirstChild("WarnPlayer") :: RemoteEvent?
if warnPlayer then
	warnPlayer.OnClientEvent:Connect(function(msg: string)
		warn(`[AC WARN] {msg}`)
		-- Tampilkan di UI
		game.StarterGui:SetCore("SendNotification", {
			Title = "⚠️ Warning",
			Text = msg,
			Duration = 5,
		})
	end)
end

print("✅ [ClientMain] Client ready!")
