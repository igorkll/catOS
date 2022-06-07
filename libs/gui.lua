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

function lib.createScene(color, resx, resy)
    local scene = {}
    scene.objs = {}
    scene.selectCallbacks = {}
    scene.leaveCallbacks = {}
    scene.removeCallbacks = {}
    scene.removed = false

    function scene.checkRemove()
        if scene.removed then error("this scene removed", 0) end
    end

    function scene.draw()
        scene.checkRemove()
        for i, v in ipairs(scene.objs) do
            v.draw()
        end
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
        scene.removed = true
    end

    return scene
end



return lib