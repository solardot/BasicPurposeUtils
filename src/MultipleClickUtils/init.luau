--!strict
--[=[
	Utility library for detecting multiple clicks or taps. Not good UX, but good for opening up a debug
	menus.

	@class MultipleClickUtils
]=]

const Maid = require("../roblox_packages/Maid")
const Signal = require("../roblox_packages/Signal")

const MultipleClickUtils = {}

const TIME_TO_CLICK_AGAIN = 0.5 -- Based upon windows default
const VALID_TYPES = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true,
}

--[=[
	Returns a signal that fires when the player clicks or taps on a Gui twice.

	@param maid Maid
	@param gui GuiObject
	@return Signal<InputObject>
]=]
@checked
function MultipleClickUtils.getDoubleClickSignal(maid: Maid.Maid, gui: GuiObject): Signal.Signal<InputObject>
	return MultipleClickUtils.getMultipleClickSignal(maid, gui, 2)
end

--[=[
	Returns a signal that fires when the player clicks or taps on a Gui a certain amount
	of times.

	@param maid Maid
	@param gui GuiObject
	@param requiredCount number
	@return Signal<InputObject>
]=]
@checked
function MultipleClickUtils.getMultipleClickSignal(
	maid,
	gui: GuiObject,
	requiredCount: number
): Signal.Signal<InputObject>
	assert(Maid.isMaid(maid), "Bad maid")
	assert(typeof(gui) == "Instance", "Bad gui")
	assert(type(requiredCount) == "number", "Bad requiredCount")

	const signal: Signal.Signal<InputObject> = maid:Add(Signal.new() :: any)

	local lastInputTime: number = 0
	local lastInputObject: InputObject? = nil
	local inputCount: number = 0

	maid:GiveTask(gui.InputBegan:Connect(function(inputObject)
		if not VALID_TYPES[inputObject.UserInputType] then
			return
		end

		if
			lastInputObject
			and inputObject.UserInputType == lastInputObject.UserInputType
			and (os.clock() - lastInputTime) <= TIME_TO_CLICK_AGAIN
		then
			inputCount = inputCount + 1

			if inputCount >= requiredCount then
				inputCount = 0
				lastInputTime = 0
				lastInputObject = nil
				signal:Fire(lastInputObject)
			end
		else
			inputCount = 1
			lastInputTime = os.clock()
			lastInputObject = inputObject
		end
	end))

	return signal
end

return MultipleClickUtils
