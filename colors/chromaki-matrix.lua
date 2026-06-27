-- colors/chromaki-matrix.lua
-- "The Matrix" terminal look: phosphor green on pure black.
--   * pure black (#000000) background for the ACTIVE window
--   * very dark green for INACTIVE windows (via the inactive_win_bg_hint
--     contract that chromaki + logarktos focus dimming both honour)
--   * a solid bright-green bar between windows (WinSeparator fg+bg)
--   * everything else in graded shades of fluorescent / phosphor green
-- Real errors keep a stark red so they stay unmistakable against the green.

local chromaki = require("chromaki")

-- Phosphor green ramp (dark -> bright) ---------------------------------------
local black = "#000000"
local phosphor = "#00ff41" -- the iconic bright Matrix green (separator/cursor)
local bright = "#5bff87" -- headings, keywords, emphasis
local text = "#2ee65f" -- body text
local mid = "#1fd14c" -- strings / numbers
local dim = "#118a32" -- comments, secondary
local gutter = "#0a4f20" -- line numbers
local faint = "#0a3d18" -- nontext, whitespace, eob
local inactive_green = "#04210c" -- very dark green for inactive windows

-- Publish the inactive-window tint so chromaki.apply() and logarktos's focus
-- dimming both paint NormalNC the same very-dark-green.
vim.g.inactive_win_bg_hint = inactive_green

chromaki.apply({
	name = "chromaki-matrix",
	flavour = "mocha",
	background = "dark",
	inactive_win_bg = inactive_green,

	palette = {
		-- Backgrounds: pure black, with barely-lifted greens for surfaces.
		base = black,
		mantle = "#020a04",
		crust = "#010602",

		-- Text ramp
		text = text,
		subtext1 = "#27cf52",
		subtext0 = "#1fb045",

		-- Gutter / dim
		overlay2 = "#15833a",
		overlay1 = "#0f6a2c",
		overlay0 = gutter,

		-- Surfaces (popups / sidebars)
		surface2 = "#0c3318",
		surface1 = "#082413",
		surface0 = "#05190d",

		-- Green-family accents for syntax (treesitter captures resolve here)
		green = "#3bff66",
		teal = mid, -- strings
		sky = bright, -- numbers / constants (light green)
		cyan = "#7dffa0", -- punctuation / macros (mint)

		-- Keywords / functions / builtins stay bright green (not white)
		blue = "#4dff70",
		sapphire = "#39e85f",
		lavender = "#74ff95",

		-- Warnings drift to a yellow-green so they read as "alert" yet on-theme
		peach = "#b6ff00",
		yellow = "#d2ff3a",
		orange = "#86d900",

		-- Real red kept for genuine errors (pops hard against the green)
		red = "#ff3b3b",
		maroon = "#d14b4b",

		-- Remaining accents folded back into the green family
		rosewater = "#9bffb4",
		flamingo = "#84ff9c",
		pink = "#a6ffbb",
		mauve = "#62ff86",
	},

	custom_highlights = function(colors)
		return {
			-- Core typography
			Normal = { fg = text, bg = black },
			Comment = { fg = dim, italic = true },
			LineNr = { fg = gutter },
			-- Inactive gutter aligns with the very-dark-green inactive bg
			LineNrNC = { fg = gutter, bg = inactive_green },
			CursorLineNr = { fg = phosphor, bold = true },
			CursorLine = { bg = "#031a0a" },

			-- The signature: a solid bright-green bar between windows.
			-- bg fills the whole separator cell regardless of the glyph.
			WinSeparator = { fg = phosphor, bg = phosphor },
			VertSplit = { fg = phosphor, bg = phosphor },

			-- Inverted phosphor statusline (bright bar, black text when active)
			StatusLine = { fg = black, bg = "#19c247", bold = false },
			StatusLineNC = { fg = "#1fb045", bg = colors.surface0 },
			StatusLineTerm = { link = "StatusLine" },
			StatusLineTermNC = { link = "StatusLineNC" },

			-- Tabline keeps the inverted spirit for the active tab
			TabLineFill = { bg = black, fg = colors.overlay1 },
			TabLine = { bg = colors.surface0, fg = colors.subtext0 },
			TabLineSel = { bg = phosphor, fg = black, bold = true },

			-- Cursor: bright green block on black
			Cursor = { fg = black, bg = phosphor },
			TermCursor = { fg = black, bg = phosphor },
			TermCursorNC = { fg = black, bg = dim },

			-- Selection / search
			Visual = { bg = "#0c4a22", fg = "NONE" },
			Search = { bg = phosphor, fg = black },
			CurSearch = { bg = bright, fg = black },
			IncSearch = { bg = "#b6ff00", fg = black },
			MatchParen = { fg = black, bg = phosphor, bold = true },

			-- Floats & menus (stay in the dark-green world)
			NormalFloat = { fg = text, bg = colors.mantle },
			FloatBorder = { fg = colors.overlay1, bg = colors.mantle },
			FloatTitle = { fg = black, bg = phosphor, bold = true },
			Pmenu = { fg = text, bg = colors.mantle },
			PmenuSel = { fg = black, bg = phosphor, bold = true },
			PmenuSbar = { bg = colors.surface0 },
			PmenuThumb = { bg = phosphor },

			-- Non-text
			NonText = { fg = faint },
			Whitespace = { fg = faint },
			SpecialKey = { fg = faint },
			EndOfBuffer = { fg = black },
			Conceal = { fg = dim },

			-- Prose headings (markdown via treesitter) — brightest green
			Title = { fg = bright, bold = true },
			["@markup.heading"] = { fg = bright, bold = true },
			["@markup.strong"] = { fg = phosphor, bold = true },
			["@markup.raw"] = { fg = mid },
			["@markup.link"] = { fg = colors.cyan, underline = true },

			-- Diagnostics
			DiagnosticWarn = { fg = colors.peach },
			DiagnosticError = { fg = colors.red },
			DiagnosticInfo = { fg = colors.sky },
			DiagnosticHint = { fg = phosphor },

			-- Git signs
			GitSignsAdd = { fg = phosphor, bg = "NONE" },
			GitSignsChange = { fg = colors.sky, bg = "NONE" },
			GitSignsDelete = { fg = colors.red, bg = "NONE" },

			-- Messages
			ModeMsg = { fg = phosphor, bold = true },
			MoreMsg = { fg = phosphor, bold = true },

			-- Telescope titles, inverted green for cohesion
			TelescopeTitle = { fg = black, bg = phosphor, bold = true },
			TelescopePromptTitle = { fg = black, bg = colors.peach, bold = true },
		}
	end,
})
