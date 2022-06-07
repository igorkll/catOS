local lib = {}

function lib.table_remove(tbl, obj)
    for i = 1, #tbl do
        if tbl[i] == obj then
            table.remove(tbl, i)
        end
    end
end

function lib.xor(...)
    local dat = {...}
    local state = false
    for i = 1, #dat do
        if dat[i] then
            state = not state
        end
    end
    return state
end

return lib