-- util functions
local uv = vim.loop

local M = {}

function M.str_split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function M.getpwid(uid)
    -- return password database from /etc/passwd
    -- for a particular id
    local fd = uv.fs_open("/etc/passwd", "r", 0) -- open(file, O_RDONLY)
    local passwd = uv.fs_read(fd, 0xffff, 0)
    uv.fs_close(fd)

    -- start parsing
    passwd = M.str_split(passwd, "\n")
    for i, passwd_entry in ipairs(passwd) do
        if #passwd_entry > 0 then
            passwd_entry = M.str_split(passwd_entry, ":")
            local pwstruct = {
                idx = i,
                username = passwd_entry[1],
                uid = tonumber(passwd_entry[3], 10),
                gid = tonumber(passwd_entry[4], 10),
                homedir = passwd_entry[6],
                shell = passwd_entry[7]
            }

            if pwstruct.uid == uid then
                return pwstruct
            end
        end
    end
    return nil
end

function M.getgroupname(gid)
    local fd = uv.fs_open("/etc/group", "r", 0) -- open(file, O_RDONLY)
    local group = uv.fs_read(fd, 0xffff, 0)
    uv.fs_close(fd)

    group = M.str_split(group, "\n")
    for i, group_entry in ipairs(group) do
        if #group_entry > 0 then
            group_entry = M.str_split(group_entry, ":")
            local gpstruct = {
                idx = i,
                username = group_entry[1],
                gid = tonumber(group_entry[3], 10)
            }

            if gpstruct.gid == gid then
                return gpstruct
            end
        end
    end
    return nil
end

function M.get_short_size(size)
    local size_units = {
        "B ",
        "KB",
        "MB",
        "GB",
        "TB"
    }
    local idx = 1
    while size > 1024 and idx < 5 do
        size = size / 1024
        idx = idx + 1
    end

    return string.format("%7.1f %s", size, size_units[idx])
end

function M.bitand(a, b)
    local r, m, s = 0, 2 ^ 31, 0
    repeat
        s, a, b = a + b + m, a % m, b % m
        r, m = r + m * 4 % (s - a - b), m / 2
    until m < 1
    return r
end

function M.bitor(a, b)
    local r, m, s = 0, 2 ^ 31, 0
    repeat
        s, a, b = a + b + m, a % m, b % m
        r, m = r + m * 1 % (s - a - b), m / 2
    until m < 1
    return r
end

function M.bitxor(a, b)
    local r, m, s = 0, 2 ^ 31, 0
    repeat
        s, a, b = a + b + m, a % m, b % m
        r, m = r + m * 3 % (s - a - b), m / 2
    until m < 1
    return r
end
return M
