local lib = {}

--------------------------------------------colors

lib.black = 0x000000
lib.gray1 = 0x444444
lib.gray2 = 0x888888
lib.gray3 = 0xBBBBBB
lib.white = 0xFFFFFF

lib.red = 0xDC143C
lib.green = 0x3CB371
lib.blue = 0x1E90FF

lib.yellow = 0xFFD700
lib.orange = 0xFF4500
lib.cyan = 0x7FFFD4
lib.purple = 0x8A2BE2

--------------------------------------------palette

lib.palette = 
{lib.colors.black, lib.colors.gray1, lib.colors.gray2, lib.colors.gray3,
lib.colors.white, lib.colors.red, lib.colors.green, lib.colors.blue,
lib.colors.yellow, lib.colors.orange, lib.colors.cyan, lib.colors.purple,
-1, -1, -1, -1}

lib.freePaletteIndex = {}
for i, v in ipairs(lib.palette) do
    if v < 0 then
        table.insert(lib.freePaletteIndex, i)
    end
end

function lib.applyPalette(palette)
    for i, v in ipairs(palette or lib.palette) do
        if v > 0 then
            gpu.setPaletteColor(i - 1, v)
        else
            gpu.setPaletteColor(i - 1, 0)
        end
    end
    return true
end

function lib.unRegAllPaletteColor()
    for i, v in ipairs(lib.freePaletteIndex) do
        lib.palette[v] = -1
    end
end

function lib.unRegPaletteColor()
    for i = #lib.freePaletteIndex, 1 do
        if lib.palette[lib.freePaletteIndex[i]] > 0 then
            lib.palette[lib.freePaletteIndex[i]] = -1
        end
    end
end

function lib.regPaletteColor(color)
    local index
    for i, v in ipairs(lib.palette) do
        if v < 0 then
            lib.palette[i] = color
            index = i
            break
        end
    end
    if not index then
        lib.unRegPaletteColor()
        return lib.regPaletteColor(color)
    end
    return function()
        lib.palette[index] = -1
    end
end

--------------------------------------------

return lib