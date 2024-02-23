-- util functions
local M = {}

M.uid_cache = {}
M.gid_cache = {}

function M.get_visual_selection()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return lines
end

function M.is_match_empty(pat, plain)
    return not not string.find("", pat, nil, plain)
end

function M.str_split(str, sep, plain)
    local b, res = 0, {}
    sep = sep or "%s+"

    assert(type(sep) == "string")
    assert(type(str) == "string")

    if #sep == 0 then
        for i = 1, #str do
            res[#res + 1] = string.sub(str, i, i)
        end
        return res
    end

    assert(not M.is_match_empty(sep, plain), "delimiter can not match empty string")

    while b <= #str do
        local e, e2 = string.find(str, sep, b, plain)
        if e then
            res[#res + 1] = string.sub(str, b, e - 1)
            b = e2 + 1
            if b > #str then
                res[#res + 1] = ""
            end
        else
            res[#res + 1] = string.sub(str, b)
            break
        end
    end
    return res
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

function M.find(table, elem)
    for i, e in ipairs(table) do
        if e == elem then
            return i
        end
    end
    return nil
end

function M.getpwid(uid)
    -- using GNU id to get username/group because libuv
    -- does not have a function to return password
    -- database by user id. Only os_get_passwd() is
    -- available.

    if vim.loop.os_uname().sysname == "Windows_NT" then
        return vim.loop.os_getenv("USERNAME")
    end

    if M.uid_cache[uid] ~= nil then
        return M.uid_cache[uid]
    end

    local username = vim.fn.system(string.format("id -nu %d", uid))
    if not username then
        return nil
    end
    username = username:gsub("[\n\r]", "")
    if string.find(username, "no such user") then
        username = "<NULL>"
    end
    M.uid_cache[uid] = username
    return username
end

function M.getgroupname(gid)
    -- using getent to get groupname.

    local sysname = vim.loop.os_uname().sysname
    if sysname == "Windows_NT" then
        return vim.loop.os_gethostname()
    end

    if M.gid_cache[gid] ~= nil then
        return M.gid_cache[gid]
    end

    local groupname = "<NULL>"

    if sysname == "Darwin" then
        groupname = vim.fn.system(string.format("dscl . -list /Groups PrimaryGroupID | awk '$2 == %d {print $1}'", gid))
    else
        groupname =
            vim.fn.system(string.format("cat /etc/group | grep :%d:| head -n 1 | awk -F ':' '{ print $1}'", gid))
    end

    if not groupname then
        return "???"
    end

    groupname = groupname:gsub("[\n\r]", "")
    if string.find(groupname, "no such user") then
        groupname = "???"
    end

    M.gid_cache[gid] = groupname
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

function M.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end

    return copy
end

function M.tableLength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

return M
