--!strict
-- Purpose: bounded server ledger. Dependencies: DataService, EconomyConfig.
-- Remotes: none. Security: callers supply server-computed integer deltas only; no yield.
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config.EconomyConfig)
local DataService = require(script.Parent.DataService)
local Economy = {}
function Economy.Change(player: Player, amount: number, reason: string): boolean
	local data = DataService.Get(player)
	if not data or amount ~= amount or math.abs(amount) == math.huge or amount % 1 ~= 0 then return false end
	local balance = data.Coins + amount
	if balance < 0 or balance > Config.MaxCurrency then return false end
	data.Coins = balance
	table.insert(data.Ledger, { At = os.time(), Amount = amount, Reason = reason, Balance = balance })
	if #data.Ledger > Config.LedgerSize then table.remove(data.Ledger, 1) end
	local stats = player:FindFirstChild("leaderstats")
	local coins = if stats then stats:FindFirstChild("Coins") else nil
	if coins and coins:IsA("IntValue") then coins.Value = balance end
	return true
end
function Economy.InitDisplay(player: Player): ()
	local data = DataService.Get(player)
	if not data then return end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.Coins
	coins.Parent = stats
	stats.Parent = player
end
return Economy
