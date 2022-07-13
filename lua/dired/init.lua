-- setup dired.
-- Author: X3eRo0
local config = require("dired.config")
local dired = require("dired.dired")
local fs = require("dired.fs")

require("dired.highlight").setup()

local M = {}

M.open = dired.open_dir
M.enter = dired.enter_dir
M.init = dired.init_dired
M.rename = dired.rename_file
M.create = dired.create_file
M.delete = dired.delete_file
M.toggle_hidden_files = dired.toggle_hidden_files
M.toggle_sort_order = dired.toggle_sort_order

function M.setup(opts)

    -- apply user config
    local errs = config.update(opts)
    if #errs == 1 then
        vim.api.nvim_err_writeln("dired.setup: " .. errs[1])
    elseif #errs > 1 then
        vim.api.nvim_err_writeln("dired.setup:")
        for _, err in ipairs(errs) do
            vim.api.nvim_err_writeln("    " .. err)
        end
    end

    if vim.g.dired_loaded then
        return
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

    vim.cmd([[command! -nargs=? -complete=dir Dired lua require'dired'.open(<q-args>)]])
    vim.cmd([[command! -nargs=? -complete=file DiredRename lua require'dired'.rename(<q-args>)]])
    vim.cmd([[command! -nargs=? -complete=file DiredDelete lua require'dired'.delete(<q-args>)]])
    vim.cmd([[command! DiredEnter e <cfile>]])
    vim.cmd([[command! DiredCreate lua require'dired'.create()]])
    vim.cmd([[command! DiredToggleHidden lua require'dired'.toggle_hidden_files()]])
    vim.cmd([[command! DiredToggleSortOrder lua require'dired'.toggle_sort_order()]])
    vim.cmd([[command! DiredQuit lua require'dired'.quit()]])

    -- setup keybinds
    local map = vim.api.nvim_set_keymap
    local opt = {unique = true, silent = true, noremap = true}
    map("", "<Plug>(dired_up)", "<cmd>execute 'Dired ..'<cr>", opt)
    map("", "<Plug>(dired_enter)", "<cmd>execute 'DiredEnter'<cr>", opt)
    map("", "<Plug>(dired_rename)", "<cmd>execute 'DiredRename'<cr>", opt)
    map("", "<Plug>(dired_delete)", "<cmd>execute 'DiredDelete'<cr>", opt)
    map("", "<Plug>(dired_create)", "<cmd>execute 'DiredCreate'<cr>", opt)
    map("", "<Plug>(dired_toggle_hidden)", "<cmd>execute 'DiredToggleHidden'<cr>", opt)
    map("", "<Plug>(dired_toggle_sort_order)", "<cmd>execute 'DiredToggleSortOrder'<cr>", opt)

    if vim.fn.mapcheck("-", "n") == "" and not vim.fn.hasmapto("<Plug>(dired_up)", "n") then
        map("n", "-", "<Plug>(dired_up)", {silent = true})
    end

    -- set dired keybinds
    -- from https://www.youtube.com/watch?v=ekMIIAqTZ34
    map = vim.api.nvim_buf_set_keymap
    opt = {silent = true, noremap = true}

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "dired",
        callback = function()
            map(0, "n", "<cr>", "<Plug>(dired_enter)", opt)
            map(0, "n", "-", "<Plug>(dired_up)", opt)
            map(0, "n", "R", "<Plug>(dired_rename)", opt)
            map(0, "n", "d", "<Plug>(dired_create)", opt)
            map(0, "n", "D", "<Plug>(dired_delete)", opt)
            map(0, "n", ".", "<Plug>(dired_toggle_hidden)", opt)
            map(0, "n", ",", "<Plug>(dired_toggle_sort_order)", opt)
        end,
    })

    local dired_group = vim.api.nvim_create_augroup("dired", {clear = true})

    -- open dired when opening a directory
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
	command = "if isdirectory(expand('%')) && !&modified | execute 'lua require(\"dired\").init(vim.b.dired_history, vim.b.dired_history_sp, true)' | endif",
        group = dired_group
    })

    vim.cmd([[silent autocmd! FileExplorer *]])
    vim.cmd([[autocmd VimEnter * silent! autocmd! FileExplorer *]])
    
    vim.g.dired_loaded = true
end

return M
