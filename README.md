# uniUI

A small, script-based UI library for Roblox. Build UI in code, give objects named **states**, and animate between them with one call.

```lua
local uniUI = require(game.ReplicatedStorage.uniUI)

local gui = uniUI.base("ScreenGui", game.Players.LocalPlayer.PlayerGui)

local button = gui:child("TextButton", {
	Size = UDim2.fromOffset(200, 50),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	TextColor3 = Color3.new(1, 1, 1),
	Text = "Play",
})

button
	:state("hover", { BackgroundColor3 = Color3.fromRGB(70, 70, 70) })
	:state("pressed", { Size = UDim2.fromOffset(190, 46) })
	:hover("hover")

button:on("Activated", function()
	button:set("pressed", { time = 0.08 }):await():set("hover", { time = 0.08 })
end)
```

## Installing

**Copy and paste:** create a ModuleScript named `uniUI` in ReplicatedStorage and paste in [`dist/uniUI.luau`](dist/uniUI.luau).

**Wally:** add `uniUI = "jgamestaken/uniui@5.0.0"` to your `[dependencies]`.

**Rojo:** the library lives in `src/`; `default.project.json` builds it as a single `uniUI` ModuleScript.

## Concepts

- **Handle:** every object uniUI creates or wraps is returned as a handle. The Roblox instance is at `handle.instance`. Most handle methods return the handle, so calls can be chained.
- **States:** a named set of properties. Each handle starts with a `"default"` state made from the properties it was created with. When you define another state, any property it touches that isn't in `"default"` yet is captured from the object's current value, so `set("default")` always gets you back to the original look.
- **Animation:** numbers, colors, UDim2s, vectors and CFrames are tweened. Everything else (text, booleans, enums, images, instances) is set instantly. A `time` of `0` sets everything instantly.

## API

### Module

| Function | Returns | Description |
|---|---|---|
| `uniUI.base(className, parent?, props?)` | Handle | Creates a `ScreenGui`, `SurfaceGui` or `BillboardGui`. ScreenGuis default to `ResetOnSpawn = false`. |
| `uniUI.new(className, parent?, props?)` | Handle | Creates any UI object. `parent` can be an Instance or a handle. |
| `uniUI.wrap(instance)` | Handle | Gets or creates a handle for an existing instance. |
| `uniUI.clone(template, parent?, props?)` | Handle | Clones a template (for example one built in Studio) and wraps it. |
| `uniUI.get(instance)` | Handle? | The instance's handle, if it has one. |
| `uniUI.configure(options)` | — | Changes the default animation options. |
| `uniUI.version` | string | The library version. |

### Handle

| Method | Description |
|---|---|
| `:state(name, props)` | Defines a state, or adds properties to an existing one. |
| `:set(name, options?)` | Animates to a state. |
| `:setAll(name, options?)` | Animates this handle and every descendant handle that has the state. |
| `:has(name)` | Whether the state exists. |
| `:removeState(name)` | Removes a state (not `"default"` or the current one). |
| `:animate(props, options?)` | Animates to arbitrary properties without changing the current state. |
| `:await()` | Yields until the running animation finishes. |
| `:stop()` | Stops the running animation where it is. |
| `:hover(name, options?)` | Shows a state while the mouse is over the object. |
| `:on(event, callback)` | Connects to an event; the connection is cleaned up with the handle. |
| `:active(enabled)` | Turns input on or off for the object and its descendants. |
| `:child(className, props?)` | Creates a child object and returns its handle. |
| `:destroy()` | Destroys the object and everything the handle owns. |

`handle.current` is the name of the current state, and `handle.tween` is the running Tween, if any.

### Animation options

Every field is optional and falls back to `uniUI.defaults`.

| Field | Default | Description |
|---|---|---|
| `time` | `0.25` | Seconds. `0` is instant. |
| `style` | `Enum.EasingStyle.Quad` | Easing style. |
| `direction` | `Enum.EasingDirection.Out` | Easing direction. |
| `repeats` | `0` | Extra repeats; `-1` repeats forever. |
| `reverses` | `false` | Play backwards after each run. |
| `delay` | `0` | Seconds before the tween starts. Instant properties aren't delayed. |

## Upgrading from 4.x

5.0 is a rewrite with a new API. See the [changelog](CHANGELOG.md) for how old calls map to new ones.
