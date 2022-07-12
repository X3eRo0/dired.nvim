# dired.nvim

A file browser inspired from Emacs Dired for neovim.

![image](https://user-images.githubusercontent.com/24680989/178328330-f7e3f502-b83b-4559-9d4d-606389a6a5ea.png)
![image](https://user-images.githubusercontent.com/24680989/178287820-a1826d5f-2109-4c1d-a38d-38fe549ccc11.png)


## Installation

Requires [Neovim 0.6](https://github.com/neovim/neovim/releases/tag/v0.6.0) or
higher.

```
use {
    "X3eRo0/dired.nvim",
    requires = "MunifTanjim/nui.nvim",
    config = function()
        require("dired").setup {
            path_separator = "/",
            show_banner = false,
            show_hidden = true
        }
    end
}
```

### Setup
You can require this plugin and use it like this.
```lua
require("dired").setup {
    path_separator = "/",
    show_banner = false,
    show_hidden = true
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
* `.`: Toggle show_hidden.
* `,`: Change sort_order.

## TODO

1. Get directory listing from "ls" dired mode.
2. Allow moving and copying of files.
3. Allow changing file permissions.
