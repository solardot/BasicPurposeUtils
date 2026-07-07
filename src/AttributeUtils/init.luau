--!strict
--[=[
	Provides utility functions to work with attributes in Roblox
	@class AttributeUtils
]=]

const Promise = require("../roblox_packages/Promise")

const DEFAULT_PREDICATE = function(value)
	return value ~= nil
end

const AttributeUtils = {}

type ValidAttributeMap = { [string]: true }

const VALID_ATTRIBUTE_TYPES: ValidAttributeMap = table.freeze({
	["nil"] = true,
	["string"] = true,
	["boolean"] = true,
	["number"] = true,
	["UDim"] = true,
	["UDim2"] = true,
	["BrickColor"] = true,
	["CFrame"] = true,
	["Color3"] = true,
	["Vector2"] = true,
	["Vector3"] = true,
	["NumberSequence"] = true,
	["ColorSequence"] = true,
	["IntValue"] = true,
	["NumberRange"] = true,
	["Rect"] = true,
	["Font"] = true,
	["EnumItem"] = true,
} :: ValidAttributeMap)

--[=[
	Returns whether the attribute is a valid type or not for an attribute.

	```lua
	print(AttributeUtils.isValidAttributeType(typeof("hi"))) --> true
	```

	@param valueType string
	@return boolean
]=]
@checked
function AttributeUtils.isValidAttributeType(valueType: string): boolean
	return VALID_ATTRIBUTE_TYPES[valueType] == true
end

--[=[
	Promises attribute value fits predicate

	@param instance Instance
	@param attributeName string
	@param predicate function | nil
	@return Promise<unknown>
]=]
@checked
function AttributeUtils.promiseAttribute(instance: Instance, attributeName: string, predicate)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(attributeName) == "string", "Bad attributeName")

	predicate = predicate or DEFAULT_PREDICATE

	do
		const attributeValue = instance:GetAttribute(attributeName)
		if predicate(attributeValue) then
			return Promise.resolve(attributeValue)
		end
	end

	return Promise.new(function(resolve, _reject, onCancel)
		local connection
		connection = instance:GetAttributeChangedSignal(attributeName):Connect(function()
			const attributeValue = instance:GetAttribute(attributeName)
			if predicate(attributeValue) then
				connection:Disconnect()
				resolve(attributeValue)
			end
		end)

		onCancel(function()
			connection:Disconnect()
		end)
	end)
end

--[=[
	Initializes an attribute for a given instance

	@param instance Instance
	@param attributeName string
	@param default any
	@return any? -- The value of the attribute
]=]
@checked
function AttributeUtils.initAttribute(instance: Instance, attributeName: string, default: any): any
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(typeof(attributeName) == "string", "Bad attributeName")

	local value = instance:GetAttribute(attributeName)
	if value == nil then
		instance:SetAttribute(attributeName, default)
		value = default
	end
	return value
end

--[=[
	Retrieves an attribute, and if it is nil, returns the default
	instead.
	@param instance Instance
	@param attributeName string
	@param default T?
	@return T?
]=]
@checked
function AttributeUtils.getAttribute(instance: Instance, attributeName: string, default: any): any
	const value = instance:GetAttribute(attributeName)
	if value == nil then
		return default
	end

	return value
end

--[=[
	Removes all attributes from an instance.

	@param instance Instance
]=]
@checked
function AttributeUtils.removeAllAttributes(instance: Instance)
	assert(typeof(instance) == "Instance", "Bad instance")

	for key, _ in instance:GetAttributes() do
		instance:SetAttribute(key, nil)
	end
end

return AttributeUtils
