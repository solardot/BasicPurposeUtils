--!strict
--[=[
	Provides utility functions to make it easy to work with network owners. This wraps this API
	because the API surface is actually quite bad.

	See also: [NetworkOwnerService]

	@class NetworkOwnerUtils
]=]

const NetworkOwnerUtils = {}

--[=[
	Attempts to set the network owner of the part, warning and returning false if
	ownership cannot currently be set.

	@param part BasePart
	@param player Player?
	@return boolean -- True if the network owner was set
]=]
@checked
function NetworkOwnerUtils.trySetNetworkOwner(part: BasePart, player: Player?): boolean
	assert(typeof(part) == "Instance" and part:IsA("BasePart"), "Bad part")

	const canSet, err = part:CanSetNetworkOwnership()
	if not canSet then
		warn("[NetworkOwnerUtils.trySetNetworkOwner] - Cannot set network ownership", err)
		return false, err
	end

	part:SetNetworkOwner(player)
	return true
end

--[=[
	Returns the player who is the network owner of the part, or nil if the server
	owns it or ownership could not be read.

	@param part BasePart
	@return Player?
]=]
@checked
function NetworkOwnerUtils.getNetworkOwnerPlayer(part: BasePart): Player?
	assert(typeof(part) == "Instance" and part:IsA("BasePart"), "Bad part")

	const ok, owner = NetworkOwnerUtils.tryToGetNetworkOwner(part)
	if not ok then
		return nil
	end

	return owner
end

--[=[
	Returns whether the given player is the network owner of the part.

	@param part BasePart
	@param player Player?
	@return boolean
]=]
@checked
function NetworkOwnerUtils.isNetworkOwner(part: BasePart, player: Player?): boolean
	assert(typeof(part) == "Instance" and part:IsA("BasePart"), "Bad part")
	assert((typeof(player) == "Instance" and player:IsA("Player")) or player == nil, "Bad player")

	const ok, owner = NetworkOwnerUtils.tryToGetNetworkOwner(part)
	if not ok then
		return false
	end

	return owner == player
end

--[=[
	Returns whether the server is the network owner of the part.

	@param part BasePart
	@return boolean
]=]
@checked
function NetworkOwnerUtils.isServerNetworkOwner(part: BasePart): boolean
	assert(typeof(part) == "Instance" and part:IsA("BasePart"), "Bad part")

	const ok, owner = NetworkOwnerUtils.tryToGetNetworkOwner(part)
	if not ok then
		return false
	end

	return owner == nil
end

--[=[
	Safely attempts to read the network owner of the part, guarding against the
	errors [BasePart:GetNetworkOwner] can throw.

	@param part BasePart
	@return boolean -- True if ownership was read successfully
	@return Player? -- The network owner, or nil for the server
]=]
@checked
function NetworkOwnerUtils.tryToGetNetworkOwner(part: BasePart): (boolean, Player?)
	assert(typeof(part) == "Instance" and part:IsA("BasePart"), "Bad part")

	local finished = false
	local networkOwner = nil

	xpcall(function()
		networkOwner = part:GetNetworkOwner()
		finished = true
	end, function(err)
		warn(err)
	end)

	if not finished then
		return false, nil
	end

	return true, networkOwner
end

return NetworkOwnerUtils
