local hl = require("dired.highlight")
local fs = require("dired.fs")
local ut = require("dired.utils")
local mk = require("dired.marker")
local cb = require("dired.clipboard")
local nt = require("nui.text")

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

    if mk.is_marked(component.fs_t) then
        return hl.MARKED_FILE
    elseif cb.get_action(component.fs_t) == "copy" then
        return hl.COPY_FILE
    elseif cb.get_action(component.fs_t) == "move" then
        return hl.MOVE_FILE
    elseif fs_t.filetype == "directory" then
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

function M.get_component_str(component)
    return {
        component = component,
        line = string.format(
            "%s %s %s %s %s %s %s %s %s",
            component.permissions,
            component.nlinks,
            component.owner,
            component.group,
            component.size,
            component.month,
            component.day,
            component.ftime,
            component.filename
        ),
    }
end

function M.get_colored_component_str(component)
    -- return nui_line
    local permcolor = M.get_permission_color()
    local nlinkcolor = M.get_nlinks_color()
    local ownercolor = M.get_owner_color()
    local groupcolor = M.get_group_color()
    local sizecolor = M.get_size_color()
    local monthcolor = M.get_month_color()
    local daycolor = M.get_day_color()
    local ftimecolor = M.get_ftime_color()
    -- primary M.and secondary color in case its a symlink
    local fcolor_p, fcolor_s = M.get_filename_color(component)
    local text_group = {
        nt(component.permissions, permcolor),
        nt(component.nlinks, nlinkcolor),
        nt(component.owner, ownercolor),
        nt(component.group, groupcolor),
        nt(component.size, sizecolor),
        nt(component.month, monthcolor),
        nt(component.day, daycolor),
        nt(component.ftime, ftimecolor),
        nt(component.filename, fcolor_p),
    }

    if component.fs_t.filetype == "link" then
        local linktarget = fs.get_symlink(component.fs_t.filepath)
        table.insert(text_group, nt("->"))
        table.insert(text_group, nt(linktarget, fcolor_s))
    end

    local line = {}
    local seperator = nt(" ")
    for i = 1, #text_group do
        table.insert(line, text_group[i])
        if i ~= #text_group then
            table.insert(line, seperator)
        end
    end

    -- returns component and formatted line
    return { component = component, line = line }
end

return M
