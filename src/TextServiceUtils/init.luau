--!strict
--[=[
	@class TextFilterUtils
]=]

const TextService = game:GetService("TextService")
const Promise = require("../roblox_packages/Promise") :: any

const TextFilterUtils = {}

--[=[
	Gets the size for the label using legacy API surface.

	:::warning
	This will not handle new font faces well.
	:::

	@param textLabel TextLabel
	@param text string
	@param maxWidth number
	@return Vector2
]=]
@checked
function TextFilterUtils.getSizeForLabel(textLabel: TextLabel, text: string, maxWidth: number?): Vector2
	assert(typeof(textLabel) == "Instance", "Bad textLabel")
	assert(type(text) == "string", "Bad text")

	maxWidth = maxWidth or 1e6
	assert(maxWidth > 0, "Bad maxWidth")

	return TextService:GetTextSize(text, textLabel.TextSize, textLabel.Font, Vector2.new(maxWidth, 1e6))
end

--[=[
	Promises the text bounds for the given parameters

	@param params GetTextBoundsParams
	@return Promise<Vector2>
]=]
@checked
function TextFilterUtils.promiseTextBounds(params: GetTextBoundsParams): Promise.Promise<Vector2>
	assert(typeof(params) == "Instance" and params:IsA("GetTextBoundsParams"), "Bad params")

	return Promise.defer(function(resolve, reject)
		local size
		local ok, err = pcall(function()
			size = TextService:GetTextBoundsAsync(params)
		end)

		if not ok then
			return reject(err)
		end

		return resolve(size)
	end)
end

return TextFilterUtils
