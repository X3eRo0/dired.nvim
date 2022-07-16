local hl = require("dired.highlight")
local fs = require("dired.fs")
local ut = require("dired.utils")

local M = {}

function M.get_permission_color()
    return hl.NORMAL
end

function M.get_nlinks_color()
    return hl.DIM_TEXT
end

function M.get_owner_color()
    return hl.USERNAME
end

function M.get_group_color()
    return hl.USERNAME
end

function M.get_size_color()
    return hl.SIZE
end

function M.get_month_color()
    return hl.MONTH
end

function M.get_day_color()
    return hl.DAY
end

function M.get_ftime_color()
    return hl.NORMAL
end

function M.get_filename_color(component)
    -- get filename color from filetype
    -- if it's a link then check if its
    -- a valid link or an broken symlink
    local fs_t = component.fs_t

    if fs_t.filetype == "directory" then
        -- if filetype is directory return DIRECTORY_NAME
        return hl.DIRECTORY_NAME
    elseif fs.is_hidden(fs_t.filename) then
        -- if file begins with a "." and not a directory then
        -- return DOTFILE
        return hl.DOTFILE
    elseif fs_t.filetype == "link" then
        -- if file is a symlink return appropriate color
        local target = fs.get_symlink(fs_t.filepath)

        -- if target exists return color for link and target
        if fs.file_exists(target) then
            return hl.SYMBOLIC_LINK, hl.SYMBOLIC_LINK_TARGET
        else
            return hl.BROKEN_LINK, hl.BROKEN_LINK_TARGET
        end
    else
        if ut.bitand(fs_t.mode, fs.fs_masks.S_ISUID) > 0 and ut.bitand(fs_t.mode, fs.fs_masks.S_ISGID) > 0 then
            -- if file is suid
            return hl.FILE_SUID
        elseif
            -- if file is executable
            ut.bitand(fs_t.mode, fs.fs_masks.S_IXUSR) > 0
            and ut.bitand(fs_t.mode, fs.fs_masks.S_IXGRP) > 0
            and ut.bitand(fs_t.mode, fs.fs_masks.S_IXOTH) > 0
        then
            return hl.FILE_EXECUTABLE
        else
            -- return FILE_NAME for "char", "block", "fifo", "socket"
            return hl.FILE_NAME
        end
    end
end

return M
