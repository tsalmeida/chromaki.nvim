-- colors/chromaki-sepia-dark-transparent.lua
-- Identical to chromaki-dark, except the active-window background is
-- transparent so the terminal's own background shows through. Keep the
-- palette/highlights in sync with colors/chromaki-dark.lua.
-- Note: on a light terminal background (the wood panel image) the light text of
-- this scheme needs a dark terminal background to stay readable.

local chromaki = require("chromaki")

chromaki.apply({
        name = "chromaki-sepia-dark-transparent",
        flavour = "mocha",
        background = "dark",
        transparent = true, -- show the terminal's background in the active window
        palette = {
                rosewater = "#f2b8c6",
                flamingo = "#f18aad",
                pink = "#f3a4ff",
                mauve = "#c6a0ff",
                red = "#ff5a70",
                maroon = "#ff6b8f",
                peach = "#f29d69",
                yellow = "#f1d06a",
                green = "#63d38c",
                teal = "#4fd0c5",
                sky = "#73d2ff",
                sapphire = "#55b7ff",
                blue = "#5f78ff",
                lavender = "#9aa4ff",
                text = "#e8ecff",
                subtext1 = "#c6cae5",
                subtext0 = "#adb2ce",
                overlay2 = "#8b90b0",
                overlay1 = "#7a7f9c",
                overlay0 = "#696f88",
                surface2 = "#585d75",
                surface1 = "#44495f",
                surface0 = "#32364a",
                base = "#0c0d14",
                mantle = "#0a0b10",
                crust = "#05060b",
        },
        custom_highlights = function(colors)
                return {
                        Comment = { fg = colors.overlay1, italic = true },
                        LineNr = { fg = colors.overlay0 },
                        CursorLineNr = { fg = colors.yellow, bold = true },
                        StatusLine = { fg = colors.text, bg = colors.surface0 },
                        StatusLineNC = { fg = colors.overlay0, bg = colors.surface0 },
                        VertSplit = { fg = colors.surface0 },
                        WinSeparator = { fg = colors.surface0 },
                        DiagnosticWarn = { fg = colors.peach },
                        DiagnosticError = { fg = colors.red },
                        DiagnosticInfo = { fg = colors.sky },
                        DiagnosticHint = { fg = colors.teal },
                }
        end,
})
