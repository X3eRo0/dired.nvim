local fs = require("dired.fs")
local ls = require("dired.ls")
local display = require("dired.display")
local config = require("dired.config")
local funcs = require("dired.functions")
local utils = require("dired.utils")
local marker = require("dired.marker")
local history = require("dired.history")
local clipboard = require("dired.clipboard")

local M = {}

-- initialize dired buffer
function M.init_dired()
    -- preserve altbuffer
    local altbuf = vim.fn.bufnr("#")
    local path = fs.get_simplified_path(vim.fn.expand("%"))

    if vim.g.current_dired_path == nil then
        vim.g.current_dired_path = path
    end

    -- set current path
    vim.g.current_dired_path = path
    -- set buffer name to path
    vim.api.nvim_buf_set_name(0, path) -- 0 is current buffer

    vim.bo.filetype = "Dired"
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

-- open a new directory
function M.open_dir(path)
    if path == "" then
        path = "."
    end

    path = fs.get_simplified_path(fs.get_absolute_path(path))

    local keep_alt = ""
    if vim.bo.filetype == "dired" then
        keep_alt = "keepalt"
    end

    history.push_path(vim.g.current_dired_path)
    vim.cmd(string.format("%s noautocmd edit %s", keep_alt, vim.fn.fnameescape(path)))
    M.init_dired()
end

-- open a file or traverse inside a directory
function M.enter_dir()
    if vim.bo.filetype ~= "dired" then
        return
    end

    local dir = vim.g.current_dired_path
    display.cursor_pos = {} -- reset cursor pos
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir)
    local file = ls.get_file_by_filename(dir_files, filename)
    if file == nil then
        vim.api.nvim_err_writeln(string.format("Dired: invalid filename (%s) for file.", filename))
        return
    end

    if file.filetype == "directory" then
        vim.cmd(string.format("keepalt noautocmd edit %s", vim.fn.fnameescape(file.filepath)))
    else
        vim.cmd(string.format("keepalt edit %s", vim.fn.fnameescape(file.filepath)))
    end

    if file.filetype == "directory" then
        history.push_path(vim.g.current_dired_path)
        M.init_dired()
    end

    -- if file is a directory then enter inside the directory
    -- if file is just a normal file then replace the dired buffer
    -- with that file
end

-- quit already opened Dired buffer
function M.quit_buf()
    if vim.bo.filetype ~= "dired" then
        return
    end

    history.pop_path()
    vim.cmd("bp")
end

function M.go_back()
    local current_path = vim.g.current_dired_path
    display.goto_filename = fs.get_filename(current_path)
    M.open_dir(fs.get_parent_path(current_path))
end

function M.go_up()
    local last_path = history.pop_path()
    M.open_dir(last_path)
end

-- toggle between showing hidden files
function M.toggle_hidden_files()
    display.cursor_pos = {}
    vim.g.dired_show_hidden = not vim.g.dired_show_hidden
    vim.notify(string.format("dired_show_hidden: %s", vim.inspect(vim.g.dired_show_hidden)))
    M.init_dired()
end

-- change the sort order
function M.toggle_sort_order()
    vim.g.dired_sort_order = config.get_next_sort_order()
    display.render(vim.g.current_dired_path)
    vim.notify(string.format("Dired by %s", vim.g.dired_sort_order))
end

-- change colors
function M.toggle_colors()
    vim.g.dired_show_colors = not vim.g.dired_show_colors
    display.render(vim.g.current_dired_path)
    vim.notify(string.format("dired_show_colors: %s", vim.inspect(vim.g.dired_show_colors)))
end

-- rename a file
function M.rename_file()
    local dir = nil
    dir = vim.g.current_dired_path
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir)
    local file = ls.get_file_by_filename(dir_files, filename)
    funcs.rename_file(file)
    display.render(vim.g.current_dired_path)
end

-- create a file
function M.create_file()
    funcs.create_file()
    display.render(vim.g.current_dired_path)
end

-- delete a file
function M.delete_file()
    local dir = nil
    dir = vim.g.current_dired_path
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure the cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir)
    local file = ls.get_file_by_filename(dir_files, filename)
    for i, fs_t in ipairs(marker.marked_files) do
        if file == fs_t then
            table.remove(marker.marked_files, i)
        end
    end
    display.cursor_pos = vim.api.nvim_win_get_cursor(0)
    display.goto_filename = ""
    funcs.delete_file(file, true)
    display.render(vim.g.current_dired_path)
end

-- delete selected files in current dired path
function M.delete_file_range()
    local dir = nil
    dir = vim.g.current_dired_path
    local lines = utils.get_visual_selection()
    vim.notify(string.format("%d files marked for deletion:", #lines))
    local files = {}
    for _, line in ipairs(lines) do
        local filename = display.get_filename_from_listing(line)
        if filename == nil then
            vim.api.nvim_err_writeln(
                "Dired: Invalid operation make sure the selected/marked are of type file/directory."
            )
            return
        end
        table.insert(files, filename)
        print(string.format('   {%.2d: "%s"}', _, filename))
    end
    local prompt = vim.fn.input("Confirm deletion {yes,n(o),q(uit)}: ", "yes", "file")
    prompt = string.lower(prompt)
    if string.sub(prompt, 1, 3) == "yes" then
        for _, filename in ipairs(files) do
            local dir_files = ls.fs_entry.get_directory(dir)
            local file = ls.get_file_by_filename(dir_files, filename)
            if not file then
                return
            end
            for i, fs_t in ipairs(marker.marked_files) do
                if file.filepath == fs_t.filepath then
                    table.remove(marker.marked_files, i)
                end
            end
            display.cursor_pos = vim.api.nvim_win_get_cursor(0)
            funcs.delete_file(file, false)
        end
        display.goto_filename = ""
        display.render(vim.g.current_dired_path)
        -- else
        --     vim.notify(" DiredDelete: Marked files not deleted", "error")
    end
end

-- mark single file
function M.mark_file()
    local dir = nil
    dir = vim.g.current_dired_path
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure the cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir)
    local file = ls.get_file_by_filename(dir_files, filename)
    display.cursor_pos = vim.api.nvim_win_get_cursor(0)
    display.goto_filename = filename
    marker.mark_file(file)
    display.render(vim.g.current_dired_path)
    -- vim.notify(string.format("\"%s\" marked.", file.filename))
end

-- mark range of files
function M.mark_file_range()
    local dir = nil
    dir = vim.g.current_dired_path
    local lines = utils.get_visual_selection()
    local files = {}
    for _, line in ipairs(lines) do
        local filename = display.get_filename_from_listing(line)
        if filename == nil then
            vim.api.nvim_err_writeln(
                "Dired: Invalid operation make sure the selected/marked are of type file/directory."
            )
            return
        end
        if filename ~= "." or filename ~= ".." then
            table.insert(files, filename)
        end
    end
    for _, filename in ipairs(files) do
        local dir_files = ls.fs_entry.get_directory(dir)
        local file = ls.get_file_by_filename(dir_files, filename)
        display.cursor_pos = vim.api.nvim_win_get_cursor(0)
        -- print(filename, file)
        marker.mark_file(file)
    end
    display.goto_filename = files[1]
    display.render(vim.g.current_dired_path)
    -- vim.notify(string.format("%d files marked.", #files))
end

-- delete marked files and update marked list
function M.delete_marked()
    local marked_files = marker.marked_files
    vim.notify(string.format("%d files marked for deletion:", #marked_files))
    local files_out_of_cwd = false
    for i, fs_t in ipairs(marked_files) do
        if fs_t.filename == nil then
            vim.api.nvim_err_writeln(
                "Dired: Invalid operation make sure the selected/marked are of type file/directory."
            )
            return
        end
        if
            fs.get_absolute_path(fs.get_parent_path(fs_t.filepath)) ~= fs.get_absolute_path(vim.g.current_dired_path)
        then
            files_out_of_cwd = true
            print(string.format('   {%.2d: "%s"} (file not in cwd)', i, fs_t.filename))
        else
            print(string.format('   {%.2d: "%s"}"', i, fs_t.filename))
        end
    end
    if files_out_of_cwd then
        print("[!] WARNING: You have files marked that are outside of your current working directory.")
    end
    local prompt = vim.fn.input("Confirm deletion {yes,n(o),q(uit)}: ", "yes", "file")
    prompt = string.lower(prompt)
    if string.sub(prompt, 1, 3) == "yes" then
        for _, fs_t in ipairs(marked_files) do
            display.cursor_pos = vim.api.nvim_win_get_cursor(0)
            display.goto_filename = ""
            funcs.delete_file(fs_t, false)
        end
        marker.marked_files = {}
    end
    display.goto_filename = ""
    display.render(vim.g.current_dired_path)
end

function M.clip_file(action)
    local dir = nil
    dir = vim.g.current_dired_path
    local filename = display.get_filename_from_listing(vim.api.nvim_get_current_line())
    if filename == nil then
        vim.api.nvim_err_writeln("Dired: Invalid operation make sure the cursor is placed on a file/directory.")
        return
    end
    local dir_files = ls.fs_entry.get_directory(dir)
    local file = ls.get_file_by_filename(dir_files, filename)
    display.cursor_pos = vim.api.nvim_win_get_cursor(0)
    display.goto_filename = filename
    clipboard.add_file(file, action)
    display.render(vim.g.current_dired_path)
    -- vim.notify(string.format("\"%s\" marked.", file.filename))
end

function M.clip_file_range(action)
    local dir = vim.g.current_dired_path
    local lines = utils.get_visual_selection()
    local files = {}
    for _, line in ipairs(lines) do
        local filename = display.get_filename_from_listing(line)
        if filename == nil then
            vim.api.nvim_err_writeln(
                "Dired: Invalid operation make sure the selected/marked are of type file/directory."
            )
            return
        end
        if filename ~= "." or filename ~= ".." then
            table.insert(files, filename)
        end
    end
    for _, filename in ipairs(files) do
        local dir_files = ls.fs_entry.get_directory(dir)
        local file = ls.get_file_by_filename(dir_files, filename)
        -- print(filename, file)
        clipboard.add_file(file, action)
    end
    display.cursor_pos = vim.api.nvim_win_get_cursor(0)
    display.goto_filename = files[1]
    display.render(vim.g.current_dired_path)
    -- vim.notify(string.format("%d files marked.", #files))
end

-- copy/move marked files and update marked list
function M.clip_marked(action)
    local files = marker.marked_files
    for _, file in ipairs(files) do
        clipboard.add_file(file, action)
    end
    marker.marked_files = {}
    display.goto_filename = files[1]
    display.render(vim.g.current_dired_path)
    -- vim.notify(string.format("%d files marked.", #files))
end

function M.paste_file()
    display.cursor_pos = vim.api.nvim_win_get_cursor(0)
    clipboard.do_action()
    display.render(vim.g.current_dired_path)
    -- vim.notify(string.format("\"%s\" marked.", file.filename))
end

return M
