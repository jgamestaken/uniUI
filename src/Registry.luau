--!strict
-- Maps instances to their uniUI handles.
--
-- Entries are removed when the instance is destroyed (via its Destroying
-- event, hooked up in Handle.new). An instance that is unparented but never
-- destroyed keeps its entry, the same as any other Roblox reference.

local Registry = {}

local handles: { [Instance]: any } = {}

function Registry.get(instance: Instance): any
	return handles[instance]
end

function Registry.set(instance: Instance, handle: any)
	handles[instance] = handle
end

function Registry.remove(instance: Instance)
	handles[instance] = nil
end

return Registry
