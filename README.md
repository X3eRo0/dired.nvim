# dired.nvim

A file browser inspired from Emacs Dired for neovim.

## Installation

Requires [Neovim 0.6](https://github.com/neovim/neovim/releases/tag/v0.6.0) or
higher.

* [vim-plug]: `Plug "X3eRo0/dired.nvim"`
* [packer.nvim]: `use "X3eRo0/dired.nvim"`

### Setup
You can require this plugin and use it like this.
```lua
require("nvim-dired").setup {
    path_separator = "/",
    show_hidden = false
}
```

## Usage

Run the command `:Dired` to open a buffer for your current
directory. Press `-` in any buffer to open a directory buffer for its parent.
Editing a directory will also open up a buffer, overriding Netrw.

Inside a directory buffer, there are the following keybindings:
* `<CR>`: Open the file or directory at the cursor.
* `d`: Create new directories and files.
* `D`: Delete a directories or files.
* `R`: Rename a directories or files.
* `-`: Open parent directory.
