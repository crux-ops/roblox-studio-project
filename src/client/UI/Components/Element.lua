--!strict
-- Small declarative UI factory. Replacement with Fusion is tracked in phase 10.
local Element = {}
-- Roblox property bags are heterogeneous; dynamic assignment stays at this UI boundary.
function Element.New(className: string, properties: { [string]: any }, parent: Instance?): Instance
	local object = Instance.new(className)
	for key, value in properties do (object :: any)[key] = value end
	object.Parent = parent
	return object
end
return Element
