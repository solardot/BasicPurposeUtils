--!strict
--[=[
	Utilities for proximity-based queries and spatial operations

	@class NearUtils
]=]

const Players = game:GetService("Players")

const NearUtils = {}

--[=[
	Returns all players whose character is within `radius` studs of the position.

	@param position Vector3
	@param radius number
	@return { Player }
]=]
@checked
function NearUtils.getPlayersNearPosition(position: Vector3, radius: number): { Player }
	const nearbyPlayers = {}

	for _, player in Players:GetPlayers() do
		const distance = player:DistanceFromCharacter(position)
		if distance > 0 and distance <= radius then
			table.insert(nearbyPlayers, player)
		end
	end

	return nearbyPlayers
end

--[=[
	Returns the player closest to the position, along with their distance. Players beyond
	`maxDistance` are ignored.

	@param position Vector3
	@param maxDistance number?
	@return Player?
	@return number?
]=]
@checked
function NearUtils.getClosestPlayer(position: Vector3, maxDistance: number?): (Player?, number?)
	local closestPlayer = nil
	local closestDistance = maxDistance or math.huge

	for _, player in Players:GetPlayers() do
		const distance = player:DistanceFromCharacter(position)
		if distance > 0 and distance < closestDistance then
			closestPlayer = player
			closestDistance = distance
		end
	end

	return closestPlayer, closestDistance
end

--[=[
	Returns all parts within `radius` studs of the position, optionally restricted to a
	whitelist of instances.

	@param position Vector3
	@param radius number
	@param whitelist { Instance }?
	@return { BasePart }
]=]
@checked
function NearUtils.getPartsNearPosition(position: Vector3, radius: number, whitelist: { Instance }?): { BasePart }
	const overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	if whitelist then
		overlapParams.FilterDescendantsInstances = whitelist
	end

	const parts = workspace:GetPartBoundsInRadius(position, radius, overlapParams)
	return parts
end

--[=[
	Returns whether two positions are within `distance` studs of each other.

	@param pos1 Vector3
	@param pos2 Vector3
	@param distance number
	@return boolean
]=]
@checked
function NearUtils.isWithinDistance(pos1: Vector3, pos2: Vector3, distance: number): boolean
	return (pos1 - pos2).Magnitude <= distance
end

--[=[
	Returns a copy of the objects sorted by ascending distance from the position.

	@param position Vector3
	@param objects { any }
	@return { any }
]=]
@checked
function NearUtils.sortByDistance(position: Vector3, objects: { any }): { any }
	const sorted = table.clone(objects)

	table.sort(sorted, function(a, b)
		const posA = if typeof(a) == "Instance" and a:IsA("BasePart") then a.Position else Vector3.zero
		const posB = if typeof(b) == "Instance" and b:IsA("BasePart") then b.Position else Vector3.zero

		return (posA - position).Magnitude < (posB - position).Magnitude
	end)

	return sorted
end

--[=[
	Returns the distance between two objects, resolving each to a position via [NearUtils.getPosition].

	@param obj1 any
	@param obj2 any
	@return number
]=]
@checked
function NearUtils.getDistance(obj1: any, obj2: any): number
	const pos1 = NearUtils.getPosition(obj1)
	const pos2 = NearUtils.getPosition(obj2)

	return (pos1 - pos2).Magnitude
end

--[=[
	Resolves an object to a world position. Supports Vector3, BasePart, and Model, and
	returns the zero vector for anything else.

	@param obj any
	@return Vector3
]=]
@checked
function NearUtils.getPosition(obj: any): Vector3
	if typeof(obj) == "Vector3" then
		return obj
	elseif typeof(obj) == "Instance" then
		if obj:IsA("BasePart") then
			return obj.Position
		elseif obj:IsA("Model") then
			return obj:GetPivot().Position
		end
	end

	return Vector3.zero
end

--[=[
	Returns the unique players whose character is touching the given part.

	@param part BasePart
	@return { Player }
]=]
@checked
function NearUtils.getPlayersInPart(part: BasePart): { Player }
	const touchingParts = part:GetTouchingParts()
	const playersInPart = {}
	const addedPlayers = {}

	for _, touchingPart in touchingParts do
		const character = touchingPart:FindFirstAncestorOfClass("Model")
		if character then
			const player = Players:GetPlayerFromCharacter(character)
			if player and not addedPlayers[player] then
				table.insert(playersInPart, player)
				addedPlayers[player] = true
			end
		end
	end

	return playersInPart
end

--[=[
	Returns the part closest to the position, along with its distance.

	@param position Vector3
	@param parts { BasePart }
	@return BasePart?
	@return number?
]=]
@checked
function NearUtils.getClosestPart(position: Vector3, parts: { BasePart }): (BasePart?, number?)
	local closestPart = nil
	local closestDistance = math.huge

	for _, part in parts do
		const distance = (part.Position - position).Magnitude
		if distance < closestDistance then
			closestPart = part
			closestDistance = distance
		end
	end

	return closestPart, closestDistance
end

--[=[
	Returns whether the two players' characters are within `range` studs of each other.

	@param player1 Player
	@param player2 Player
	@param range number
	@return boolean
]=]
@checked
function NearUtils.isPlayerInRange(player1: Player, player2: Player, range: number): boolean
	const char2 = player2.Character
	if not char2 then
		return false
	end

	const hrp2 = char2:FindFirstChild("HumanoidRootPart")
	if not hrp2 then
		return false
	end

	const distance = player1:DistanceFromCharacter(hrp2.Position)
	return distance > 0 and distance <= range
end

--[=[
	Like [NearUtils.getPlayersNearPosition], but omits `excludePlayer` from the results.

	@param position Vector3
	@param radius number
	@param excludePlayer Player?
	@return { Player }
]=]
@checked
function NearUtils.getPlayersNearPositionExcluding(
	position: Vector3,
	radius: number,
	excludePlayer: Player?
): { Player }
	const nearbyPlayers = NearUtils.getPlayersNearPosition(position, radius)

	if excludePlayer then
		for i = #nearbyPlayers, 1, -1 do
			if nearbyPlayers[i] == excludePlayer then
				table.remove(nearbyPlayers, i)
			end
		end
	end

	return nearbyPlayers
end

return NearUtils
