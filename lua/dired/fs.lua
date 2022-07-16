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
function M.is_hidden(filepath)
    return string.sub(filepath, 1, 1) == "."
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

return M
