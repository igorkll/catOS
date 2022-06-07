local colors = require("colors")

local function table_remove(tbl, obj)
    for i = 1, #tbl do
        if tbl[i] == obj then
            table.remove(tbl, i)
        end
    end
end

--------------------------------------------

local lib = {}
lib.scenes = {}
lib.scene = false

lib.posXadd = 0
lib.posYadd = 1

function lib.drawUi()
    local rx, ry = gpu.getResolution()
    gpu.setBackground(colors.purple)
    gpu.fill(1, 1, rx, ry, " ")
end

function lib.maxResolution()
    local mx, my = gpu.maxResolution()
    my = my - 2
    return mx, my
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
        gpu.setResolution(scene.resy, scene.resy + 2)
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
    end

    function lib.remove()
        scene.checkRemove()
        for i, v in ipairs(scene.leaveCallbacks) do v() end
        for i, v in ipairs(scene.removeCallbacks) do v() end
        table_remove(lib.scenes, lib)
        scene.removed = true
    end

    function lib.uploadEvent(...)
        scene.checkRemove()
        for i, v in ipairs(scene.objs) do v.uploadEvent(...) end
    end

    --------------------------------------------

    function lib.createButton(x, y, sizeX, sizeY, text, callback)
        
    end

    --------------------------------------------

    return scene
end



return lib