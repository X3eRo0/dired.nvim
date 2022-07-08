-- setup nvim-dired.
-- Author: X3eRo0
local config = require("nvim-dired.config")
local dirs = require("nvim-dired.dirs")
local disp = require("nvim-dired.display")
local dired = require("nvim-dired.dired")

local M = {}

function M.setup(opts)
    local errs = config.update(opts)
    if #errs == 1 then
        vim.api.nvim_err_writeln("nvim-dired.setup: " .. errs[1])
    elseif #errs > 1 then
        vim.api.nvim_err_writeln("nvim-dired.setup:")
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
