local fs = require("dired.fs")
local config = require("dired.config")
local display = require("dired.display")
local dirs = require("dired.dirs")
local uv = vim.loop

local M = {}

-- initialize dired buffer
function M.init_dired(history, sp, update_history, from_path)
    -- preserve altbuffer
    local altbuf = vim.fn.bufnr("#")
    local path = fs.get_simplified_path(vim.fn.expand("%"))
    vim.b.current_dired_path = path
    vim.api.nvim_buf_set_name(0, path) -- 0 is current buffer

    -- Add cursor position calculation here

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

    if vim.b.dired_show_hidden == nil then
        vim.b.dired_show_hidden = config.get("show_hidden")
    end

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

    -- the path we are coming from
    local from_path = fs.get_simplified_path(vim.fn.expand("%"))
    -- if from_path == path then
    --     local id = display.get_id_from_listing(vim.api.nvim_get_current_line())
    --     local dir_files =
    -- end

    local keep_alt = ""
    if vim.bo.filetype == "dired" then
        keep_alt = "keepalt"
    end

    local history, sp = vim.b.dired_history, vim.b.dired_history_sp
    vim.cmd(string.format("%s noautocmd edit %s", keep_alt, vim.fn.fnameescape(path)))
    M.init_dired(history, sp, true, from_path)
end

function M.enter_dir(cmd)
    if vim.bo.filetype ~= "dired" then
        return
    end

    if cmd == nil then
        cmd = "edit"
    end

    local dir = vim.b.current_dired_path
    local id = display.get_id_from_listing(vim.api.nvim_get_current_line())
    if id == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = dirs.get_dir_content(dir, config.get("show_hidden"))
    local file = dirs.get_file_by_id(dir_files, id)
    if file == nil then
        vim.api.nvim_err_writeln(string.format("Dired: invalid id (%d) for file.", id))
        return
    end

    local noautocmd = ""
    if file.filetype == "directory" then
        noautocmd = "noautocmd"
    end

    local history, sp = vim.b.dired_history, vim.b.dired_history_sp
    vim.cmd(string.format("keepalt %s %s %s", noautocmd, cmd, vim.fn.fnameescape(file.filepath)))

    if file.filetype == "directory" then
        M.init_dired(history, sp, true)
    end

    -- if file is a directory then enter inside the directory
    -- if file is just a normal file then replace the dired buffer
    -- with that file
end

function M.rename_file()
    local dir = nil
    dir = vim.b.current_dired_path
    local id = display.get_id_from_listing(vim.api.nvim_get_current_line())
    if id == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = dirs.get_dir_content(dir, config.get("show_hidden"))
    local file = dirs.get_file_by_id(dir_files, id)
    fs.FsEntry.RenameFile(file)
    M.init_dired(vim.b.dired_history, vim.b.dired_history_sp, true)
end

function M.create_file()
    fs.FsEntry.CreateFile()
    M.init_dired(vim.b.dired_history, vim.b.dired_history_sp, true)
end

function M.delete_file()
    local dir = nil
    dir = vim.b.current_dired_path
    local id = display.get_id_from_listing(vim.api.nvim_get_current_line())
    if id == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = dirs.get_dir_content(dir, config.get("show_hidden"))
    local file = dirs.get_file_by_id(dir_files, id)
    fs.FsEntry.DeleteFile(file)
    M.init_dired(vim.b.dired_history, vim.b.dired_history_sp, true)
end

return M
