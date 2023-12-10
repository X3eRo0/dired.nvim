local fs = require("dired.fs")
local config = require("dired.config")
local display = require("dired.display")
local utils = require("dired.utils")

local M = {}

M.path_separator = config.get("path_separator")

function M.rename_file(fs_t)
    local new_name = vim.fn.input({
        prompt = string.format("Enter New Name (%s): ", fs_t.filename),
        default = fs_t.filename,
    })
    if new_name == "" then
        return
    end
    local old_path = fs_t.filepath
    local new_path = fs.join_paths(fs_t.parent_dir, new_name)
    local success = vim.loop.fs_rename(old_path, new_path)
    if not success then
        vim.notify(
            string.format(' DiredRename: Could not rename "%s" to "%s".', fs_t.filename, new_name)
        )
        return
    end
    display.goto_filename = new_name
end

function M.create_file()
    local filename = vim.fn.input("Enter Filename: ")
    if filename == "" then
        return
    end
    local default_dir_mode = tonumber("775", 8)
    local default_file_mode = tonumber("644", 8)

    if filename:sub(-1, -1) == M.path_separator then
        -- create a directory
        filename = filename:sub(1, -2)
        local dir = vim.g.current_dired_path
        local fd = vim.loop.fs_mkdir(fs.join_paths(dir, filename), default_dir_mode)

        if not fd then
            vim.notify(string.format(' DiredCreate: Could not create Directory "%s".', filename))
            return
        end
    else
        local dir = vim.g.current_dired_path
        local fd, err = vim.loop.fs_open(fs.join_paths(dir, filename), "w+", default_file_mode)

        if not fd or err ~= nil then
            vim.notify(string.format(' DiredCreate: Could not create file "%s".', filename))
            return
        end

        vim.loop.fs_close(fd)
    end
    display.goto_filename = filename
end

function M.delete_file(fs_t, ask)
    if fs_t.filename == "." or fs_t.filename == ".." then
        vim.notify(string.format(' Cannot Delete "%s"', fs_t.filepath), "error")
        return
    end
    if ask ~= true then
        if fs_t.filetype == "directory" then
            fs.do_delete(fs_t.filepath)
        else
            vim.loop.fs_unlink(fs_t.filepath)
        end
        return
    end
    local prompt = vim.fn.input(
        string.format("Confirm deletion of (%s) {yes,n(o),q(uit)}: ", fs_t.filename),
        "yes",
        "file"
    )
    prompt = string.lower(prompt)
    if string.sub(prompt, 1, 3) == "yes" then
        if fs_t.filetype == "directory" then
            fs.do_delete(fs_t.filepath)
        else
            vim.loop.fs_unlink(fs_t.filepath)
        end
    end
end

return M
