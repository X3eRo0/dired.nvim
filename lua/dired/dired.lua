local fs = require("dired.fs")
local ls = require("dired.ls")
local display = require("dired.display")
local config = require("dired.config")
local dirs = require("dired.dirs")
local funcs = require("dired.functions")

local M = {}

-- initialize dired buffer
function M.init_dired(history, sp, update_history)
    -- preserve altbuffer
    local altbuf = vim.fn.bufnr("#")
    local path = fs.get_simplified_path(vim.fn.expand("%"))
    -- set current path
    vim.g.current_dired_path = path
    -- set buffer name to path
    vim.api.nvim_buf_set_name(0, path) -- 0 is current buffer

    -- if history stack is nil then initialize
    -- history stack and stack pointer
    if history == nil then
        history = {}
        sp = 0
    end

    if update_history then
        -- empty the history
        while sp < #history do
            table.remove(history)
        end

        if path ~= history[sp] then
            table.insert(history, path)
            sp = sp + 1
        end
    end

    vim.b.dired_history = history
    vim.b.dired_history_sp = sp

    vim.bo.filetype = "dired"
    vim.bo.buftype = "acwrite"
    vim.bo.bufhidden = "wipe"
    vim.bo.modifiable = true

    if altbuf ~= -1 then
        vim.fn.setreg("#", altbuf)
    end

    if fs.is_directory(path) ~= true then
        path = fs.get_parent_path(path)
    end
    vim.api.nvim_set_current_dir(path)
    display.render(path)
end

function M.open_dir(path)
    if path == "" then
        path = "."
    end

    path = fs.get_simplified_path(fs.get_absolute_path(path))

    local keep_alt = ""
    if vim.bo.filetype == "dired" then
        keep_alt = "keepalt"
    end

    local history, sp = vim.b.dired_history, vim.b.dired_history_sp
    vim.cmd(string.format("%s noautocmd edit %s", keep_alt, vim.fn.fnameescape(path)))
    M.init_dired(history, sp, true)
end

function M.enter_dir()
    vim.notify("Entering a directory")
    if vim.bo.filetype ~= "dired" then
        return
    end

    local cmd = "edit"

    local dir = vim.g.current_dired_path
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir, vim.g.dired_show_dot_dirs, vim.g.dired_show_hidden)
    local file = ls.get_file_by_filename(dir_files, filename)
    if file == nil then
        vim.api.nvim_err_writeln(string.format("Dired: invalid filename (%s) for file.", filename))
        return
    end

    if file.filetype == "directory" then
        vim.cmd(string.format("keepalt noautocmd %s %s", cmd, vim.fn.fnameescape(file.filepath)))
    else
        vim.cmd(string.format("keepalt %s %s", cmd, vim.fn.fnameescape(file.filepath)))
    end

    local history, sp = vim.b.dired_history, vim.b.dired_history_sp

    if file.filetype == "directory" then
        M.init_dired(history, sp, true)
    end

    -- if file is a directory then enter inside the directory
    -- if file is just a normal file then replace the dired buffer
    -- with that file
end

function M.toggle_hidden_files()
    vim.g.dired_show_hidden = not vim.g.dired_show_hidden
    local history, sp = vim.b.dired_history, vim.b.dired_history_sp
    M.init_dired(history, sp, true)
end

function M.toggle_sort_order()
    vim.g.dired_sort_order = config.get_next_sort_order()
    local history, sp = vim.b.dired_history, vim.b.dired_history_sp
    M.init_dired(history, sp, true)
end

function M.rename_file()
    local dir = nil
    dir = vim.g.current_dired_path
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir, vim.g.dired_show_dot_dirs, vim.g.dired_show_hidden)
    local file = ls.get_file_by_filename(dir_files, filename)
    funcs.rename_file(file)
    M.init_dired(vim.b.dired_history, vim.b.dired_history_sp, true)
end

function M.create_file()
    funcs.create_file()
    M.init_dired(vim.b.dired_history, vim.b.dired_history_sp, true)
end

function M.delete_file()
    local dir = nil
    dir = vim.g.current_dired_path
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir, vim.g.dired_show_dot_dirs, vim.g.dired_show_hidden)
    local file = ls.get_file_by_filename(dir_files, filename)
    funcs.delete_file(file)
    M.init_dired(vim.b.dired_history, vim.b.dired_history_sp, true)
end

return M
