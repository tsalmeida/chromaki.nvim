-- after/plugin/chromaki-overrides.lua
-- Extra polish for chromaki-sepia-blue

local function align_inactive_gutter()
	-- Grab NormalNC background (chromaki's apply() sets the inactive tint)
	local ok, normal_nc = pcall(vim.api.nvim_get_hl, 0, { name = "NormalNC", link = false })
	if not ok or not normal_nc or not normal_nc.bg then
		return
	end

	local bg = normal_nc.bg
	local bg_hex = nil
	if type(bg) == "number" then
		bg_hex = string.format("#%06x", bg)
	elseif type(bg) == "string" and bg:match("^#%x%x%x%x%x%x$") then
		bg_hex = bg
	end
	if not bg_hex then
		return
	end

	-- Align inactive gutters with the inactive window background
	vim.api.nvim_set_hl(0, "LineNrNC", { bg = bg_hex, fg = "NONE" })

	-- REMOVED: These lines were turning the active window's gutter blue
	-- and overwriting the black separator line.
	-- vim.api.nvim_set_hl(0, "SignColumn", { bg = bg_hex, fg = "NONE" })
	-- vim.api.nvim_set_hl(0, "WinSeparator", { bg = bg_hex, fg = "NONE" })
end

local function tweak_tabline()
	if vim.g.colors_name ~= "chromaki-sepia-blue" then
		return
	end

	local light_blue = "#a0c4ff"
	local dark_blue = "#1f3c88"
	local black = "#000000"
	local white = "#ffffff"

	vim.api.nvim_set_hl(0, "TabLine", { fg = black, bg = light_blue })
	vim.api.nvim_set_hl(0, "TabLineSel", { fg = white, bg = dark_blue, bold = true })
	vim.api.nvim_set_hl(0, "TabLineFill", { fg = black, bg = light_blue })
end

local function tweak_statusline()
	if vim.g.colors_name ~= "chromaki-sepia-blue" then
		return
	end

	local dark_blue = "#102a66"
	local dark_blue_dim = "#1c3b80"
	local white = "#ffffff"
	local grey = "#d0d0d0"

	vim.api.nvim_set_hl(0, "StatusLine", { fg = white, bg = dark_blue, bold = false })
	vim.api.nvim_set_hl(0, "StatusLineNC", { fg = grey, bg = dark_blue_dim, bold = false })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ChromakiChroming", { clear = true }),
	callback = function()
		if vim.g.colors_name == "chromaki-sepia-blue" then
			vim.schedule(function()
				align_inactive_gutter()
				tweak_tabline()
				tweak_statusline()
			end)
		end
	end,
})
