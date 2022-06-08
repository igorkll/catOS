local event = {}

event.push = computer.pushSignal

function event.pull(time, ...)
    local args = {...}
end

return event