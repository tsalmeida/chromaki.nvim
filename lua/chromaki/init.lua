local M = {}

local function reset_catppuccin_compiler()
        -- Catppuccin's compiler module captures its options table at require
        -- time. Chromaki changes compile_path per colorscheme, so reload the
        -- compiler before setup to keep cache writes aligned with cache loads.
        package.loaded["catppuccin.lib.compiler"] = nil
end

local function clear_terminal_palette()
        for index = 0, 15 do
                vim.g["terminal_color_" .. index] = nil
        end
end

local function as_hex(s)
        return (type(s) == "string" and s:match("^#%x%x%x%x%x%x$")) and s or nil
end

local function default_integrations()
        return {
                cmp = true,
                gitsigns = true,
                neotree = true,
                mason = true,
                mini = {
                        enabled = true,
                        indentscope = { enabled = true },
                },
                native_lsp = {
                        enabled = true,
                        inlay_hints = { background = true },
                },
                noice = true,
                notify = true,
                indent_blankline = {
                        enabled = true,
                        colored_indent_levels = false,
                },
                telescope = {
                        enabled = true,
                },
                treesitter = true,
                which_key = true,
        }
end

local function default_highlights(colors)
        return {
                NormalFloat = { bg = colors.mantle },
                FloatBorder = { fg = colors.surface1, bg = colors.mantle },
                FloatTitle = { fg = colors.text, bg = colors.mantle },
                NormalNC = { bg = colors.base },
                CursorLine = { bg = colors.surface0 },
                CursorLineNr = { fg = colors.yellow },
                Visual = { bg = colors.surface1 },
                Pmenu = { bg = colors.surface0, fg = colors.text },
                PmenuSel = { bg = colors.surface1, fg = colors.text },
                PmenuSbar = { bg = colors.surface0 },
                PmenuThumb = { bg = colors.surface2 },
                TelescopeBorder = { fg = colors.surface1, bg = colors.mantle },
                TelescopeNormal = { bg = colors.mantle, fg = colors.text },
                TelescopeTitle = { fg = colors.mantle, bg = colors.blue, bold = true },
                TelescopePromptBorder = { fg = colors.surface1, bg = colors.mantle },
                TelescopePromptNormal = { fg = colors.text, bg = colors.mantle },
                TelescopePromptTitle = { fg = colors.mantle, bg = colors.peach, bold = true },
                TelescopeResultsBorder = { fg = colors.surface0, bg = colors.base },
                TelescopeResultsNormal = { fg = colors.text, bg = colors.base },
                TelescopePreviewBorder = { fg = colors.surface0, bg = colors.base },
                TelescopePreviewNormal = { fg = colors.text, bg = colors.base },
                GitSignsCurrentLineBlame = { fg = colors.overlay1, italic = true },
        }
end

local function resolve_extra_highlights(extra, colors)
        if type(extra) == "function" then
                return extra(colors)
        elseif type(extra) == "table" then
                return extra
        end
        return {}
end

---@class ChromakiSpec
---@field name string : colorscheme name reported to :colorscheme
---@field flavour "mocha"|"latte"
---@field palette table<string, string>
---@field background? "dark"|"light"
---@field transparent? boolean : drop the editor background so the terminal's own background (e.g. the paper texture image) shows through
---@field inactive_win_bg? string : hex tint for inactive windows (NormalNC); falls back to vim.g.inactive_win_bg_hint
---@field custom_highlights? table<string, table>|fun(colors: table):table
---@field setup? table : extra catppuccin.setup options

---Apply a Chromaki preset by configuring Catppuccin and forwarding highlights.
---@param spec ChromakiSpec
function M.apply(spec)
        local cp = require("catppuccin")

        local colour_overrides = spec.setup and spec.setup.color_overrides or {}
        colour_overrides = vim.tbl_deep_extend("force", {}, colour_overrides)
        colour_overrides[spec.flavour] = spec.palette

        local extra_highlights = spec.custom_highlights
        local transparent = spec.transparent or false
        -- Catppuccin compiles by flavour, so isolate each Chromaki palette.
        local compile_name = spec.name:gsub("[^%w_.-]", "_")
        local compile_path = vim.fn.stdpath("cache") .. "/chromaki/" .. compile_name

        local setup_opts = vim.tbl_deep_extend("force", {
                flavour = spec.flavour,
                transparent_background = transparent,
                term_colors = false,
                background = { light = "latte", dark = "mocha" },
                compile = { enabled = true, path = compile_path },
                compile_path = compile_path,
                default_integrations = true,
                integrations = default_integrations(),
                styles = {
                        comments = { "italic" },
                        conditionals = {},
                        loops = {},
                        functions = {},
                        keywords = {},
                        strings = {},
                        variables = {},
                        numbers = {},
                        booleans = {},
                        properties = {},
                        types = {},
                        operators = {},
                },
                color_overrides = colour_overrides,
                custom_highlights = function(colors)
                        local highlights = default_highlights(colors)
                        local extra = resolve_extra_highlights(extra_highlights, colors)
                        if extra and next(extra) ~= nil then
                                highlights = vim.tbl_deep_extend("force", highlights, extra)
                        end
                        if transparent then
                                -- Presets set Normal/NormalNC bg explicitly, which would
                                -- defeat transparent_background; strip them back out.
                                -- (The inactive-window tint below is skipped for
                                -- transparent schemes, so NormalNC stays see-through.)
                                highlights.Normal =
                                        vim.tbl_extend("force", highlights.Normal or {}, { bg = "NONE" })
                                highlights.NormalNC =
                                        vim.tbl_extend("force", highlights.NormalNC or {}, { bg = "NONE" })
                        end
                        return highlights
                end,
        }, spec.setup or {})

        reset_catppuccin_compiler()
        cp.setup(setup_opts)
        if cp.load then
                cp.load(spec.flavour)
        else
                vim.cmd.colorscheme("catppuccin-" .. spec.flavour)
        end

        vim.opt.background = spec.background or (spec.flavour == "latte" and "light" or "dark")
        vim.g.colors_name = spec.name

        -- Coloured inactive windows, self-contained. Each preset publishes its
        -- tint via spec.inactive_win_bg (or the vim.g.inactive_win_bg_hint global,
        -- which logarktos's focus dimming also reads). Apply it to NormalNC here
        -- so the effect works with chromaki alone, no external consumer required.
        -- Transparent schemes intentionally keep NormalNC see-through.
        local inactive_bg = as_hex(spec.inactive_win_bg) or as_hex(vim.g.inactive_win_bg_hint)
        if inactive_bg and not transparent then
                vim.api.nvim_set_hl(0, "NormalNC", { bg = inactive_bg, fg = "NONE" })
        end

        if setup_opts.term_colors == false then
                if transparent then
                        -- Transparent schemes show the terminal's own background image through
                        -- bg = "NONE" cells.  Clearing the palette leaves Neovim's built-in
                        -- #000000 as terminal_color_0, so :terminal apps that paint their
                        -- background with ANSI colour-0 get solid black -- hiding the dark
                        -- (#1a1a1a) foreground text against it.  Pin colours 0/7/15 to the
                        -- scheme's ink-on-parchment anchors instead; leave accent colours
                        -- (1-6, 8-14) as Neovim's built-in standard ANSI values.
                        local p = colour_overrides[spec.flavour] or {}
                        vim.g.terminal_color_0  = p.base  or nil
                        vim.g.terminal_color_7  = p.text  or nil
                        vim.g.terminal_color_15 = p.text  or nil
                        for i = 1, 6  do vim.g["terminal_color_" .. i] = nil end
                        for i = 8, 14 do vim.g["terminal_color_" .. i] = nil end
                else
                        clear_terminal_palette()
                end
        end
end

return M
