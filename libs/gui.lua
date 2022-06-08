local colors = require("colors")
local utiles = require("utiles")

--------------------------------------------

local lib = {}
lib.scenes = {}
lib.scene = false

registerTimer(1, function()
    computer.beep((#lib.scenes + 1) * 100)
end, math.huge)

lib.posXadd = 0
lib.posYadd = 1

lib.resXadd = 0
lib.resYadd = 2

function lib.drawUi()
    local rx, ry = gpu.getResolution()
    gpu.setBackground(colors.purple)
    gpu.fill(1, 1, rx, ry, " ")
end

function lib.maxResolution()
    local mx, my = gpu.maxResolution()
    my = my - lib.resYadd
    return math.floor(mx), math.floor(my)
end

function lib.getCenter(posX, posY, sizeX, sizeY)
    return math.floor((posX + (sizeX // 2)) + 0.5), math.floor((posY + (sizeY // 2)) + 0.5)
end

function lib.drawText(posX, posY, sizeX, sizeY, text, offSetX, offSetY, resetX, resetY)
    local x, y = lib.getCenter(posX, posY, sizeX, sizeY, text)
    x = math.floor((x - (unicode.len(text) / 2)) + 0.5)
    if resetX then x = 0 end
    if resetY then y = 0 end
    x = x + (offSetX or 0)
    y = y + (offSetY or 0)
    gpu.set(x, y, text)
end

function lib.detab(value, tabWidth)
    checkArg(1, value, "string")
    checkArg(2, tabWidth, "number", "nil")
    tabWidth = tabWidth or 8
    local function rep(match)
        local spaces = tabWidth - match:len() % tabWidth
        return match .. string.rep(" ", spaces)
    end
    local result = value:gsub("([^\n]-)\t", rep) -- truncate results
    return result
end

function lib.createScene(color, resx, resy)
    local scene = {}
    scene.objs = {}
    scene.selectCallbacks = {}
    scene.leaveCallbacks = {}
    scene.removeCallbacks = {}
    scene.removed = false

    scene.color = color or colors.green
    local mx, my = lib.maxResolution()
    scene.resx = resx or mx
    scene.resy = resy or my

    scene.service = {}

    function scene.checkRemove()
        if scene.removed then error("this scene removed", 0) end
    end

    function scene.draw()
        scene.checkRemove()
        gpu.setResolution(scene.resx + lib.resXadd, scene.resy + lib.resYadd)
        lib.drawUi()
        gpu.setBackground(scene.color)
        gpu.fill(1 + lib.posXadd, 1 + lib.posYadd, scene.resx, scene.resy, " ")
        for i, v in ipairs(scene.objs) do v.draw() end
    end

    local function callTbl(tbl)
        for i = #tbl, 1 do
            if tbl[i] then tbl[i]() end
        end
    end

    function scene.select()
        scene.checkRemove()
        if lib.scene then callTbl(scene.leaveCallbacks) end
        lib.scene = scene
        callTbl(scene.selectCallbacks)
        scene.draw()
    end

    function scene.remove()
        scene.checkRemove()
        callTbl(scene.leaveCallbacks)
        callTbl(scene.removeCallbacks)
        utiles.table_remove(lib.scenes, scene)
        scene.removed = true
    end

    function scene.uploadEvent(...)
        scene.checkRemove()
        for i, v in ipairs(scene.objs) do v.uploadEvent(...) end
    end

    --------------------------------------------

    function scene.createButton(x, y, sizeX, sizeY, text, callback, mode)
        local obj = {}
        obj.backColor = colors.white
        obj.foreColor = colors.gray2
        obj.invBackColor = colors.gray1
        obj.invForeColor = colors.black
        obj.text = text

        obj.mode = mode or 0
        obj.callback = callback or function() end

        obj.posX = x + lib.posXadd
        obj.posY = y + lib.posYadd

        obj.sizeX = sizeX
        obj.sizeY = sizeY

        obj.state = false

        obj.removed = false

        function obj.checkRemove()
            if scene.removed then error("this object removed", 0) end
        end

        function obj.remove()
            obj.checkRemove()
            utiles.table_remove(scene.objs, obj)
            scene.removed = true
        end

        function obj.draw()
            obj.checkRemove()
            if utiles.xor(obj.state, obj.mode == 1) then
                gpu.setBackground(obj.invBackColor)
                gpu.setForeground(obj.invForeColor)
            else
                gpu.setBackground(obj.backColor)
                gpu.setForeground(obj.foreColor)
            end
            gpu.fill(obj.posX, obj.posY, obj.sizeX, obj.sizeY, " ")
            lib.drawText(obj.posX, obj.posY, obj.sizeX, obj.sizeY, obj.text)
        end
        
        function obj.uploadEvent(...)
            local tbl = {...}
            if obj.mode == 0 then
                if tbl[1] == "touch" and tbl[5] == 0 and tbl[3] >= obj.posX and tbl[3] < (obj.posX + obj.sizeX) then
                    if tbl[4] >= obj.posY and tbl[4] < (obj.posY + obj.sizeY) then
                        obj.state = true
                        obj.draw()
                        computer.delay()
                        obj.state = false
                        obj.draw()
                        obj.callback(true, false, tbl[6])
                    end
                end
            elseif obj.mode == 1 then
                if tbl[1] == "touch" and tbl[5] == 0 and tbl[3] >= obj.posX and tbl[3] < (obj.posX + obj.sizeX) then
                    if tbl[4] >= obj.posY and tbl[4] < (obj.posY + obj.sizeY) then
                        obj.state = not obj.state
                        obj.draw()
                        obj.callback(obj.state, not obj.state, tbl[6])
                    end
                end
            elseif obj.mode == 2 then
                if tbl[1] == "touch" and tbl[5] == 0 and tbl[3] >= obj.posX and tbl[3] < (obj.posX + obj.sizeX) then
                    if tbl[4] >= obj.posY and tbl[4] < (obj.posY + obj.sizeY) then
                        obj.state = not obj.state
                        obj.draw()
                        obj.callback(obj.state, not obj.state, tbl[6])
                        return
                    end
                end
                if (tbl[1] == "drop" or tbl[1] == "touch") and obj.state then
                    obj.state = false
                    obj.draw()
                    obj.callback(obj.state, not obj.state, tbl[6])
                end
            end
        end
        
        table.insert(scene.objs, obj)
        table.insert(scene.removeCallbacks, obj.remove)
        return obj
    end

    function scene.createLabel(x, y, sizeX, sizeY, text)
        local obj = {}
        obj.backColor = colors.white
        obj.foreColor = colors.gray2
        obj.text = text

        obj.posX = x + lib.posXadd
        obj.posY = y + lib.posYadd

        obj.sizeX = sizeX
        obj.sizeY = sizeY

        obj.removed = false

        function obj.checkRemove()
            if scene.removed then error("this object removed", 0) end
        end

        function obj.remove()
            obj.checkRemove()
            utiles.table_remove(scene.objs, obj)
            scene.removed = true
            for i, v in ipairs(scene.timers) do
                cancelTimer(scene.timers)
            end
        end

        function obj.draw()
            obj.checkRemove()
            gpu.setBackground(obj.backColor)
            gpu.setForeground(obj.foreColor)
            gpu.fill(obj.posX, obj.posY, obj.sizeX, obj.sizeY, " ")
            lib.drawText(obj.posX, obj.posY, obj.sizeX, obj.sizeY, obj.text)
        end
        
        function obj.uploadEvent(...)
        end
        
        table.insert(scene.objs, obj)
        table.insert(scene.removeCallbacks, obj.remove)
        return obj
    end

    --------------------------------------------

    
    table.insert(lib.scenes, scene)

    local mainbutton = scene.createButton(scene.resx / 2, scene.resy + 1, 2, 1, "◖◗", function() computer.pushSignal("exitPressed") end, 0)
    mainbutton.backColor = colors.purple
    mainbutton.foreColor = colors.white
    mainbutton.invBackColor = colors.purple
    mainbutton.invForeColor = colors.red

    local powerLabel = scene.createLabel(1, 0, 16, 1)
    powerLabel.backColor = colors.purple
    powerLabel.foreColor = colors.white

    local ramLabel = scene.createLabel(scene.resx - 15, 0, 16, 1)
    ramLabel.backColor = colors.purple
    ramLabel.foreColor = colors.white

    scene.timers = {}

    function scene.refresh(noNotSkip)
        if not noNotSkip and (scene.removed or lib.scene ~= scene) then return end
        ramLabel.text = "ram: " .. tostring(utiles.floorAt(utiles.mapClip(computer.freeMemory(), computer.totalMemory(), 0, 0, 100), 0.1)) .. "%"
        powerLabel.text = "power: " .. tostring(utiles.floorAt(utiles.mapClip(computer.energy(), 0, computer.maxEnergy(), 0, 100), 0.1)) .. "%"
        ramLabel.draw()
        powerLabel.draw()
    end
    scene.refresh(true)
    table.insert(scene.timers, registerTimer(1, scene.refresh, math.huge))

    table.insert(scene.service, mainbutton)
    table.insert(scene.service, powerLabel)
    table.insert(scene.service, ramLabel)

    return scene
end

function lib.uploadEvent(...)
    if not lib.scene then return end
    lib.scene.uploadEvent(...)
end

function lib.draw()
    if not lib.scene then return end
    lib.scene.draw()
end

function lib.status(text)
    local mx, my = gpu.maxResolution()
    gpu.setResolution(mx, my)
    gpu.setBackground(colors.white)
    gpu.setForeground(colors.orange)
    gpu.fill(1 + lib.posXadd, 1 + lib.posYadd, mx - lib.resXadd, my - lib.resYadd, " ")

    text = lib.detab(text, 4)
    text = utiles.split(text, "\n")

    local newText = {}
    for i, v in ipairs(text) do
        local sunText = utiles.toParts(v, mx)
        for i, v in ipairs(sunText) do
            table.insert(newText, v)
        end
    end
    
    for i, v in ipairs(newText) do
        lib.drawText(1, 1, mx, my, v, 0, i + 1, false, true)
    end
end

function lib.splash(text)
    lib.status(text .. "\npress enter to continue")
    local listen = registerListen(nil, function(...)
        if lib.scene then
            for i, v in ipairs(lib.scene.service) do
                v.uploadEvent(...)
            end
        end
    end)
    while true do
        local eventData = {computer.pullSignal(0.5)}
        if eventData[1] == "exitPressed" or (eventData[1] == "key_down" and eventData[4] == 28) then
            break
        end
    end
    cancelListen(listen)
end

return lib