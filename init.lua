function getCp(ctype)
    return component.proxy(component.list(ctype)() or "")
end

_G.gpu = component.proxy(component.list("gpu")())
gpu.bind(component.list("screen")(), true)

_G.palette = {0x000000, 0x444444, 0x888888, 0xBBBBBB, 0xFFFFFF, 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF6600, 0x00FFFF, 0xFF00FF, 0x000000, 0x000000, 0x000000, 0x000000}
local function setpalette(lpalette)
    for i, v in ipairs(lpalette or palette) do
        _G.gpu.setPaletteColor(i - 1, v)
    end
end
setpalette()