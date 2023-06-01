 --[[
    modem Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-19 : Initial Version.
]]

local modem = {}

function modem.init()
    rednet.open("left") --enable the modem attached to the right side of the PC
end

function modem.sendStatus(status)
    local label         = os.getComputerLabel()
    local currentPos    = location.getCurrentPos()
    local fuelLevel     = turtle.getFuelLevel()

    if(status == nil or status == "") then
        status = "EMPTY"
    end

    rednet.broadcast("TurtleStatus;"..label..";"..currentPos.x..";"..currentPos.z..";"..currentPos.y..";"..currentPos.f .. ";"..fuelLevel..";"..status)
end

return modem