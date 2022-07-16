-- TODO: Implement these

local M = {}
function M.sort_by_name(left, right)
    left = left.component.fs_t
    right = right.component.fs_t
    return left.filename:lower() < right.filename:lower()
end

function M.sort_by_date(left, right)
    left = left.component.fs_t
    right = right.component.fs_t
    return left.stat.mtime.sec < right.stat.mtime.sec
end

-- TODO: Implement these
function M.sort_by_dirs(left, right)
    left = left.component.fs_t
    right = right.component.fs_t
    if left.filetype ~= right.filetype then
        return left.filetype < right.filetype
    else
        return left.filename:lower() < right.filename:lower()
    end
end

return M
