local gui = require("gui")
local colors = require("colors")
local utiles = require("utiles")
local fs = require("filesystem")

--------------------------------------------

local thisPath = fs.path(utiles.getPath())
local rx, ry = gui.maxResolution()
local scene = gui.createScene(colors.green, rx, ry)

--------------------------------------------

local appsButtons = {}
local function refreshAppList()
    for i, v in ipairs(appsButtons) do
        appsButtons.remove()
    end
    local count = 0
    for file in fs.list("/apps") do
        local full_path = fs.concat("/apps", file)
        if full_path ~= thisPath then
            count = count + 1
            local b = scene.createButton((1 + count) % 9, (1 + count) // 8, 8, 4, fs.name(full_path), function()
                os.execute(full_path)
            end)
            b.backColor = colors.yellow
            b.foreColor = colors.orange
        end
    end
end
refreshAppList()

--------------------------------------------

scene.select()

while true do
    local eventData = {computer.pullSignal()}
    if eventData[1] == "exitPressed" then
        computer.beep(200)
        computer.beep(200)
    end
    gui.uploadEvent(table.unpack(eventData))
end