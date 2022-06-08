local gui = require("gui")
local colors = require("colors")
local utiles = require("utiles")
local fs = require("filesystem")
local serialization = require("serialization")

local nikname = ...
if not nikname then error("nikname is not sended", 0) return end
local thisPath = fs.path(utiles.getPath())
local nano = dofile(fs.concat(thisPath, "nano.lua"))

gui.status("connectiong")

local inputCount = math.floor(nano.getTotalInputCount())

--------------------------------------------

local rx, ry = gui.maxResolution()
local scene = gui.createScene(colors.blue, rx, ry)
_G.nanoScene = scene

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

local function createStr(str)
    str = unicode.sub(str, 2, unicode.len(str) - 1)
    local strs = {}
    for _, dat in ipairs(utiles.split(str, ",")) do
        local _, d = table.unpack(utiles.split(dat, "."))
        table.insert(strs, d)
    end
    str = table.concat(strs, ", ")
    str = unicode.sub(str, 1, 64)
    if str == "" then return false end
    return str
end

local profile
if not cfg.profiles[nikname] then
    gui.status("profile creating")

    cfg.profiles[nikname] = {states = {}, notes = {}}
    profile = cfg.profiles[nikname]

    for i = 1, inputCount do
        gui.status("off pin: " .. tostring(math.floor(i)) .. "/" .. tostring(inputCount))
        nano.setInput(i, false)
    end
    for i = 1, inputCount do
        gui.status("check pin: " .. tostring(math.floor(i)) .. "/" .. tostring(inputCount))
        nano.setInput(i, true)
        table.insert(profile.states, false)
        table.insert(profile.notes, createStr(nano.getActiveEffects()))
        nano.setInput(i, false)
    end
    saveCfg()
    gui.draw()
else
    profile = cfg.profiles[nikname]
end

--------------------------------------------

local statesButtons = {}
for i = 1, inputCount do
    table.insert(statesButtons, scene.createButton(1, i + 5, 64, 1, "input: " .. tostring(i) .. ", note: " .. (profile.notes[i] or "none"), function(state)
        nano.setInput(i, state)
        profile.states[i] = state
        saveCfg()
    end, 1))
    statesButtons[i].state = profile.states[i]
end

local profile_label = scene.createLabel(1, 1, 32, 1, "profile:" .. nikname)

local full_upload = scene.createButton(1, 2, 32, 1, "full upload", function()
    for i, v in ipairs(profile.states) do
        gui.status("uploading: " .. tostring(i) .. "/" .. tostring(inputCount))
        nano.setInput(i, v.state)
    end
    gui.draw()
end)

local download = scene.createButton(1, 3, 32, 1, "download", function()
    for i, v in ipairs(profile.states) do
        gui.status("download: " .. tostring(i) .. "/" .. tostring(inputCount))
        nano.setInput(i, v.state)
    end
    gui.draw()
end)

local removeProfile = scene.createButton(1, 4, 32, 1, "remove profile", function()
    cfg.profiles[nikname] = nil
    saveCfg()
    error("profile removed", 0)
end)

--------------------------------------------

scene.select()

while true do
    local eventData = {computer.pullSignal()}
    if eventData[1] == "exitPressed" then
        return
    end
    gui.uploadEvent(table.unpack(eventData))
end