local fs = require("dired.fs")
local ls = require("dired.ls")

local M = {}

M.clipboard = {}

function M.get_action(fs_t)
    for i, e in ipairs(M.clipboard) do
        if e.fs_t.filepath == fs_t.filepath then
            return e.action
        end
    end
    return nil
end

-- action can be copy or paste
function M.add_file(fs_t, action)
    local idx = nil
    for i, e in ipairs(M.clipboard) do
        if e.fs_t.filepath == fs_t.filepath then
            idx = i
        end
    end
    if idx ~= nil then
        M.clipboard[idx].action = action
        return
    end
    local entry = {}
    entry.fs_t = fs_t
    entry.action = action
    table.insert(M.clipboard, entry)
end

function M.remove_file(fs_t)
    for i, e in ipairs(M.clipboard) do
        if e.fs_t == fs_t then
            table.remove(M.clipboard, i)
        end
    end
end

-- copy files to current directory
function M.copy_files(files)
    -- should we check if user is trying to copy paste in the same directory?
    -- idk yet.
    local curren_files = ls.fs_entry.get_directory(vim.g.current_dired_path)
    local copy_files = {}

    for _, fs_t in ipairs(files) do
        -- sanity check
        if fs_t.filename == nil then
            vim.api.nvim_err_writeln(
                "Dired: Invalid operation make sure the selected/marked are of type file/directory."
            )
            return
        end

        -- check #1
        if
            fs.get_absolute_path(fs.get_parent_path(fs_t.filepath)) ~= fs.get_absolute_path(vim.g.current_dired_path)
        then
            -- check #2
            local already_in_cwd = false
            for _, ds_t in ipairs(curren_files) do
                if fs_t.filename == ds_t.filename then
                    local prompt =
                        vim.fn.input(string.format('Overwrite "%s"? {yes,n(o),q(uit)}: ', fs_t.filename), "no")
                    prompt = string.lower(prompt)
                    already_in_cwd = true
                    if string.sub(prompt, 1, 3) == "yes" then
                        table.insert(copy_files, fs_t)
                    end
                    break
                end
            end
            if not already_in_cwd then
                table.insert(copy_files, fs_t)
            end
        end
    end
    for _, fs_t in ipairs(copy_files) do
        fs.do_copy(fs_t.filepath, fs.join_paths(vim.g.current_dired_path, fs_t.filename))
    end
end

-- move files to current directory
function M.move_files(files)
    -- should we check if user is trying to move paste in the same directory?
    -- idk yet.
    local curren_files = ls.fs_entry.get_directory(vim.g.current_dired_path)
    local move_files = {}

    for _, fs_t in ipairs(files) do
        -- sanity check
        if fs_t.filename == nil then
            vim.api.nvim_err_writeln(
                "Dired: Invalid operation make sure the selected/marked are of type file/directory."
            )
            return
        end

        -- check #1
        if
            fs.get_absolute_path(fs.get_parent_path(fs_t.filepath)) ~= fs.get_absolute_path(vim.g.current_dired_path)
        then
            -- check #2
            local already_in_cwd = false
            for _, ds_t in ipairs(curren_files) do
                if fs_t.filename == ds_t.filename then
                    local prompt =
                        vim.fn.input(string.format('Overwrite "%s"? {yes,n(o),q(uit)}: ', fs_t.filename), "no")
                    prompt = string.lower(prompt)
                    already_in_cwd = true
                    if string.sub(prompt, 1, 3) == "yes" then
                        table.insert(move_files, fs_t)
                    end
                    break
                end
            end
            if not already_in_cwd then
                table.insert(move_files, fs_t)
            end
        end
    end
    for _, fs_t in ipairs(move_files) do
        vim.loop.fs_rename(fs_t.filepath, fs.join_paths(vim.g.current_dired_path, fs_t.filename))
        -- fs.do_move(fs_t.filepath, fs.join_paths(vim.g.current_dired_path, fs_t.filename))
    end
end

function M.do_action()
    local copyf = {}
    local movef = {}
    for i, file in ipairs(M.clipboard) do
        if file.action == "copy" then
            table.insert(copyf, file.fs_t)
        elseif file.action == "move" then
            table.insert(movef, file.fs_t)
        end
    end
    M.clipboard = {}
    if #copyf > 0 then
        M.copy_files(copyf)
    end

    if #movef > 0 then
        M.move_files(movef)
    end
end

return M
