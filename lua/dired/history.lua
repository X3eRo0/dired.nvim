
local M = {}

M.path_stack = {}
M.path_stackptr = 0

function M.push_path(path)
    table.insert(M.path_stack, path)
    M.path_stackptr = M.path_stackptr + 1
end

function M.pop_path()
    M.path_stackptr = M.path_stackptr - 1
    return table.remove(M.path_stack, M.path_stackptr + 1)
end

return M
