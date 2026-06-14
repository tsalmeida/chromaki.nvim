-- colors/chromaki-sepia-blue.lua
-- Sepia page for the main text, blue-tinted chrome & inactive windows.

local chromaki = require("chromaki")

-- Hint for FocusMode (personal.lua): use a soft blue for inactive windows.
-- This is only a hint; FocusMode still enforces gentle contrast rules.
vim.g.inactive_win_bg_hint = "#c4d5eb"

chromaki.apply({
	name = "chromaki-sepia-blue",
	flavour = "latte",
	background = "light",

	-- Sepia base + blue UI palette (Catppuccin-style keys)
	palette = {
		-- Accents
		rosewater = "#d9a2a0",
		flamingo = "#c97f6b",
		pink = "#c45e93",
		mauve = "#9b63b5",
		red = "#c02e2e",
		maroon = "#b84a62",
		peach = "#cc6f3e",
		yellow = "#b0891d",
		green = "#3a7f52",
		teal = "#2a9088",
		sky = "#3b83c6",
		sapphire = "#23538a",
		blue = "#2f6db5",
		lavender = "#7b6fb0",

		-- Text & neutrals (for the sepia "page")
		text = "#271c15",
		subtext1 = "#504136",
		subtext0 = "#756557",
		overlay2 = "#948676",
		overlay1 = "#b3a492",
		overlay0 = "#c7b9a5",

		-- Surfaces: bluish, NOT sepia, for UI chrome (tabs, statusline, popups)
		surface2 = "#d4e3f4",
		surface1 = "#c4d5eb",
		surface0 = "#b4c7e1",

		-- Sepia backgrounds for the actual editing area
		base = "#f7ecda", -- main editor background
		mantle = "#f0e2cc",
		crust = "#e5d6bc",
	},

	custom_highlights = function(colors)
		local base = colors.base
		local text = colors.text
		local blue = colors.blue
		local surface0 = colors.surface0
		local surface1 = colors.surface1
		local surface2 = colors.surface2
		local white = "#ffffff"
		local dark_blue_bg = colors.sapphire -- good dark blue from your palette
		local dark_blue_fg = colors.blue -- slightly brighter blue for text
		-- Explicit pure black for the window separator line
		local black = "#000000"

		return {
			-- Main editor
			Normal = { fg = text, bg = base },

			-- Keep sign column + gutter visually part of the "page" (Sepia Base)
			-- MODIFIED: Set bg to "NONE" (transparent) so it inherits the window background
			-- (Sepia in active windows, Blue in inactive windows via NormalNC).
			SignColumn = { bg = "NONE" },
			LineNr = { fg = colors.overlay0, bg = "NONE" },

			-- Cursor color (block under the caret)
			Cursor = { fg = base, bg = blue }, -- normal modes
			TermCursor = { fg = base, bg = blue }, -- terminal buffers
			TermCursorNC = { fg = base, bg = colors.overlay1 },

			-- "Active line" = dark text on white strip
			CursorLine = { bg = "#ffffff" },

			-- Window separators: THICK PURE BLACK LINE
			-- We set both fg and bg to black to create a solid block line.
			WinSeparator = { fg = black, bg = black },
			VertSplit = { link = "WinSeparator" },

			CursorLineNr = { fg = blue, bg = "#ffffff", bold = true },

			-- Statusline: white text on a dark blue strip
			StatusLine = { fg = white, bg = dark_blue_bg },
			StatusLineNC = { fg = colors.overlay2, bg = dark_blue_bg },

			-- Terminal statuslines follow the same style
			StatusLineTerm = { link = "StatusLine" },
			StatusLineTermNC = { link = "StatusLineNC" },

			-- Tabline: distinct bluish bar + colored tabs

			-- Tabline: distinct bluish bar + colored tabs
			TabLineFill = { bg = surface1, fg = colors.overlay1 }, -- strip behind tabs
			TabLine = { bg = surface2, fg = colors.overlay0 }, -- inactive tabs
			TabLineSel = { bg = "#ffffff", fg = blue, bold = true }, -- active tab

			-- Popups / floating windows (Sepia background)
			-- Changing bg to colors.mantle makes it sepia (like the page) instead of blue.
			NormalFloat = { fg = text, bg = colors.mantle },

			-- Keep the border foreground blue (surface0) for the "Sepia-Blue" theme feel,
			-- but ensure the border background matches the popup background (sepia).
			FloatBorder = { fg = surface0, bg = colors.mantle },

			-- Menus (completion etc.) - Updated to match the sepia dialog style
			Pmenu = { fg = text, bg = colors.mantle },

			-- Menus (completion etc.)
			Pmenu = { fg = text, bg = surface2 },
			PmenuSel = { fg = blue, bg = "#ffffff", bold = true },
			PmenuSbar = { bg = surface1 },
			PmenuThumb = { bg = blue },

			-- Visual selection & search: blue-tinted, no brown overlays
			Visual = { bg = surface1, fg = text },
			Search = { bg = colors.sky, fg = colors.crust },
			IncSearch = { bg = colors.teal, fg = colors.crust },

			-- Make “non-text” characters softer so writing feels cleaner
			NonText = { fg = colors.overlay1 },
			EndOfBuffer = { fg = base },

			-- Diagnostics: keep them colourful but not muddy
			DiagnosticWarn = { fg = colors.peach },
			DiagnosticError = { fg = colors.red },
			DiagnosticInfo = { fg = colors.sky },
			DiagnosticHint = { fg = colors.teal },

			-- Git signs: match the writing-focused style
			-- MODIFIED: Set bg to "NONE" to match the underlying column color
			GitSignsAdd = { fg = colors.green, bg = "NONE" },
			GitSignsChange = { fg = colors.sky, bg = "NONE" },
			GitSignsDelete = { fg = colors.red, bg = "NONE" },

			-- Mode messages (e.g. "NORMAL", "INSERT") as dark blue on white
			ModeMsg = { fg = dark_blue_fg, bg = white, bold = true },
			MoreMsg = { fg = dark_blue_fg, bg = white, bold = true },
		}
	end,
})
