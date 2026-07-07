--!strict
--[=[
	Utility functions to work with the CoreGui
	@class CoreGuiUtils
]=]

const StarterGui = game:GetService("StarterGui")

const Promise = require("../roblox_packages/Promise")

const CoreGuiUtils = {}

--[=[
	Retries setting the the core. This is required because sometimes the Core
	scripts are not initialized by the time that client code executes.

	@param tries number
	@param initialWaitTime number
	@param ... any -- parameters to set core with
	@return Promise<()>
]=]
@checked
function CoreGuiUtils.promiseRetrySetCore(tries: number, initialWaitTime: number, ...)
	assert(type(tries) == "number", "Bad tries")
	assert(type(initialWaitTime) == "number", "Bad initialWaitTime")

	const args = { ... }
	const n = select("#", ...)

	return Promise.new(function(resolve, reject)
		local waitTime = initialWaitTime

		local ok, err
		for _ = 1, tries do
			ok, err = CoreGuiUtils.tryToSetCore(unpack(args, 1, n))
			if ok then
				return resolve()
			else
				task.wait(waitTime)
				-- Exponential backoff
				waitTime = waitTime * 2
			end
		end

		if not ok then
			return reject(err)
		end

		return
	end)
end

--[=[
	Tries to invoke `StarterGui:SetCore` with the arguments specified

	@param ... any -- Args to try to call SetCore with
	@return boolean -- false if failed
	@return string? -- error, if there was one
]=]
@checked
function CoreGuiUtils.tryToSetCore(...): (boolean, string?)
	const args = { ... }
	const n = select("#", ...)

	const ok, err = pcall(function()
		StarterGui:SetCore(unpack(args, 1, n))
	end)
	if not ok then
		return false, err
	end

	return true
end

--[=[
	Safely enables or disables a specific CoreGuiType.

	This is a safe wrapper for `StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType, boolean)`
	that retries automatically if CoreScripts are not yet initialized.

	@param coreGuiType Enum.CoreGuiType
	@param enabled boolean
	@param tries number? -- optional retry attempts (default = 5)
	@param initialWaitTime number? -- optional initial delay (default = 0.25)
	@return Promise<()>
]=]
@checked
function CoreGuiUtils.setCoreGuiEnabled(
	coreGuiType: Enum.CoreGuiType,
	enabled: boolean,
	tries: number?,
	initialWaitTime: number?
)
	assert(typeof(coreGuiType) == "EnumItem" and coreGuiType.EnumType == Enum.CoreGuiType, "Bad coreGuiType")
	assert(type(enabled) == "boolean", "Bad enabled value")

	tries = tries or 5
	initialWaitTime = initialWaitTime or 0.25

	return Promise.new(function(resolve, reject)
		local waitTime = initialWaitTime

		for _ = 1, tries :: number do
			const ok = pcall(function()
				StarterGui:SetCoreGuiEnabled(coreGuiType, enabled)
			end)

			if ok then
				return resolve()
			end

			task.wait(waitTime)
			waitTime *= 2
		end

		return reject(`Failed to SetCoreGuiEnabled({coreGuiType.Name}) after {tries} attempts.`)
	end)
end

return CoreGuiUtils
