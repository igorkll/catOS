local fs = require("filesystem")

--------------------------------------------

local lib = {}

function lib.table_remove(tbl, obj)
    for i = #tbl, 1, -1 do
        if tbl[i] == obj then
            table.remove(tbl, i)
        end
    end
end

function lib.xor(...)
    local dat = {...}
    local state = false
    for i = 1, #dat do
        if dat[i] then
            state = not state
        end
    end
    return state
end

function lib.split(str, sep)
    local parts, count = {}, 1
    local i = 1
    while true do
        if i > #str then break end
        local char = str:sub(i, #sep + (i - 1))
        if not parts[count] then parts[count] = "" end
        if char == sep then
            count = count + 1
            i = i + #sep
        else
            parts[count] = parts[count] .. str:sub(i, i)
            i = i + 1
        end
    end
    if str:sub(#str - (#sep - 1), #str) == sep then table.insert(parts, "") end
    return parts
end

function lib.toParts(str, max)
    local strs = {}
    local temp = ""
    for i = 1, #str do
        local char = str:sub(i, i)
        temp = temp .. char
        if #temp >= max then
            table.insert(strs, temp)
            temp = ""
        end
    end
    table.insert(strs, temp)
    if #strs[#strs] == 0 then table.remove(strs, #strs) end
    return strs
end

function lib.simpleTableClone(tbl)
    local newtbl = {}
    for k, v in pairs(tbl) do
        newtbl[k] = v
    end
    return newtbl
end

function lib.map(value, low, high, low_2, high_2)
    local relative_value = (value - low) / (high - low)
    local scaled_value = low_2 + (high_2 - low_2) * relative_value
    return scaled_value
end

function lib.constrain(value, min, max)
    return math.min(math.max(value, min), max)
end

function lib.mapClip(value, low, high, low_2, high_2)
    return lib.constrain(lib.map(value, low, high, low_2, high_2), low_2, high_2)
end

function lib.floorAt(value, subValue)
    return math.floor(value // subValue) * subValue
end

function lib.logTo(path, text)
    fs.makeDirectory(fs.path(path))
    local file, err = fs.open(path, "ab")
    if not file then return nil, err end
    file:write(text .. "\n")
    file:close()
    return true
end

function lib.getInternetFile(url)
    local handle, data, result, reason = component.proxy(component.list("internet")()).request(url), ""
    if handle then
        while true do
            result, reason = handle.read(math.huge) 
            if result then
                data = data .. result
            else
                handle.close()
                
                if reason then
                    return nil, reason
                else
                    return data
                end
            end
        end
    else
        return nil, "unvalid address"
    end
end

function lib.isInternet()
    return component.list("internet")() and pcall(function(url) assert(lib.getInternetFile(url)) end, "https://raw.githubusercontent.com/igorkll/openOSpath/main/null")
end

function lib.getPath()
    local info

    for runLevel = 0, math.huge do
        info = debug.getinfo(runLevel)

        if info then
            if info.what == "main" then
                return info.source:sub(2, -1)
            end
        else
            error("Failed to get debug info for runlevel " .. runLevel)
        end
    end
end

function lib.isTouchScreen(address)
    local inf = computer.getDeviceInfo()
    local dat = math.floor(inf[address].width) ~= 1
    inf = nil
    return dat
end

function lib.findWirelessModem()
    local bestAddress, bestWidth, width

    for address in component.list("modem") do
        local proxy = component.proxy(address)
        if proxy.isWireless() then
            width = proxy.getStrength()

            if not bestWidth or width > bestWidth then
                bestAddress, bestWidth = address, width
            end
        end
    end

    return component.proxy(bestAddress or "*")
end

function lib.endAt(str, char)
    local tbl = lib.split(str, char)
    return tbl[#tbl]
end

function lib.startAt(str, char)
    local tbl = lib.split(str, char)
    return tbl[1]
end

function lib.tableRemove(tbl, dat)
    local count = 0
    for k, v in pairs(tbl) do
        if v == dat then
            count = count + 1
            tbl[k] = nil
        end
    end
    return count > 0
end

function lib.tablePress(tbl)
    local newtbl = {}
    for k, v in pairs(tbl) do
        if tonumber(v) then
            table.insert(newtbl, v)
        end
    end
    return newtbl
end

function lib.clearTable(tbl)
    for k, v in pairs(tbl) do
        tbl[k] = nil
    end
end

function lib.getMountPoints(address)
    local paths = {}
    for proxy, path in fs.mounts() do
        if proxy.address == address then
            table.insert(paths, path)
        end
    end
    return paths
end

function lib.getMountPoint(address)
    local paths = lib.getMountPoints(address)
    local ints = {}
    for i = 1, #paths do
        table.insert(ints, unicode.len(paths[i]))
    end
    local path = math.min(table.unpack(ints))
    for i = 1, #paths do
        if ints[i] == path then
            path = paths[i]
            break
        end
    end
    return path
end

function lib.getFsFiles(address)
    local files = {}

    local function recurse(lfs, path, tbl)
        for _, file in ipairs(lfs.list(path)) do
            local full_path = fs.concat(path, file)
            if fs.isDirectory(full_path) then
                recurse(lfs, full_path, tbl)
            else
                table.insert(tbl, full_path)
            end
        end
    end
    recurse(component.proxy(address), "/", files)

    return files
end

return lib