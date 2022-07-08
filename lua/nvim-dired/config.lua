local M = {}

-- TODO: Implement these
local function sort_default(left, right)
    return true
end

-- TODO: Implement these
local function sort_directories(left, right)
    return true
end

local CONFIG_SPEC = {
    show_hidden = {
        default = true,
        check = function(val)
            if type(val) ~= "boolean" then
                return "Must be boolean, instead received " .. type(val)
            end
        end,
    },
    path_separator = {
        default = "/",
        check = function (val)
            if type(val) ~= "string" then
                return "Must be string of length 1, instead received " .. type(val)
            end
            if #val ~= 1 then
                return "Must be string of length 1, instead received string of length ".. tostring(#val)
            end
        end,
    },
    sort_order = {
        default = sort_default,
        check = function(val)
            if val == "default" then
                return sort_default
            elseif val == "directories" then
                return sort_directories
            elseif type(val) == "function" then
                return val
            else
                return "Must be one of {\"default\", \"directories\", or function}"
            end
        end,
    },
}

local user_config = {}

function M.update(opts)
    local errs = {}
    for opt_name, spec in pairs(CONFIG_SPEC) do
        local val = opts[opt_name]
        if val == nil then
            user_config[opt_name] = nil
        else
            local err, converted = spec.check(val)
            if err ~= nil then
                table.insert(errs, string.format("`%s` %s", opt_name, err))
            else
                user_config[opt_name] = converted
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
        error("Unrecognised Option: ".. opt)
    end
    if user_config[opt] == nil then
        return CONFIG_SPEC[opt].default
    else
        return user_config[opt]
    end
end

return M
