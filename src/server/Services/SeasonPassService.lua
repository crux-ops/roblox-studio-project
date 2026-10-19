--!strict
-- Purpose: dated free season progression. Dependencies: DataService, configs.
-- Remotes: Season dispatcher. Security: bounded tier claims from server XP only.
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config.SeasonConfig)
local EconomyConfig = require(Shared.Config.EconomyConfig)
local Data = require(script.Parent.DataService)
local Economy = require(script.Parent.EconomyService)
local Season = {}
function Season.Refresh(player: Player): ()
	local data = Data.Get(player)
	if not data then return end
	local id = math.floor((os.time() - Config.Epoch) / Config.Duration)
	if data.SeasonId ~= id then data.SeasonId, data.XP, data.SeasonClaims = id, 0, {} end
end
function Season.Claim(player: Player, tier: number): (boolean, string)
	Season.Refresh(player)
	local data = Data.Get(player)
	if not data or tier % 1 ~= 0 or tier < 1 or tier > Config.Tiers or data.XP < tier * Config.XPPerTier or data.SeasonClaims[tostring(tier)] then
		return false, "Tier belum terbuka atau sudah diklaim."
	end
	if not Economy.Change(player, Config.FreeCoinsPerTier * tier, "Season") then return false, "Saldo penuh." end
	data.SeasonClaims[tostring(tier)] = true
	return true, "Hadiah season diterima!"
end
return Season
