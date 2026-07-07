--!strict
--[=[
	Helpful functions involving Roblox groups.
	@class GroupUtils
]=]

const GroupService = game:GetService("GroupService")

const Promise = require("../roblox_packages/Promise")

const GroupUtils = {}

--[=[
	Retrieves the rank of the player in the group.

	@param player Player
	@param groupId number
	@return Promise<number> -- Generally from 0 to 255
]=]
@checked
function GroupUtils.promiseRankInGroup(player: Player, groupId: number): Promise.Promise<number>
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")
	assert(type(groupId) == "number", "Bad groupId")

	return Promise.defer(function(resolve, reject)
		local rank = nil
		const ok, err = pcall(function()
			rank = player:GetRankInGroup(groupId)
		end)

		if not ok then
			return reject(err)
		end

		if type(rank) ~= "number" then
			return reject("Rank is not a number")
		end

		return resolve(rank)
	end)
end

--[=[
	Retrieves the role of the player in the group.

	@param player Player
	@param groupId number
	@return Promise<string>
]=]
@checked
function GroupUtils.promiseRoleInGroup(player: Player, groupId: number): Promise.Promise<string>
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")
	assert(type(groupId) == "number", "Bad groupId")

	return Promise.defer(function(resolve, reject)
		local role = nil
		const ok, err = pcall(function()
			role = player:GetRoleInGroup(groupId)
		end)

		if not ok then
			return reject(err)
		end

		if type(role) ~= "string" then
			return reject("Role is not a string")
		end

		return resolve(role)
	end)
end

export type GroupRoleInfo = {
	Name: string,
	Rank: number,
}

export type GroupInfo = {
	Name: string,
	Id: number,
	Owner: {
		Name: string,
		Id: number,
	},
	EmblemUrl: string,
	Description: string,
	Roles: { GroupRoleInfo },
}

--[=[
	Retrieves groupInfo about a group.

	@param groupId number
	@return Promise<table>
]=]
@checked
function GroupUtils.promiseGroupInfo(groupId: number): Promise.Promise<GroupInfo>
	assert(groupId, "Bad groupId")

	return Promise.defer(function(resolve, reject)
		local groupInfo = nil
		const ok, err = pcall(function()
			groupInfo = GroupService:GetGroupInfoAsync(groupId)
		end)

		if not ok then
			return reject(err)
		end

		if type(groupInfo) ~= "table" then
			return reject("GroupInfo is not a table")
		end

		return resolve(groupInfo)
	end)
end

--[=[
	Retrieves group role info for a given rankId

	@param groupId number
	@param rankId number
	@return Promise<table>
]=]
@checked
function GroupUtils.promiseGroupRoleInfo(groupId: number, rankId: number): Promise.Promise<GroupRoleInfo>
	assert(groupId, "Bad groupId")
	assert(rankId, "Bad rankId")

	return GroupUtils.promiseGroupInfo(groupId):andThen(function(groupInfo)
		if type(groupInfo.Roles) ~= "table" then
			return Promise.reject("No Roles table")
		end

		for _, rankInfo in groupInfo.Roles do
			if rankInfo.Rank == rankId then
				return rankInfo
			end
		end

		return Promise.reject("No rank with given id")
	end)
end

return GroupUtils
