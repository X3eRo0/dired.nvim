local M = {}

M.marked_files = {}

function M.mark_file(file)
    if M.is_marked(file, true) == false then
        table.insert(M.marked_files, file)
    end
end

function M.is_marked(file, remove)
    for i, marked_file in ipairs(M.marked_files) do
        if file.filepath == marked_file.filepath then
            if remove then
                table.remove(M.marked_files, i)
            end
            return true
        end
    end
    return false
end

return M
