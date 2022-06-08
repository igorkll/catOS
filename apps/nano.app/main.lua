local gui = require("gui")
local colors = require("colors")
local utiles = require("utiles")
local fs = require("filesystem")
local serialization = require("serialization")

local nikname = ...
local thisPath = fs.path(utiles.getPath())
local nano = dofile(fs.concat(thisPath, "nano.lua"))

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

local profile
if not cfg.profiles[nikname] then
    cfg.profiles[nikname] = {states = {}, notes = {}}
    profile = cfg.profiles[nikname]
end

--------------------------------------------

local function set()
    
end

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