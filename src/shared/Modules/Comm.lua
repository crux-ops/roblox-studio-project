--!strict
-- Purpose: server-created allowlisted traffic; bounded string requests, server-only state.
-- Dependencies: config, Janitor. Domain validators and mutation handlers must not yield.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Parent.Config.AntiCheatConfig)
local Janitor = require(script.Parent.Janitor)
local TokenBucket = require(script.Parent.TokenBucket)
type Bucket = TokenBucket.Bucket
type Validator = (Player, unknown) -> boolean
type Handler = (Player, unknown) -> ()
local Comm = {}
local function request(name: string): boolean
	return name == Config.HandshakeRemote or name == Config.ActionRemote
end
local function outbound(name: string): boolean
	return name == Config.StateRemote or name == Config.NoticeRemote
end
local function folder(): Folder
	local existing = ReplicatedStorage:FindFirstChild(Config.RemoteFolder)
	if existing then assert(existing:IsA("Folder"), "Remote folder collision") return existing end
	assert(RunService:IsServer(), "Server must create remotes")
	local result = Instance.new("Folder")
	result.Name = Config.RemoteFolder
	result.Parent = ReplicatedStorage
	return result
end
function Comm.CreateOutbound(name: string): RemoteEvent
	assert(RunService:IsServer() and outbound(name), "Invalid outbound remote")
	local parent = folder()
	assert(not parent:FindFirstChild(name), "Duplicate remote")
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = parent
	return remote
end
function Comm.Bind(name: string, validator: Validator, handler: Handler): Janitor.Janitor
	assert(RunService:IsServer() and request(name), "Invalid request remote")
	local parent = folder()
	assert(not parent:FindFirstChild(name), "Duplicate binding")
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	local cleanup = Janitor.new()
	local buckets: { [Player]: Bucket } = {}
	cleanup:Add(remote)
	cleanup:Add(Players.PlayerRemoving:Connect(function(player: Player): () buckets[player] = nil end))
	cleanup:Add(remote.OnServerEvent:Connect(function(player: Player, payload: unknown, ...: unknown): ()
		local now = os.clock()
		local bucket = buckets[player] or TokenBucket.New(Config.BucketCapacity, now)
		buckets[player] = bucket
		if not TokenBucket.Take(bucket, Config.BucketCapacity, Config.RefillPerSecond, now) then return end
		if select("#", ...) ~= 0 or typeof(payload) ~= "string" or #payload > Config.MaxStringLength then return end
		local ok, message = pcall(function(): ()
			if validator(player, payload) then handler(player, payload) end
		end)
		if not ok then warn("Remote handler error", name, message) end
	end))
	remote.Parent = parent
	return cleanup
end
local function getRemote(name: string): RemoteEvent
	local parent = ReplicatedStorage:WaitForChild(Config.RemoteFolder, 30)
	assert(parent, "Remote folder timeout")
	local remote = parent:WaitForChild(name, 30)
	assert(remote and remote:IsA("RemoteEvent"), "Remote timeout")
	return remote
end
function Comm.Send(name: string, payload: string): ()
	assert(RunService:IsClient() and request(name), "Invalid client request")
	assert(#payload <= Config.MaxStringLength, "Payload too long")
	getRemote(name):FireServer(payload)
end
function Comm.Listen(name: string, callback: (unknown) -> ()): RBXScriptConnection
	assert(RunService:IsClient() and outbound(name), "Invalid subscription")
	return getRemote(name).OnClientEvent:Connect(callback)
end
return table.freeze(Comm)
