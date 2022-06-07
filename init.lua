--[[
эта операционная системма расшитана на мониторы вторго уровня
вчастности планшеты
системма НЕ мольти мониторная
и в первую очередь была разботана под конкретное железа: планшет
палитра состоит из 12 цветов 4 зарезервированы под нужды программ
]]

--------------------------------------------lua version check

if computer.setArchitecture then pcall(computer.setArchitecture, "Lua 5.3") end --зашита от моих биосов(они усторели и удин удаляет setArchitecture а другой заставляет его выдать ошибку)
if _VERSION ~= "Lua 5.3" then error("requires Lua 5.3 pull out the processor and press shift plus the right mouse button on it", 0) end

--------------------------------------------preinit

do --atan2 в Lua 5.3
    local atan = math.atan
    function math.atan2(y, x)
        return atan(y / x)
    end
end

do --системма слушателей
    local computer_pullSignal = computer.pullSignal

    local timers = {}
    local listens = {}

    function registerTimer(period, func, times)
        checkArg(1, period, "number")
        checkArg(2, func, "function")
        checkArg(3, times, "number")
        table.insert(timers, {period = period, func = func, times = times})
    end

    function registerListen(eventName, func)
        checkArg(1, eventName, "string", "nil")
        checkArg(2, func, "function")
        table.insert(listens, {eventName = eventName, func = func})
    end

    function computer.pullSignal(time)
        local tbl = {computer.pullSignal(0.1)}

        if #tbl > 0 then
            for i, v in ipairs(listens) do
                
            end

            return table.unpack(tbl)
        end
    end
end

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

function os.sleep(time)
    local inTime = computer.uptime()
    while computer.uptime() - inTime < time do
        computer.pullSignal(time - (computer.uptime() - inTime))
    end
end

local oldInterruptTime = computer.uptime()
_G.interruptTime = 1
function _G.interrupt()
    if computer.uptime() - oldInterruptTime > _G.interruptTime then
        os.sleep()
        oldInterruptTime = uptime()
    end
end

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

--------------------------------------------libs

loadedLibs = {}
loadedLibs.filesystem = raw_loadfile("/libs/filesystem.lua", nil, _G)()

function require(name)
    if loadedLibs[name] then return loadedLibs[name] end

    local fs = require("filesystem")
    loadedLibs[name] = assert(loadfile(fs.concat("/libs", name .. ".lua")))()

    return loadedLibs[name]
end

--------------------------------------------graphic

gpu = getCp("gpu")
gpu.bind(component.list("screen")(), true)
gpu.setDepth(4)

local colors = require("colors")
colors.applyPalette()

--------------------------------------------

local rx, ry = 16, 12
gpu.setResolution(rx, ry)

gpu.setBackground(colors.black)
gpu.set(1, 1, string.rep(" ", rx))

gpu.setBackground(colors.gray1)
gpu.set(1, 2, string.rep(" ", rx))

gpu.setBackground(colors.gray2)
gpu.set(1, 3, string.rep(" ", rx))

gpu.setBackground(colors.gray3)
gpu.set(1, 4, string.rep(" ", rx))

gpu.setBackground(colors.white)
gpu.set(1, 5, string.rep(" ", rx))


gpu.setBackground(colors.red)
gpu.set(1, 6, string.rep(" ", rx))

gpu.setBackground(colors.green)
gpu.set(1, 7, string.rep(" ", rx))

gpu.setBackground(colors.blue)
gpu.set(1, 8, string.rep(" ", rx))


gpu.setBackground(colors.yellow)
gpu.set(1, 9, string.rep(" ", rx))

gpu.setBackground(colors.orange)
gpu.set(1, 10, string.rep(" ", rx))

gpu.setBackground(colors.cyan)
gpu.set(1, 11, string.rep(" ", rx))

gpu.setBackground(colors.purple)
gpu.set(1, 12, string.rep(" ", rx))

computer.pullSignal()

do
    local gui = require("gui")
    
    local scene = gui.createScene(colors.red, 50, 16)
    local b1 = scene.createButton(1, 1, 8, 3, "asd123", function()
        
    end, 0)

    scene.select()

    while true do
        gui.uploadEvent(computer.pullSignal())
    end
end