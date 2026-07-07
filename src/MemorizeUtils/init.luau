--!strict
--[=[
	Provides utility functions for memoizing the results of functions.
	@class MemorizeUtils
]=]

const MemorizeUtils = {}

local function getMemoizeKey(...: any): string
	const values = table.pack(...)
	const parts = table.create(values.n)

	for index = 1, values.n do
		parts[index] = tostring(values[index])
	end

	return table.concat(parts, ",")
end

--[=[
	Wraps a function so results are cached by their arguments and computed only once
	per unique argument set.

	@param fn (...any) -> any
	@return (...any) -> any
]=]
@checked
function MemorizeUtils.memoize(fn: (...any) -> any)
	const cache = {}

	return function(...)
		const key = getMemoizeKey(...)
		if cache[key] == nil then
			cache[key] = fn(...)
		end
		return cache[key]
	end
end

--[=[
	Wraps a function so results are cached by their arguments for `ttl` seconds before
	being recomputed.

	@param fn (...any) -> any
	@param ttl number -- Time to live in seconds
	@return (...any) -> any
]=]
@checked
function MemorizeUtils.timed(fn: (...any) -> any, ttl: number)
	const cache = {}

	return function(...)
		const key = getMemoizeKey(...)
		const entry = cache[key]
		const now = tick()

		if not entry or now - entry.time > ttl then
			cache[key] = {
				value = fn(...),
				time = now,
			}
		end

		return cache[key].value
	end
end

--[=[
	Wraps a function with a least-recently-used cache holding at most `maxSize` entries.

	@param fn (...any) -> any
	@param maxSize number -- Maximum number of cached entries
	@return (...any) -> any
]=]
@checked
function MemorizeUtils.lruMemoize(fn: (...any) -> any, maxSize: number)
	const cache = {}
	const order = {}

	return function(...)
		const key = getMemoizeKey(...)

		if cache[key] then
			for i, k in ipairs(order) do
				if k == key then
					table.remove(order, i)
					break
				end
			end
			table.insert(order, key)
			return cache[key]
		end

		const result = fn(...)
		cache[key] = result
		table.insert(order, key)

		if #order > maxSize then
			const oldest = table.remove(order, 1)
			cache[oldest :: string] = nil
		end

		return result
	end
end

return MemorizeUtils
