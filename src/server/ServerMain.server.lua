--!strict
-- Purpose: phase-zero bootstrap. Dependencies: Comm, Constants, AntiCheatConfig.
-- Remotes: ClientReady. Security: exact protocol match; no economy writes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Comm = require(Shared.Modules.Comm)
local Constants = require(Shared.Constants)
local Config = require(Shared.Config.AntiCheatConfig)
local cleanup = Comm.Bind(Config.HandshakeRemote, function(_player: Player, payload: unknown): boolean
	return payload == tostring(Constants.ProtocolVersion)
end, function(player: Player, _payload: unknown): ()
	player:SetAttribute("GardenReady", true)
end)
game:BindToClose(function(): () cleanup:Destroy() end)
print(Constants.GameTitle .. " | Phase 0 server ready")
