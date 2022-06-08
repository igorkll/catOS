local gui = require("gui")
local colors = require("colors")
local utiles = require("utiles")
local fs = require("filesystem")
local serialization = require("serialization")

local nikname = ...
if not nikname then error("nikname is not sended", 0) return end
local thisPath = fs.path(utiles.getPath())
local nano = dofile(fs.concat(thisPath, "nano.lua"))

local inputCount = math.floor(nano.getTotalInputCount())
if not nano.isOk() then error("нет подключения к нанитам", 0) return end

--------------------------------------------

local rx, ry = gui.maxResolution()
local scene = gui.createScene(colors.blue, rx, ry)

--------------------------------------------data base

local cfg = {profiles = {}}

local function saveCfg()
    fs.saveFile(fs.concat(thisPath, "cfg.dbs"), serialization.serialize(cfg))
end

local function loadCfg()
    cfg = assert(serialization.unserialize(assert(fs.getFile(fs.concat(thisPath, "cfg.dbs")))))
end

if fs.exists(fs.concat(thisPath, "cfg.dbs")) then
    loadCfg()
else
    saveCfg()
end

--------------------------------------------profile

local function check()
    if not nano.isOk() then error("no connection", 0) end
end

local profile
if not cfg.profiles[nikname] then
    cfg.profiles[nikname] = {states = {}, notes = {}}
    profile = cfg.profiles[nikname]

    for i = 1, inputCount do
        gui.status("off pin: " .. tostring(math.floor(i)) .. "/" .. tostring(inputCount))
        nano.setInput(i, false)
        check()
    end
    for i = 1, inputCount do
        gui.status("check pin: " .. tostring(math.floor(i)) .. "/" .. tostring(inputCount))
        nano.setInput(i, true)
        check()
        table.insert(profile.states, false)
        table.insert(profile.notes, nano.getActiveEffects())
        check()
        nano.setInput(i, false)
        check()
    end
    saveCfg()
    gui.draw()
end

--------------------------------------------

local statesButtons = {}
for i = 1, inputCount do
    table.insert(statesButtons, scene.createButton(1, i + 4, 16, 1, "input", function(state)
        nano.setInput(i, state)
        profile.states[i] = state
    end, 1))
    statesButtons.state = profile.states[i]
end

local profile_label = scene.createLabel(1, 1, 32, 1, "profile:" .. nikname)

local full_upload = scene.createButton(1, 2, 32, 1, "full upload", function()
    for i, v in ipairs(profile.states) do
        gui.status("uploading: " .. tostring(i) .. "/" .. tostring(inputCount))
        nano.setInput(i, v.state)
        check()
    end
    gui.draw()
end)

local download = scene.createButton(1, 3, 32, 1, "download", function()
    for i, v in ipairs(profile.states) do
        gui.status("download: " .. tostring(i) .. "/" .. tostring(inputCount))
        nano.setInput(i, v.state)
        check()
    end
    gui.draw()
end)

local removeProfile = scene.createButton(1, 3, 32, 1, "remove profile", function()
    cfg.profiles[nikname] = nil
    error("profile removed", 0)
end)

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