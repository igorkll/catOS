--------------------------------------------main

function getCp(ctype)
    return component.proxy(component.list(ctype)() or "")
end

function createEnv()
    local env = {}
    setmetatable(env, {__index = function(_, key)
        return _G[key]
    end})
    env.load = function(data, name, mode, lenv)
        if not lenv then lenv = env end --для коректной таблицы env
        return load(data, name, mode, lenv)
    end
    return env
end

--------------------------------------------raw

local function raw_loadfile(path, mode, env)
    
end

--------------------------------------------graphic

gpu = getCp("gpu")
gpu.bind(component.list("screen")(), true)

palette = {0x000000, 0x444444, 0x888888, 0xBBBBBB, 0xFFFFFF, 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF6600, 0x00FFFF, 0xFF00FF, 0x000000, 0x000000, 0x000000, 0x000000}
function setpalette(lpalette)
    for i, v in ipairs(lpalette or palette) do
        gpu.setPaletteColor(i - 1, v)
    end
end
setpalette()

--------------------------------------------libs

loadedLibs = {}
function require(name)
    loadedLibs[name] = 
    return loadedLibs[name]
end