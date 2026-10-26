--!strict
-- uniUI 5 — a small, script-based UI library for Roblox.
-- https://github.com/jgamestaken/uniUI

local Animation = require(script.Animation)
local Handle = require(script.Handle)
local Registry = require(script.Registry)
local Types = require(script.Types)

export type Handle = Handle.Handle
export type AnimOptions = Types.AnimOptions
export type Props = Types.Props

type Parent = Instance | Handle

local VERSION = "5.0.0"

local BASE_CLASSES: { [string]: boolean } = {
	ScreenGui = true,
	SurfaceGui = true,
	BillboardGui = true,
}

local function resolveParent(parent: Parent?): Instance?
	if parent == nil then
		return nil
	elseif typeof(parent) == "Instance" then
		return parent
	elseif type(parent) == "table" and typeof((parent :: any).instance) == "Instance" then
		return (parent :: Handle).instance
	end
	error("uniUI: parent must be an Instance, a uniUI handle, or nil", 3)
end

local uniUI = {
	version = VERSION,
	-- Default animation options. Change them with uniUI.configure.
	defaults = Animation.defaults,
}

-- Creates a ScreenGui, SurfaceGui or BillboardGui.
-- ScreenGuis default to ResetOnSpawn = false.
function uniUI.base(className: string, parent: Parent?, props: Props?): Handle
	if not BASE_CLASSES[className] then
		error(`uniUI.base: expected ScreenGui, SurfaceGui or BillboardGui, got "{className}"`, 2)
	end
	local initial = table.clone(props or {})
	if className == "ScreenGui" and initial.ResetOnSpawn == nil then
		initial.ResetOnSpawn = false
	end
	return Handle.create(className, resolveParent(parent), initial)
end

-- Creates a new UI object. Its starting props become its "default" state.
function uniUI.new(className: string, parent: Parent?, props: Props?): Handle
	return Handle.create(className, resolveParent(parent), props)
end

-- Returns the handle for an existing instance, creating one if needed.
-- Its "default" state fills in as other states are defined.
function uniUI.wrap(instance: Instance): Handle
	return Registry.get(instance) or Handle.new(instance)
end

-- Clones a template (e.g. one built in Studio), applies props and returns its handle.
function uniUI.clone(template: Instance, parent: Parent?, props: Props?): Handle
	local instance = template:Clone()
	local initial = props or {}
	for key, value in initial do
		Animation.setProperty(instance, key, value)
	end
	instance.Parent = resolveParent(parent)
	return Handle.new(instance, initial)
end

-- Returns the handle for an instance, or nil if it has none.
function uniUI.get(instance: Instance): Handle?
	return Registry.get(instance)
end

-- Changes the default animation options, e.g. uniUI.configure({ time = 0.4 }).
function uniUI.configure(options: AnimOptions)
	for key, value in options :: { [string]: any } do
		if (Animation.defaults :: any)[key] == nil then
			error(`uniUI.configure: unknown option "{key}"`, 2)
		end
		(Animation.defaults :: any)[key] = value
	end
end

return uniUI
