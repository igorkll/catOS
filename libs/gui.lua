local colors = require("colors")
local utiles = require("utiles")

--------------------------------------------

local lib = {}
lib.scenes = {}
lib.scene = false

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
    return mx, my
end

function lib.getCenter(posX, posY, sizeX, sizeY)
    return math.floor((posX + (sizeX / 2)) + 0.5), math.floor((posY + (sizeY / 2)) + 0.5)
end

function lib.drawText(posX, posY, sizeX, sizeY, text)
    local x, y = lib.getCenter(posX, posY, text)
    gpu.set(math.floor((x - (unicode.len(text) / 2)) + 0.5), y, text)
end

function lib.createScene(color, resx, resy)
    local scene = {}
    scene.objs = {}
    scene.selectCallbacks = {}
    scene.leaveCallbacks = {}
    scene.removeCallbacks = {}
    scene.removed = false

    scene.color = color
    scene.resx = resx
    scene.resy = resy

    function scene.checkRemove()
        if scene.removed then error("this scene removed", 0) end
    end

    function scene.draw()
        scene.checkRemove()
        gpu.setResolution(scene.resy, scene.resy)
        lib.drawUi()
        gpu.setBackground(scene.color)
        gpu.fill(1 + lib.posXadd, 1 + lib.posYadd, scene.resx, scene.resy, " ")
        for i, v in ipairs(scene.objs) do v.draw() end
    end

    function lib.select()
        scene.checkRemove()
        if lib.scene then for i, v in ipairs(lib.scene.leaveCallbacks) do v() end end
        lib.scene = scene
        for i, v in ipairs(scene.selectCallbacks) do v() end
        scene.draw()
    end

    function lib.remove()
        scene.checkRemove()
        for i, v in ipairs(scene.leaveCallbacks) do v() end
        for i, v in ipairs(scene.removeCallbacks) do v() end
        utiles.table_remove(lib.scenes, lib)
        scene.removed = true
    end

    function lib.uploadEvent(...)
        scene.checkRemove()
        for i, v in ipairs(scene.objs) do v.uploadEvent(...) end
    end

    --------------------------------------------

    function lib.createButton(x, y, sizeX, sizeY, text, callback, mode)
        local obj = {}
        obj.backColor = colors.white
        obj.foreColor = colors.gray2
        obj.invBackColor = colors.gray1
        obj.invForeColor = colors.black
        obj.text = text

        obj.mode = mode or 0

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
            if mode == 0 then
                if tbl[1] == "touch" and tbl[5] == 0 and tbl[3] >= obj.posX and tbl[3] < (obj.posX + obj.sizeX) then
                    if tbl[4] >= obj.posY and tbl[4] < (obj.posY + obj.sizeY) then
                        obj.state = true
                        obj.draw()
                        obj.state = false
                        obj.draw()
                    end
                end
            elseif mode == 1 then
                if tbl[1] == "touch" and tbl[5] == 0 and tbl[3] >= obj.posX and tbl[3] < (obj.posX + obj.sizeX) then
                    if tbl[4] >= obj.posY and tbl[4] < (obj.posY + obj.sizeY) then
                        obj.state = not obj.state
                        obj.draw()
                    end
                end
            elseif mode == 2 then
                if tbl[1] == "touch" and tbl[5] == 0 and tbl[3] >= obj.posX and tbl[3] < (obj.posX + obj.sizeX) then
                    if tbl[4] >= obj.posY and tbl[4] < (obj.posY + obj.sizeY) then
                        obj.state = not obj.state
                        obj.draw()
                    end
                end
                if tbl[1] == "drop" then
                    obj.state = false
                    obj.draw()
                end
            end
        end
        
        table.insert(scene.objs, obj)
        table.insert(scene.removeCallbacks, obj.remove)
        return obj
    end

    --------------------------------------------

    table.insert(lib.scenes, scene)
    return scene
end

return lib