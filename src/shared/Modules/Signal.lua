--!strict
-- Local, payload-free lifecycle signal. Connections are explicitly disposable.
local Signal = {}
Signal.__index = Signal
export type Signal = typeof(setmetatable({} :: { _event: BindableEvent }, Signal))
function Signal.new(): Signal
	return setmetatable({ _event = Instance.new("BindableEvent") }, Signal)
end
function Signal.Connect(self: Signal, callback: () -> ()): RBXScriptConnection
	return self._event.Event:Connect(callback)
end
function Signal.Once(self: Signal, callback: () -> ()): RBXScriptConnection
	return self._event.Event:Once(callback)
end
function Signal.Fire(self: Signal): ()
	self._event:Fire()
end
function Signal.Destroy(self: Signal): ()
	self._event:Destroy()
end
return Signal
