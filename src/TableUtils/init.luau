--!strict
--[=[
	Provide a variety of utility table operations
	@class TableUtils
]=]

local TableUtils = {}

export type Array<T> = { [number]: T }
export type Map<Key, Value> = { [Key]: Value }

--[=[
	Concats `target` with `source` in-place, modifying the target

	@param target table -- TableUtils to append to
	@param source table -- TableUtils read from
	@return table -- parameter table
]=]
function TableUtils.append<T>(target: Array<T>, source: Array<T>): Array<T>
	for _, value in source do
		target[#target + 1] = value
	end

	return target
end

--[=[
	Converts a map into another map using a transformer function.

	@param source table -- Source table
	@param callback function -- Function returning key/value pair
	@return table
]=]
function TableUtils.mapTo<Key, Value, NewKey, NewValue>(source: Map<Key, Value>, callback: (Key, Value) -> (NewKey, NewValue)): Map<NewKey, NewValue>
	local result = {}

	for key, value in source do
		local newKey, newValue = callback(key, value)
		result[newKey] = newValue
	end

	return result
end

--[=[
	Maps every value in an array into a new array.

	@param source table -- Source array
	@param callback function -- Transform function
	@return table
]=]
function TableUtils.map<T, U>(source: Array<T>, callback: (T, number) -> U): Array<U>
	local result = {}

	for index, value in source do
		table.insert(result, callback(value, index))
	end

	return result
end

--[=[
	Filters an array based on a predicate.

	@param source table -- Source array
	@param callback function -- Filter function
	@return table
]=]
function TableUtils.filter<T>(source: Array<T>, callback: (T, number) -> boolean): Array<T>
	local result = {}

	for index, value in source do
		if callback(value, index) then
			table.insert(result, value)
		end
	end

	return result
end

--[=[
	Finds the first value matching a predicate.

	@param source table
	@param callback function
	@return any?
]=]
function TableUtils.find<T>(source: Array<T>, callback: (T, number) -> boolean): T?
	for index, value in source do
		if callback(value, index) then
			return value
		end
	end

	return nil
end

--[=[
	Returns true if any value matches the predicate.

	@param source table
	@param callback function
	@return boolean
]=]
function TableUtils.some<T>(source: Array<T>, callback: (T, number) -> boolean): boolean
	for index, value in source do
		if callback(value, index) then
			return true
		end
	end

	return false
end

--[=[
	Returns true if every value matches the predicate.

	@param source table
	@param callback function
	@return boolean
]=]
function TableUtils.every<T>(source: Array<T>, callback: (T, number) -> boolean): boolean
	for index, value in source do
		if not callback(value, index) then
			return false
		end
	end

	return true
end

--[=[
	Checks if a table contains a key.

	@param source table
	@param key any
	@return boolean
]=]
function TableUtils.includesKey<Key>(source: Map<Key, any>, key: Key): boolean
	return source[key] ~= nil
end

--[=[
	Clones an array.

	@param source table
	@return table
]=]
function TableUtils.cloneArray<T>(source: Array<T>): Array<T>
	local result = table.create(#source)

	for index, value in source do
		result[index] = value
	end

	return result
end

--[=[
	Removes the first matching value.

	@param source table
	@param value any
	@return boolean
]=]
function TableUtils.removeValue<T>(source: Array<T>, value: T): boolean
	local index = TableUtils.getIndex(source, value)

	if index then
		table.remove(source, index)
		return true
	end

	return false
end

--[=[
	Randomizes an array in-place.

	@param source table
	@return table
]=]
function TableUtils.shuffle<T>(source: Array<T>): Array<T>
	for index = #source, 2, -1 do
		local randomIndex = math.random(index)

		source[index], source[randomIndex] = source[randomIndex], source[index]
	end

	return source
end

--[=[
	Returns a random value from an array.

	@param source table
	@return any?
]=]
function TableUtils.random<T>(source: Array<T>): T?
	if #source == 0 then
		return nil
	end

	return source[math.random(1, #source)]
end

--[=[
	Groups values by a key.

	@param source table
	@param callback function
	@return table
]=]
function TableUtils.groupBy<T, Key>(source: Array<T>, callback: (T) -> Key): Map<Key, Array<T>>
	local result = {}

	for _, value in source do
		local key = callback(value)

		if not result[key] then
			result[key] = {}
		end

		table.insert(result[key], value)
	end

	return result
end

--[=[
	Returns whether a table has no entries.

	@param source table
	@return boolean
]=]
function TableUtils.isEmpty(source: Map<any, any>): boolean
	return next(source) == nil
end

--[=[
	Shallow merges two tables without modifying either.

	@param orig table -- Original table
	@param new table -- Result
	@return table
]=]
function TableUtils.merge<T, U, T2, U2>(orig: Map<T, U>, new: Map<T2, U2>): Map<T | T2, U | U2>
	local result = table.clone(orig)
	for key, val in new do
		result[key :: any] = val :: any
	end
	return result
end

--[=[
	Reverses the list and returns the reversed copy

	@param orig table -- Original table
	@return table
]=]
function TableUtils.reverse<T>(orig: Array<T>): Array<T>
	local new = {}
	for i = #orig, 1, -1 do
		table.insert(new, orig[i])
	end
	return new
end

--[=[
	Returns a list of all of the values that a table has.

	@param source table -- TableUtils source to extract values from
	@return table -- A list with all the values the table has
]=]
function TableUtils.values<T>(source: Map<any, T>): Array<T>
	local new = {}
	for _, val in source do
		table.insert(new, val)
	end
	return new
end

--[=[
	Returns a list of all of the keys that a table has. (In order of pairs)

	@param source table -- TableUtils source to extract keys from
	@return table -- A list with all the keys the table has
]=]
function TableUtils.keys<T>(source: Map<T, any>): Array<T>
	local new = {}
	for key, _ in source do
		table.insert(new, key)
	end
	return new
end

--[=[
	Shallow merges two lists without modifying either.

	@param orig table -- Original table
	@param new table -- Result
	@return table
]=]
function TableUtils.mergeLists<T, U>(orig: Array<T>, new: Array<U>): Array<T | U>
	local _table: Array<T | U> = {}
	for _, val in orig do
		table.insert(_table, val)
	end
	for _, val in new do
		table.insert(_table, val)
	end
	return _table
end

--[=[
	Swaps keys with values, overwriting additional values if duplicated.

	@param orig table -- Original table
	@return table
]=]
function TableUtils.swapKeyValue<Key, Value>(orig: Map<Key, Value>): Map<Value, Key>
	local tab = {}
	for key, val in orig do
		tab[val] = key
	end
	return tab
end

--[=[
	Converts a table to a list.

	@param _table table -- TableUtils to convert to a list
	@return table
]=]
function TableUtils.toList<T>(_table: Map<any, T>): Array<T>
	local list = {}
	for _, item in _table do
		table.insert(list, item)
	end
	return list
end

--[=[
	Counts the number of items in `_table`.
	Useful since `__len` on table in Lua 5.2 returns just the array length.

	@param _table table -- TableUtils to count
	@return number -- count
]=]
function TableUtils.count(_table: Map<any, any>): number
	local count = 0
	for _, _ in _table do
		count = count + 1
	end
	return count
end

--[=[
	Shallow copies a table from target into a new table

	@function TableUtils.copy
	@param target table -- TableUtils to copy
	@return table -- Result
	@within TableUtils
]=]
TableUtils.copy = table.clone

--[=[
	Deep copies a table including metatables

	@param target table -- TableUtils to deep copy
	@param _deepCopyContext table? -- Context to deepCopy the value in
	@return table -- Result
]=]
function TableUtils.deepCopy<T>(target: T, _deepCopyContext: any?): T
	local context = _deepCopyContext or {}
	if context[target] then
		return context[target]
	end

	if type(target) == "table" then
		local new = {}
		context[target] = new
		for index, value in target do
			new[TableUtils.deepCopy(index, context)] = TableUtils.deepCopy(value, context)
		end
		return setmetatable(new, TableUtils.deepCopy(getmetatable(target), context) :: any) :: any
	else
		return target
	end
end

--[=[
	Overwrites a table's value
	@param target table -- Target table
	@param source table -- TableUtils to read from
	@return table -- target
]=]
function TableUtils.deepOverwrite<K0, K1, V0, V1>(target: Map<K0, V0>, source: Map<K1, V1>): Map<K0 | K1, V0 | V1>
	for index: any, value: any in source do
		if type(target[index]) == "table" and type(value) == "table" then
			target[index] = TableUtils.deepOverwrite(target[index] :: any, value) :: any
		else
			target[index] = value
		end
	end
	return target
end

--[=[
	Gets an index by value, returning `nil` if no index is found.
	@param haystack table -- To search in
	@param needle Value to search for
	@return The index of the value, if found
	@return nil -- if not found
]=]
function TableUtils.getIndex<T>(haystack: Array<T>, needle: T): number?
	assert(needle ~= nil, "Needle cannot be nil")

	for index, item in haystack do
		if needle == item then
			return index
		end
	end

	return nil
end

--[=[
	Recursively prints the table. Does not handle recursive tables.

	@param _table table -- TableUtils to stringify
	@param indent number? -- Indent level
	@param output string? -- Output string, used recursively
	@return string -- The table in string form
]=]
function TableUtils.stringify<Key, Value>(_table: Map<Key, Value>, indent: number?, output: string?): string
	local result = output or tostring(_table)
	local stringIndent = indent or 0
	for key, value in _table do
		local formattedText = "\n" .. string.rep("  ", stringIndent) .. tostring(key) .. ": "
		if type(value) == "table" then
			result = result .. formattedText
			result = TableUtils.stringify(value, stringIndent + 1, result)
		else
			result = result .. formattedText .. tostring(value)
		end
	end
	return result
end

--[=[
	Returns whether `value` is within `table`

	@param _table table -- To search in for value
	@param value any -- Value to search for
	@return boolean -- `true` if within, `false` otherwise
]=]
function TableUtils.contains<T>(_table: { T }, value: T): boolean
	for _, item in _table do
		if item == value then
			return true
		end
	end

	return false
end

--[=[
	Overwrites an existing table with the source values.

	@param target table -- TableUtils to overwite
	@param source table -- Source table to read from
	@return table -- target
]=]
function TableUtils.overwrite(target, source)
	for index, item in source do
		target[index] = item
	end

	return target
end

--[=[
	Deep equivalent comparison of a table assuming keys are indexable in the same way.

	@param target table -- TableUtils to check
	@param source table -- Other table to check
	@return boolean
]=]
function TableUtils.deepEquivalent(target, source): boolean
	if target == source then
		return true
	end

	if type(target) ~= type(source) then
		return false
	end

	if type(target) == "table" then
		for key, value in target do
			if not TableUtils.deepEquivalent(value, source[key]) then
				return false
			end
		end

		for key, value in source do
			if not TableUtils.deepEquivalent(value, target[key]) then
				return false
			end
		end

		return true
	else
		-- target == source should do it.
		return false
	end
end

--[=[
	Takes `count` entries from the table. If the table does not have
	that many entries, will return up to the number the table has to
	provide.

	@param source table -- Source table to retrieve values from
	@param count number -- Number of entries to take
	@return table -- List with the entries retrieved
]=]
function TableUtils.take<T>(source: Array<T>, count: number): Array<T>
	local n = math.min(#source, count)
	local newTableUtils = table.create(n)

	for i = 1, n do
		newTableUtils[i] = source[i]
	end

	return newTableUtils
end

local function errorOnIndex(_, index)
	error(string.format("Bad index %q", tostring(index)), 2)
end

local READ_ONLY_METATABLE = {
	__index = errorOnIndex,
	__newindex = errorOnIndex,
}

--[=[
	Sets a metatable on a table such that it errors when
	indexing a nil value

	@param target table -- TableUtils to error on indexing
	@return table -- The same table, with the metatable set to readonly
]=]
function TableUtils.readonly<T>(target: T): T
	return table.freeze(setmetatable(target :: any, READ_ONLY_METATABLE)) :: any
end

--[=[
	Sets a metatable on a table such that it errors when
	indexing a nil value

	@param target table -- TableUtils to error on indexing
	@return table -- The same table, with the target set to error on nil
]=]
function TableUtils.errorOnNilIndex<T>(target: T): T
	return setmetatable(target :: any, READ_ONLY_METATABLE)
end

--[=[
	Recursively sets the table as ReadOnly

	@param target table -- TableUtils to error on indexing
	@return table -- The same table
]=]
function TableUtils.deepReadonly<T>(target: T): T
	for _, item in target :: any do
		if type(item) == "table" then
			TableUtils.deepReadonly(item)
		end
	end

	return TableUtils.readonly(target)
end

--[=[
	Reduces a table into a single value.

	@param target table -- TableUtils to reduce
	@param reducer function -- Reducer function
	@param initial any -- Initial value
	@return any -- Result
]=]
function TableUtils.reduce<T, U>(target: T, reducer: (U, T) -> U, initial: U): U
	local result = initial
	for _, item in target :: any do
		result = reducer(result, item)
	end
	return result
end

return TableUtils
