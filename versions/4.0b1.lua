--░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░--
--░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░   ░   ░--
--▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒   ▒▒▒▒▒   ▒   ▒--
--▒   ▒▒   ▒   ▒   ▒▒▒▒▒▒▒   ▒▒▒▒▒   ▒   ▒--
--▓   ▓▓   ▓▓   ▓▓   ▓   ▓   ▓▓▓▓▓   ▓   ▓--
--▓   ▓▓   ▓▓   ▓▓   ▓   ▓   ▓▓▓▓▓   ▓   ▓--
--▓   ▓▓   ▓▓   ▓▓   ▓   ▓   ▓▓▓▓▓   ▓   ▓--
--███      █    ██   █   ███      ████   █--
--████████████████████████████████████████--



local VERSION = "4.0b"
local LICENSE = "Development"

-- uniUI version 4.0
-- NOT COMPATIBLE WITH PREVIOUS VERSIONS
-- CODE-BASED UI LIBRARY


-- PUBLIC FUNCTION DIRECTORY:
-- |
-- |__ object
-- |    |
-- |    |__ new(type, base, default) - Function to generate a new object.
-- |    |
-- |    |__ toggle_activation(object, toggle) - Whether to activate or deactivate the object for user input. This defaults to true with object.new().
-- |    |
-- |     \__ import(path, base, default*) - Function to import a Roblox object into the code-based module.
-- |
-- |__ base
-- |    |
-- |    |__ ScreenGui(parent, ignoreguiinset*) - Creates a new ScreenGui to build on!
-- |    |
-- |    |__ BillboardGui(parent, maxdistance) - Creates a new BillboardGui to build on, this is work in progress and some values may need to be edited manually.
-- |    |
-- |     \__ SurfaceGui(parent, face*) - Creates a new SurfaceGui to build on!
-- |
-- |__ state
-- |    |
-- |    |__ create(object, name, properties, set*, ap**) - Create a new state for an object.
-- |    |
-- |    |__ set(object, name, ap**) - Set the state of an object.
-- |    |
-- |    |__ setall(object, name, ap**) - Set the state of that object and all descendants.
-- |    |
-- |     \__ delete(object, name) - Removes a state from an object.
-- |    
-- |__ json - NOT FINISHED YET, PROJECTED FOR 4.1.0.
-- |    |
-- |    |__ import(parent, json) - Decode a json UI page, examples can be found on the Discord documentation section.
-- |    |
-- |     \__ decode_import(parent, json) - Decode a json UI object, this is NOT a page.
-- |
--  \__ animate
--      |
--      |__ custom(object, properties, ap**) - Animates to a custom undefined state. Useful for loading bars and such.
--
-- * Optional property, not required for functioning.
-- ** Animation properties, {speed, easingstyle, easingdirection, repeatcount} 


local uniUI = {}

---- SET UP _G ----

_G["uniUI"] = {}

---- SETTINGS ----

uniUI.Settings = {
	D_SPEED = 1, -- Default animation speed.
	D_STYLE = Enum.EasingStyle.Cubic, -- Default animation style.
	D_DIRECTION = Enum.EasingDirection.InOut, -- Default animation direction
	D_REPEAT = 0 -- Default repeating count, for repeating animations. -1 is infinite.
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
	uniUI._BU.try(function ()
		if object.Active == true then
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
	return uniUI._BU.try(function ()
		return uniUI._OBJ.getvalue(object, "uniUI_STATE_"..tostring(name))
	end)
end

function uniUI._STATE.create(object, name, properties) -- Set the state of an object. THIS IS NOT STATE.SET, which is an animation command.
	uniUI._BU.try(function ()
		uniUI._OBJ.setvalue(object, "uniUI_STATE_"..tostring(name), properties)
	end)
end

function uniUI._STATE.delete(object, name) -- Delete the state from an object.
	uniUI._BU.try(function ()
		uniUI._OBJ.setvalue(object, "uniUI_STATE_"..tostring(name), nil)
	end)
end

---- STATE - Public commands ----

uniUI.state = {}

function uniUI.state.set(object, name, ap) -- Set the state of a single object.
	uniUI._BU.try(function ()
		local properties = uniUI._STATE.get(object, name)
		
		uniUI._ANIM.tween(object, properties, ap)
	end)
end

function uniUI.state.setall(object, name, ap) -- Set the state of the object and all descendants.
	uniUI._BU.try(function ()
		local descendants = object:GetDescendants()
		table.insert(descendants, object)
		for _, obj in descendants do
			uniUI.state.set(obj, name, ap)
		end
	end)
end

function uniUI.state.create(object, name, properties, set, ap) -- Create a new state for an object, and possibly also animate it to it.
	uniUI._STATE.create(object, name, properties)
	if set == true then
		uniUI.state.set(object, name, ap)
	end
end

function uniUI.state.delete(object, name) -- Delete the state of an object.
	uniUI.state.delete(object, name)
end

---- OBJECT ---

uniUI.object = {}

function uniUI.object.new(objtype, base, properties) -- Create a new object with a new default state.
	return uniUI._BU.try(function ()
		local newobj = Instance.new(objtype)
		newobj:SetAttribute("ID", uniUI._SERVICE.HttpService:GenerateGUID(false))
		newobj.Parent = base
		newobj.Active = true
		uniUI.state.create(newobj, "DEFAULT", properties)
		
		uniUI.state.set(newobj, "DEFAULT", {0})
		
		return newobj
	end)
end

function uniUI.object.toggle_activation(object, toggle) --
	uniUI._BU.try(function ()
		local descendants = object:GetDescendants()
		table.insert(descendants, object)
		for _, obj in descendants do
			obj.Active = toggle
		end
	end)
end

function uniUI.object.import(path, base) -- Clones and imports an object from an existing instance.
	return uniUI._BU.try(function ()
		local obj = path:Clone()
		obj.Parent = base
		obj:SetAttribute("ID", uniUI._SERVICE.HttpService:GenerateGUID(false))
		return obj
	end)
end

---- BASE ----

uniUI.base = {}

function uniUI.base.ScreenGui(parent, ignoreguiinset)
	return uniUI._BU.try(function ()
		local gui = Instance.new("ScreenGui")
		gui.IgnoreGuiInset = ignoreguiinset
		gui.Parent = parent
		return gui
	end)
end

function uniUI.base.SurfaceGui(parent, face)
	return uniUI._BU.try(function ()
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.Parent = parent
		return gui
	end)
end

function uniUI.base.BillboardGui(parent, maxdistance)
	return uniUI._BU.try(function ()
		local gui = Instance.new("BillboardGui")
		gui.MaxDistance = maxdistance
	end)
end

---- ANIMATE ----

uniUI.animate = {}

function uniUI.animate.custom(object, properties, ap)
	uniUI._ANIM.tween(object, properties, ap)
end

---- MODULE RETURN. ----

uniUI._BU.log("Finished loading uniUI "..VERSION..". This copy was licensed by "..LICENSE..".")

return uniUI
