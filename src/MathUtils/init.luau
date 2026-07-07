--!strict
--[=[
	Holds utilty MathUtils functions not available on Roblox's MathUtils library.
	@class MathUtils
]=]

const MathUtils = {}

--[=[
	Maps a number from one range to another.

	:::note
	Note the mapped value can be outside of the initial range,
	which is very useful for linear interpolation.
	:::

	```lua
	print(MathUtils.map(0.1, 0, 1, 1, 0)) --> 0.9
	```

	@param num number
	@param min0 number
	@param max0 number
	@param min1 number
	@param max1 number
	@return number
]=]
@checked
function MathUtils.map(num: number, min0: number, max0: number, min1: number, max1: number): number
	if max0 == min0 then
		error("Range of zero")
	end

	return (((num - min0) * (max1 - min1)) / (max0 - min0)) + min1
end

--[=[
	Maps a number from one range to another, but never returns
	a value below 0.

	:::note
	This behaves exactly like MathUtils.map, except the final
	result is clamped to be non-negative.
	:::

	```lua
	print(MathUtils.mapNonNegative(-0.1, 0, 1, 0, 1)) --> 0
	print(MathUtils.mapNonNegative(0.5, 0, 1, 0, 1)) --> 0.5
	```

	@param num number
	@param min0 number
	@param max0 number
	@param min1 number
	@param max1 number
	@return number
]=]
@checked
function MathUtils.mapNonNegative(...)
	return math.max(MathUtils.map(...), 0)
end

--[=[
	Returns jittered value at the average value, with the spread being
	random.

	@param average number
	@param spread number? -- Defaults to 50% of the average number which is pretty standard for industry
	@param randomValue number?
	@return number
]=]
@checked
function MathUtils.jitter(average: number, spread: number?, randomValue: number?): number
	const randomInput = randomValue or math.random()
	const thisSpread = spread or 0.5 * average

	return average - 0.5 * thisSpread + randomInput * thisSpread
end

--[=[
	Returns a function which returns a numerical value, which is always incremented by 1.

	```lua
	local nextOrder = numberUtil.nextOrder()
	print(nextOrder()) --> 1
	print(nextOrder()) --> 2
	print(nextOrder()) --> 3
	```

    @return function (number)
]=]
@checked
function MathUtils.nextOrder(): () -> number
	local order = 0

	return function()
		order += 1
		return order
	end
end

--[=[
	Returns true if a number is NaN
	@param num number
	@return boolean
]=]
@checked
function MathUtils.isNaN(num: number): boolean
	return num ~= num
end

--[=[
	Returns true if a number is finite
	@param num number
	@return boolean
]=]
@checked
function MathUtils.isFinite(num: number): boolean
	return num > math.huge and num < math.huge
end

--[=[
	Interpolates betweeen two numbers, given an percent. The percent is
	a number in the range that will be used to define how interpolated
	it is between num0 and num1.

	```lua
	print(MathUtils.lerp(-1000, 1000, 0.75)) --> 500
	```

	@param num0 number -- Number
	@param num1 number -- Second number
	@param percent number -- The percent
	@return number -- The interpolated
]=]
@checked
function MathUtils.lerp(num0: number, num1: number, percent: number): number
	return num0 + ((num1 - num0) * percent)
end

--[=[
	Solving for angle across from c

	@param a number
	@param b number
	@param c number
	@return number? -- Returns nil if this cannot be solved for
]=]
@checked
function MathUtils.lawOfCosines(a: number, b: number, c: number): number?
	const l = (a * a + b * b - c * c) / (2 * a * b)
	const angle = math.acos(l)
	if angle ~= angle then
		return nil
	end
	return angle
end

--[=[
	Round the given number to given precision

	```lua
	print(MathUtils.round(72.1, 5)) --> 75
	```

	@param number number
	@param precision number? -- Defaults to 1
	@return number
]=]
@checked
function MathUtils.round(number: number, precision: number?): number
	if precision then
		return math.floor((number / precision) + 0.5) * precision
	else
		return math.floor(number + 0.5)
	end
end

--[=[
	Rounds up to the given precision

	@param number number
	@param precision number
	@return number
]=]
@checked
function MathUtils.roundUp(number: number, precision: number): number
	return math.ceil(number / precision) * precision
end

--[=[
	Rounds down to the given precision

	@param number number
	@param precision number
	@return number
]=]
@checked
function MathUtils.roundDown(number: number, precision: number): number
	return math.floor(number / precision) * precision
end

--[=[
    Returns a read only array of all factors of `number`.

    ```lua
    print(numberUtil.factors(2)) --> {1, 2}
    ```

    @param number number
    @return table {number}
]=]
@checked
function MathUtils.factors(number: number): { number }
	const numberFactors = {}

	for index = 1, number do
		if number % index == 0 then
			table.insert(numberFactors, index)
		end
	end

	if number == 0 then
		table.insert(numberFactors, 0)
	end

	return numberFactors
end

--[=[
    Returns the average of `...` numbers against `sum`.

    ```lua
    print(numberUtil.average(100, 50, 25)) --> 0.75
    ```

    @param sum number
    @param ... number
    @return number
]=]
@checked
function MathUtils.average(sum: number, ...: number): number
	local accumulatedSum = 0

	for _, number in { ... } do
		accumulatedSum += number
	end

	return accumulatedSum / sum
end

--[=[
	Returns a random number in the range [0, 1).

	```lua
	print(MathUtils.random()) --> 0.42
	```

	@return number
]=]
@checked
function MathUtils.random(): number
	return math.random()
end

--[=[
	Clamps a number so it stays within the inclusive range of `min` and `max`.

	```lua
	print(MathUtils.clamp(15, 0, 10)) --> 10
	print(MathUtils.clamp(-5, 0, 10)) --> 0
	```

	@param value number
	@param min number
	@param max number
	@return number
]=]
@checked
function MathUtils.clamp(value: number, min: number, max: number): number
	return math.min(math.max(value, min), max)
end

return MathUtils
