--!strict
-- Purpose: best-effort platform custom events; never blocks or grants gameplay rewards.
-- Dependencies: Roblox AnalyticsService. Remotes: none. Security: server event names only.
local Platform = game:GetService("AnalyticsService")
local Analytics = {}
local allowed: { [string]: boolean } = { Join = true, Leave = true, Buy = true, Plant = true, Harvest = true, Sell = true, Fuse = true, Daily = true, Quest = true, Season = true, Claim = true }
function Analytics.Log(player: Player, event: string, value: number?): ()
	if not allowed[event] then return end
	task.spawn(function(): ()
		local ok, message = pcall(function(): () Platform:LogCustomEvent(player, event, value or 1) end)
		if not ok then warn("Analytics unavailable:", message) end
	end)
end
return Analytics
