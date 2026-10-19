--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Comm = require(Shared.Modules.Comm)
local Constants = require(Shared.Constants)
local Config = require(Shared.Config.AntiCheatConfig)
Comm.Send(Config.HandshakeRemote, tostring(Constants.ProtocolVersion))
print(Constants.GameTitle .. " | Phase 0 client ready")
