# Image Preview for Neovim

Neovim plugin for image previews.

At moment depends on [WezTerm](https://wezfurlong.org/wezterm/) image terminal support.

![image](https://user-images.githubusercontent.com/430272/194723584-3af9e272-b6b9-456a-af88-e1f79e5213e5.png)

## Installing

### Plug

```
Plug 'https://github.com/adelarsq/image_preview.nvim'
```

## Configuration

Vim Script:

```vim
lua <<EOF
require("image_preview").setup({})
EOF
```

Lua:

```lua
require("image_preview").setup({})
```

## Keybinds

- `<leader>p` - image preview for file under cursor

## Features

- Plugins:
   - [x] [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)
   - [ ] NerdTree
- [x] Windows support. Depends on PowerShell
- [x] macOS support
- [x] Linux support
- [x] bmp, png and jpg
- [ ] svg




