local gui = require("gui")
local colors = require("colors")

local scene = gui.createScene(colors.green, 50, 16)
local b1 = scene.createButton(1, 1, 8, 3, "asd123", function(new, old)
    if new then
        computer.beep(2000)
    else
        computer.beep(200)
    end
end, 0)

scene.select()

while true do
    local eventData = {computer.pullSignal()}
    if eventData[1] == "mainButtonPressed" and eventData[2] == 0 then
        return
    end
    gui.uploadEvent(table.unpack(eventData))
end