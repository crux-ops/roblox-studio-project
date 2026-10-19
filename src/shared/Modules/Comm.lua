--!strict
-- Purpose: server-created, allowlisted remotes with bounded per-player traffic.
-- Dependencies: AntiCheatConfig, Janitor. Domain checks belong in service validators.
-- Security: validators/handlers must not yield between validation and mutation.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Parent.Config.AntiCheatConfig)
local Janitor = require(script.Parent.Janitor)
type Bucket = { tokens: number, time: number }
type Validator = (Player, unknown) -> boolean
type Handler = (Player, unknown) -> ()
local Comm = {}
local function folder(): Folder
	local existing = ReplicatedStorage:FindFirstChild(Config.RemoteFolder)
	if existing then
		assert(existing:IsA("Folder"), "Remote folder collision")
		return existing
	end
	assert(RunService:IsServer(), "Server must create remotes first")
	local result = Instance.new("Folder")
	result.Name = Config.RemoteFolder
	result.Parent = ReplicatedStorage
	return result
end
function Comm.Bind(name: string, validator: Validator, handler: Handler): Janitor.Janitor
	assert(RunService:IsServer(), "Server only")
	assert(name == Config.HandshakeRemote, "Unregistered remote")
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
		local bucket = buckets[player] or { tokens = Config.BucketCapacity, time = now }
		buckets[player] = bucket
		bucket.tokens = math.min(Config.BucketCapacity, bucket.tokens + (now - bucket.time) * Config.RefillPerSecond)
		bucket.time = now
		if bucket.tokens < 1 then return end
		bucket.tokens -= 1
		if select("#", ...) ~= 0 then return end
		if typeof(payload) ~= "string" or #payload > Config.MaxStringLength then return end
		local ok, message = pcall(function(): ()
			if validator(player, payload) then handler(player, payload) end
		end)
		if not ok then warn("Remote handler error", name, message) end
	end))
	remote.Parent = parent
	return cleanup
end
function Comm.Send(name: string, payload: string): ()
	assert(RunService:IsClient(), "Client only")
	assert(name == Config.HandshakeRemote, "Unregistered remote")
	assert(#payload <= Config.MaxStringLength, "Payload too long")
	local parent = ReplicatedStorage:WaitForChild(Config.RemoteFolder, 15)
	assert(parent, "Remote folder timeout")
	local remote = parent:WaitForChild(name, 15)
	assert(remote and remote:IsA("RemoteEvent"), "Remote timeout")
	remote:FireServer(payload)
end
return table.freeze(Comm)
