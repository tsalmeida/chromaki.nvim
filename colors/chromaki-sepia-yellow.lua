-- colors/chromaki-sepia-yellow.lua
-- Sepia page for the main text, yellow-tinted chrome & inactive windows.

local chromaki = require("chromaki")

-- Hint for FocusMode (personal.lua): warm golden beige for inactive windows.
vim.g.inactive_win_bg_hint = "#e9d481"

chromaki.apply({
        name = "chromaki-sepia-yellow",
        flavour = "latte",
        background = "light",

        -- Sepia base + shared accent palette (focus: yellow UI surfaces)
        palette = {
                -- Accents (shared with other sepia variants)
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

                -- Surfaces: golden chrome framing the sepia page
                surface2 = "#e9d481",
                surface1 = "#dbc569",
                surface0 = "#c8b45c",

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

                -- Yellow accent for chrome elements
                local accent = colors.yellow
                local dark_accent_bg = colors.peach
                local dark_accent_fg = colors.yellow

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

                        -- Statusline: white text on a warm strip
                        StatusLine = { fg = white, bg = dark_accent_bg },
                        StatusLineNC = { fg = colors.overlay2, bg = dark_accent_bg },

                        -- Terminal statuslines follow the same style
                        StatusLineTerm = { link = "StatusLine" },
                        StatusLineTermNC = { link = "StatusLineNC" },

                        -- Tabline: golden bar + coloured tabs
                        TabLineFill = { bg = surface1, fg = colors.overlay1 },
                        TabLine = { bg = surface2, fg = colors.overlay0 },
                        TabLineSel = { bg = "#ffffff", fg = accent, bold = true },

                        -- Popups / floating windows: sepia dialog
                        NormalFloat = { fg = text, bg = colors.mantle },

                        -- Yellow border over sepia background
                        FloatBorder = { fg = surface0, bg = colors.mantle },

                        -- Menus (completion etc.) on golden chrome
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

                        -- Mode messages: warm yellow on white
                        ModeMsg = { fg = dark_accent_fg, bg = white, bold = true },
                        MoreMsg = { fg = dark_accent_fg, bg = white, bold = true },
                }
        end,
})
