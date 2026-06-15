-- colors/chromaki-transparent-light-bones-spotlight.lua
-- Bones-style spotlight: active window is near-monochrome over the terminal's
-- transparent background, but the scheme avoids flattening plugin/app colors.
-- Markdown carries structure through typography:
--   BOLD    - major headings and strong emphasis.
--   ITALIC  - minor headings, emphasis, quotes.
--   REGULAR - body text and everything owned by other plugins/apps.
-- Inactive windows flatten to grey-on-black via spotlight.

local chromaki = require("chromaki")

vim.g.inactive_win_bg_hint = "#000000"

chromaki.apply({
	name = "chromaki-transparent-light-bones-spotlight",
	flavour = "latte",
	background = "light",
	transparent = true,

	palette = {
		-- Leave Catppuccin's accent palette intact so plugin icons,
		-- diagnostics, signs, and terminal-style colors can stay colored.

		-- Text & neutrals: ink-on-parchment scale
		text      = "#1a1a1a",
		subtext1  = "#2c2c2c",
		subtext0  = "#4a4a4a",
		overlay2  = "#6a6a6a",
		overlay1  = "#8a8a8a",
		overlay0  = "#aaaaaa",

		-- Dark surfaces for status bar / tabline chrome
		surface2 = "#2a2a2a",
		surface1 = "#1f1f1f",
		surface0 = "#191919",

		-- Sepia page (matches wezterm colors.background so cuts are seamless)
		base   = "#f7ecda",
		mantle = "#f0e2cc",
		crust  = "#e5d6bc",
	},

	custom_highlights = function(colors)
		local base     = colors.base
		local text     = colors.text
		local surface0 = colors.surface0
		local surface1 = colors.surface1
		local surface2 = colors.surface2
		local white    = "#ffffff"
		local black    = "#000000"
		local ink      = "#1a1a1a"
		local dim      = "#4a4a4a"
		local muted    = "#6a6a6a"

		return {
			-- Main editor (bg stripped to NONE by transparent = true)
			Normal = { fg = text, bg = base },

			SignColumn = { bg = "NONE" },
			LineNr     = { fg = colors.overlay0, bg = "NONE" },

			Cursor       = { fg = base, bg = ink },
			TermCursor   = { fg = base, bg = ink },
			TermCursorNC = { fg = base, bg = colors.overlay1 },

			CursorLine   = { bg = white },
			CursorLineNr = { fg = ink, bg = white, bold = true },

			WinSeparator = { fg = black, bg = black },
			VertSplit    = { link = "WinSeparator" },

			StatusLine       = { fg = white, bg = surface0 },
			StatusLineNC     = { fg = colors.overlay2, bg = surface0 },
			StatusLineTerm   = { link = "StatusLine" },
			StatusLineTermNC = { link = "StatusLineNC" },

			TabLineFill = { bg = surface1, fg = colors.overlay1 },
			TabLine     = { bg = surface2, fg = colors.overlay0 },
			TabLineSel  = { bg = white, fg = ink, bold = true },

			NormalFloat = { fg = text, bg = colors.mantle },
			FloatBorder = { fg = surface0, bg = colors.mantle },

			Pmenu      = { fg = white, bg = surface2 },
			PmenuSel   = { fg = white, bg = ink, bold = true },
			PmenuSbar  = { bg = surface1 },
			PmenuThumb = { bg = dim },

			Visual    = { bg = colors.overlay1, fg = text },
			Search    = { bg = ink, fg = base },
			IncSearch = { bg = dim, fg = base },

			NonText     = { fg = colors.overlay1 },
			EndOfBuffer = { fg = base },

			-- Markdown typography: neutral foreground, structure by weight/slant.
			["@markup.heading.markdown"]   = { fg = text, bold = true },
			["@markup.heading.1.markdown"] = { fg = text, bold = true },
			["@markup.heading.2.markdown"] = { fg = text, bold = true },
			["@text.title.1.markdown"]     = { fg = text, bold = true },
			["@text.title.2.markdown"]     = { fg = text, bold = true },
			markdownH1                     = { fg = text, bold = true },
			markdownH2                     = { fg = text, bold = true },
			markdownHeadingDelimiter       = { fg = text, bold = true },

			["@markup.heading.3.markdown"] = { fg = text, italic = true },
			["@markup.heading.4.markdown"] = { fg = text, italic = true },
			["@markup.heading.5.markdown"] = { fg = text, italic = true },
			["@markup.heading.6.markdown"] = { fg = text, italic = true },
			["@text.title.3.markdown"]     = { fg = text, italic = true },
			["@text.title.4.markdown"]     = { fg = text, italic = true },
			["@text.title.5.markdown"]     = { fg = text, italic = true },
			["@text.title.6.markdown"]     = { fg = text, italic = true },
			markdownH3                     = { fg = text, italic = true },
			markdownH4                     = { fg = text, italic = true },
			markdownH5                     = { fg = text, italic = true },
			markdownH6                     = { fg = text, italic = true },

			["@markup.strong.markdown_inline"] = { fg = text, bold = true },
			["@markup.italic.markdown_inline"] = { fg = text, italic = true },
			["@text.strong.markdown_inline"]   = { fg = text, bold = true },
			["@text.emphasis.markdown_inline"] = { fg = text, italic = true },

			["@markup.raw.markdown_inline"] = { fg = dim },
			["@markup.raw.block.markdown"]  = { fg = dim },
			markdownCode                    = { fg = dim },
			markdownCodeBlock               = { fg = dim },

			["@markup.link.label.markdown_inline"] = { fg = text, underline = true },
			["@markup.link.url.markdown_inline"]   = { fg = muted },
			markdownLinkText                       = { fg = text, underline = true },

			["@markup.list.markdown"]  = { fg = text, bold = true },
			["@markup.quote.markdown"] = { fg = dim, italic = true },

			ModeMsg = { fg = ink, bg = white, bold = true },
			MoreMsg = { fg = ink, bg = white, bold = true },
		}
	end,
})

-- Spotlight: flatten all inactive windows to grey-on-black dark mode.
require("chromaki.spotlight").enable({
	scheme = "chromaki-transparent-light-bones-spotlight",
	inactive = "flat",
})
