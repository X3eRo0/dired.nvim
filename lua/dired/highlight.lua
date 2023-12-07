---@diagnostic disable: missing-parameter, param-type-mismatch

local config = require("dired.config")

local vim = vim
local M = {}

M.DIM_TEXT = "DiredDimText"
M.DIRECTORY_NAME = "DiredDirectoryName"
M.DOTFILE = "DiredDotfile"
M.FADE_TEXT_1 = "DiredFadeText1"
M.FADE_TEXT_2 = "DiredFadeText2"
M.FILE_NAME = "DiredFileName"
M.FILE_SUID = "DiredFileSuid"
M.FILE_EXECUTABLE = "DiredFileExecutable"
M.NORMAL = "DiredNormal"
M.SIZE = "DiredSize"
M.NORMALBOLD = "DiredNormalBold"
M.USERNAME = "DiredUsername"
M.MONTH = "DiredMonth"
M.DAY = "DiredDay"
M.SYMBOLIC_LINK = "DiredSymbolicLink"
M.BROKEN_LINK = "DiredBrokenLink"
M.SYMBOLIC_LINK_TARGET = "DiredSymbolicLinkTarget"
M.BROKEN_LINK_TARGET = "DiredBrokenLinkTarget"
M.MARKED_FILE = "DiredMarkedFile"
M.COPY_FILE = "DiredCopyFile"
M.MOVE_FILE = "DiredMoveFile"

local function dec_to_hex(n, chars)
    chars = chars or 6
    local hex = string.format("%0" .. chars .. "x", n)
    while #hex < chars do
        hex = "0" .. hex
    end
    return hex
end

---If the given highlight group is not defined, define it.
---@param hl_group_name string The name of the highlight group.
---@param link_to_if_exists table A list of highlight groups to link to, in
--order of priority. The first one that exists will be used.
---@param background string The background color to use, in hex, if the highlight group
--is not defined and it is not linked to another group.
---@param foreground string The foreground color to use, in hex, if the highlight group
--is not defined and it is not linked to another group.
---@gui string The gui to use, if the highlight group is not defined and it is not linked
--to another group.
---@return table table The highlight group values.
local function create_highlight_group(hl_group_name, link_to_if_exists, background, foreground, gui)
    local success, hl_group = pcall(vim.api.nvim_get_hl_by_name, hl_group_name, true)
    if not success or not hl_group.foreground or not hl_group.background then
        for _, link_to in ipairs(link_to_if_exists) do
            success, hl_group = pcall(vim.api.nvim_get_hl_by_name, link_to, true)
            if success then
                local new_group_has_settings = background or foreground or gui
                local link_to_has_settings = hl_group.foreground or hl_group.background
                if link_to_has_settings or not new_group_has_settings then
                    vim.cmd("highlight default link " .. hl_group_name .. " " .. link_to)
                    return hl_group
                end
            end
        end

        if type(background) == "number" then
            background = dec_to_hex(background)
        end
        if type(foreground) == "number" then
            foreground = dec_to_hex(foreground)
        end

        local cmd = "highlight default " .. hl_group_name
        if background then
            cmd = cmd .. " guibg=#" .. background
        end
        if foreground then
            cmd = cmd .. " guifg=#" .. foreground
        else
            cmd = cmd .. " guifg=NONE"
        end
        if gui then
            cmd = cmd .. " gui=" .. gui
        end
        vim.cmd(cmd)

        return {
            background = background and tonumber(background, 16) or nil,
            foreground = foreground and tonumber(foreground, 16) or nil,
        }
    end
    return hl_group
end

local faded_highlight_group_cache = {}
M.get_faded_highlight_group = function(hl_group_name, fade_percentage)
    if type(hl_group_name) ~= "string" then
        error("hl_group_name must be a string")
    end
    if type(fade_percentage) ~= "number" then
        error("hl_group_name must be a number")
    end
    if fade_percentage < 0 or fade_percentage > 1 then
        error("fade_percentage must be between 0 and 1")
    end

    local key = hl_group_name .. "_" .. tostring(math.floor(fade_percentage * 100))
    if faded_highlight_group_cache[key] then
        return faded_highlight_group_cache[key]
    end

    local normal = vim.api.nvim_get_hl_by_name("Normal", true)
    if type(normal.foreground) ~= "number" then
        if vim.api.nvim_get_option("background") == "dark" then
            normal.foreground = 0xffffff
        else
            normal.foreground = 0x000000
        end
    end
    if type(normal.background) ~= "number" then
        if vim.api.nvim_get_option("background") == "dark" then
            normal.background = 0x000000
        else
            normal.background = 0xffffff
        end
    end
    local foreground = dec_to_hex(normal.foreground)
    local background = dec_to_hex(normal.background)

    local hl_group = vim.api.nvim_get_hl_by_name(hl_group_name, true)
    if type(hl_group.foreground) == "number" then
        foreground = dec_to_hex(hl_group.foreground)
    end
    if type(hl_group.background) == "number" then
        background = dec_to_hex(hl_group.background)
    end

    local gui = {}
    if hl_group.bold then
        table.insert(gui, "bold")
    end
    if hl_group.italic then
        table.insert(gui, "italic")
    end
    if hl_group.underline then
        table.insert(gui, "underline")
    end
    if hl_group.undercurl then
        table.insert(gui, "undercurl")
    end
    if #gui > 0 then
        gui = table.concat(gui, ",")
    else
        gui = nil
    end

    local f_red = tonumber(foreground:sub(1, 2), 16)
    local f_green = tonumber(foreground:sub(3, 4), 16)
    local f_blue = tonumber(foreground:sub(5, 6), 16)

    local b_red = tonumber(background:sub(1, 2), 16)
    local b_green = tonumber(background:sub(3, 4), 16)
    local b_blue = tonumber(background:sub(5, 6), 16)

    local red = (f_red * fade_percentage) + (b_red * (1 - fade_percentage))
    local green = (f_green * fade_percentage) + (b_green * (1 - fade_percentage))
    local blue = (f_blue * fade_percentage) + (b_blue * (1 - fade_percentage))

    local new_foreground = string.format("%s%s%s", dec_to_hex(red, 2), dec_to_hex(green, 2), dec_to_hex(blue, 2))

    create_highlight_group(key, {}, hl_group.background, new_foreground, gui)
    faded_highlight_group_cache[key] = key
    return key
end

M.setup = function()
    -- Reset this here in case of color scheme change
    local clr = config.get("colors")
    if clr ~= nil then
        create_highlight_group(
            M.DIM_TEXT,
            clr.DiredDimText.hg,
            clr.DiredDimText.bg,
            clr.DiredDimText.fg,
            clr.DiredDimText.gui
        )
        create_highlight_group(
            M.DIRECTORY_NAME,
            clr.DiredDirectoryName.hg,
            clr.DiredDirectoryName.bg,
            clr.DiredDirectoryName.fg,
            clr.DiredDirectoryName.gui
        )
        create_highlight_group(
            M.DOTFILE,
            clr.DiredDotfile.hg,
            clr.DiredDotfile.bg,
            clr.DiredDotfile.fg,
            clr.DiredDotfile.gui
        )
        create_highlight_group(
            M.FADE_TEXT_1,
            clr.DiredFadeText1.hg,
            clr.DiredFadeText1.bg,
            clr.DiredFadeText1.fg,
            clr.DiredFadeText1.gui
        )
        create_highlight_group(
            M.FADE_TEXT_2,
            clr.DiredFadeText2.hg,
            clr.DiredFadeText2.bg,
            clr.DiredFadeText2.fg,
            clr.DiredFadeText2.gui
        )

        create_highlight_group(M.SIZE, clr.DiredSize.hg, clr.DiredSize.bg, clr.DiredSize.fg, clr.DiredSize.gui)
        create_highlight_group(
            M.USERNAME,
            clr.DiredUsername.hg,
            clr.DiredUsername.bg,
            clr.DiredUsername.fg,
            clr.DiredUsername.gui
        )
        create_highlight_group(M.MONTH, clr.DiredMonth.hg, clr.DiredMonth.bg, clr.DiredMonth.fg, clr.DiredMonth.gui)
        create_highlight_group(M.DAY, clr.DiredDay.hg, clr.DiredDay.bg, clr.DiredDay.fg, clr.DiredDay.gui)
        create_highlight_group(
            M.FILE_NAME,
            clr.DiredFileName.hg,
            clr.DiredFileName.bg,
            clr.DiredFileName.fg,
            clr.DiredFileName.gui
        )
        create_highlight_group(
            M.FILE_SUID,
            clr.DiredFileSuid.hg,
            clr.DiredFileSuid.bg,
            clr.DiredFileSuid.fg,
            clr.DiredFileSuid.gui
        )
        create_highlight_group(
            M.NORMAL,
            clr.DiredNormal.hg,
            clr.DiredNormal.bg,
            clr.DiredNormal.fg,
            clr.DiredNormal.gui
        )
        create_highlight_group(
            M.NORMALBOLD,
            clr.DiredNormalBold.hg,
            clr.DiredNormalBold.bg,
            clr.DiredNormalBold.fg,
            clr.DiredNormalBold.gui
        )
        create_highlight_group(
            M.SYMBOLIC_LINK,
            clr.DiredSymbolicLink.hg,
            clr.DiredSymbolicLink.bg,
            clr.DiredSymbolicLink.fg,
            clr.DiredSymbolicLink.gui
        )
        create_highlight_group(
            M.SYMBOLIC_LINK_TARGET,
            clr.DiredBrokenLink.hg,
            clr.DiredBrokenLink.bg,
            clr.DiredBrokenLink.fg,
            clr.DiredBrokenLink.gui
        )
        create_highlight_group(
            M.BROKEN_LINK,
            clr.DiredSymbolicLinkTarget.hg,
            clr.DiredSymbolicLinkTarget.bg,
            clr.DiredSymbolicLinkTarget.fg,
            clr.DiredSymbolicLinkTarget.gui
        )
        create_highlight_group(
            M.BROKEN_LINK_TARGET,
            clr.DiredBrokenLinkTarget.hg,
            clr.DiredBrokenLinkTarget.bg,
            clr.DiredBrokenLinkTarget.fg,
            clr.DiredBrokenLinkTarget.gui
        )
        create_highlight_group(
            M.FILE_EXECUTABLE,
            clr.DiredFileExecutable.hg,
            clr.DiredFileExecutable.bg,
            clr.DiredFileExecutable.fg,
            clr.DiredFileExecutable.gui
        )
        create_highlight_group(
            M.MARKED_FILE,
            clr.DiredMarkedFile.hg,
            clr.DiredMarkedFile.bg,
            clr.DiredMarkedFile.fg,
            clr.DiredMarkedFile.gui
        )
        create_highlight_group(
            M.COPY_FILE,
            clr.DiredCopyFile.hg,
            clr.DiredCopyFile.bg,
            clr.DiredCopyFile.fg,
            clr.DiredCopyFile.gui
        )
        create_highlight_group(
            M.MOVE_FILE,
            clr.DiredMoveFile.hg,
            clr.DiredMoveFile.bg,
            clr.DiredMoveFile.fg,
            clr.DiredMoveFile.gui
        )
    end
end

return M
