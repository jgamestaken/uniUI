# Changelog

## 5.0.0 — unreleased

A full rewrite. The 4.x API is gone; the table below shows where everything went.

### Changes

- **Handles:** objects are returned as handles with chainable methods instead of passing instances to module functions.
- **No untweenable property lists:** values are sorted automatically. Tweenable types animate, everything else is set instantly.
- **Readable errors:** bad class names, properties, states or events raise a clear error instead of being retried and silently ignored.
- **No leaks:** state lives in a registry cleared when an instance is destroyed, replacing the old `_G` table that was never cleaned.
- **Restorable defaults:** defining a state captures the original value of every property it touches, so `set("default")` always works.
- **New:** `hover`, `on`, `await`, `stop`, `child`, `destroy`, `uniUI.clone`, `uniUI.get`, `uniUI.configure`.
- **Animation options** are a named table (`{ time = 0.3 }`) instead of a positional `{speed, style, direction, repeat}` list.
- **Animations always play.** In 4.x, animations were skipped on objects marked inactive.
- Typed Luau source with Rojo and Wally support, plus a single-file build in `dist/`.

### Migrating from 4.x

| 4.x | 5.0 |
|---|---|
| `uniUI.base.new("ScreenGui", parent, props)` | `uniUI.base("ScreenGui", parent, props)` |
| `uniUI.object.new(type, base, props, utp)` | `uniUI.new(type, base, props)` (merge `utp` into `props`) |
| `uniUI.object.import(path, base)` | `uniUI.clone(path, base)` |
| `uniUI.object.toggle_activation(obj, on)` | `handle:active(on)` |
| `uniUI.state.create(obj, name, props, utp, set, ap)` | `handle:state(name, props)` then `handle:set(name, options)` |
| `uniUI.state.set(obj, name, ap)` | `handle:set(name, options)` |
| `uniUI.state.delete(obj, name)` | `handle:removeState(name)` |
| `uniUI.state.all.set(obj, name, ap)` | `handle:setAll(name, options)` |
| `uniUI.state.all.create` / `.delete` | Define states on each child's handle |
| `uniUI.animate.custom(obj, props, ap)` | `handle:animate(props, options)` |
| `uniUI.Settings.D_SPEED` etc. | `uniUI.configure({ time = ..., style = ..., direction = ..., repeats = ... })` |
| `ap = {1, style, dir, 0}` | `{ time = 1, style = style, direction = dir, repeats = 0 }` |
| `"DEFAULT"` state | `"default"` |
