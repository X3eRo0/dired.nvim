-- util functions
local M = {}

function M.str_split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function M.replace_char(pos, str, r)
    return str:sub(1, pos - 1) .. r .. str:sub(pos + 1)
end

function M.concatenate_tables(table1, table2)
    for _, v in ipairs(table2) do
        table.insert(table1, v)
    end
    return table1
end

function M.getpwid(uid)
    -- using GNU id to get username because libuv
    -- does not have a function to return password
    -- database by user id. Only os_get_passwd() is
    -- available.

    local username = vim.fn.system(string.format("id -nu %d", uid))
    if not username then
        return nil
    end
    username = username:gsub("[\n\r]", "")
    return username
end

function M.getgroupname(gid)
    -- using GNU id to get groupname.

    local groupname = vim.fn.system(string.format("id -ng %d", gid))
    if not groupname then
        return nil
    end
    groupname = groupname:gsub("[\n\r]", "")
    return groupname
end

function M.get_short_size(size)
    local size_units = {
        "",
        "K",
        "M",
        "G",
        "T",
    }
    local idx = 1
    while size > 1024 and idx < 5 do
        size = size / 1024
        idx = idx + 1
    end

    if idx == 1 then
        return string.format("%d%s", size, size_units[idx])
    else
        return string.format("%.1f%s", size, size_units[idx])
    end
end

function M.get_ftime(stat)
    local os = require("os")

    -- decide which time to show mtime or ctime?
    local time = nil
    if stat.ctime.sec > stat.mtime.sec then
        time = stat.ctime.sec
    else
        time = stat.mtime.sec
    end
    local cdate = os.date("*t", time)
    local tdate = os.date("*t", os.time())
    local show_year = false

    if cdate.year < tdate.year then
        show_year = true
    end

    local ftime = nil
    if show_year then
        ftime = vim.fn.strftime("%Y  %H:%M", time)
    else
        ftime = vim.fn.strftime("%m-%y %H:%M", time)
    end

    return ftime
end

function M.get_month(stat)
    local os = require("os")

    -- decide which time to show mtime or ctime?
    local time = nil
    if stat.ctime.sec > stat.mtime.sec then
        time = stat.ctime.sec
    else
        time = stat.mtime.sec
    end
    return vim.fn.strftime("%b", time)
end

function M.get_day(stat)
    local os = require("os")

    -- decide which time to show mtime or ctime?
    local time = nil
    if stat.ctime.sec > stat.mtime.sec then
        time = stat.ctime.sec
    else
        time = stat.mtime.sec
    end
    return vim.fn.strftime("%e", time)
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
