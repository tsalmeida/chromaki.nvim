-- lua/chromaki/spotlight.lua
-- Per-window "spotlight" rendering for the chromaki spotlight schemes: the
-- active window keeps the real (light) colorscheme, while every inactive
-- window is re-rendered dark -- as focus moves, one window goes dark while
-- another is revealed.
--
-- Two inactive looks are supported:
--   "flat"    -- plain light-grey text on solid black, syntax flattened
--                (chromaki-light-transparent-spotlight)
--   "capture" -- a snapshot of a real donor colorscheme, e.g. chromaki-dark
--                (chromaki-spotlight-sepia-inverted); fill it with M.capture()
--                before chromaki.apply() repaints the global scheme
--
-- Terminal windows are a special case (opts.terminal = "matrix"): they render
-- phosphor-green-on-black WHETHER OR NOT they are focused. Terminals can't
-- follow the light/dark spotlight split anyway -- app text drawn with explicit
-- ANSI colors resolves through the single global vim.g.terminal_color_0..15
-- palette, which no window namespace can remap -- so any palette tuned for the
-- light active window is unreadable in a dark inactive window and vice versa.
-- Giving terminals one permanent look of their own dissolves that conflict:
-- the global ANSI palette is pinned to a green ramp that is correct in the
-- terminal's only state. Focus is still signalled by the statusline (bright
-- phosphor bar when active) and the cursor, not by recoloring the content.
--
-- How: nvim_win_set_hl_ns() (Neovim 0.8+) makes a window resolve highlight
-- groups from a namespace before falling back to the global scheme. That
-- covers treesitter @captures too, so by defining a dark version of every
-- global highlight group inside a namespace and attaching it to inactive
-- windows, those windows become dark-mode. NormalNC alone (what focus.lua
-- tints) can never do this, because syntax groups are global.

local M = {}

local AUGROUP = "ChromakiSpotlight"
local NS_FLAT = vim.api.nvim_create_namespace("chromaki_spotlight_flat")
local NS_CAPTURE = vim.api.nvim_create_namespace("chromaki_spotlight_capture")
local NS_TERM = vim.api.nvim_create_namespace("chromaki_spotlight_term")

-- Active spotlight configuration: { scheme = <colors_name>, inactive =
-- "flat"|"capture", terminal = "matrix"|nil }. Module-level so stale scheduled
-- ColorScheme callbacks evaluate against the current state, not the one they
-- were created under.
local config = nil

-- The "flat" inactive dark-mode tones
local dark = {
	bg = "#000000",
	panel = "#121212", -- floats / statusline strips
	fg = "#cfcfcf", -- regular text
	dim = "#8a8a8a", -- comments, diagnostics, anything secondary
	faint = "#4a4a4a", -- line numbers, whitespace, borders
}

-- The "matrix" terminal tones (same phosphor ramp as chromaki-matrix)
local matrix = {
	bg = "#000000",
	phosphor = "#00ff41", -- cursor / focused statusline bar
	bright = "#5bff87",
	fg = "#2ee65f", -- default terminal text
	mid = "#1fd14c",
	dim = "#118a32",
	faint = "#0a3d18",
	panel = "#031a0a",
	bar = "#19c247", -- focused statusline strip
}

-- Global ANSI-16 palette for terminals, green-on-black. vim.g.terminal_color_x
-- can't vary per window, but with opts.terminal = "matrix" terminals have a
-- single permanent look, so one global palette is finally correct everywhere.
-- Non-green survivors: red (1/9) so real errors stay unmistakable, and
-- yellow slots (3/11) drift to yellow-green so warnings read as alerts.
local term_ansi = {
	[0] = matrix.bg,
	[1] = "#ff3b3b",
	[2] = "#3bff66",
	[3] = "#b6ff00",
	[4] = matrix.mid,
	[5] = "#62ff86",
	[6] = "#39e85f",
	[7] = matrix.fg,
	[8] = matrix.dim,
	[9] = "#ff5c5c",
	[10] = matrix.bright,
	[11] = "#d2ff3a",
	[12] = "#4dff70",
	[13] = "#a6ffbb",
	[14] = "#7dffa0",
	[15] = matrix.bright,
}

-- UI groups that need real (non-flattened) definitions in the flat namespace.
local function ui_overrides()
	return {
		Normal = { fg = dark.fg, bg = dark.bg },
		NormalNC = { fg = dark.fg, bg = dark.bg },
		NormalFloat = { fg = dark.fg, bg = dark.panel },
		FloatBorder = { fg = dark.faint, bg = dark.panel },
		FloatTitle = { fg = dark.fg, bg = dark.panel },
		LineNr = { fg = dark.faint, bg = dark.bg },
		LineNrNC = { fg = dark.faint, bg = dark.bg },
		CursorLineNr = { fg = dark.dim, bg = dark.bg },
		SignColumn = { bg = dark.bg },
		FoldColumn = { fg = dark.faint, bg = dark.bg },
		Folded = { fg = dark.dim, bg = dark.panel },
		CursorLine = { bg = dark.bg },
		CursorColumn = { bg = dark.bg },
		ColorColumn = { bg = dark.panel },
		Visual = { fg = "NONE", bg = "#333333" },
		Search = { fg = dark.bg, bg = dark.dim },
		CurSearch = { fg = dark.bg, bg = dark.fg },
		IncSearch = { fg = dark.bg, bg = dark.fg },
		MatchParen = { fg = "#ffffff", bg = "#3a3a3a", bold = true },
		NonText = { fg = dark.faint },
		Whitespace = { fg = dark.faint },
		SpecialKey = { fg = dark.faint },
		EndOfBuffer = { fg = dark.bg, bg = dark.bg },
		Conceal = { fg = dark.dim },
		WinSeparator = { fg = "#000000", bg = "#000000" },
		VertSplit = { fg = "#000000", bg = "#000000" },
		StatusLine = { fg = dark.dim, bg = dark.panel },
		StatusLineNC = { fg = dark.dim, bg = dark.panel },
		WinBar = { fg = dark.dim, bg = dark.bg },
		WinBarNC = { fg = dark.dim, bg = dark.bg },
		Comment = { fg = dark.dim, italic = true },
		DiffAdd = { fg = dark.fg, bg = "#10210f" },
		DiffChange = { fg = dark.fg, bg = "#1a1a24" },
		DiffDelete = { fg = dark.dim, bg = "#241010" },
		DiffText = { fg = dark.fg, bg = "#2a2a3a" },
	}
end

-- Resolve a group's final attributes, following link chains inside the
-- snapshot returned by nvim_get_hl(0, {}).
local function resolve(all, name, depth)
	local attrs = all[name]
	if not attrs then return nil end
	if attrs.link and depth < 10 then
		return resolve(all, attrs.link, depth + 1) or attrs
	end
	return attrs
end

local function pick_fg(name)
	local lower = name:lower()
	if lower:find("comment") or lower:find("diagnostic") or lower:find("git") then
		return dark.dim
	end
	return dark.fg
end

-- Define, inside NS_FLAT, a flattened (monochrome) version of every
-- highlight group currently known to the global namespace.
local function build_flat()
	local all = vim.api.nvim_get_hl(0, {})
	local overrides = ui_overrides()

	for name in pairs(all) do
		if not overrides[name] then
			local src = resolve(all, name, 0) or {}
			vim.api.nvim_set_hl(NS_FLAT, name, {
				fg = pick_fg(name),
				bg = dark.bg,
				sp = dark.dim,
				bold = src.bold or nil,
				italic = src.italic or nil,
				underline = src.underline or nil,
				undercurl = src.undercurl or nil,
				underdouble = src.underdouble or nil,
				underdotted = src.underdotted or nil,
				underdashed = src.underdashed or nil,
				strikethrough = src.strikethrough or nil,
			})
		end
	end

	for name, attrs in pairs(overrides) do
		vim.api.nvim_set_hl(NS_FLAT, name, attrs)
	end
end

-- Define the terminal-window namespace: green-on-black for everything a
-- terminal window can show. Groups not defined here fall back to the global
-- scheme, but terminals draw almost everything through Normal + explicit ANSI
-- cells, so this short list covers the visible surface.
local function build_term()
	local groups = {
		Normal = { fg = matrix.fg, bg = matrix.bg },
		NormalNC = { fg = matrix.fg, bg = matrix.bg },
		TermCursor = { fg = matrix.bg, bg = matrix.phosphor },
		TermCursorNC = { fg = matrix.bg, bg = matrix.dim },
		CursorLine = { bg = matrix.panel },
		Visual = { fg = "NONE", bg = "#0c4a22" },
		Search = { fg = matrix.bg, bg = matrix.phosphor },
		CurSearch = { fg = matrix.bg, bg = matrix.bright },
		IncSearch = { fg = matrix.bg, bg = "#b6ff00" },
		LineNr = { fg = "#0a4f20", bg = matrix.bg },
		CursorLineNr = { fg = matrix.phosphor, bg = matrix.bg, bold = true },
		SignColumn = { bg = matrix.bg },
		NonText = { fg = matrix.faint },
		Whitespace = { fg = matrix.faint },
		EndOfBuffer = { fg = matrix.bg, bg = matrix.bg },
		-- Focus cue: bright phosphor bar when the terminal is the active
		-- window, dim strip otherwise -- content colors never change.
		StatusLine = { fg = matrix.bg, bg = matrix.bar },
		StatusLineNC = { fg = "#1fb045", bg = "#05190d" },
		StatusLineTerm = { fg = matrix.bg, bg = matrix.bar },
		StatusLineTermNC = { fg = "#1fb045", bg = "#05190d" },
		WinBar = { fg = matrix.fg, bg = matrix.bg },
		WinBarNC = { fg = matrix.dim, bg = matrix.bg },
	}
	for name, attrs in pairs(groups) do
		vim.api.nvim_set_hl(NS_TERM, name, attrs)
	end
end

-- Pin the global ANSI palette to the green ramp. Neovim reads these variables
-- at TermOpen, so this recolors terminals opened AFTER the scheme loads --
-- terminals already running keep their old palette until restarted. (At
-- startup the colorscheme loads before any layout opens its terminals, so the
-- normal flow is fine.)
local function apply_term_palette()
	for i = 0, 15 do
		vim.g["terminal_color_" .. i] = term_ansi[i]
	end
end

-- Load a donor colorscheme and snapshot every global highlight group into
-- the capture namespace. Call this at the TOP of a spotlight colors file,
-- before chromaki.apply() repaints the global scheme; the donor's global
-- state is not restored here -- the apply() that follows replaces it.
function M.capture(donor)
	-- NOT :colorscheme -- that command is a silent no-op while another colors
	-- file is being sourced (Vim's load_colors() recursion guard), and capture
	-- runs from inside a spotlight colors file. Sourcing the donor's colors
	-- file directly sidesteps the guard.
	pcall(vim.cmd.runtime, "colors/" .. donor .. ".lua")
	if vim.g.colors_name ~= donor then
		vim.notify("chromaki spotlight: could not load donor scheme " .. donor, vim.log.levels.WARN)
		return
	end
	local all = vim.api.nvim_get_hl(0, {})
	for name in pairs(all) do
		local attrs = vim.tbl_extend("force", {}, resolve(all, name, 0) or {})
		attrs.link = nil
		attrs.default = nil
		vim.api.nvim_set_hl(NS_CAPTURE, name, attrs)
	end
end

local function set_win_ns(win, ns)
	pcall(vim.api.nvim_win_set_hl_ns, win, ns)
end

-- Current window gets the real scheme (namespace 0); every other regular
-- window in the tab gets the dark namespace. Floats keep the real scheme so
-- pickers/popups stay readable while focused elsewhere. Terminal windows
-- (with terminal = "matrix") get the green namespace no matter what.
local function update()
	if not config or vim.g.colors_name ~= config.scheme then return end
	local ns = config.inactive == "capture" and NS_CAPTURE or NS_FLAT
	local cur = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if config.terminal == "matrix" and vim.bo[buf].buftype == "terminal" then
			set_win_ns(win, NS_TERM)
		elseif win == cur or vim.api.nvim_win_get_config(win).relative ~= "" then
			set_win_ns(win, 0)
		else
			set_win_ns(win, ns)
		end
	end
end

function M.disable()
	config = nil
	pcall(vim.api.nvim_del_augroup_by_name, AUGROUP)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		set_win_ns(win, 0)
	end
end

---@param opts { scheme: string, inactive?: "flat"|"capture", terminal?: "matrix" }
function M.enable(opts)
	config = { scheme = opts.scheme, inactive = opts.inactive or "flat", terminal = opts.terminal }

	if config.inactive == "flat" then
		build_flat()
	end
	if config.terminal == "matrix" then
		build_term()
		-- Runs after chromaki.apply(), overriding the palette apply() pinned.
		apply_term_palette()
	end

	local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

	-- TermOpen matters when a buffer becomes a terminal inside a window that
	-- update() already routed by its old, non-terminal buftype.
	vim.api.nvim_create_autocmd({ "WinEnter", "WinNew", "BufEnter", "TabEnter", "VimEnter", "TermOpen" }, {
		group = group,
		callback = update,
	})

	-- chromaki.apply() fires ColorScheme with the underlying catppuccin name
	-- before vim.g.colors_name gets its final value, so check after a tick.
	-- Capture mode never rebuilds here: re-sourcing the colors file already
	-- re-captures, and rebuilding now would clobber the global scheme again.
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			vim.schedule(function()
				if config and vim.g.colors_name == config.scheme then
					if config.inactive == "flat" then
						build_flat()
					end
					if config.terminal == "matrix" then
						apply_term_palette()
					end
					update()
				else
					M.disable()
				end
			end)
		end,
	})

	update()
end

return M
