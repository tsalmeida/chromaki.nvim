-- colors/chromaki-dark-blue.lua
-- Dark theme inspired by Tokyo Night. Deep navy background with vibrant blue/cyan accents.
-- Inactive windows are lightened for focus contrast (dark theme behavior).

local chromaki = require("chromaki")

-- Hint for FocusMode: a slightly lighter navy for inactive windows.
vim.g.inactive_win_bg_hint = "#24283b"

chromaki.apply({
	name = "chromaki-dark-blue",
	flavour = "mocha",
	background = "dark",

	palette = {
		-- Tokyo Night Night inspired backgrounds
		base = "#1a1b26",
		mantle = "#16161e",
		crust = "#13141c",

		-- Text hierarchy
		text = "#c0caf5",
		subtext1 = "#a9b1d6",
		subtext0 = "#9aa5ce",

		-- Comments / dim text
		overlay2 = "#565f89",
		overlay1 = "#4a516f",
		overlay0 = "#3b4261",

		-- Surfaces (popups, sidebars, slightly lifted)
		surface2 = "#292e42",
		surface1 = "#24283b",
		surface0 = "#1f2335",

		-- Accents — Tokyo Night palette
		rosewater = "#ff9e64",
		flamingo = "#f7768e",
		pink = "#ff75a0",
		mauve = "#bb9af7",
		red = "#f7768e",
		maroon = "#c75b6e",
		peach = "#ff9e64",
		yellow = "#e0af68",
		green = "#9ece6a",
		teal = "#73daca",
		sky = "#7dcfff",
		sapphire = "#5f8fff",
		blue = "#7aa2f7",
		lavender = "#bb9af7",
	},

	custom_highlights = function(colors)
		local bg = colors.base
		local fg = colors.text
		local surface0 = colors.surface0
		local surface1 = colors.surface1
		local blue = colors.blue
		local white = "#ffffff"

		return {
			-- Core
			Normal = { fg = fg, bg = bg },
			Comment = { fg = colors.overlay2, italic = true },
			LineNr = { fg = colors.overlay0 },
			CursorLineNr = { fg = colors.yellow, bold = true },

			-- Cursor
			Cursor = { fg = bg, bg = blue },
			TermCursor = { fg = bg, bg = blue },
			TermCursorNC = { fg = bg, bg = colors.overlay1 },

			-- Active line
			CursorLine = { bg = surface1 },

			-- Status & UI bars (cohesive dark)
			StatusLine = { fg = fg, bg = surface0 },
			StatusLineNC = { fg = colors.overlay1, bg = surface0 },

			-- Tabline
			TabLineFill = { bg = surface1, fg = colors.overlay1 },
			TabLine = { bg = surface0, fg = colors.overlay0 },
			TabLineSel = { bg = colors.surface2, fg = blue, bold = true },

			-- Separators (subtle)
			VertSplit = { fg = colors.surface1 },
			WinSeparator = { fg = colors.surface1 },

			-- Popups & floats
			NormalFloat = { fg = fg, bg = colors.mantle },
			FloatBorder = { fg = colors.surface1, bg = colors.mantle },
			Pmenu = { fg = fg, bg = colors.mantle },
			PmenuSel = { fg = fg, bg = surface1, bold = true },
			PmenuSbar = { bg = surface0 },
			PmenuThumb = { bg = colors.blue },

			-- Selection & search (Tokyo Night blue-ish)
			Visual = { bg = colors.surface2, fg = fg },
			Search = { bg = colors.blue, fg = bg },
			IncSearch = { bg = colors.peach, fg = bg },

			-- Non-text
			NonText = { fg = colors.overlay1 },
			EndOfBuffer = { fg = bg },

			-- Diagnostics
			DiagnosticWarn = { fg = colors.peach },
			DiagnosticError = { fg = colors.red },
			DiagnosticInfo = { fg = colors.sky },
			DiagnosticHint = { fg = colors.teal },

			-- Git
			GitSignsAdd = { fg = colors.green, bg = "NONE" },
			GitSignsChange = { fg = colors.sky, bg = "NONE" },
			GitSignsDelete = { fg = colors.red, bg = "NONE" },

			-- Mode messages
			ModeMsg = { fg = blue, bold = true },
			MoreMsg = { fg = blue, bold = true },

			-- Telescope
			TelescopeTitle = { fg = colors.mantle, bg = colors.blue, bold = true },
			TelescopePromptTitle = { fg = colors.mantle, bg = colors.peach, bold = true },
		}
	end,
})
