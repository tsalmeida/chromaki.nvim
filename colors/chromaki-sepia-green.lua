-- colors/chromaki-sepia-green.lua
-- Sepia page for the main text, green-tinted chrome & inactive windows.

local chromaki = require("chromaki")

vim.g.inactive_win_bg_hint = "#b9e1c4"

chromaki.apply({
	name = "chromaki-sepia-green",
	flavour = "latte",
	background = "light",

	-- Sepia base + shared accent palette (focus: green UI surfaces)
	palette = {
		-- Accents (shared with sepia-blue)
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

		-- Surfaces: fresh green chrome
		surface2 = "#d5eedb",
		surface1 = "#b9e1c4",
		surface0 = "#9fceb0",

		-- Sepia backgrounds for the actual editing area
		base = "#f7ecda", -- main editor background
		mantle = "#f0e2cc",
		crust = "#e5d6bc",
	},

	custom_highlights = function(colors)
		local base = colors.base
		local text = colors.text
		local surface0 = colors.surface0
		local surface1 = colors.surface1
		local surface2 = colors.surface2
		local white = "#ffffff"
		local black = "#000000"

		-- Green accent for chrome elements
		local accent = colors.green
		local dark_accent_bg = colors.green
		local dark_accent_fg = colors.teal

		return {
			-- Main editor
			Normal = { fg = text, bg = base },

			-- Keep sign column + gutter visually part of the "page"
			SignColumn = { bg = "NONE" },
			LineNr = { fg = colors.overlay0, bg = "NONE" },

			-- Cursor color (block under the caret)
			Cursor = { fg = base, bg = accent }, -- normal modes
			TermCursor = { fg = base, bg = accent }, -- terminal buffers
			TermCursorNC = { fg = base, bg = colors.overlay1 },

			-- "Active line" = dark text on white strip
			CursorLine = { bg = "#ffffff" },

			-- Window separators: THICK PURE BLACK LINE
			WinSeparator = { fg = black, bg = black },
			VertSplit = { link = "WinSeparator" },

			CursorLineNr = { fg = accent, bg = "#ffffff", bold = true },

			-- Statusline: white text on a green strip
			StatusLine = { fg = white, bg = dark_accent_bg },
			StatusLineNC = { fg = colors.overlay2, bg = dark_accent_bg },

			-- Terminal statuslines follow the same style
			StatusLineTerm = { link = "StatusLine" },
			StatusLineTermNC = { link = "StatusLineNC" },

			-- Tabline: greenish bar + coloured tabs
			TabLineFill = { bg = surface1, fg = colors.overlay1 },
			TabLine = { bg = surface2, fg = colors.overlay0 },
			TabLineSel = { bg = "#ffffff", fg = accent, bold = true },

			-- Popups / floating windows: sepia dialog
			NormalFloat = { fg = text, bg = colors.mantle },

			-- Green border over sepia background
			FloatBorder = { fg = surface0, bg = colors.mantle },

			-- Menus (completion etc.) on green chrome
			Pmenu = { fg = text, bg = surface2 },
			PmenuSel = { fg = accent, bg = "#ffffff", bold = true },
			PmenuSbar = { bg = surface1 },
			PmenuThumb = { bg = accent },

			-- Visual selection & search
			Visual = { bg = surface1, fg = text },
			Search = { bg = colors.sky, fg = colors.crust },
			IncSearch = { bg = colors.teal, fg = colors.crust },

			-- Non-text and buffer edges
			NonText = { fg = colors.overlay1 },
			EndOfBuffer = { fg = base },

			-- Diagnostics
			DiagnosticWarn = { fg = colors.peach },
			DiagnosticError = { fg = colors.red },
			DiagnosticInfo = { fg = colors.sky },
			DiagnosticHint = { fg = colors.teal },

			-- Git signs
			GitSignsAdd = { fg = colors.green, bg = "NONE" },
			GitSignsChange = { fg = colors.sky, bg = "NONE" },
			GitSignsDelete = { fg = colors.red, bg = "NONE" },

			-- Mode messages: teal-ish on white
			ModeMsg = { fg = dark_accent_fg, bg = white, bold = true },
			MoreMsg = { fg = dark_accent_fg, bg = white, bold = true },
		}
	end,
})
