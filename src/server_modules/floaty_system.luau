local Floats_fldr = game.ReplicatedStorage.Assets.Floats
local Waypoints_fldr = game.Workspace.Waypoints

local run_service = game:GetService("RunService")

local FloatySystem = {}

local function GetClosestWaypoint(position: Vector3): Part
	local closestWaypoint = nil
	local closestDistance = math.huge

	for _, waypoint in pairs(Waypoints_fldr:GetChildren()) do
		if waypoint:IsA("Part") then
			local distance = (waypoint.Position - position).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestWaypoint = waypoint
			end
		end
	end

	return closestWaypoint
end

function FloatySystem.CreateFloaty(plr: Player, floattype: string, spawnCframe: CFrame)
	local char = plr.Character or plr.CharacterAdded:Wait()

	local floaty = Floats_fldr:FindFirstChild(floattype)

	if not floaty then
		warn("Floaty type not found: " .. floattype)
		return
	end

	local floatyClone: Model = floaty:Clone()
	floatyClone:PivotTo(spawnCframe)

	floatyClone.Parent = workspace

	--Seat plr
	local seat = floatyClone:FindFirstChild("Seat")

	if seat and seat:IsA("VehicleSeat") then
		--Move player to the seat
		print(char)
		seat:Sit(char.Humanoid)
	else
		warn("No valid seat found in floaty model: " .. floattype)
		return
	end

	--Set up logic to handle floaty interaction

	local base: Part = floatyClone:FindFirstChild("Base")

	if not base then
		warn("Base part not found in floaty model: " .. floattype)
		return
	end

	local vector_force = base.VectorForce
	local align_orientation: AlignOrientation = base.AlignOrientation

	if not vector_force then
		warn("VectorForce not found in base part of floaty model: " .. floattype)
		return
	end

	if not align_orientation then
		warn("AlignOrientation not found in base part of floaty model: " .. floattype)
		return
	end

	local pow = 10000

	local max_speed = 200

	run_service.Stepped:Connect(function()
		local closestWaypoint = GetClosestWaypoint(base.Position)
		--align orientation with closest waypoint
		align_orientation.CFrame = CFrame.Angles(0, math.rad(closestWaypoint.Orientation.Y - 90), math.rad(90))

		--vector_force.Force = base.CFrame.LookVector * seat.Throttle * pow
		local original_look_vector = base.CFrame.LookVector
		local adjustedLookVector = Vector3.new(original_look_vector.X, 0, original_look_vector.Y)

		seat.AssemblyLinearVelocity = adjustedLookVector * seat.Throttle * pow
		base.AssemblyLinearVelocity = adjustedLookVector * seat.Throttle * pow

		if math.round(seat.AssemblyLinearVelocity.Magnitude) > max_speed then
			base.AssemblyLinearVelocity = max_speed * base.AssemblyLinearVelocity.Unit
			seat.AssemblyLinearVelocity = max_speed * seat.AssemblyLinearVelocity.Unit
		end
		--print(math.round(seat.AssemblyLinearVelocity.Magnitude))
	end)
end

function FloatySystem.DestroyFloaty(plr: Player, floattype: string) end

return FloatySystem
