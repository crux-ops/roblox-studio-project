--!strict
-- Purpose: UTC-aligned cross-server day/night clock. Dependencies: EconomyConfig.
-- Remotes: snapshot only. Security: server time only; no client overrides.
local Lighting = game:GetService("Lighting")
local Config = require(game:GetService("ReplicatedStorage").Shared.Config.EconomyConfig)
local World = {}
function World.IsNight(): boolean
	return os.time() % Config.NightCycle >= Config.NightCycle - Config.NightDuration
end
function World.Remaining(): number
	local elapsed = os.time() % Config.NightCycle
	return (if World.IsNight() then Config.NightCycle else Config.NightCycle - Config.NightDuration) - elapsed
end
function World.Update(): ()
	Lighting.ClockTime = if World.IsNight() then 0 else 12
	Lighting.Brightness = if World.IsNight() then 1 else 2
end
return World
