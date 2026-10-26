--!strict
-- A Handle wraps one Instance and owns its states, its running tween and any
-- event connections made through it. Everything is cleaned up when the
-- instance is destroyed.

local Animation = require(script.Parent.Animation)
local Registry = require(script.Parent.Registry)
local Types = require(script.Parent.Types)

type Props = Types.Props
type AnimOptions = Types.AnimOptions

local DEFAULT = "default"

local Handle = {}
Handle.__index = Handle

type HandleData = {
	instance: Instance,
	current: string,
	tween: Tween?,
	_states: { [string]: Props },
	_connections: { RBXScriptConnection },
	_destroyed: boolean,
}

export type Handle = typeof(setmetatable({} :: HandleData, Handle))

local function assertAlive(self: Handle, method: string)
	if self._destroyed then
		error(`uniUI: can't call :{method}() on a destroyed handle`, 3)
	end
end

-- Wraps an existing instance. `initial` becomes the "default" state.
-- Prefer uniUI.new / uniUI.wrap over calling this directly.
function Handle.new(instance: Instance, initial: Props?): Handle
	local self = setmetatable({
		instance = instance,
		current = DEFAULT,
		tween = nil,
		_states = { [DEFAULT] = table.clone(initial or {}) },
		_connections = {},
		_destroyed = false,
	} :: HandleData, Handle)

	table.insert(
		self._connections,
		instance.Destroying:Connect(function()
			self:_cleanup()
		end)
	)
	Registry.set(instance, self)
	return self
end

-- Creates a new instance, applies props instantly, then parents it.
function Handle.create(className: string, parent: Instance?, props: Props?): Handle
	local ok, instance = pcall(Instance.new, className)
	if not ok then
		error(`uniUI: "{className}" isn't a class that can be created`, 3)
	end

	local initial = props or {}
	for key, value in initial do
		Animation.setProperty(instance, key, value)
	end
	instance.Parent = parent

	return Handle.new(instance, initial)
end

---- States ----

-- Defines a state, or adds properties to an existing one.
-- Any property not already in "default" has its current value captured there,
-- so set("default") always restores the original look.
function Handle.state(self: Handle, name: string, props: Props): Handle
	assertAlive(self, "state")
	assert(type(name) == "string", "uniUI: state name must be a string")
	assert(type(props) == "table", "uniUI: state properties must be a table")

	local default = self._states[DEFAULT]
	if name ~= DEFAULT then
		for key in props do
			if default[key] == nil then
				default[key] = Animation.getProperty(self.instance, key)
			end
		end
	end

	local existing = self._states[name]
	if existing then
		for key, value in props do
			existing[key] = value
		end
	else
		self._states[name] = table.clone(props)
	end
	return self
end

function Handle.has(self: Handle, name: string): boolean
	return self._states[name] ~= nil
end

-- Removes a state. "default" and the current state can't be removed.
function Handle.removeState(self: Handle, name: string): Handle
	assertAlive(self, "removeState")
	if name == DEFAULT then
		error('uniUI: the "default" state can\'t be removed', 2)
	end
	if name == self.current then
		error(`uniUI: "{name}" is the current state; switch to another state before removing it`, 2)
	end
	self._states[name] = nil
	return self
end

-- Animates to a state.
function Handle.set(self: Handle, name: string, options: AnimOptions?): Handle
	assertAlive(self, "set")
	local props = self._states[name]
	if not props then
		error(`uniUI: unknown state "{name}" on {self.instance:GetFullName()}`, 2)
	end
	self:_play(props, options)
	self.current = name
	return self
end

-- Animates this handle and every descendant handle that has the state.
function Handle.setAll(self: Handle, name: string, options: AnimOptions?): Handle
	assertAlive(self, "setAll")
	if self:has(name) then
		self:set(name, options)
	end
	for _, descendant in self.instance:GetDescendants() do
		local handle = Registry.get(descendant)
		if handle and handle:has(name) then
			handle:set(name, options)
		end
	end
	return self
end

---- Animation ----

-- Animates to arbitrary properties without changing the current state.
-- Useful for progress bars and one-off effects.
function Handle.animate(self: Handle, props: Props, options: AnimOptions?): Handle
	assertAlive(self, "animate")
	self:_play(props, options)
	return self
end

-- Yields until the running tween (if any) finishes.
function Handle.await(self: Handle): Handle
	local tween = self.tween
	if tween then
		local state = tween.PlaybackState
		if
			state == Enum.PlaybackState.Begin
			or state == Enum.PlaybackState.Delayed
			or state == Enum.PlaybackState.Playing
		then
			tween.Completed:Wait()
		end
	end
	return self
end

-- Stops the running tween where it is.
function Handle.stop(self: Handle): Handle
	local tween = self.tween
	if tween then
		self.tween = nil
		tween:Cancel()
	end
	return self
end

---- Events and input ----

-- Connects to an event on the instance. The connection is cleaned up with the handle.
function Handle.on(self: Handle, event: string, callback: (...any) -> ()): RBXScriptConnection
	assertAlive(self, "on")
	local ok, signal = pcall(function()
		return (self.instance :: any)[event]
	end)
	if not ok or typeof(signal) ~= "RBXScriptSignal" then
		error(`uniUI: {self.instance.ClassName} has no event "{event}"`, 2)
	end
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

-- Switches to `name` while the mouse is over the instance, then back to
-- whatever state was showing before.
function Handle.hover(self: Handle, name: string, options: AnimOptions?): Handle
	assertAlive(self, "hover")
	if not self:has(name) then
		error(`uniUI: unknown state "{name}" on {self.instance:GetFullName()}`, 2)
	end

	local previous = DEFAULT
	self:on("MouseEnter", function()
		if self.current ~= name then
			previous = self.current
			self:set(name, options)
		end
	end)
	self:on("MouseLeave", function()
		if self.current == name then
			self:set(if self:has(previous) then previous else DEFAULT, options)
		end
	end)
	return self
end

-- Turns user input on or off for this object and its descendants.
function Handle.active(self: Handle, enabled: boolean): Handle
	assertAlive(self, "active")
	local instance = self.instance
	if instance:IsA("GuiObject") then
		instance.Active = enabled
		-- Interactable also blocks input to descendants.
		pcall(function()
			(instance :: any).Interactable = enabled
		end)
	end
	return self
end

---- Building ----

-- Creates a child object and returns its handle, so trees can be built inline.
function Handle.child(self: Handle, className: string, props: Props?): Handle
	assertAlive(self, "child")
	return Handle.create(className, self.instance, props)
end

-- Destroys the instance and everything the handle owns.
function Handle.destroy(self: Handle)
	if self._destroyed then
		return
	end
	local instance = self.instance
	self:_cleanup()
	instance:Destroy()
end

---- Internal ----

function Handle._play(self: Handle, props: Props, options: AnimOptions?)
	self:stop()
	local tween = Animation.apply(self.instance, props, options)
	self.tween = tween
	if tween then
		tween.Completed:Once(function()
			if self.tween == tween then
				self.tween = nil
			end
		end)
	end
end

function Handle._cleanup(self: Handle)
	if self._destroyed then
		return
	end
	self._destroyed = true
	self:stop()
	for _, connection in self._connections do
		connection:Disconnect()
	end
	table.clear(self._connections)
	Registry.remove(self.instance)
end

return Handle
