-- colors/chromaki-dark-green.lua
-- Dark theme inspired by Naysayer (Nick Aversano / Jonathan Blow's Emaki compiler streams).
-- Very dark teal-green background, warm tan text, signature bright green comments and inverted statusline.

local chromaki = require("chromaki")

-- Hint for FocusMode: a slightly lighter teal-green for inactive windows.
-- This keeps the "deep lagoon" feel while providing gentle contrast when splitting.
vim.g.inactive_win_bg_hint = "#0a2f35"

chromaki.apply({
	name = "chromaki-dark-green",
	flavour = "mocha",
	background = "dark",

	palette = {
		-- Naysayer core background (the famous dark cyan-green)
		base = "#062329",
		mantle = "#051f23",
		crust = "#04191c",

		-- Warm tan text (signature of the theme)
		text = "#d1b897",
		subtext1 = "#c1b08a",
		subtext0 = "#a89878",

		-- Gutter / dim (original uses a teal-ish line number color)
		overlay2 = "#3a6b6f",
		overlay1 = "#2a5a5e",
		overlay0 = "#126367", -- original gutter-fg

		-- Surfaces (slightly lifted dark teal for popups/sidebars)
		surface2 = "#0b3335", -- original highlight-line
		surface1 = "#0a2c2e",
		surface0 = "#082427",

		-- Accents tuned to Naysayer spirit
		-- Bright vibrant green for comments (the most famous part)
		green = "#44b340",
		teal = "#2ec09c", -- strings
		sky = "#7ad0c6", -- numbers / constants
		cyan = "#8cde94", -- punctuation / macros (very bright green)

		-- White for keywords, functions, builtins (as in original)
		blue = "#ffffff",
		sapphire = "#e8e8e8",
		lavender = "#f0f0f0",

		-- Warm / warning accents
		peach = "#ffaa00", -- warning
		yellow = "#E6DB74",
		orange = "#FD971F",

		-- Red for errors (kept strong)
		red = "#ff0000",
		maroon = "#e04040",

		-- Softer supporting accents (mapped to remaining Catppuccin roles)
		rosewater = "#ff9e64",
		flamingo = "#ff6b9d",
		pink = "#ff75a0",
		mauve = "#c792ea",
	},

	custom_highlights = function(colors)
		local bg = colors.base
		local fg = colors.text
		local tan = "#d1b897"
		local bright_green = "#44b340"
		local white = "#ffffff"

		return {
			-- Core typography — Naysayer character
			Normal = { fg = fg, bg = bg },
			Comment = { fg = bright_green, italic = true },
			LineNr = { fg = colors.overlay0 },
			CursorLineNr = { fg = white, bold = true },

			-- The signature Naysayer inverted statusline:
			-- Warm tan bar with dark text when active.
			StatusLine = { fg = bg, bg = tan, bold = false },
			StatusLineNC = { fg = tan, bg = colors.surface0 },

			-- Terminal statuslines follow the same dramatic style
			StatusLineTerm = { link = "StatusLine" },
			StatusLineTermNC = { link = "StatusLineNC" },

			-- Tabline — keep the "inverted" spirit for active tab
			TabLineFill = { bg = colors.surface0, fg = colors.overlay1 },
			TabLine = { bg = colors.surface1, fg = colors.overlay0 },
			TabLineSel = { bg = tan, fg = bg, bold = true },

			-- Subtle separators in the dark teal family
			VertSplit = { fg = colors.surface1 },
			WinSeparator = { fg = colors.surface1 },

			-- Cursor (classic white block on dark)
			Cursor = { fg = bg, bg = white },
			TermCursor = { fg = bg, bg = white },
			TermCursorNC = { fg = bg, bg = colors.overlay1 },

			-- Active line — very subtle lift
			CursorLine = { bg = colors.surface1 },

			-- Selection: the original used pure blue; we use a deep teal
			Visual = { bg = "#0d3f44", fg = fg },

			-- Search — bright but harmonious
			Search = { bg = colors.sky, fg = bg },
			IncSearch = { bg = colors.peach, fg = bg },

			-- Popups & floats (stay in the dark teal world)
			NormalFloat = { fg = fg, bg = colors.mantle },
			FloatBorder = { fg = colors.surface1, bg = colors.mantle },
			Pmenu = { fg = fg, bg = colors.mantle },
			PmenuSel = { fg = bg, bg = tan, bold = true },
			PmenuSbar = { bg = colors.surface0 },
			PmenuThumb = { bg = bright_green },

			-- Non-text
			NonText = { fg = colors.overlay1 },
			EndOfBuffer = { fg = bg },

			-- Diagnostics — keep loud where appropriate
			DiagnosticWarn = { fg = colors.peach },
			DiagnosticError = { fg = colors.red },
			DiagnosticInfo = { fg = colors.sky },
			DiagnosticHint = { fg = bright_green },

			-- Git signs in the Naysayer accent language
			GitSignsAdd = { fg = bright_green, bg = "NONE" },
			GitSignsChange = { fg = colors.sky, bg = "NONE" },
			GitSignsDelete = { fg = colors.red, bg = "NONE" },

			-- Mode messages
			ModeMsg = { fg = tan, bold = true },
			MoreMsg = { fg = tan, bold = true },

			-- Telescope titles use the warm tan for cohesion
			TelescopeTitle = { fg = bg, bg = tan, bold = true },
			TelescopePromptTitle = { fg = bg, bg = colors.peach, bold = true },
		}
	end,
})
