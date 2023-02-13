-- ls implementation in lua

local utils = require("dired.utils")
local fs = require("dired.fs")
local M = {}
M.fs_entry = {}

-- typedef struct fs_t {
--     u32    id,       // id
--     char * filename, // file.exe
--     char * fullpath, // /tmp/file.exe
--     char * parent,   // parent directory
--     char * filetype  // filetype
--     u32    mode,     // file permissions
--     u32    nlinks,   // number of links in dir
--     u32    uid,      // user id
--     char * user,     // username
--     u32    gid,      // group id
--     char * group,    // groupname
--     u64    size,     // file size
--     char * time,     // file time
-- } FsEntry;

local fs_entry = M.fs_entry

-- permission string from stat.mode_t
function M.get_permission_str(mode)
    local filetype = "-"
    if utils.bitand(mode, fs.fs_masks.S_IFREG) > 0 then
        filetype = "-"
    elseif utils.bitand(mode, fs.fs_masks.S_IFDIR) > 0 then
        filetype = "d"
    elseif utils.bitand(mode, fs.fs_masks.S_IFLNK) > 0 then
        filetype = "l"
    elseif utils.bitand(mode, fs.fs_masks.S_IFCHR) > 0 then
        filetype = "c"
    elseif utils.bitand(mode, fs.fs_masks.S_IFBLK) > 0 then
        filetype = "b"
    elseif utils.bitand(mode, fs.fs_masks.S_IFIFO) > 0 then
        filetype = "p"
    elseif utils.bitand(mode, fs.fs_masks.S_IFSOCK) > 0 then
        filetype = "s"
    end

    local rwx = { "---", "--x", "-w-", "-wx", "r--", "r-x", "rw-", "rwx" }
    local access_string = {}

    -- set filetype
    table.insert(access_string, filetype)
    local user = rwx[1 + utils.bitand(mode / 64, 7)]
    local group = rwx[1 + utils.bitand(mode / 8, 7)]
    local other = rwx[1 + utils.bitand(mode, 7)]

    if utils.bitand(mode, fs.fs_masks.S_ISUID) > 0 then
        user = utils.replace_char(3, user, (utils.bitand(mode, fs.fs_masks.S_IXUSR) > 0) and "s" or "S")
    end

    if utils.bitand(mode, fs.fs_masks.S_ISGID) > 0 then
        group = utils.replace_char(3, group, (utils.bitand(mode, fs.fs_masks.S_IXGRP) > 0) and "s" or "l")
    end

    if utils.bitand(mode, fs.fs_masks.S_ISVTX) > 0 then
        other = utils.replace_char(3, other, (utils.bitand(mode, fs.fs_masks.S_IXOTH) > 0) and "t" or "T")
    end

    table.insert(access_string, user)
    table.insert(access_string, group)
    table.insert(access_string, other)
    return table.concat(access_string)
end

-- fs_entry functions

function fs_entry.new(filename, parent_dir, filetype)
    -- create a file entry

    local filepath = fs.join_paths(parent_dir, filename)
    local stat, err = vim.loop.fs_lstat(filepath)
    if stat == nil then
        return nil, err
    end

    local fs_t = {
        filename = filename,
        filepath = filepath,
        parent_dir = parent_dir,
        filetype = filetype,
        mode = stat.mode,
        nlinks = stat.nlink,
        uid = stat.uid,
        owner = utils.getpwid(stat.uid),
        gid = stat.gid,
        group = utils.getgroupname(stat.gid),
        size = stat.size,
        stat = stat,
    }

    return fs_t, err
end

-- fs_entry.cache = {}

function fs_entry.get_directory(directory)
    -- if fs_entry.cache[directory] ~= nil then
    --     return fs_entry.cache[directory]
    -- end
    -- array of fs_entries of all files in the directory
    local dir_fs = {}
    local fs_t = nil
    -- get fd for directory and start scanning.
    local dirfd, error = vim.loop.fs_scandir(directory)
    local dir_size = 0

    -- append the "." directory
    fs_t, error = fs_entry.new(".", directory, "directory")
    table.insert(dir_fs, fs_t)

    -- append the ".." directory
    fs_t, error = fs_entry.new("..", directory, "directory")
    table.insert(dir_fs, fs_t)

    -- scan the rest of the files
    while true do
        -- get filename and filetype
        local filename, filetype = vim.loop.fs_scandir_next(dirfd)
        if filename == nil then
            -- directory scanning completed.
            break
        end

        -- get fullpath of the file.
        fs_t, error = fs_entry.new(filename, directory, filetype)
        if fs_t == nil then
            return nil, error
        end

        dir_size = dir_size + fs_t.size
        -- insert the fs_t in dir_fs
        table.insert(dir_fs, fs_t)
    end

    dir_fs.size = dir_size
    -- return the list of files.
    -- fs_entry.cache[directory] = dir_fs
    return dir_fs
end

-- function to format each component
function fs_entry.format(dir_files, show_dot_dirs, show_hidden)
    -- components :
    --  1. permissions
    --  2. # of links
    --  3. owner name
    --  4. group name
    --  5. size
    --  6. time
    --  7. filename

    -- dictionary of (fs_t -> formatted components)
    local comps_by_fs_t = {}

    -- we don't really care about length of filename
    local max_widths = {
        permlen = 0,
        linklen = 0,
        ownerlen = 0,
        grouplen = 0,
        sizelen = 0,
        monthlen = 0,
        daylen = 0,
        ftimelen = 0,
    }

    local show_file = false
    for _, fs_t in ipairs(dir_files) do
        -- get formatted components

        show_file = false
        if (fs_t.filename == "." or fs_t.filename == "..") and show_dot_dirs then
            show_file = true
        elseif fs.is_hidden(fs_t.filename) and show_hidden then
            show_file = true
        elseif not fs.is_hidden(fs_t.filename) then
            show_file = true
        else
            show_file = false
        end

        if show_file == true then
            local fs_comps = {
                fs_t = fs_t,
                permissions = M.get_permission_str(fs_t.mode),
                nlinks = string.format("%d", fs_t.nlinks),
                owner = fs_t.owner,
                group = fs_t.group,
                size = utils.get_short_size(fs_t.size),
                month = utils.get_month(fs_t.stat),
                day = utils.get_day(fs_t.stat),
                ftime = utils.get_ftime(fs_t.stat),
                filename = fs_t.filename,
            }

            -- calculate maximum widths for each component
            -- length of permissions will always be same
            max_widths.permlen = #fs_comps.permissions

            if max_widths.linklen < #fs_comps.nlinks then
                max_widths.linklen = #fs_comps.nlinks
            end

            if max_widths.ownerlen < #fs_comps.owner then
                max_widths.ownerlen = #fs_comps.owner
            end

            if max_widths.grouplen < #fs_comps.group then
                max_widths.grouplen = #fs_comps.group
            end

            if max_widths.sizelen < #fs_comps.size then
                max_widths.sizelen = #fs_comps.size
            end

            if max_widths.monthlen < #fs_comps.month then
                max_widths.monthlen = #fs_comps.month
            end

            if max_widths.daylen < #fs_comps.day then
                max_widths.daylen = #fs_comps.day
            end

            if max_widths.ftimelen < #fs_comps.ftime then
                max_widths.ftimelen = #fs_comps.ftime
            end

            table.insert(comps_by_fs_t, fs_comps)
        end
    end

    -- calculate where to place cursor?
    local cursor_x = max_widths.permlen
        + max_widths.linklen
        + max_widths.ownerlen
        + max_widths.grouplen
        + max_widths.sizelen
        + max_widths.monthlen
        + max_widths.daylen
        + max_widths.ftimelen
        + 8

    -- we now have length for formatting
    -- we now format the listing properly
    for _, comp in ipairs(comps_by_fs_t) do
        -- format
        comp.nlinks = string.format("%" .. max_widths.linklen .. "s", comp.nlinks)
        comp.owner = string.format("%-" .. max_widths.ownerlen .. "s", comp.owner)
        comp.group = string.format("%-" .. max_widths.grouplen .. "s", comp.group)
        comp.size = string.format("%" .. max_widths.sizelen .. "s", comp.size)
        comp.month = string.format("%" .. max_widths.monthlen .. "s", comp.month)
        comp.day = string.format("%" .. max_widths.daylen .. "s", comp.day)
        comp.ftime = string.format("%" .. max_widths.ftimelen .. "s", comp.ftime)
    end

    return comps_by_fs_t, cursor_x
end


function M.get_file_by_filename(dir_files, filename)
    if string.find(filename, " -> ") then
        filename = utils.str_split(filename, " -> ", true)[1]
    end
    for _, fs_t in ipairs(dir_files) do
        if fs_t.filename == filename then
            return fs_t
        end
    end

    return nil
end

return M
