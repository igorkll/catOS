local gui = require("gui")
local colors = require("colors")

local exitFlag = false

local scene = gui.createScene(colors.gray2)
for i = 1, 16 do
    scene.createButton(1, i, 16, 1, "num: " .. tostring(i), function()
        computer.beep(i * 100)
        scene.remove()
        exitFlag = true
    end)
end

--------------------------------------------

scene.select()

while true do
    if exitFlag then return end
    scene.uploadEvent(computer.pullSignal())
end