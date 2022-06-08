local serialization = require("serialization")

--------------------------------------------

local event = {}

event.push = computer.pushSignal

function event.pull(time, ...)
    local args = {...}
    local inTime = computer.uptime()
    while computer.uptime() - inTime < time do
        local eventData = {computer.pullSignal(time - (computer.uptime() - inTime))}
        if #eventData > 0 and serialization.serialize(eventData) == serialization.serialize(args) then
            return table.unpack(eventData)
        end
    end
end

return event