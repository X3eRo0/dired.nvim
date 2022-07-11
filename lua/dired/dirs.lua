-- get directory
local fs = require("dired.fs")
local cf = require("dired.config")
local uv = vim.loop
local M = {}

function M.get_dir_content(directory, show_hidden)
    -- scan the directory
    local dir_files = {}
    local dirfd, err, _ = uv.fs_scandir(directory)
    if dirfd == nil then
        return nil, err
    end

    table.insert(dir_files, fs.FsEntry.New(0, fs.join_paths(directory, "."), directory, "directory"))
    table.insert(dir_files, fs.FsEntry.New(1, fs.join_paths(directory, ".."), directory, "directory"))

    local id = 2
    while true do
        local filename, filetype = uv.fs_scandir_next(dirfd)
        if filename == nil then
            break
        end

        if show_hidden or not fs.is_hidden(filename) then
            local filepath = fs.join_paths(directory, filename)
            local fs_t = fs.FsEntry.New(id, filepath, directory, filetype)
            id = id + 1
            table.insert(dir_files, fs_t)
        end
    end

    return dir_files
end

function M.get_dir_size_by_files(dir_files)
    local size = 0
    for _, fs_t in ipairs(dir_files) do
        if fs_t.size == nil then
            if fs_t.filename ~= nil then
                vim.notify(string.format("Dired: %s is causing issues.", fs_t.filename), "warn")
            else
                vim.notify("Dired: One of the directory entry is causing issues.", "warn")
            end
        else
            size = size + fs_t.size
        end
    end
    return size
end

function M.get_dir_size(directory)
    local dir_files = M.get_dir_content(directory)
    return M.get_dir_size_by_files(dir_files)
end

function M.get_file_by_id(dir_files, id)
    for _, fs_t in ipairs(dir_files) do
        if id == fs_t.id then
            return fs_t
        end
    end

    return nil
end

return M
