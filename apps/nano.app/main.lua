local gui = require("gui")
local colors = require("colors")
local utiles = require("utiles")
local fs = require("filesystem")
local nano = dofile(fs.concat(fs.path(utiles.getPath()), "nano.lua"))

--------------------------------------------

local rx, ry = gui.maxResolution()
local scene = gui.createScene(colors.blue, rx, ry)

--------------------------------------------

local 

--------------------------------------------

scene.select()

while true do
    local eventData = {computer.pullSignal()}
    if eventData[1] == "exitPressed" then
        scene.remove()
        return
    end
    gui.uploadEvent(table.unpack(eventData))
end