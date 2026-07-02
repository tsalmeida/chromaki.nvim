# chromaki.nvim

A family of Neovim colorschemes built on [Catppuccin](https://github.com/catppuccin/nvim), centred on warm sepia tones with deliberate active/inactive window contrast.

The main idea: when your focus moves between windows, the inactive ones shift — either to a cooler tinted chrome, or (in the spotlight variants) to full dark mode — so your eye always knows where the cursor is without reading line numbers.

## Variants

| Colorscheme | Character |
|---|---|
| `chromaki-sepia-purple` | Sepia page, lilac/purple chrome |
| `chromaki-sepia-blue` | Sepia page, steel-blue chrome |
| `chromaki-sepia-green` | Sepia page, muted-green chrome |
| `chromaki-sepia-red` | Sepia page, brick-red chrome |
| `chromaki-sepia-yellow` | Sepia page, amber chrome |
| `chromaki-sepia-night` | Sepia page, deep-indigo chrome |
| `chromaki-sepia` | Plain sepia, no accent tint |
| `chromaki-dark` | Dark mode — inactive windows lighten instead of darken |
| `chromaki-dark-blue` | Dark mode with blue accent |
| `chromaki-dark-green` | Dark mode with green accent |
| `chromaki-sepia-light-transparent` | Sepia page, terminal background shows through inactive windows |
| `chromaki-sepia-dark-transparent` | Dark version of the transparent variant |
| `chromaki-light-transparent-spotlight` | Active window: sepia. Inactive windows: flat monochrome dark, terminal background visible. Terminals: always Matrix green-on-black |
| `chromaki-spotlight-sepia-inverted` | Active window: sepia. Inactive windows: captured dark snapshot |
| `chromaki-transparent-light-bones-spotlight` | Bone-white spotlight variant with terminal background. Terminals: always Matrix green-on-black |
| `chromaki-matrix` | Phosphor green on pure black, bright-green separator bars, red kept for real errors |

## Requirements

- Neovim 0.8+
- [catppuccin/nvim](https://github.com/catppuccin/nvim) (declared as a dependency — installed automatically by Lazy)

## Installation

### lazy.nvim

```lua
{
  "tsalmeida/chromaki.nvim",
  dependencies = { "catppuccin/nvim" },
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("chromaki-sepia-purple")
  end,
}
```

Replace `"chromaki-sepia-purple"` with any variant from the table above.

## Active/inactive window contrast

Every variant except the transparent ones uses solid background colours. The inactive chrome colour comes from the `surface` palette entries — warmer or cooler depending on the variant's accent.

The **spotlight** variants go further: inactive windows are re-rendered in a separate highlight namespace (`nvim_win_set_hl_ns`), making them truly dark-mode regardless of the global scheme. This covers treesitter captures too, not just UI groups.

The **transparent** variants let the terminal's own background image show through inactive windows.

## Terminal windows in the spotlight variants

`:terminal` windows can't follow the light/dark spotlight split: app text drawn with explicit ANSI colours resolves through the single global `vim.g.terminal_color_0..15` palette, which no window namespace can remap, so any palette tuned for the light active window is unreadable in a dark inactive window and vice versa. The transparent spotlight variants therefore give terminals a third, permanent world of their own (`terminal = "matrix"` in `spotlight.lua`): phosphor green on black, focused or not, with the global ANSI palette pinned to a matching green ramp (red and yellow-green survive for errors and warnings). Focus on a terminal is signalled by its statusline — a bright phosphor bar when active — rather than by recolouring content. Note that Neovim reads the palette at `TermOpen`, so terminals opened before switching to the scheme keep their old colours until restarted.

## Focus mode integration

`vim.g.inactive_win_bg_hint` is set by each colorscheme to the intended inactive-window background colour. A focus-mode autocmd can read this to tint `NormalNC` at runtime, creating a smooth "dim inactive windows" effect without the spotlight machinery.

## License

MIT
