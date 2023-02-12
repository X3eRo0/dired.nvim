-- functions for fetching files and directories information
local config = require("dired.config")

local M = {}

-- masks to identify files.
M.fs_masks = {
    S_IFMT = 61440,
    S_IFSOCK = 49152,
    S_IFLNK = 40960,
    S_IFREG = 32768,
    S_IFBLK = 24576,
    S_IFDIR = 16384,
    S_IFCHR = 8192,
    S_IFIFO = 4096,
    S_ISUID = 2048,
    S_ISGID = 1024,
    S_ISVTX = 512,
    S_IRUSR = 256,
    S_IWUSR = 128,
    S_IXUSR = 64,
    S_IRGRP = 32,
    S_IWGRP = 16,
    S_IXGRP = 8,
    S_IROTH = 4,
    S_IWOTH = 2,
    S_IXOTH = 1,
}

M.path_separator = config.get("path_separator")

-- is filepath a directory or just a file
function M.is_directory(filepath)
    return vim.fn.isdirectory(filepath) == 1
end

-- is filepath a hidden directory/file
function M.is_hidden(filename)
    return string.sub(filename, 1, 1) == "."
end

-- get filename from absolute path
function M.get_filename(filepath)
    local fname = filepath:match("^.+" .. M.path_separator .. "(.+)$")
    if fname == nil then
        fname = string.sub(filepath, 2, #filepath)
    end
    return fname
end

function M.get_simplified_path(filepath)
    filepath = vim.fn.simplify(vim.fn.fnamemodify(filepath, ":p"))
    if filepath:sub(-1, -1) == M.path_separator then
        filepath = vim.fn.fnamemodify(filepath, ":h")
    end

    return filepath
end

-- get parent path
function M.get_parent_path(path)
    local sep = M.path_separator
    sep = sep or "/"
    return path:match("(.*" .. sep .. ")")
end

-- get absolute path
function M.get_absolute_path(path)
    if M.is_directory(path) then
        return vim.fn.fnamemodify(path, ":p")
    else
        return vim.fn.fnamemodify(path, ":h:p")
    end
end

-- join_paths
function M.join_paths(...)
    local string_builder = {}
    for _, path in ipairs({ ... }) do
        if path:sub(-1, -1) == M.path_separator then
            path = path:sub(0, -2)
        end
        table.insert(string_builder, path)
    end
    return table.concat(string_builder, M.path_separator)
end

function M.file_exists(filepath)
    local stat, err = vim.loop.fs_lstat(filepath)
    if stat == nil and err ~= nil then
        return false
    end
    return true
end

function M.get_symlink(filepath)
    local link = vim.loop.fs_readlink(filepath)
    if not link then
        return nil
    end
    return link
end

function M.do_delete(path)
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

function M.do_copy(source, destination)
    local source_stats, handle
    local success, errmsg

    source_stats, errmsg = vim.loop.fs_stat(source)
    if not source_stats then
        vim.api.nvim_err_writeln("do_copy fs_stat '%s' failed '%s'", source, errmsg)
        return false, errmsg
    end

    if source == destination then
        vim.api.nvim_err_writeln("do_copy source and destination are the same, exiting early")
        return true
    end

    if source_stats.type == "file" then
        success, errmsg = vim.loop.fs_copyfile(source, destination)
        if not success then
            vim.api.nvim_err_writeln("do_copy fs_copyfile failed '%s'", errmsg)
            return false, errmsg
        end
        return true
    elseif source_stats.type == "directory" then
        handle, errmsg = vim.loop.fs_scandir(source)
        if type(handle) == "string" then
            return false, handle
        elseif not handle then
            vim.api.nvim_err_writeln("do_copy fs_scandir '%s' failed '%s'", source, errmsg)
            return false, errmsg
        end

        success, errmsg = vim.loop.fs_mkdir(destination, source_stats.mode)
        if not success then
            M.do_delete(destination)
            success, errmsg = vim.loop.fs_mkdir(destination, source_stats.mode)
            -- vim.api.nvim_err_writeln(string.format("do_copy fs_mkdir '%s' failed '%s'", destination, errmsg))
            -- return false, errmsg
        end

        while true do
            local name, _ = vim.loop.fs_scandir_next(handle)
            if not name then
                break
            end

            local new_name = M.join_paths(source, name)
            local new_destination = M.join_paths(destination, name)
            success, errmsg = M.do_copy(new_name, new_destination)
            if not success then
                return false, errmsg
            end
        end
    else
        errmsg = string.format("'%s' illegal file type '%s'", source, source_stats.type)
        vim.api.nvim_err_writeln("do_copy %s", errmsg)
        return false, errmsg
    end

    return true
end

return M
