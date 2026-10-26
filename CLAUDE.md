# uniUI

A script-based UI library for Roblox, written in typed Luau. Version 5 is a ground-up rewrite (the 4.x code was removed); see CHANGELOG.md for the old-to-new API map.

## Layout

- `src/init.luau`: public module (`uniUI.base`, `new`, `wrap`, `clone`, `get`, `configure`). Holds `VERSION`.
- `src/Handle.luau`: the Handle class (states, `set`/`setAll`, `animate`, `hover`, `on`, `active`, `child`, `destroy`) and cleanup.
- `src/Animation.luau`: defaults, TweenInfo building, splitting tweenable vs instant props, property get/set with readable errors.
- `src/Registry.luau`: Instance → Handle map, cleared on `Destroying`.
- `src/Types.luau`: `AnimOptions`, `Props`.
- `tools/bundle.py`: builds `dist/uniUI.luau`, the single-file copy-paste build. Committed; regenerate after any change in `src/`.

## Commands

- Build the bundle: `python3 tools/bundle.py` (CI runs `--check` and fails if it's stale)
- Format: `stylua src`
- Lint: `selene src`
- Type check: `luau-analyze src` (needs a Roblox type definitions file, e.g. via luau-lsp)
- Toolchain is pinned in `rokit.toml`.

## Conventions

- Every source file starts with `--!strict`. Tabs, double quotes, 100 columns (`stylua.toml`).
- Modules require siblings with `require(script.Parent.X)` (or `require(script.X)` from init). The bundler rewrites exactly those two forms, so don't use other require styles.
- Errors are raised, never swallowed. Messages start with `uniUI:` and say what went wrong in plain words.
- Handle methods that change things return `self` so they chain.
- Bump `VERSION` in `src/init.luau` and `version` in `wally.toml` together, and add a CHANGELOG entry.

## Not done yet

- **Nothing has been run yet.** The code was written without a Luau toolchain. First step: run `luau-analyze`, StyLua and selene, fix what they find, then try it in Studio.
- **Tests.** Write unit tests that run outside Roblox with a small mock of Instance, TweenService and Enum (no Roblox tests exist yet), plus a Studio test place.
- **CI:** `.github/workflows/ci.yml` only checks the bundle; add StyLua, selene and the tests.
- **Bundle types:** the bundle uses `--!nocheck` and downgrades `export type` to local types. Hoisting the public types to the top of `dist/uniUI.luau` would give paste-install users autocomplete.
- **Docs site:** the old GitHub Pages site was removed with the 4.x code. README.md is the documentation for now.
- **Release:** the repo has no license file yet (needed before publishing to Wally). Then publish to Wally and attach `dist/uniUI.luau` to a GitHub release.
