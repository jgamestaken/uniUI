--░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░--
--░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░   ░   ░--
--▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒   ▒▒▒▒▒   ▒   ▒--
--▒   ▒▒   ▒   ▒   ▒▒▒▒▒▒▒   ▒▒▒▒▒   ▒   ▒--
--▓   ▓▓   ▓▓   ▓▓   ▓   ▓   ▓▓▓▓▓   ▓   ▓--
--▓   ▓▓   ▓▓   ▓▓   ▓   ▓   ▓▓▓▓▓   ▓   ▓--
--▓   ▓▓   ▓▓   ▓▓   ▓   ▓   ▓▓▓▓▓   ▓   ▓--
--███      █    ██   █   ███      ████   █--
--████████████████████████████████████████--



local VERSION = "4.0b3"
local LICENSE = "PLEASE REPLACE WITH YOUR PROJECT NAME" 

-- uniUI version 4.0b3
-- NOT COMPATIBLE WITH PREVIOUS VERSIONS
-- CODE-BASED UI LIBRARY


-- PUBLIC FUNCTION DIRECTORY:
-- |
-- |__ object
-- |    |
-- |    |__ new(type, base, properties, utp***) - Function to generate a new object.
-- |    |
-- |    |__ toggle_activation(object, toggle) - Whether to activate or deactivate the object for user input. This defaults to true with object.new().
-- |    |
-- |     \__ import(path, base, default*) - Function to import a Roblox object into the code-based module.
-- |
-- |__ base
-- |    |
-- |     \__ new(type, parent, properties) - Creates a new base to use.
-- |
-- |__ state
-- |    |
-- |    |__ all
-- |    |    |
-- |    |    |__ create(object, name, properties, utp***, set*, ap**) - Creates a new state for an object and all descendants.
-- |    |    |
-- |    |    |__ set(object, name, ap**) - Sets all descendants to that state.
-- |    |    |
-- |    |     \__ delete(object, name) - Removes a state from all descendants
-- |    |
-- |    |__ create(object, name, properties, utp***, set*, ap**) - Create a new state for an object.
-- |    |
-- |    |__ set(object, name, ap**) - Set the state of an object.
-- |    |
-- |     \__ delete(object, name) - Removes a state from an object.
-- |
--  \__ animate
--      |
--      |__ custom(object, properties, ap**) - Animates to a custom undefined state. Useful for loading bars and such.
--
-- * Optional property, not required for functioning.
-- ** Animation properties, {speed, easingstyle, easingdirection, repeatcount} 
-- *** Untweenable property list, not required for functioning, but can be useful when setting up.


local uniUI = {}

---- SET UP _G ----

_G["uniUI"] = {}

---- SETTINGS ----

uniUI.Settings = {
	D_SPEED = 1, -- Default animation speed.
	D_STYLE = Enum.EasingStyle.Cubic, -- Default animation style.
	D_DIRECTION = Enum.EasingDirection.InOut, -- Default animation direction
	D_REPEAT = 0, -- Default repeating count, for repeating animations. -1 is infinite.
}

---- SERVICES ----

uniUI._SERVICE = {
	TweenService = game:GetService("TweenService"),
	HttpService = game:GetService("HttpService")
}

---- _BU - Basic script requirements. ----

uniUI._BU = {}

function uniUI._BU.try(func, retry, t) -- Try to run something, but don't worry about exceptions!
	if uniUI.Settings.DEBUG == nil then
		if retry == nil then retry = true end
		if t == nil then t = 0 end
		local s, result = pcall(func)
		if s == true then
			return result
		else
			if t < 3 and retry == true then
				warn("[WARN] Function failed because of '"..tostring(result).."', retrying, count: "..tostring(t))
				return uniUI._BU.try(func, nil, t+1)
			else 
				warn("[WARN] Function failed because of '"..tostring(result).."'. Ignoring and continuing.")
				return nil
			end
		end
	else
		local r = func()
		return r
	end
end

function uniUI._BU.safevar(var, r) -- If a variable is left empty, set it to the replacement.
	if var == nil then return r else return var end
end

function uniUI._BU.log(text) -- Log something.
	uniUI._BU.try(function ()
		print("[LOG] "..tostring(text))
	end, false)
end

function uniUI._BU.warn(text) -- Warn about something.
	uniUI._BU.try(function ()
		warn("[WARN] "..tostring(text))
	end, false)
end

---- _UTP - Function to set untweenable properties to an object ----

uniUI._UTP = {}

function uniUI._UTP.set(object, properties) -- Set a list of untweenable properties to an object.
	properties = uniUI._BU.safevar(properties, {})
	uniUI._BU.try(function ()
		for i, v in pairs(properties) do
			object[i] = v
		end
	end)
end

---- _ANIM - Animation functions such as Tween ----

uniUI._ANIM = {}

function uniUI._ANIM.tweeninfo(ap) -- Create a new TweenInfo object with the right properties.
	ap = uniUI._BU.safevar(ap, {})
	return uniUI._BU.try(function ()
		local sp = uniUI._BU.safevar(ap[1], uniUI.Settings.D_SPEED)
		local es = uniUI._BU.safevar(ap[2], uniUI.Settings.D_STYLE)
		local ed = uniUI._BU.safevar(ap[3], uniUI.Settings.D_DIRECTION)
		local rc = uniUI._BU.safevar(ap[4], uniUI.Settings.D_REPEAT)
		return TweenInfo.new(sp, es, ed, rc)
	end)
end

function uniUI._ANIM.getanimation(object) -- See if an animation is running, and return it if it is.
	return uniUI._BU.try(function ()
		local uia = uniUI._OBJ.getvalue(object, "uniUI_ANIMATION")
		if uia ~= nil then
			return uia
		else
			return nil
		end
	end, false)
end

function uniUI._ANIM.cancelanimation(object)
	uniUI._BU.try(function ()
		if uniUI._ANIM.getanimation(object) ~= nil then
			uniUI._OBJ.getvalue(object, "uniUI_ANIMATION"):Cancel()
			uniUI._OBJ.setvalue(object, "uniUI_ANIMATION", nil)
		end
	end)
end

function uniUI._ANIM.setanimation(object, animation) -- Set the animation on an object, so that it can be cancelled.
	uniUI._BU.try(function ()
		uniUI._ANIM.cancelanimation(object) -- Cancel any animation currently running.
		
		uniUI._OBJ.setvalue(object, "uniUI_ANIMATION", animation)
	end)
end

function uniUI._ANIM.tween(object, properties, ap) -- Tween the object itself, has to check for activation first!
	properties = uniUI._BU.safevar(properties, {})
	uniUI._BU.try(function ()
		if object:GetAttribute("Active") == true then
			local tween = uniUI._SERVICE.TweenService:Create(object, uniUI._ANIM.tweeninfo(ap), properties)
			tween:Play()
			uniUI._ANIM.setanimation(object, tween)
		end
	end)
end

---- OBJ - Manages the object data storage ----

uniUI._OBJ = {}

function uniUI._OBJ.getvalue(object, name) -- Get a value from an object from a server-global database, using ID's.
	return uniUI._BU.try(function ()
		return _G["uniUI"][tostring(object:GetAttribute("ID"))][name]
	end, false)
end

function uniUI._OBJ.setvalue(object, name, value) -- Set a value to an object in a server-global database, using ID's.
	uniUI._BU.try(function ()
		if _G["uniUI"][tostring(object:GetAttribute("ID"))] == nil then _G["uniUI"][tostring(object:GetAttribute("ID"))] = {} end
		
		_G["uniUI"][tostring(object:GetAttribute("ID"))][name] = value
	end)
end

---- STATE - Manage states of an object ----

uniUI._STATE = {}

function uniUI._STATE.get(object, name) -- Get a state from an object.
	return uniUI._OBJ.getvalue(object, "uniUI_STATE_"..tostring(name)), uniUI._OBJ.getvalue(object, "uniUI_UTP_STATE_"..tostring(name))
end

function uniUI._STATE.create(object, name, properties, utp) -- Set the state of an object. THIS IS NOT STATE.SET, which is an animation command.
	uniUI._OBJ.setvalue(object, "uniUI_STATE_"..tostring(name), properties)
	uniUI._OBJ.setvalue(object, "uniUI_UTP_STATE_"..tostring(name), utp)
end

function uniUI._STATE.delete(object, name) -- Delete the state from an object.
	uniUI._OBJ.setvalue(object, "uniUI_STATE_"..tostring(name), nil)
	uniUI._OBJ.setvalue(object, "uniUI_UTP_STATE_"..tostring(name), nil)
end

---- STATE - Public commands ----

uniUI.state = {} -- Set state functions for one object.

function uniUI.state.set(object, name, ap) -- Set the state of a single object.
	uniUI._BU.try(function ()
		local properties, utp = uniUI._STATE.get(object, name)
		
		uniUI._ANIM.tween(object, properties, ap)
		uniUI._UTP.set(object, utp)
	end)
end

function uniUI.state.create(object, name, properties, utp, set, ap) -- Create a new state for an object, and possibly also animate it to it.
	utp = uniUI._BU.safevar(utp, {})

	uniUI._STATE.create(object, name, properties, utp)
	if set == true then
		uniUI.state.set(object, name, ap)
	end
end

function uniUI.state.delete(object, name) -- Delete the state of an object.
	uniUI._STATE.delete(object, name)
end

---- STATE.ALL ----

uniUI.state.all = {} -- Set state functions for all objects.

function uniUI.state.all.create(object, name, properties, utp, set, ap)
	uniUI._BU.try(function ()
		local descendants = object:GetDescendants()
		table.insert(descendants, object)
		for _, obj in descendants do
			uniUI.state.create(obj, name, properties, utp, set, ap)
		end
	end)
end

function uniUI.state.all.set(object, name, ap) -- Create a state for the object and all descendants.
	uniUI._BU.try(function ()
		local descendants = object:GetDescendants()
		table.insert(descendants, object)
		for _, obj in descendants do
			uniUI.state.set(obj, name, ap)
		end
	end)
end

function uniUI.state.all.delete(object, name) -- Delete a state for the object and all descendants.
	uniUI._BU.try(function ()
		local descendants = object:GetDescendants()
		table.insert(descendants, object)
		for _, obj in descendants do
			uniUI.state.delete(obj, name)
		end
	end)
end

---- OBJECT ---

uniUI.object = {}

function uniUI.object.new(objtype, base, properties, utp) -- Create a new object with a new default state.
	utp = uniUI._BU.safevar(utp, {})
	return uniUI._BU.try(function ()
		local newobj = Instance.new(objtype)
		newobj:SetAttribute("ID", uniUI._SERVICE.HttpService:GenerateGUID(false))
		newobj.Parent = base
		uniUI.object.toggle_activation(newobj, true)
		uniUI.state.create(newobj, "DEFAULT", properties, utp, true, {0})
		
		return newobj
	end)
end

function uniUI.object.toggle_activation(object, toggle) --
	uniUI._BU.try(function ()
		local descendants = object:GetDescendants()
		table.insert(descendants, object)
		for _, obj in descendants do
			obj:SetAttribute("Active", toggle)
			uniUI._BU.try(function () obj.Active = toggle end, false)
		end
	end)
end

function uniUI.object.import(path, base) -- Clones and imports an object from an existing instance.
	return uniUI._BU.try(function ()
		local obj = path:Clone()
		obj.Parent = base
		uniUI.object.toggle_activation(obj, true)
		obj:SetAttribute("ID", uniUI._SERVICE.HttpService:GenerateGUID(false))
		uniUI.state.create(obj, "DEFAULT", {}, {}, false, {0})
		return obj
	end)
end

---- BASE ----

uniUI.base = {}

function uniUI.base.new(basetype, parent, properties) -- New function, better compatibility
	return uniUI._BU.try(function () 
		if table.find({"ScreenGui", "SurfaceGui", "BillboardGui"}, basetype) then
			local base = Instance.new(basetype)
			uniUI._UTP.set(base, properties)
			base.Parent = parent
			return base
		end
	end)
end

---- ANIMATE ----

uniUI.animate = {}

function uniUI.animate.custom(object, properties, ap)
	uniUI._ANIM.tween(object, properties, ap)
end


---- DEPRECATED FUNCTIONS ----

function uniUI.state.setall(object, name, ap) -- Deprecated, will be removed at 04/09/2025, replaced by state.all.set
	uniUI._BU.warn("'uniUI.state.setall' has been deprecated, please use 'uniUI.state.all.set' instead.")
	uniUI._BU.try(function ()
		local descendants = object:GetDescendants()
		table.insert(descendants, object)
		for _, obj in descendants do
			uniUI.state.set(obj, name, ap)
		end
	end)
end

function uniUI.base.ScreenGui(parent, ignoreguiinset) -- Deprecated, to be removed 04/09/2025, replaced by base.new
	uniUI._BU.warn("'uniUI.base.ScreenGui' has been deprecated, please use 'base.new' instead.")
	return uniUI._BU.try(function ()
		local gui = Instance.new("ScreenGui")
		gui.IgnoreGuiInset = ignoreguiinset
		gui.Parent = parent
		return gui
	end)
end

function uniUI.base.SurfaceGui(parent, face) -- Deprecated, to be removed 04/09/2025, replaced by base.new
	uniUI._BU.warn("'uniUI.base.SurfaceGui' has been deprecated, please use 'base.new' instead.")
	return uniUI._BU.try(function ()
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.Parent = parent
		return gui
	end)
end

function uniUI.base.BillboardGui(parent, maxdistance) -- Deprecated, to be removed 04/09/2025, replaced by base.new
	uniUI._BU.warn("'uniUI.base.BillboardGui' has been deprecated, please use 'base.new' instead.")
	return uniUI._BU.try(function ()
		local gui = Instance.new("BillboardGui")
		gui.MaxDistance = maxdistance
		return gui
	end)
end

---- MODULE RETURN. ----

uniUI._BU.log("Finished loading uniUI "..VERSION..". This copy was licensed by "..LICENSE..".")

return uniUI
