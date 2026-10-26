--!strict
-- Shared types for uniUI.

-- Animation options. Anything left out falls back to uniUI.defaults.
export type AnimOptions = {
	time: number?, -- Seconds. 0 applies the change instantly.
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?,
	repeats: number?, -- -1 repeats forever.
	reverses: boolean?,
	delay: number?, -- Seconds before a tween starts. Instant properties are not delayed.
}

-- A property table, e.g. { BackgroundColor3 = Color3.new(1, 0, 0), Text = "Hi" }.
export type Props = { [string]: any }

return {}
