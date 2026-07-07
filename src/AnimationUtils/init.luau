--!nonstrict
--[=[
	Utility functions for animations with reactive programming support
	@class AnimationUtils
]=]

const RunService = game:GetService("RunService")

const EnumUtils = require("./EnumUtils")
const RbxAssetUtils = require("./RbxAssetUtils")

const AnimationUtils = {}

--[=[
	Loads an animation from the given animation id onto the humanoid or animator.

	@param animatorOrHumanoid Humanoid | Animator
	@param animationId string
	@return AnimationTrack
]=]
@checked
function AnimationUtils.loadAnimationFromId(
	animatorOrHumanoid: Humanoid | Animator,
	animationId: string
): AnimationTrack
	const animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return (animatorOrHumanoid :: any):LoadAnimation(animation)
end

--[=[
	Adjusts the weight of a track only if the current weight target is not already set,
	avoiding redundant weight adjustments.

	@param track AnimationTrack
	@param weight number
	@param fadeTime number
]=]
@checked
function AnimationUtils.setWeightTargetIfNotSet(track: AnimationTrack, weight: number, fadeTime: number): ()
	assert(typeof(track) == "Instance", "Bad track")
	assert(type(weight) == "number", "Bad weight")
	assert(type(fadeTime) == "number", "Bad fadeTime")

	if track.WeightTarget ~= weight then
		track:AdjustWeight(weight, fadeTime)
	end
end

--[=[
	Gets the existing animator on the humanoid or animation controller, creating one
	if it does not already exist.

	@param humanoid Humanoid | AnimationController
	@return Animator
]=]
@checked
function AnimationUtils.getOrCreateAnimator(humanoid: Humanoid | AnimationController): Animator
	const animator = humanoid:FindFirstChildOfClass("Animator")
	if animator ~= nil then
		return animator
	end

	if RunService:IsClient() then
		warn(
			string.format(
				"[HumanoidAnimatorUtils.getOrCreateAnimator] - Creating an animator on %s on the client",
				humanoid:GetFullName()
			)
		)
	end

	const newAnimator = Instance.new("Animator")
	newAnimator.Name = "Animator"
	newAnimator.Parent = humanoid
	return newAnimator
end

--[=[
	Gets an existing animation track for the given id, or loads a new one onto the target's
	animator. Returns nil if the animation fails to load.

	@param target Animator | Player | Model | AnimationController
	@param id string | number
	@param priority Enum.AnimationPriority?
	@return AnimationTrack?
]=]
@checked
function AnimationUtils.getOrCreateAnimationTrack(
	target: Animator | Player | Model | AnimationController,
	id: string | number,
	priority: Enum.AnimationPriority?
): AnimationTrack?
	assert(typeof(target) == "Instance", "Bad target")
	assert(RbxAssetUtils.isConvertableToRbxAsset(id), "Bad id")
	assert(priority == nil or EnumUtils.isOfType(Enum.AnimationPriority, priority), "Bad priority")

	const animator = AnimationUtils.getOrCreateAnimator(target :: any)
	if not animator then
		return nil
	end

	assert(typeof(animator) == "Instance" and animator:IsA("Animator"), "Bad animator")

	const foundAnimationTrack = AnimationUtils.findAnimationTrackInAnimator(animator, id, priority)
	if foundAnimationTrack then
		return foundAnimationTrack
	end

	const animation = AnimationUtils.getOrCreateAnimationFromIdInAnimator(animator, id, priority)

	local animationTrack
	const ok, err = pcall(function()
		animationTrack = animator:LoadAnimation(animation)
	end)
	if not ok then
		warn(
			string.format(
				"[AnimationUtils] - Failed to load animation with id %q due to %q",
				tostring(id),
				tostring(err)
			)
		)
		return nil
	end

	if priority then
		animationTrack.Priority = priority
	end

	return animationTrack
end

--[=[
	Gets an existing animation instance for the given id parented to the animator, or
	creates and parents a new one.

	@param animator Animator
	@param id string | number
	@param priority Enum.AnimationPriority?
	@return Animation
]=]
@checked
function AnimationUtils.getOrCreateAnimationFromIdInAnimator(
	animator: Animator,
	id: string | number,
	priority: Enum.AnimationPriority?
): Animation
	assert(typeof(animator) == "Instance" and animator:IsA("Animator"), "Bad animator")
	assert(RbxAssetUtils.isConvertableToRbxAsset(id), "Bad id")
	assert(priority == nil or EnumUtils.isOfType(Enum.AnimationPriority, priority), "Bad priority")

	const animationId = RbxAssetUtils.toRbxAssetId(id)
	for _, animation in animator:GetChildren() do
		if animation:IsA("Animation") then
			if animation.AnimationId == animationId then
				return animation
			end
		end
	end

	const animation = AnimationUtils.createAnimationFromId(id)
	animation.Parent = animator

	return animation
end

--[=[
	Stops all currently playing animation tracks on the humanoid.

	@param humanoid Humanoid
	@param fadeTime number
]=]
@checked
function AnimationUtils.stopAnimations(humanoid: Humanoid, fadeTime: number)
	const animator = AnimationUtils.getOrCreateAnimator(humanoid)

	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(fadeTime)
	end
end

--[=[
	Stops the animation matching the given id on the target, if it is playing.

	@param target Animator | Player | Model | AnimationController
	@param id string | number
	@param fadeTime number?
	@return AnimationTrack?
]=]
@checked
function AnimationUtils.stopAnimation(
	target: Animator | Player | Model | AnimationController,
	id: string | number,
	fadeTime: number?
): AnimationTrack?
	assert(typeof(target) == "Instance", "Bad target")
	assert(RbxAssetUtils.isConvertableToRbxAsset(id), "Bad id")
	assert(type(fadeTime) == "number" or fadeTime == nil, "Bad fadeTime")

	const animationTrack = AnimationUtils.findAnimationTrack(target, id)

	if animationTrack then
		animationTrack:Stop(fadeTime)
	end

	return animationTrack
end

--[=[
	Returns whether the given track is currently playing on the humanoid.

	@param humanoid Humanoid
	@param track AnimationTrack
	@return boolean
]=]
@checked
function AnimationUtils.isPlayingAnimationTrack(humanoid: Humanoid, track: AnimationTrack): boolean
	const animator = AnimationUtils.getOrCreateAnimator(humanoid)

	for _, playingTrack in animator:GetPlayingAnimationTracks() do
		if playingTrack == track then
			return true
		end
	end

	return false
end

--[=[
	Returns whether an animation track matches the given id and, optionally, priority.

	@param animationTrack AnimationTrack
	@param id string | number
	@param priority Enum.AnimationPriority?
	@return boolean
]=]
@checked
function AnimationUtils.isMatchingAnimationTrack(
	animationTrack: AnimationTrack,
	id: string | number,
	priority: Enum.AnimationPriority?
): boolean
	assert(typeof(animationTrack) == "Instance" and animationTrack:IsA("AnimationTrack"), "Bad animationTrack")
	assert(RbxAssetUtils.isConvertableToRbxAsset(id), "Bad id")
	assert(priority == nil or EnumUtils.isOfType(Enum.AnimationPriority, priority), "Bad priority")

	const animation = animationTrack.Animation
	if not animation then
		return false
	end

	const animationId = RbxAssetUtils.toRbxAssetId(id)
	if animation.AnimationId ~= animationId then
		return false
	end

	if priority and animationTrack.Priority ~= priority then
		return false
	end

	return true
end

--[=[
	Finds a playing animation track matching the id and priority on the target.

	@param target Animator | Player | Model | AnimationController
	@param id string | number
	@param priority Enum.AnimationPriority?
	@return AnimationTrack?
]=]
@checked
function AnimationUtils.findAnimationTrack(
	target: Animator | Player | Model | AnimationController,
	id: string | number,
	priority: Enum.AnimationPriority?
): AnimationTrack?
	assert(typeof(target) == "Instance", "Bad target")
	assert(RbxAssetUtils.isConvertableToRbxAsset(id), "Bad id")
	assert(priority == nil or EnumUtils.isOfType(Enum.AnimationPriority, priority), "Bad priority")

	const animator = AnimationUtils.getOrCreateAnimator(target)
	if not animator then
		return nil
	end

	return AnimationUtils.findAnimationTrackInAnimator(animator, id, priority)
end

--[=[
	Finds a playing animation track matching the id and priority within a specific animator.

	@param animator Animator
	@param id string | number
	@param priority Enum.AnimationPriority?
	@return AnimationTrack?
]=]
@checked
function AnimationUtils.findAnimationTrackInAnimator(
	animator: Animator,
	id: string | number,
	priority: Enum.AnimationPriority?
): AnimationTrack?
	assert(typeof(animator) == "Instance" and animator:IsA("Animator"), "Bad animator")
	assert(RbxAssetUtils.isConvertableToRbxAsset(id), "Bad id")

	const animationId = RbxAssetUtils.toRbxAssetId(id)

	for _, animationTrack in animator:GetPlayingAnimationTracks() do
		if AnimationUtils.isMatchingAnimationTrack(animationTrack, animationId, priority) then
			return animationTrack
		end
	end

	return nil
end

--[=[
	Creates a non-archivable animation instance from the given id.

	@param id string | number
	@return Animation
]=]
@checked
function AnimationUtils.createAnimationFromId(id: string | number): Animation
	assert(RbxAssetUtils.isConvertableToRbxAsset(id), "Bad id")

	const animationId = RbxAssetUtils.toRbxAssetId(id)
	assert(type(animationId) == "string", "Bad id")

	const animation = Instance.new("Animation")
	animation.Name = AnimationUtils.getAnimationName(animationId)
	animation.AnimationId = animationId
	animation.Archivable = false

	return animation
end

--[=[
	Returns the conventional name used for an animation instance with the given id.

	@param animationId string
	@return string
]=]
@checked
function AnimationUtils.getAnimationName(animationId: string): string
	return string.format("Animation_%s", animationId)
end

return AnimationUtils
