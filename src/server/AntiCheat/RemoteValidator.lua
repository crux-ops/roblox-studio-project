--!strict
-- Exact command grammar, bounded by Comm before split. No arbitrary client tables.
local Validator = {}
local arities: { [string]: number } = {
	Claim = 1, Go = 1, Buy = 2, Plant = 3, Harvest = 2, Sell = 2,
	Fuse = 2, Daily = 1, Quest = 2, Season = 2, Tutorial = 1,
}
function Validator.Parse(payload: string): { string }?
	if not string.match(payload, "^[%w_:%-]+$") then return nil end
	local parts = string.split(payload, ":")
	if arities[parts[1]] ~= #parts then return nil end
	for _, item in parts do if #item == 0 then return nil end end
	return parts
end
function Validator.Integer(value: string): number?
	if not string.match(value, "^%d+$") or #value > 6 then return nil end
	local number = tonumber(value)
	if not number or number % 1 ~= 0 then return nil end
	return number
end
return Validator
