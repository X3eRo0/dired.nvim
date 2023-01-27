local fs = require("dired.fs")
local config = require("dired.config")
local display = require("dired.display")

local M = {}

M.path_separator = config.get("path_separator")

function M.rename_file(fs_t)
    local new_name = vim.fn.input(string.format("Enter New Name (%s): ", fs_t.filename))
    if new_name == "" then
        return
    end
    local old_path = fs_t.filepath
    local new_path = fs.join_paths(fs_t.parent_dir, new_name)
    local success = vim.loop.fs_rename(old_path, new_path)
    if not success then
        vim.notify(string.format('DiredRename: Could not rename "%s" to "%s".', fs_t.filename, new_name))
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
        local dir = vim.g.current_dired_path
        -- print(vim.inspect(M.join_paths(dir, filename)))
        local fd = vim.loop.fs_mkdir(fs.join_paths(dir, filename), default_dir_mode)

        if not fd then
            vim.notify(string.format('DiredCreate: Could not create Directory "%s".', filename))
            return
        end
    else
        local dir = vim.g.current_dired_path
        local fd, err = vim.loop.fs_open(fs.join_paths(dir, filename), "w+", default_file_mode)

        if not fd or err ~= nil then
            vim.notify(string.format('DiredCreate: Could not create file "%s".', filename))
            return
        end

        vim.loop.fs_close(fd)
    end
    display.goto_filename = filename
end

local function delete_files(path)
    local handle = vim.loop.fs_scandir(path)
    if type(handle) == "string" then
        return vim.api.nvim_err_writeln(handle)
    end

    while true do
        local name, t = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end

        local new_cwd = fs.join_paths(path, name)

        if t == "directory" then
            local success = delete_files(new_cwd)
            if not success then
                return false
            end
        else
            local success = vim.loop.fs_unlink(new_cwd)

            if not success then
                return false
            end
        end
    end

    return vim.loop.fs_rmdir(path)
end

function M.delete_file(fs_t)
    if fs_t.filename == "." or fs_t.filename == ".." then
        vim.notify(string.format('Cannot Delete "%s"', fs_t.filepath), "error")
        return
    end
    local prompt =
        vim.fn.input(string.format("Confirm deletion of (%s) {y(es),n(o),q(uit)}: ", fs_t.filename), "yes", "file")
    prompt = string.lower(prompt)
    if string.sub(prompt, 1, 1) == "y" then
        if fs_t.filetype == "directory" then
            delete_files(fs_t.filepath)
        else
            vim.loop.fs_unlink(fs_t.filepath)
        end
    else
        vim.notify("DiredDelete: File/Directory not deleted", "error")
    end
    display.cursor_pos = vim.api.nvim_win_get_cursor(0)
    display.goto_filename = ""
end

return M
