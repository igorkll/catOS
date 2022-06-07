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

do --спяший режим
    local computer = computer
    local computer_pullSignal = computer.pullSignal
    local computer_pushSignal = computer.pushSignal
    local computer_uptime = computer.uptime
    local table_unpack = table.unpack
    local checkArg = checkArg

    uptimeAdd = 0
    function computer.uptime()
        return computer_uptime() + uptimeAdd
    end

    function computer.sleep(time, saveEvent, doNotCorectUptime)
        checkArg(1, time, "number")
        checkArg(2, saveEvent, "nil", "boolean")
        checkArg(3, doNotCorectUptime, "nil", "boolean")
        local inTime = computer_uptime()
        while computer_uptime() - inTime < time do
            local eventData = {computer_pullSignal(time - (computer_uptime() - inTime))}
            if saveEvent and #eventData > 0 then
                computer_pushSignal(table_unpack(eventData))
            end
        end
        if not doNotCorectUptime then
            uptimeAdd = uptimeAdd - (computer_uptime() - inTime)
        end
    end

    function computer.delay(time)
        computer.sleep(time or 0.1, true, true)
    end
end

do --системма слушателей
    local computer_pullSignal = computer.pullSignal

    listensError = {}
    timers = {}
    listens = {}

    local function runCallback(func, ...)
        local tbl = {pcall(func, ...)}
        if not tbl[1] then return nil, tbl[2] end
        return true, table.unpack(tbl, 2)
    end

    function registerTimer(period, func, times)
        if not times then times = 1 end
        checkArg(1, period, "number")
        checkArg(2, func, "function")
        checkArg(3, times, "number")
        table.insert(timers, {period = period, func = func, times = times, oldTime = computer.uptime()})
    end

    function registerListen(eventName, func)
        checkArg(1, eventName, "string", "nil")
        checkArg(2, func, "function")
        table.insert(listens, {eventName = eventName, func = func})
    end

    function computer.pullSignal(time)
        if not time then time = math.huge end
        local inTime = computer.uptime()
        while computer.uptime() - inTime < time do
            local tbl = {computer_pullSignal(0.1)}
            for i = #timers, 1, -1 do
                if computer.uptime() - timers[i].oldTime > timers[i].period then
                    local ok, value = runCallback(timers[i].func)
                    timers[i].times = timers[i].times - 1
                    if ok then
                        if value == false or timers[i].times <= 0 then
                            table.remove(timers, i)
                        end
                    else
                        table.insert(listensError, value)
                    end
                end
            end

            if #tbl > 0 then
                for i = #listens, 1, -1 do
                    if not listens[i].eventName or listens[i].eventName == tbl[1] then
                        local ok, value = runCallback(listens[i].func)
                        if ok then
                            if value == false then
                                table.remove(timers, i)
                            end
                        else
                            table.insert(listensError, value)
                        end
                    end
                end

                return table.unpack(tbl)
            end
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
    if not time then time = 0.1 end
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
local fs = require("filesystem")

--------------------------------------------graphic

gpu = getCp("gpu")
gpu.bind(component.list("screen")(), true)
gpu.setDepth(4)

local colors = require("colors")
colors.applyPalette()

--------------------------------------------OS

function loadprogramm(path)
    if not fs.exists(path) then return nil, "no this application" end
    if fs.isDirectory(path) then path = fs.concat(path, "main.lua") end
    if not fs.exists(path) then return nil, "no main.lua file" end
    local code, err = loadfile(path)
    if not code then return nil, err end
    return code
end

function os.execute(path, ...)
    return xpcall(loadprogramm(path), debug.traceback, ...)
end

--------------------------------------------main

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
os.sleep(2)

assert(os.execute("shell.app"))