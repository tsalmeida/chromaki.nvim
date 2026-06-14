-- colors/chromaki-transparent-light-bones-spotlight.lua
-- Bones-style spotlight: active window is near-monochrome over the terminal's
-- transparent background. Three typographic levels carry all structure:
--   BOLD    — primary declarations: function/class/type keywords, type names,
--             major headings (H1–H2). The scaffolding of code and documents.
--   ITALIC  — secondary structure: control-flow keywords (if/for/return),
--             strings (content, like prose), comments, minor headings (H3–H6).
--   REGULAR — body: variables, calls, values, operators. Everything else.
-- Inactive windows flatten to grey-on-black via spotlight.

local chromaki = require("chromaki")

vim.g.inactive_win_bg_hint = "#000000"

chromaki.apply({
	name = "chromaki-transparent-light-bones-spotlight",
	flavour = "latte",
	background = "light",
	transparent = true,

	palette = {
		-- All accents collapsed to near-black so catppuccin's syntax mappings
		-- produce uniform dark ink; bold/italic carry all structural variation.
		rosewater = "#2c2c2c",
		flamingo  = "#2c2c2c",
		pink      = "#2c2c2c",
		mauve     = "#2c2c2c",
		red       = "#1a1a1a",
		maroon    = "#2c2c2c",
		peach     = "#2c2c2c",
		yellow    = "#2c2c2c",
		green     = "#2c2c2c",
		teal      = "#2c2c2c",
		sky       = "#2c2c2c",
		sapphire  = "#2c2c2c",
		blue      = "#2c2c2c",
		lavender  = "#2c2c2c",

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
		local base    = colors.base
		local text    = colors.text
		local surface0 = colors.surface0
		local surface1 = colors.surface1
		local surface2 = colors.surface2
		local white   = "#ffffff"
		local black   = "#000000"
		local ink     = "#1a1a1a"  -- deepest text / bold accents
		local dim     = "#4a4a4a"  -- secondary text, strings
		local muted   = "#6a6a6a"  -- comments, diagnostics

		return {
			-- Main editor (bg stripped to NONE by transparent = true)
			Normal = { fg = text, bg = base },

			SignColumn    = { bg = "NONE" },
			LineNr        = { fg = colors.overlay0, bg = "NONE" },

			Cursor        = { fg = base, bg = ink },
			TermCursor    = { fg = base, bg = ink },
			TermCursorNC  = { fg = base, bg = colors.overlay1 },

			CursorLine    = { bg = white },
			CursorLineNr  = { fg = ink, bg = white, bold = true },

			WinSeparator  = { fg = black, bg = black },
			VertSplit     = { link = "WinSeparator" },

			StatusLine    = { fg = white, bg = surface0 },
			StatusLineNC  = { fg = colors.overlay2, bg = surface0 },
			StatusLineTerm   = { link = "StatusLine" },
			StatusLineTermNC = { link = "StatusLineNC" },

			TabLineFill = { bg = surface1, fg = colors.overlay1 },
			TabLine     = { bg = surface2, fg = colors.overlay0 },
			TabLineSel  = { bg = white, fg = ink, bold = true },

			NormalFloat  = { fg = text, bg = colors.mantle },
			FloatBorder  = { fg = surface0, bg = colors.mantle },

			Pmenu      = { fg = white, bg = surface2 },
			PmenuSel   = { fg = white, bg = ink, bold = true },
			PmenuSbar  = { bg = surface1 },
			PmenuThumb = { bg = dim },

			Visual    = { bg = colors.overlay1, fg = text },
			Search    = { bg = ink, fg = base },
			IncSearch = { bg = dim, fg = base },

			NonText     = { fg = colors.overlay1 },
			EndOfBuffer = { fg = base },

			-- ── Syntax ───────────────────────────────────────────────────────

			-- REGULAR — body: identifiers, calls, values, operators
			Identifier = { fg = ink },
			Operator   = { fg = ink },
			Special    = { fg = dim },
			SpecialChar = { fg = dim },
			Constant   = { fg = ink },
			Number     = { fg = ink },
			Float      = { fg = ink },
			Boolean    = { fg = ink },

			["@variable"]            = { fg = ink },
			["@variable.member"]     = { fg = ink },
			["@property"]            = { fg = ink },
			["@operator"]            = { fg = ink },
			["@function.call"]       = { fg = ink },
			["@function.method.call"] = { fg = ink },
			["@constant"]            = { fg = ink },
			["@number"]              = { fg = ink },
			["@float"]               = { fg = ink },
			["@boolean"]             = { fg = ink },
			["@punctuation.bracket"]   = { fg = ink },
			["@punctuation.delimiter"] = { fg = ink },

			-- ITALIC — secondary structure: control flow, strings, comments,
			--          parameters, self/this, minor headings

			-- Comments: italic + muted (clearly meta)
			Comment      = { fg = muted, italic = true },
			["@comment"] = { fg = muted, italic = true },

			-- Strings: italic + slightly dimmed (content, like prose)
			String    = { fg = dim, italic = true },
			Character = { fg = dim, italic = true },
			["@string"]        = { fg = dim, italic = true },
			["@string.escape"] = { fg = dim, italic = true },
			["@character"]     = { fg = dim, italic = true },

			-- Control-flow keywords: italic (structural connectors, not declarations)
			Statement   = { fg = ink, italic = true },
			Keyword     = { fg = ink, italic = true },
			Conditional = { fg = ink, italic = true },
			Repeat      = { fg = ink, italic = true },
			Exception   = { fg = ink, italic = true },

			["@keyword"]             = { fg = ink, italic = true },
			["@keyword.conditional"] = { fg = ink, italic = true },
			["@keyword.loop"]        = { fg = ink, italic = true },
			["@keyword.return"]      = { fg = ink, italic = true },
			["@keyword.exception"]   = { fg = ink, italic = true },
			["@keyword.operator"]    = { fg = ink, italic = true },

			-- Parameters & self/this: italic (they're like prose arguments)
			["@variable.builtin"] = { fg = ink, italic = true },
			["@parameter"]        = { fg = ink, italic = true },

			-- BOLD — primary declarations: the scaffolding that names things

			-- Declaration keywords: function/def/fn/class/struct/import
			PreProc   = { fg = ink, bold = true },
			PreCondit = { fg = ink, bold = true },
			Include   = { fg = ink, bold = true },
			Define    = { fg = ink, bold = true },
			Macro     = { fg = ink, bold = true },

			["@keyword.function"] = { fg = ink, bold = true },
			["@keyword.import"]   = { fg = ink, bold = true },

			-- Types: bold (they're naming a shape/contract)
			Type         = { fg = ink, bold = true },
			StorageClass = { fg = ink, bold = true },
			Structure    = { fg = ink, bold = true },
			Typedef      = { fg = ink, bold = true },

			["@type"]         = { fg = ink, bold = true },
			["@type.builtin"] = { fg = ink, bold = true },

			-- Function/method names at their definition site: bold
			-- (calls stay regular — only the declaration is bold)
			Function = { fg = ink, bold = true },

			["@function"]         = { fg = ink, bold = true },
			["@function.builtin"] = { fg = ink, bold = true },
			["@function.method"]  = { fg = ink, bold = true },

			-- ── Markdown ─────────────────────────────────────────────────────

			-- Major headings (H1–H2): bold — like a title or chapter name
			["@markup.heading"]             = { fg = ink, bold = true },
			["@markup.heading.1"]           = { fg = ink, bold = true },
			["@markup.heading.2"]           = { fg = ink, bold = true },
			["@markup.heading.1.markdown"]  = { fg = ink, bold = true },
			["@markup.heading.2.markdown"]  = { fg = ink, bold = true },

			-- Minor headings (H3–H6): italic — section labels, not titles
			["@markup.heading.3"]           = { fg = ink, italic = true },
			["@markup.heading.4"]           = { fg = ink, italic = true },
			["@markup.heading.5"]           = { fg = ink, italic = true },
			["@markup.heading.6"]           = { fg = ink, italic = true },
			["@markup.heading.3.markdown"]  = { fg = ink, italic = true },
			["@markup.heading.4.markdown"]  = { fg = ink, italic = true },
			["@markup.heading.5.markdown"]  = { fg = ink, italic = true },
			["@markup.heading.6.markdown"]  = { fg = ink, italic = true },

			-- Inline emphasis: honour the author's intent
			["@markup.strong"]                  = { bold = true },
			["@markup.italic"]                  = { italic = true },
			["@markup.strong.markdown_inline"]  = { bold = true },
			["@markup.italic.markdown_inline"]  = { italic = true },

			-- Code spans / blocks: dimmed (raw, no syntax weight)
			["@markup.raw"]                  = { fg = dim },
			["@markup.raw.markdown_inline"]  = { fg = dim },
			["@markup.raw.block.markdown"]   = { fg = dim },

			-- Links: underlined so they read as links
			["@markup.link"]                        = { fg = ink, underline = true },
			["@markup.link.label"]                  = { fg = ink },
			["@markup.link.label.markdown_inline"]  = { fg = ink, underline = true },
			["@markup.link.url.markdown_inline"]    = { fg = muted },

			-- List markers: bold (structural punctuation)
			["@markup.list"]          = { fg = ink, bold = true },
			["@markup.list.markdown"] = { fg = ink, bold = true },

			-- Blockquotes: italic + dimmed (quoted voice)
			["@markup.quote"]          = { fg = dim, italic = true },
			["@markup.quote.markdown"] = { fg = dim, italic = true },

			-- Compatibility aliases (older nvim-treesitter versions)
			["@text.title"]    = { fg = ink, bold = true },
			["@text.strong"]   = { bold = true },
			["@text.emphasis"] = { italic = true },
			["@text.uri"]      = { fg = muted },
			["@text.reference"] = { fg = ink },

			-- ── Diagnostics & VCS ────────────────────────────────────────────

			DiagnosticWarn  = { fg = dim },
			DiagnosticError = { fg = ink, bold = true },
			DiagnosticInfo  = { fg = muted },
			DiagnosticHint  = { fg = muted },

			GitSignsAdd    = { fg = dim, bg = "NONE" },
			GitSignsChange = { fg = dim, bg = "NONE" },
			GitSignsDelete = { fg = ink, bg = "NONE" },

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
