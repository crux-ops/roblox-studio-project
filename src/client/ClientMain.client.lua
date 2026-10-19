--!strict
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Comm = require(Shared.Modules.Comm)
local Constants = require(Shared.Constants)
local Config = require(Shared.Config.AntiCheatConfig)
local UI = require(script.Parent.Controllers.UIController)
local cleanup = UI.Start()
Comm.Send(Config.HandshakeRemote, tostring(Constants.ProtocolVersion))
script.Destroying:Connect(function(): () cleanup:Destroy() end)
