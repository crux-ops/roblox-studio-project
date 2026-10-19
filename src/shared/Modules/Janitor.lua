--!strict
-- Janitor.lua - Memory management (Hoidberg Janitor pattern)
-- WAJIB pakai untuk semua Connect agar tidak memory leak!

local Janitor = {}
Janitor.__index = Janitor

export type Janitor = {
	Add: (self: Janitor, object: any, methodName: string?, index: any?) -> any,
	Remove: (self: Janitor, index: any) -> Janitor,
	Cleanup: (self: Janitor) -> (),
	Destroy: (self: Janitor) -> (),
}

function Janitor.new(): Janitor
	return setmetatable({
		_tasks = {},
	}, Janitor) :: any
end

function Janitor.Add(self: Janitor, object: any, methodName: string?, index: any?): any
	local janitor = self :: any
	local task = {
		Object = object,
		Method = methodName,
	}
	if index ~= nil then
		janitor._tasks[index] = task
	else
		table.insert(janitor._tasks, task)
	end
	return object
end

function Janitor.Remove(self: Janitor, index: any): Janitor
	local janitor = self :: any
	local task = janitor._tasks[index]
	if task then
		Janitor._cleanTask(task)
		janitor._tasks[index] = nil
	end
	return self
end

function Janitor._cleanTask(task: any)
	local object = task.Object
	local method = task.Method

	if method then
		if type(object) == "table" then
			object[method](object)
		elseif typeof(object) == "Instance" then
			-- Untuk Instance, method biasanya Destroy
			if object.Parent ~= nil then
				object[method](object)
			end
		end
	else
		if typeof(object) == "RBXScriptConnection" then
			if object.Connected then
				object:Disconnect()
			end
		elseif typeof(object) == "function" then
			object()
		elseif typeof(object) == "Instance" then
			object:Destroy()
		elseif type(object) == "table" and object.Destroy then
			object:Destroy()
		elseif type(object) == "table" and object.Disconnect then
			object:Disconnect()
		elseif type(object) == "table" and object.Cancel then
			object:Cancel()
		end
	end
end

function Janitor.Cleanup(self: Janitor)
	local janitor = self :: any
	for index, task in janitor._tasks do
		Janitor._cleanTask(task)
		janitor._tasks[index] = nil
	end
end

function Janitor.Destroy(self: Janitor)
	self:Cleanup()
	local janitor = self :: any
	janitor._tasks = nil
	setmetatable(self :: any, nil)
end

return Janitor
