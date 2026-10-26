--!strict
-- Applies property tables to instances: tweenable values are tweened,
-- everything else (strings, booleans, enums, instances...) is set instantly.

local TweenService = game:GetService("TweenService")

local Types = require(script.Parent.Types)

type Props = Types.Props
type AnimOptions = Types.AnimOptions

local Animation = {}

Animation.defaults = {
	time = 0.25,
	style = Enum.EasingStyle.Quad,
	direction = Enum.EasingDirection.Out,
	repeats = 0,
	reverses = false,
	delay = 0,
}

-- Value types TweenService can interpolate. Booleans are deliberately left out:
-- a tweened boolean only flips at the end, which is rarely what UI code wants.
local TWEENABLE: { [string]: boolean } = {
	number = true,
	CFrame = true,
	Rect = true,
	Color3 = true,
	UDim = true,
	UDim2 = true,
	Vector2 = true,
	Vector2int16 = true,
	Vector3 = true,
}

function Animation.isTweenable(value: any): boolean
	return TWEENABLE[typeof(value)] == true
end

function Animation.info(options: AnimOptions?): TweenInfo
	local o: AnimOptions = options or {}
	local d = Animation.defaults
	return TweenInfo.new(
		if o.time ~= nil then o.time else d.time,
		o.style or d.style,
		o.direction or d.direction,
		if o.repeats ~= nil then o.repeats else d.repeats,
		if o.reverses ~= nil then o.reverses else d.reverses,
		if o.delay ~= nil then o.delay else d.delay
	)
end

-- Sets one property, turning Roblox's error into a readable one.
function Animation.setProperty(instance: Instance, key: string, value: any)
	local ok, err = pcall(function()
		(instance :: any)[key] = value
	end)
	if not ok then
		error(`uniUI: couldn't set {instance.ClassName}.{key}: {err}`, 3)
	end
end

-- Reads one property, or errors if the instance doesn't have it.
function Animation.getProperty(instance: Instance, key: string): any
	local ok, value = pcall(function()
		return (instance :: any)[key]
	end)
	if not ok then
		error(`uniUI: {instance.ClassName} has no property "{key}"`, 3)
	end
	return value
end

-- Applies props to an instance. Returns the playing Tween, or nil if
-- everything was set instantly.
function Animation.apply(instance: Instance, props: Props, options: AnimOptions?): Tween?
	local info = Animation.info(options)
	local tweened: Props = {}
	local hasTween = false

	for key, value in props do
		if info.Time > 0 and Animation.isTweenable(value) then
			tweened[key] = value
			hasTween = true
		else
			Animation.setProperty(instance, key, value)
		end
	end

	if not hasTween then
		return nil
	end

	local tween = TweenService:Create(instance, info, tweened)
	tween:Play()
	return tween
end

return Animation
