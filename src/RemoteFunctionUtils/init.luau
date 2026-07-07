--!strict
--[=[
	Utility functions to wrap invoking a remote function with a promise
	@class RemoteFunctionUtils
]=]

const Promise = require("../roblox_packages/Promise")

const RemoteFunctionUtils = {}

--[=[
	Invokes the server with the remote function call.
	@param remoteFunction RemoteFunction
	@param ... any
	@return Promise<T>
]=]
@checked
function RemoteFunctionUtils.promiseInvokeServer(remoteFunction: RemoteFunction, ...)
	assert(typeof(remoteFunction) == "Instance" and remoteFunction:IsA("RemoteFunction"), "Bad remoteFunction")

	const args = table.pack(...)

	return Promise.new(function(resolve, reject)
		local results
		const ok, err = pcall(function()
			results = table.pack(remoteFunction:InvokeServer(table.unpack(args, 1, args.n)))
		end)

		if not ok then
			return reject(err or "Failed to invoke server from RemoteFunction")
		end

		if not results then
			return reject("Failed to get results from RemoteFunction")
		end

		return resolve(table.unpack(results, 1, results.n))
	end)
end

--[=[
	Invokes the client with the remote function call.
	@param remoteFunction RemoteFunction
	@param player Instance
	@param ... any
	@return Promise<T>
]=]
@checked
function RemoteFunctionUtils.promiseInvokeClient(remoteFunction: RemoteFunction, player: Player, ...)
	assert(typeof(remoteFunction) == "Instance" and remoteFunction:IsA("RemoteFunction"), "Bad remoteFunction")

	const args = table.pack(...)

	return Promise.new(function(resolve, reject)
		local results
		const ok, err = pcall(function()
			results = table.pack(remoteFunction:InvokeClient(player, table.unpack(args, 1, args.n)))
		end)

		if not ok then
			return reject(err or "Failed to invoke clientfrom RemoteFunction")
		end

		if not results then
			return reject("Failed to get results from RemoteFunction")
		end

		return resolve(table.unpack(results, 1, results.n))
	end)
end

--[=[
	Invokes the server with the remote function call.
	@param bindableFunction RemoteFunction
	@param ... any
	@return Promise<T>
]=]
@checked
function RemoteFunctionUtils.promiseInvokeBindableFunction(bindableFunction: BindableFunction, ...)
	assert(typeof(bindableFunction) == "Instance" and bindableFunction:IsA("BindableFunction"), "Bad bindableFunction")

	const args = table.pack(...)

	return Promise.new(function(resolve, reject)
		local results
		const ok, err = pcall(function()
			results = table.pack(bindableFunction:Invoke(table.unpack(args, 1, args.n)))
		end)

		if not ok then
			return reject(err or "Failed to invoke from BindableFunction")
		end

		if not results then
			return reject("Failed to get results from BindableFunction")
		end

		return resolve(table.unpack(results, 1, results.n))
	end)
end

--[=[
	Converts a promise result into a promise

	@param ok boolean
	@param ... any
	@return Promise<T>
]=]
@checked
function RemoteFunctionUtils.fromPromiseYieldResult(ok: boolean, ...)
	if ok then
		return ...
	else
		local n = select("#", ...)
		if n == 0 then
			return Promise.reject("Failed to get result from RemoteFunction")
		else
			return Promise.reject(...)
		end
	end
end

return RemoteFunctionUtils
