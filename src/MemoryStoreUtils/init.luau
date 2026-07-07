--!strict
--[=[
	Wraps MemoryService APIs
	@class MemoryStoreUtils
]=]

const HttpService = game:GetService("HttpService")

const Promise = require("../roblox_packages/Promise")

const MemoryStoreUtils = {}

const DEBUG_QUEUE = false

--[=[
	Adds a value to the memory store queue.

	@param queue MemoryStoreQueue
	@param value any
	@param expirationSeconds number
	@param priority number?
	@return Promise
]=]
@checked
function MemoryStoreUtils.promiseAdd(queue: MemoryStoreQueue, value: any, expirationSeconds: number, priority: number?)
	assert(typeof(queue) == "Instance" and queue:IsA("MemoryStoreQueue"), "Bad queue")
	assert(type(expirationSeconds) == "number", "Bad expirationSeconds")
	assert(type(priority) == "number" or priority == nil, "Bad priority")

	return Promise.new(function(resolve, reject)
		if DEBUG_QUEUE then
			print(string.format("[MemoryStoreUtils.promiseAdd] - Queuing %q", HttpService:JSONEncode(value)))
		end

		const ok, err = pcall(function()
			queue:AddAsync(value, expirationSeconds, priority)
		end)

		if not ok then
			if DEBUG_QUEUE then
				warn(string.format("Failed to queue due to %q", err or "nil"))
			end
			return reject(err or "[MemoryStoreUtils.promiseAdd] - Failed to AddAsync to the queue")
		end
		return resolve()
	end)
end

--[=[
	Reads values from the memory store queue.

	@param queue MemoryStoreQueue
	@param count number
	@param allOrNothing boolean
	@param waitTimeout number
	@return Promise<{ any }, string> -- Resolves with the read values and their removal id
]=]
@checked
function MemoryStoreUtils.promiseRead(
	queue: MemoryStoreQueue,
	count: number,
	allOrNothing: boolean,
	waitTimeout: number
)
	assert(typeof(queue) == "Instance" and queue:IsA("MemoryStoreQueue"), "Bad queue")
	assert(type(count) == "number", "Bad count")
	assert(type(allOrNothing) == "boolean", "Bad allOrNothing")
	assert(type(waitTimeout) == "number", "Bad waitTimeout")

	return Promise.new(function(resolve, reject)
		if DEBUG_QUEUE then
			print("[MemoryStoreUtils.promiseRead] - Reading queue")
		end

		local values, removeId
		const ok, err = pcall(function()
			values, removeId = queue:ReadAsync(count, allOrNothing, waitTimeout)
		end)

		if not ok then
			if DEBUG_QUEUE then
				print("[MemoryStoreUtils.promiseRead] - Read from queue", ok, values, removeId)
				warn(string.format("[MemoryStoreUtils.promiseRead] - Failed to read queue due to %q", err or "nil"))
			end

			return reject(err or "[MemoryStoreUtils.promiseRead] - Failed to ReadAsync from the queue")
		end

		if DEBUG_QUEUE then
			print("[MemoryStoreUtils.promiseRead] - Read from queue", values, removeId)
		end

		return resolve(values, removeId)
	end)
end

--[=[
	Removes a previously read entry from the memory store queue.

	@param queue MemoryStoreQueue
	@param id string
	@return Promise
]=]
@checked
function MemoryStoreUtils.promiseRemove(queue: MemoryStoreQueue, id: string)
	assert(typeof(queue) == "Instance" and queue:IsA("MemoryStoreQueue"), "Bad queue")
	assert(type(id) == "string", "Bad id")

	return Promise.new(function(resolve, reject)
		if DEBUG_QUEUE then
			print(string.format("[MemoryStoreUtils.promiseRemove] - Removing %q", HttpService:JSONEncode(id)))
		end

		const ok, err = pcall(function()
			queue:RemoveAsync(id)
		end)

		if not ok then
			if DEBUG_QUEUE then
				warn(string.format("Failed to remove queue id %q due to %q", id, err or "nil"))
			end

			return reject(err or "[MemoryStoreUtils.promiseRemove] - Failed to RemoveAsync from the queue")
		end
		return resolve()
	end)
end

return MemoryStoreUtils
