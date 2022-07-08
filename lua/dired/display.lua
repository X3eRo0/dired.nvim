-- display the directory and its contents
local dirs = require("dired.dirs")
local fs = require("dired.fs")
local config = require("dired.config")
local utils = require("dired.utils")
local M = {}

-- fill the buffer with directory contents
-- buffer to be flushed in neovim buffer
M.buffer = {}
M.cursor_pos = {}

local function concatenate_tables(table1, table2)
    for _, v in ipairs(table2) do
        table.insert(table1, v)
    end
    return table1
end

function M.display_banner()
    local banner = {
        "NVIM-Dired by X3eRo0",
        "Version 1.0"
    }
    M.buffer = concatenate_tables(M.buffer, banner)
end

function M.render(path)
    M.buffer = {}
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    if config.get("show_banner") then
        M.display_banner()
    end
    M.display_dired_listing(path)
    M.flush_buffer()
end

function M.flush_buffer()
    local undolevels = vim.bo.undolevels
    vim.bo.undolevels = -1
    vim.api.nvim_buf_set_lines(0, 0, -1, true, M.buffer)
    vim.bo.undolevels = undolevels
    vim.bo.modified = false
    vim.api.nvim_win_set_cursor(0, M.cursor_pos)
    M.buffer = {}
end

function M.get_dired_listing(directory)
    local buffer_listings = {}
    local dir_files = dirs.get_dir_content(directory, config.get("show_hidden"))
    local dir_size = dirs.get_dir_size_by_files(dir_files)

    local size = utils.get_short_size(dir_size)

    -- printing the current directory (ex. "/home/x3ero0:")
    table.insert(buffer_listings, string.format("%s:", vim.fn.fnamemodify(fs.get_simplified_path(directory), ":h")))
    table.insert(buffer_listings, string.format("total used in directory %s", size))
    for i, fs_t in ipairs(dir_files) do
        table.insert(buffer_listings, fs.FsEntry.Format(fs_t))
        if #dir_files == 2 and i == 2 then
            local first_listing = buffer_listings[#buffer_listings]
            local filename_idx = string.find(first_listing, " ..", 1, true)
            M.cursor_pos = {#M.buffer + #buffer_listings, filename_idx}
        end
        if i == 3 then -- place cursor on first file
            local first_listing = buffer_listings[#buffer_listings]
            local filename_idx = string.find(first_listing, " " .. fs_t.filename, 1, true)
            M.cursor_pos = {#M.buffer + #buffer_listings, filename_idx}
        end
    end

    return buffer_listings
end

function M.display_dired_listing(directory)
    local buffer_listings = M.get_dired_listing(directory)
    -- vim.api.nvim_buf_set_lines(0, 0, -1, true, buffer_listings)
    M.buffer = concatenate_tables(M.buffer, buffer_listings)
end

function M.get_id_from_listing(line)
    return tonumber(utils.str_split(line, " ")[1], 10)
end

return M
