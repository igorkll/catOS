--[[
for i = 1, 16 do
    local tim = registerTimer(1, function()
        
    end, math.huge)
    cancelTimer(tim)
end
]]

if not _G.tbk then _G.tbk = {} end
for i = 1, 16 do
    _G.tbk[math.floor(math.random(0, 10))] = string.rep(" ", 1024 * 4)
    for i = #_G.tbk, 1, -1 do
        table.remove(_G.tbk, 1)
    end
end