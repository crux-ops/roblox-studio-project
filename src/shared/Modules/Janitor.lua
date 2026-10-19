--!strict
export type Task = RBXScriptConnection | Instance | (() -> ())
local Janitor = {}
Janitor.__index = Janitor
export type Janitor = typeof(setmetatable({} :: { _tasks: { Task } }, Janitor))
function Janitor.new(): Janitor
	return setmetatable({ _tasks = {} }, Janitor)
end
function Janitor.Add(self: Janitor, item: Task): Task
	table.insert(self._tasks, item)
	return item
end
function Janitor.Cleanup(self: Janitor): ()
	local tasks = self._tasks
	self._tasks = {}
	for i = #tasks, 1, -1 do
		local item = tasks[i]
		local ok, message = pcall(function(): ()
			if typeof(item) == "RBXScriptConnection" then item:Disconnect()
			elseif typeof(item) == "Instance" then item:Destroy()
			elseif type(item) == "function" then item() end
		end)
		if not ok then warn(message) end
	end
end
Janitor.Destroy = Janitor.Cleanup
return Janitor
