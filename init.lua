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
bootaddress = computer.getBootAddress()
bootfs = component.proxy(bootaddress)

--------------------------------------------raw

local function raw_getFile(path)
    local file, err = bootfs.open(path, "rb")
    if not file then return nil, err end
    local buffer = ""
    while true do
        local data = bootfs.read(file, math.huge)
        if not data then break end
        buffer = buffer .. data
    end
    bootfs.close(file)
    return buffer
end

local function raw_loadfile(path, mode, env)
    local data, err = raw_getFile(path)
    if not data then return nil, err end
    local code, err = load(data, "=" .. path, mode or "bt", env or createEnv())
    if not code then return nil, err end
    return code
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
loadedLibs.filesystem = raw_loadfile("/libs/filesystem.lua")

function require(name)
    if loadedLibs[name] then return loadedLibs[name] end

    local fs = require("filesystem")
    loadedLibs[name] = assert(loadfile(fs.concat("/libs", name .. ".lua")))()

    return loadedLibs[name]
end