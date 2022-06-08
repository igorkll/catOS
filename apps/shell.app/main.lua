local gui = require("gui")
local colors = require("colors")
local utiles = require("utiles")
local fs = require("filesystem")

--------------------------------------------

local thisPath = fs.path(utiles.getPath())
thisPath = unicode.sub(thisPath, 1, unicode.len(thisPath) - 1)

local rx, ry = gui.maxResolution()
--local rx, ry = 25, 10
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
            local name = fs.name(full_path)
            if name:find("%.") then
                local parts = utiles.split(name, ".")
                parts[#parts] = nil
                name = table.concat(parts, ".")
            end

            local b = scene.createButton(((count % (rx // 9)) * 9) + 1,
            (((count * 9) // (rx - 8)) * 5) + 1, 8, 4, name, function(_, _, nikname)
                os.execute(full_path, nikname)
            end)
            count = count + 1
            b.backColor = colors.yellow
            b.foreColor = colors.orange
            b.invBackColor = colors.cyan
            b.invForeColor = colors.red
            table.insert(appsButtons, b)
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