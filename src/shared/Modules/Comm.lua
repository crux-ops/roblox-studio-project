--!strict
-- Comm.lua - Remote Wrapper Aman (Pengganti RemoteEvent mentah)
-- Semua Remote HARUS lewat sini biar otomatis ada validasi
-- Inspired by Nevermore Comm & Simplified Pattern 2026

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Comm = {}
Comm.__index = Comm

export type CommServer = {
	_events: { [string]: RemoteEvent },
	_functions: { [string]: RemoteFunction },
	BindEvent: (self: CommServer, name: string, callback: (...any) -> ()) -> RBXScriptConnection,
	BindFunction: (self: CommServer, name: string, callback: (...any) -> any) -> (),
	FireClient: (self: CommServer, player: Player, name: string, ...any) -> (),
	FireAllClients: (self: CommServer, name: string, ...any) -> (),
	FireExcept: (self: CommServer, except: Player, name: string, ...any) -> (),
}

export type CommClient = {
	_events: { [string]: RemoteEvent },
	_functions: { [string]: RemoteFunction },
	BindEvent: (self: CommClient, name: string, callback: (...any) -> ()) -> RBXScriptConnection,
	FireServer: (self: CommClient, name: string, ...any) -> (),
	InvokeServer: (self: CommClient, name: string, ...any) -> any,
}

local REMOTE_FOLDER_NAME = "Remotes"

function Comm.GetServer(): CommServer
	local remotesFolder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER_NAME)
	if not remotesFolder then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = REMOTE_FOLDER_NAME
		remotesFolder.Parent = ReplicatedStorage
	end

	local self: CommServer = setmetatable({
		_events = {},
		_functions = {},
	}, Comm) :: any

	-- Pre-create semua RemoteEvent yang dibutuhkan
	local remoteNames = {
		-- Plant
		"PlantSeed",
		"HarvestPlant",
		"PlantPlanted",
		"PlantHarvested",
		"PlantGrowthUpdate",
		-- Shop & Economy
		"BuySeed",
		"SellCrop",
		"CurrencyUpdate",
		-- Steal
		"StealAttempt",
		"StealSuccess",
		"StealFailed",
		"WorldStateChanged", -- Day/Night
		-- Fusion & Collection
		"FusePlants",
		"FuseResult",
		"CollectionUpdate",
		-- Trading
		"TradeRequest",
		"TradeAccept",
		"TradeConfirm",
		"TradeComplete",
		"TradeCancel",
		-- Quest & Daily
		"QuestUpdate",
		"DailyRewardClaim",
		"DailyRewardResult",
		-- System
		"WarnPlayer",
		"Notification",
		-- HONEYPOT (HANYA SERVER - jangan expose ke client!)
		"_HoneypotAdminGiveCoins",
		"_HoneypotFreeMythic",
	}

	for _, name in remoteNames do
		local remote = remotesFolder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = remotesFolder
		end
		self._events[name] = remote :: RemoteEvent
	end

	return self
end

function Comm.GetClient(): CommClient
	local remotesFolder = ReplicatedStorage:WaitForChild(REMOTE_FOLDER_NAME) :: Folder

	local self: CommClient = setmetatable({
		_events = {},
		_functions = {},
	}, Comm) :: any

	for _, child in remotesFolder:GetChildren() do
		if child:IsA("RemoteEvent") then
			-- Client TIDAK BOLEH lihat honeypot (tapi tetap ada di folder, exploiter bisa scan)
			self._events[child.Name] = child
		elseif child:IsA("RemoteFunction") then
			self._functions[child.Name] = child
		end
	end

	-- Listen untuk remote baru (jika server tambah runtime)
	remotesFolder.ChildAdded:Connect(function(child)
		if child:IsA("RemoteEvent") then
			self._events[child.Name] = child
		end
	end)

	return self
end

-- Server methods
function Comm.BindEvent(self: CommServer, name: string, callback: (...any) -> ()): RBXScriptConnection
	local remote = self._events[name]
	assert(remote, `RemoteEvent '{name}' not found!`)
	return remote.OnServerEvent:Connect(callback)
end

function Comm.FireClient(self: CommServer, player: Player, name: string, ...: any)
	local remote = self._events[name]
	assert(remote, `RemoteEvent '{name}' not found!`)
	remote:FireClient(player, ...)
end

function Comm.FireAllClients(self: CommServer, name: string, ...: any)
	local remote = self._events[name]
	assert(remote, `RemoteEvent '{name}' not found!`)
	remote:FireAllClients(...)
end

function Comm.FireExcept(self: CommServer, except: Player, name: string, ...: any)
	local remote = self._events[name]
	assert(remote, `RemoteEvent '{name}' not found!`)
	for _, player in game.Players:GetPlayers() do
		if player ~= except then
			remote:FireClient(player, ...)
		end
	end
end

-- Client methods
function Comm.BindEventClient(self: CommClient, name: string, callback: (...any) -> ()): RBXScriptConnection
	local remote = self._events[name]
	assert(remote, `RemoteEvent '{name}' not found on client!`)
	return remote.OnClientEvent:Connect(callback)
end

function Comm.FireServer(self: CommClient, name: string, ...: any)
	local remote = self._events[name]
	assert(remote, `RemoteEvent '{name}' not found on client!`)
	remote:FireServer(...)
end

return Comm
