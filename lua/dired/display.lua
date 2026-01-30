-- display the directory and its contents
local fs = require("dired.fs")
local ls = require("dired.ls")
local config = require("dired.config")
local nui_line = require("nui.line")
local nui_text = require("nui.text")
local utils = require("dired.utils")
local colors = require("dired.colors")
local M = {}

-- fill the buffer with directory contents
-- buffer to be flushed in neovim buffer
M.buffer = {}
M.cursor_pos = {}
M.goto_filename = ""

function M.clear()
    M.buffer = {}
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
end

function M.render(path)
    vim.bo.modifiable = true
    M.clear()
    M.display_dired_listing(path)
    M.flush_buffer()
    vim.bo.modifiable = false
end

function M.flush_buffer()
    local undolevels = vim.bo.undolevels
    vim.bo.undolevels = -1
    if vim.g.dired_show_colors then
        for i, line in ipairs(M.buffer) do
            line:render(0, -1, i)
        end
    else
        vim.api.nvim_buf_set_lines(0, 0, -1, true, M.buffer)
    end

    vim.bo.undolevels = undolevels
    vim.api.nvim_win_set_cursor(0, M.cursor_pos)
    vim.bo.modified = false
    M.buffer = {}
end

function M.get_directory_listing(directory)
    local buffer_listing = {}
    local dir_files = ls.fs_entry.get_directory(directory)
    local dir_size = dir_files.size
    local dir_size_str = utils.get_short_size(dir_size)
    local info1, info2 = nil, nil

    vim.g.dired_file_count = 0
    vim.g.dired_dir_count = 0

    for i, e in ipairs(dir_files) do
        if e.filetype == "directory" then
            vim.g.dired_dir_count = vim.g.dired_dir_count + 1
        else
            vim.g.dired_file_count = vim.g.dired_file_count + 1
        end
    end

    if vim.g.dired_show_colors then
        info1 = { nui_text(string.format("%s:", fs.get_simplified_path(directory))) }
        info2 = { nui_text(string.format("total used in directory %s:", dir_size_str)) }
    else
        info1 = string.format("%s:", fs.get_simplified_path(directory))
        info2 = string.format("total used in directory %s:", dir_size_str)
    end
    local formatted_components, cursor_x = ls.fs_entry.format(
        dir_files,
        vim.g.dired_show_dot_dirs,
        vim.g.dired_show_hidden,
        vim.g.dired_hide_details,
        vim.g.dired_show_icons
    )
    table.insert(buffer_listing, { component = nil, line = info1 })
    table.insert(buffer_listing, { component = nil, line = info2 })

    local listing = {}
    for _, comp in ipairs(formatted_components) do
        if vim.g.dired_show_colors then
            table.insert(listing, colors.get_colored_component_str(comp))
        else
            table.insert(listing, colors.get_component_str(comp))
        end
    end

    table.sort(listing, config.get_sort_order(vim.g.dired_sort_order))
    if #formatted_components > #buffer_listing then
        if #M.cursor_pos == 0 then
            -- when M.cursor_pos is not populated
            for i, fs_t in ipairs(listing) do
                if fs_t.component.filename == ".." then
                    if i < #listing then
                        M.cursor_pos = { i + 1 + #buffer_listing, cursor_x }
                    else
                        M.cursor_pos = { i + #buffer_listing, cursor_x }
                    end
                    break
                end
            end
        else
            -- if M.cursor is populated
            if M.goto_filename ~= "" then
                for i, fs_t in ipairs(listing) do
                    if fs_t.component.filename == M.goto_filename then
                        M.cursor_pos = { i + #buffer_listing, cursor_x }
                        M.goto_filename = ""
                        break
                    end
                end
            elseif M.goto_filename == "" then
                M.goto_filename = ".."
                for i, fs_t in ipairs(listing) do
                    if fs_t.component.filename == ".." then
                        if i < #listing then
                            M.cursor_pos = { i + 1 + #buffer_listing, cursor_x }
                        else
                            M.cursor_pos = { i + #buffer_listing, cursor_x }
                        end
                        break
                    end
                end
            end
        end
    else
        for i, fs_t in ipairs(listing) do
            if fs_t.component.filename == ".." then
                M.cursor_pos = { i + #buffer_listing, cursor_x }
                break
            end
        end
    end

    buffer_listing = utils.concatenate_tables(buffer_listing, listing)
    return buffer_listing
end

function M.display_dired_listing(directory)
    local buffer_listings = {}
    local listing = M.get_directory_listing(directory)
    for _, tbl in ipairs(listing) do
        if vim.g.dired_show_colors then
            table.insert(buffer_listings, nui_line(tbl.line))
        else
            table.insert(buffer_listings, tbl.line)
        end
    end
    M.buffer = utils.concatenate_tables(M.buffer, buffer_listings)
end

local function remove_empty_strings(t)
    local output = {}
    for _, s in ipairs(t) do
        if s ~= "" then
            table.insert(output, s)
        end
    end
    return output
end

function M.get_filename_from_listing(line)
	local columns = 8
	if vim.g.dired_show_icons == true then
		columns = 9
	end
	local n = 0
	local i = 1
	while n < columns do
		local start_pos, end_pos = line:find("%S+", i)
		if not start_pos then
			vim.api.nvim_err_writeln(string.format("Dired: formatting error (%d columns expected, got %d)", columns+1, n))
			return nil
		end
		n = n + 1
		if n == columns then
			-- Handle filenames that start with a space
			local next = line:find("%s", end_pos)
			if(vim.g.dired_show_icons == true) then
				return line:sub(next+2)
			else
				return line:sub(next+1)
			end
		end
		i = end_pos + 1
	end
end

return M
