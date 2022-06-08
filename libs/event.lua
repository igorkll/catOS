local serialization = require("serialization")

--------------------------------------------

local event = {}

event.push = computer.pushSignal

function event.pull(time, ...)
    local args = {...}
    if type(time) == "string" then
        table.insert(args, 1, time)
        time = math.huge
    end

    local inTime = computer.uptime()
    while computer.uptime() - inTime < time do
        ::tonew::
        local eventData = {computer.pullSignal(time - (computer.uptime() - inTime))}
        if #eventData > 0 then
            for i, v in ipairs(args) do
                if v and v ~= eventData[i] then
                    goto tonew
                end
            end
            return table.unpack(eventData)
        end
    end
end

return event