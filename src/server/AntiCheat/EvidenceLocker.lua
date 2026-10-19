--!strict
-- Bounded session-local diagnostic evidence, never automatic proof of guilt.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config.AntiCheatConfig)
type Entry = { At: number, Reason: string }
local records: { [Player]: { Entry } } = {}
local Evidence = {}
function Evidence.Flag(player: Player, reason: string): ()
	local entries = records[player] or {}
	records[player] = entries
	table.insert(entries, { At = os.time(), Reason = string.sub(reason, 1, 128) })
	if #entries > Config.EvidenceLimit then table.remove(entries, 1) end
end
function Evidence.Get(player: Player): { Entry } return table.clone(records[player] or {}) end
function Evidence.Release(player: Player): () records[player] = nil end
return Evidence
