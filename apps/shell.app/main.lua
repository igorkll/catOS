local function loop()
    local gui = require("gui")
    
    local scene = gui.createScene(colors.green, 50, 16)
    local b1 = scene.createButton(1, 1, 8, 3, "asd123", function()
        
    end, 2)

    scene.select()

    while true do
        gui.uploadEvent(computer.pullSignal())
    end
end
local ok, err = xpcall(loop, debug.traceback)
if not ok then
    error(err, 0)
end