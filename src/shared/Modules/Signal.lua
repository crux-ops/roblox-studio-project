--!strict
-- Signal.lua - GoodSignal implementation (tanpa memory leak)
-- Lebih aman dari BindableEvent

local Signal = {}
Signal.__index = Signal

export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Fire: (self: Signal<T...>, T...) -> (),
	Wait: (self: Signal<T...>) -> T...,
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

function Signal.new<T...>(): Signal<T...>
	return setmetatable({
		_connections = {},
		_threads = {},
	}, Signal) :: any
end

function Signal.Connect<T...>(self: Signal<T...>, callback: (T...) -> ()): RBXScriptConnection
	local conn: RBXScriptConnection
	local sig = self :: any
	conn = {
		Connected = true,
		Disconnect = function()
			if not conn.Connected then return end
			conn.Connected = false
			for i, c in sig._connections do
				if c == conn then
					table.remove(sig._connections, i)
					break
				end
			end
		end,
	} :: any
	-- Simpan callback di connection
	(conn :: any)._callback = callback
	table.insert(sig._connections, conn)
	return conn
end

function Signal.Once<T...>(self: Signal<T...>, callback: (T...) -> ()): RBXScriptConnection
	local conn: RBXScriptConnection
	conn = self:Connect(function(...: T...)
		conn:Disconnect()
		callback(...)
	end)
	return conn
end

function Signal.Fire<T...>(self: Signal<T...>, ...: T...)
	local sig = self :: any
	for _, conn in sig._connections do
		if conn.Connected then
			local cb = (conn :: any)._callback
			task.spawn(cb, ...)
		end
	end
	-- Resume Wait threads
	for _, thread in sig._threads do
		task.spawn(thread, ...)
	end
	sig._threads = {}
end

function Signal.Wait<T...>(self: Signal<T...>): T...
	local sig = self :: any
	local thread = coroutine.running()
	table.insert(sig._threads, thread)
	return coroutine.yield()
end

function Signal.DisconnectAll<T...>(self: Signal<T...>)
	local sig = self :: any
	for _, conn in sig._connections do
		(conn :: any).Connected = false
	end
	sig._connections = {}
end

function Signal.Destroy<T...>(self: Signal<T...>)
	self:DisconnectAll()
	local sig = self :: any
	sig._threads = {}
end

return Signal
