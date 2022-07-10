-- display the directory and its contents
local dirs = require("dired.dirs")
local fs = require("dired.fs")
local hl = require("dired.highlight")
local config = require("dired.config")
local nui_line = require("nui.line")
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
        nui_line("NVIM-Dired by X3eRo0", "Normal"),
        nui_line("Version 1.0", "Normal"),
    }

    M.buffer = concatenate_tables(M.buffer, banner)
end

function M.render(path)
    M.buffer = {}
    -- vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    if config.get("show_banner") then
        M.display_banner()
    end
    M.display_dired_listing(path)
    M.flush_buffer()
end

function M.flush_buffer()
    local undolevels = vim.bo.undolevels
    vim.bo.undolevels = -1
    -- vim.api.nvim_buf_set_lines(0, 0, -1, true, M.buffer)
    for i, line in ipairs(M.buffer) do
        line:render(0, -1, i)
    end
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
    local dis_path = nui_line()
    local dis_info = nui_line()
    dis_path:append(string.format("%s:", fs.get_simplified_path(directory)), hl.NORMAL)
    dis_info:append(string.format("total used in directory %s", size), hl.NORMAL)
    table.insert(buffer_listings, dis_path)
    table.insert(buffer_listings, dis_info)
    for i, fs_t in ipairs(dir_files) do
        table.insert(buffer_listings, nui_line(fs.FsEntry.Format(fs_t)))
        if (#dir_files == 2 and i == 2) or (i == 3) then
            M.cursor_pos = { #M.buffer + #buffer_listings, vim.b.cursor_column }
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
