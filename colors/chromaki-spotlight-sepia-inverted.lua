-- colors/chromaki-spotlight-sepia-inverted.lua
-- Opaque spotlight scheme: the ACTIVE window is chromaki-sepia, while every
-- INACTIVE window is rendered as the real chromaki-dark colorscheme (full
-- syntax colors, dark background). No transparency -- both sides paint their
-- own background. Keep the palette/highlights in sync with
-- colors/chromaki-sepia.lua (active) and colors/chromaki-dark.lua (donor).
--
-- The inactive look is done per-window by lua/chromaki/spotlight.lua via
-- highlight namespaces: chromaki-dark is loaded once below, its highlights
-- are snapshotted into the capture namespace, and then chromaki-sepia is
-- applied as the global scheme.

local chromaki = require("chromaki")
local spotlight = require("chromaki.spotlight")

-- Snapshot chromaki-dark into the inactive-window namespace. This must run
-- BEFORE chromaki.apply() below repaints the global scheme.
spotlight.capture("chromaki-dark")

chromaki.apply({
	name = "chromaki-spotlight-sepia-inverted",
	flavour = "latte",
	background = "light",
	palette = {
		rosewater = "#d8b59b",
		flamingo = "#c79282",
		pink = "#b35b80",
		mauve = "#8b5d8c",
		red = "#9a2f1b",
		maroon = "#6b2014",
		peach = "#c2691b",
		yellow = "#b08926",
		green = "#4c6b3c",
		teal = "#3f6f63",
		sky = "#4b7b88",
		sapphire = "#2f5876",
		blue = "#294a78",
		lavender = "#555c99",
		text = "#000000",
		subtext1 = "#1f1606",
		subtext0 = "#342412",
		overlay2 = "#5c4320",
		overlay1 = "#72532a",
		overlay0 = "#876336",
		surface2 = "#9a7443",
		surface1 = "#ad8551",
		surface0 = "#e8cc81",
		base = "#f4e7c3",
		mantle = "#ecd9aa",
		crust = "#e3cfa0",
	},
	custom_highlights = function(colors)
		return {
			Normal = { fg = colors.text, bg = colors.base },
			NormalNC = { fg = colors.text, bg = colors.base },
			Comment = { fg = colors.overlay1, italic = true },
			LineNr = { fg = colors.surface0 },
			CursorLine = { bg = colors.surface0 },
			CursorLineNr = { fg = colors.text, bg = colors.surface0, bold = true },
			StatusLine = { fg = colors.text, bg = colors.surface0 },
			StatusLineNC = { fg = colors.overlay0, bg = colors.surface0 },
			VertSplit = { fg = colors.text, bg = colors.text },
			WinSeparator = { fg = colors.text, bg = colors.text },
			DiagnosticWarn = { fg = colors.peach },
			DiagnosticError = { fg = colors.red },
			DiagnosticInfo = { fg = colors.blue },
			DiagnosticHint = { fg = colors.teal },
			WarningMsg = { fg = colors.base, bg = colors.green, bold = true },
		}
	end,
})

-- Spotlight: inactive windows render as the captured chromaki-dark.
spotlight.enable({
	scheme = "chromaki-spotlight-sepia-inverted",
	inactive = "capture",
})
