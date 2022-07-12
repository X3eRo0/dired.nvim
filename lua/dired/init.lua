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

    -- global variable for show_hidden
    if config.get("show_hidden") == nil then
        -- default for show-hidden is true
        vim.g.dired_show_hidden = true
    else
        vim.g.dired_show_hidden = config.get("show_hidden")
    end

    -- global variable for sort_order
    if config.get("sort_order") == nil then
        -- default for sort_order is sort_by_name
        vim.g.dired_sort_order = true
    else
        vim.g.dired_sort_order = config.get("sort_order")
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
M.toggle_hidden_files = dired.toggle_hidden_files
M.toggle_sort_order = dired.toggle_sort_order
return M
