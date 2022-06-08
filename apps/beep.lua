computer.beep(2000)
for i = 1, 16 do
    require("gui").status("a" .. tostring(i))
end