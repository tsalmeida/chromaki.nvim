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

-- Active spotlight configuration: { scheme = <colors_name>, inactive =
-- "flat"|"capture" }. Module-level so stale scheduled ColorScheme callbacks
-- evaluate against the current state, not the one they were created under.
local config = nil

-- The "flat" inactive dark-mode tones
local dark = {
	bg = "#000000",
	panel = "#121212", -- floats / statusline strips
	fg = "#cfcfcf", -- regular text
	dim = "#8a8a8a", -- comments, diagnostics, anything secondary
	faint = "#4a4a4a", -- line numbers, whitespace, borders
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
				bg = "NONE",
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
-- pickers/popups stay readable while focused elsewhere.
local function update()
	if not config or vim.g.colors_name ~= config.scheme then return end
	local ns = config.inactive == "capture" and NS_CAPTURE or NS_FLAT
	local cur = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win == cur or vim.api.nvim_win_get_config(win).relative ~= "" then
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

---@param opts { scheme: string, inactive?: "flat"|"capture" }
function M.enable(opts)
	config = { scheme = opts.scheme, inactive = opts.inactive or "flat" }

	if config.inactive == "flat" then
		build_flat()
	end

	local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

	vim.api.nvim_create_autocmd({ "WinEnter", "WinNew", "TabEnter", "VimEnter" }, {
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
