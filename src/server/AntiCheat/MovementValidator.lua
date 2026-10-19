--!strict
-- Conservative horizontal speed fallback. Not a complete flight/noclip detector.
-- Server teleports explicitly reset samples; flags alone never trigger bans.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config.MovementConfig)
local Evidence = require(script.Parent.EvidenceLocker)
type Sample = { Character: Model, Frame: CFrame, At: number }
local samples: { [Player]: Sample } = {}
local Movement = {}
function Movement.Authorize(player: Player): ()
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if character and root and root:IsA("BasePart") then
		samples[player] = { Character = character, Frame = root.CFrame, At = os.clock() }
	end
end
function Movement.Check(player: Player): ()
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if not character or not root or not root:IsA("BasePart") then samples[player] = nil return end
	local previous = samples[player]
	local now = os.clock()
	if not previous or previous.Character ~= character or now - previous.At > Config.MaxSampleGap then Movement.Authorize(player) return end
	local delta = root.Position - previous.Frame.Position
	local distance = Vector2.new(delta.X, delta.Z).Magnitude
	if distance > Config.MaxHorizontalSpeed * (now - previous.At) + Config.Tolerance then
		Evidence.Flag(player, "Horizontal displacement exceeded fallback envelope")
		root.CFrame = previous.Frame
		root.AssemblyLinearVelocity = Vector3.zero
	end
	samples[player] = { Character = character, Frame = root.CFrame, At = now }
end
function Movement.Release(player: Player): () samples[player] = nil end
return Movement
