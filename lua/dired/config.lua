local M = {}

local sort = require("dired.sort")
local util = require("dired.utils")

local CONFIG_SPEC = {
    show_colors = {
        default = true,
        check = function(val)
            if type(val) ~= "boolean" then
                return "Must be boolean, instead received " .. type(val)
            end
        end,
    },
    show_dot_dirs = {
        default = true,
        check = function(val)
            if type(val) ~= "boolean" then
                return "Must be boolean, instead received " .. type(val)
            end
        end,
    },
    show_hidden = {
        default = true,
        check = function(val)
            if type(val) ~= "boolean" then
                return "Must be boolean, instead received " .. type(val)
            end
        end,
    },
    show_icons = {
        default = false,
        check = function(val)
            if type(val) ~= "boolean" then
                return "Must be boolean, instead received " .. type(val)
            end
        end,
    },
    hide_details = {
        default = false,
        check = function(val)
            if type(val) ~= "boolean" then
                return "Must be boolean, instead received " .. type(val)
            end
        end,
    },
    path_separator = {
        default = "/",
        check = function(val)
            if type(val) ~= "string" then
                return "Must be string of length 1, instead received " .. type(val)
            end
            if #val ~= 1 then
                return "Must be string of length 1, instead received string of length " .. tostring(#val)
            end
        end,
    },
    show_banner = {
        default = false,
        check = function(val)
            if type(val) ~= "boolean" then
                return "Must be boolean, instead received " .. type(val)
            end
        end,
    },
    sort_order = {
        default = "name",
        check = function(val)
            if val == "name" then
                return sort.sort_by_name
            elseif val == "dirs" then
                return sort.sort_by_dirs
            elseif val == "date" then
                return sort.sort_by_date
            elseif type(val) == "function" then
                return val
            else
                return 'Must be one of {"name", "dirs", "date", or function}'
            end
        end,
    },
    keybinds = {
        default = {
            dired_enter = "<cr>",
            dired_back = "-",
            dired_up = "_",
            dired_rename = "R",
            dired_create = "d",
            dired_delete = "D",
            dired_delete_range = "D",
            dired_copy = "C",
            dired_copy_range = "C",
            dired_copy_marked = "MC",
            dired_move = "X",
            dired_move_range = "X",
            dired_move_marked = "MX",
            dired_paste = "P",
            dired_mark = "M",
            dired_mark_range = "M",
            dired_delete_marked = "MD",
            dired_toggle_hidden = ".",
            dired_toggle_sort_order = ",",
            dired_toggle_colors = "c",
            dired_toggle_icons = "*",
            dired_toggle_hide_details = "(",
            dired_quit = "q",
        },
        check = function()
            return {}
        end,
    },
    colors = {
        default = {
            DiredDimText = { link = {}, bg = "NONE", fg = "505050", gui = "NONE" },
            DiredDirectoryName = { link = {}, bg = "NONE", fg = "9370DB", gui = "NONE" },
            DiredDotfile = { link = {}, bg = "NONE", fg = "626262" },
            DiredFadeText1 = { link = {}, bg = "NONE", fg = "626262", gui = "NONE" },
            DiredFadeText2 = { link = {}, bg = "NONE", fg = "444444", gui = "NONE" },
            DiredSize = { link = { "Normal" }, bg = "NONE", fg = "None", gui = "NONE" },
            DiredUsername = { link = {}, bg = "NONE", fg = "87CEFA", gui = "bold" },
            DiredMonth = { link = { "Normal" }, bg = "NONE", fg = "None", gui = "bold" },
            DiredDay = { link = { "Normal" }, bg = "NONE", fg = "None", gui = "bold" },
            DiredFileName = { link = {}, bg = "NONE", fg = "NONE", gui = "NONE" },
            DiredFileSuid = { link = {}, bg = "ff6666", fg = "000000", gui = "bold" },
            DiredNormal = { link = { "Normal" }, bg = "NONE", fg = "NONE", gui = "NONE" },
            DiredNormalBold = { link = {}, bg = "NONE", fg = "ffffff", gui = "bold" },
            DiredSymbolicLink = { link = {}, bg = "NONE", fg = "33ccff", gui = "bold" },
            DiredBrokenLink = { link = {}, bg = "2e2e1f", fg = "ff1a1a", gui = "bold" },
            DiredSymbolicLinkTarget = { link = {}, bg = "5bd75b", fg = "000000", gui = "bold" },
            DiredBrokenLinkTarget = { link = {}, bg = "2e2e1f", fg = "ff1a1a", gui = "bold" },
            DiredFileExecutable = { link = {}, bg = "NONE", fg = "5bd75b", gui = "bold" },
            DiredMarkedFile = { link = {}, bg = "NONE", fg = "a8b103", gui = "bold" },
            DiredCopyFile = { link = {}, bg = "NONE", fg = "ff8533", gui = "bold" },
            DiredMoveFile = { link = {}, bg = "NONE", fg = "ff3399", gui = "bold" },
        },
        check = function(cfg)
            for k, v in pairs(cfg) do
                if v["link"] == nil or v["bg"] == nil or v["fg"] == nil or v["gui"] == nil then
                    return "Must contain a link, bg, fg and gui element for each highlight group"
                end
            end
        end,
    },
}

local user_config = {}

function M.update(opts)
    local errs = {}
    for opt_name, spec in pairs(CONFIG_SPEC) do
        local usr_val = opts[opt_name]
        if usr_val == nil then
            user_config[opt_name] = nil
        else
            -- create keybind config of user + defaults
            if opt_name == "keybinds" then
                user_config.keybinds = util.shallowcopy(CONFIG_SPEC.keybinds.default)
                local ret = spec.check(usr_val)
                if type(ret) == "string" then
                    table.insert(errs, string.format("`%s` %s", opt_name, ret))
                else
                    for key, val in pairs(usr_val) do
                        user_config.keybinds[key] = val
                    end
                end

            -- create colors config of user + defaults
            elseif opt_name == "colors" then
                user_config.colors = util.shallowcopy(CONFIG_SPEC.colors.default)
                local ret = spec.check(usr_val)
                if type(ret) == "string" then
                    table.insert(errs, string.format("`%s` %s", opt_name, ret))
                else
                    for key, val in pairs(usr_val) do
                        user_config.colors[key] = val
                    end
                end
            elseif opt_name == "sort_order" then
                local ret = spec.check(usr_val)
                if type(ret) == "string" then
                    table.insert(errs, string.format("`%s` %s", opt_name, ret))
                else
                    user_config[opt_name] = ret
                end

            -- handle rest of the config that are not tables
            else
                local ret = spec.check(usr_val)
                if type(ret) == "string" then
                    table.insert(errs, string.format("`%s` %s", opt_name, ret))
                else
                    user_config[opt_name] = usr_val
                end
            end
        end
    end

    local unrecognised_opts = {}
    for key, _ in pairs(opts) do
        if CONFIG_SPEC[key] == nil then
            table.insert(unrecognised_opts, string.format("`%s`", key))
        end
    end

    if #unrecognised_opts > 0 then
        table.insert(errs, table.concat(unrecognised_opts, ", ") .. "not recognised")
    end

    return errs
end

function M.get(opt)
    if CONFIG_SPEC[opt] == nil then
        error("Unrecognised Option: " .. opt)
    end
    if user_config[opt] == nil then
        return CONFIG_SPEC[opt].default
    else
        return user_config[opt]
    end
end

function M.get_sort_order(val)
    if val == "name" then
        return sort.sort_by_name
    elseif val == "dirs" then
        return sort.sort_by_dirs
    elseif val == "date" then
        return sort.sort_by_date
    elseif type(val) == "function" then
        return val
    else
        return nil
    end
end

function M.get_next_sort_order()
    local current = vim.g.dired_sort_order
    local sorting_functions = { "name", "date", "dirs" }
    local idx = 0
    for i, str in ipairs(sorting_functions) do
        if str == current then
            table.remove(sorting_functions, i)
            idx = i
        end
    end
    if idx > #sorting_functions then
        idx = 1
    end
    return sorting_functions[idx]
end

return M
