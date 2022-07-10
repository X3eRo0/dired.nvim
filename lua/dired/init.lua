-- setup dired.
-- Author: X3eRo0
local config = require("dired.config")
local dired = require("dired.dired")

require("dired.highlight").setup()

local M = {}

function M.setup(opts)
    local errs = config.update(opts)
    if #errs == 1 then
        vim.api.nvim_err_writeln("dired.setup: " .. errs[1])
    elseif #errs > 1 then
        vim.api.nvim_err_writeln("dired.setup:")
        for _, err in ipairs(errs) do
            vim.api.nvim_err_writeln("    " .. err)
        end
    end
    -- setup keybinds
    local map = vim.api.nvim_set_keymap
end

M.open = dired.open_dir
M.enter = dired.enter_dir
M.init = dired.init_dired
M.rename = dired.rename_file
M.create = dired.create_file
M.delete = dired.delete_file
return M
