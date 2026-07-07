--!strict
--[=[
	This module provides utility functions for strings
	@class StringUtils
]=]

const StringUtils = {}

--[=[
	Trims the string of the given pattern

	@param str string
	@param pattern string? -- Defaults to whitespace
	@return string
]=]
@checked
function StringUtils.trim(str: string, pattern: string?): string
	if pattern == nil then
		return string.match(str, "^%s*(.-)%s*$") :: string
	else
		-- When we find the first non space character defined by ^%s
		-- we yank out anything in between that and the end of the string
		-- Everything else is replaced with %1 which is essentially nothing
		return string.match(str, "^" .. pattern .. "*(.-)" .. pattern .. "*$")
	end
end

--[=[
	Converts the string to `UpperCamelCase` from `camelCase` or `snakeCase` or `YELL_CASE`
	@param str string
	@return string
]=]
@checked
function StringUtils.toCamelCase(str: string): string
	str = string.lower(str)
	str = string.gsub(str, "[ _](%a)", string.upper)
	str = string.gsub(str, "^%a", string.upper)
	str = string.gsub(str, "%p", "")

	return str
end

--[=[
	Uppercases the first letter of the string
	@param str string
	@return string
]=]
@checked
function StringUtils.uppercaseFirstLetter(str: string): string
	return (string.gsub(str, "^%a", string.upper))
end

--[=[
	Converts to the string to `lowerCamelCase` from `camelCase` or `snakeCase` or `YELL_CASE`
	@param str string
	@return string
]=]
@checked
function StringUtils.toLowerCamelCase(str: string): string
	str = string.lower(str)
	str = string.gsub(str, "[ _](%a)", string.upper)
	str = string.gsub(str, "^%a", string.lower)
	str = string.gsub(str, "%p", "")

	return str
end

--[=[
	Converts the string to _privateCamelCase
	@param str string
	@return string
]=]
@checked
function StringUtils.toPrivateCase(str: string): string
	return "_" .. string.lower(string.sub(str, 1, 1)) .. str:sub(2, #str)
end

--[=[
	Like trim, but only applied to the beginning of the setring
	@param str string
	@param pattern string? -- Defaults to whitespace
	@return string
]=]
@checked
function StringUtils.trimFront(str: string, pattern: string?): string
	const strPattern = pattern or "%s"
	return (string.gsub(str, "^" .. strPattern .. "*(.-)" .. strPattern .. "*", "%1"))
end

--[=[
	Counts the number of times a char appears in a string.

	:::note
	Note that this is not UTF8 safe
	:::

	@param str string
	@param char string
	@return number
]=]
@checked
function StringUtils.checkNumOfCharacterInStringUtils(str: string, char: string): number
	local count = 0
	for _ in string.gmatch(str, char) do
		count = count + 1
	end
	return count
end

--[=[
	Checks if a string is empty or nil
	@param str any
	@return boolean
]=]
@checked
function StringUtils.isEmptyOrWhitespaceOrNil(str: any): boolean
	return type(str) ~= "string" or str == "" or StringUtils.isWhitespace(str)
end

--[=[
	Returns whether or not text is only whitespace
	@param str string
	@return boolean
]=]
@checked
function StringUtils.isWhitespace(str: string): boolean
	return string.match(str, "[%s]+") == str
end

--[=[
	Converts text to have a ... after it if it's too long.
	@param str string
	@param characterLimit number
	@return string
]=]
@checked
function StringUtils.elipseLimit(str: string, characterLimit: number): string
	if #str > characterLimit then
		str = string.sub(str, 1, characterLimit - 3) .. "..."
	end
	return str
end

--[=[
	Removes a prefix from a string if it exists

	@param str string
	@param prefix string
	@return string
]=]
@checked
function StringUtils.removePrefix(str: string, prefix: string): string
	if string.sub(str, 1, #prefix) == prefix then
		return string.sub(str, #prefix + 1)
	else
		return str
	end
end

--[=[
	Removes a postfix from a string if it exists

	@param str string
	@param postfix string
	@return string
]=]
@checked
function StringUtils.removePostfix(str: string, postfix: string): string
	if string.sub(str, -#postfix) == postfix then
		return string.sub(str, 1, -#postfix - 1)
	else
		return str
	end
end

--[=[
	Returns if a string ends with a postfix

	@param str string
	@param postfix string
	@return boolean
]=]
@checked
function StringUtils.endsWith(str: string, postfix: string): boolean
	return string.sub(str, -#postfix) == postfix
end

--[=[
	Returns if a string starts with a postfix

	@param str string
	@param prefix string
	@return boolean
]=]
@checked
function StringUtils.startsWith(str: string, prefix: string): boolean
	return string.sub(str, 1, #prefix) == prefix
end

--[=[
	Adds commas to a number. Not culture aware.

	See [NumberLocalizationUtils.abbreviate] for a culture aware version.

	@param number string | number
	@param seperator string?
	@return string
]=]
@checked
function StringUtils.addCommas(number: string | number, seperator: string?): string
	local strNumber
	if type(number) == "number" then
		strNumber = tostring(number)
	else
		strNumber = number
	end
	seperator = seperator or ","

	local index = -1

	while index ~= 0 do
		strNumber, index = string.gsub(strNumber, "^(-?%d+)(%d%d%d)", "%1" .. seperator .. "%2")
	end

	return strNumber
end

--[=[
	Splits a string by a separator

	@param str string
	@param separator string
	@return {string}
]=]
@checked
function StringUtils.split(str: string, separator: string): { string }
	const result = {}
	for match in (str .. separator):gmatch("(.-)" .. separator) do
		table.insert(result, match)
	end
	return result
end

--[=[
	Formats a number of seconds into a countdown string such as `1:23` or `2:04:15:00`.

	@param seconds number
	@param whenAtZeroText string? -- Text returned when the countdown is at or below zero. Defaults to "0"
	@return string
]=]
@checked
function StringUtils.formatCountdown(seconds: number, whenAtZeroText: string?): string
	assert(type(seconds) == "number", "Bad seconds")
	assert(type(whenAtZeroText) == "string" or whenAtZeroText == nil, "Bad whenAtZeroText")

	if seconds < 0 then
		return whenAtZeroText or "0"
	end

	-- less than 1 minute
	if seconds <= 60 then
		return string.format("%d", seconds)
	end

	-- less than 1 hour
	if seconds <= 60 * 60 then
		const hours = math.floor(seconds / 60)
		return string.format("%0d:%02d", hours, seconds % 60)
	end

	const days = math.floor(seconds / 60 / 60 / 24)
	local hours = math.floor(seconds / 60 / 60) % 24
	const minutes = math.floor(seconds / 60) % 60

	if days == 0 then
		return string.format("%d:%02d:%02d", hours, minutes, seconds % 60)
	elseif days == 1 then
		-- People would be confused about "1 day 2:15:00"
		-- So show 47:15:00
		hours = math.floor(seconds / 60 / 60) % 48

		return string.format("%d:%02d:%02d", hours, minutes, seconds % 60)
	else
		-- TODO: Localize this "days" part?

		return string.format("%d days %d:%02d:%02d", days, hours, minutes, seconds % 60)
	end
end

return StringUtils
