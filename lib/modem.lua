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
    local lable     = os.getComputerLabel()
    local homePos   = location.getHomePos()
    local fuelLevel = location.getFuelLevel()

    if(status == nil or status == "") then
        status = "EMPTY"
    end

    rednet.broadcast("TurtleStatus;"..lable..";"..homePos.x..";"..homePos.z..";"..homePos.y..";"..homePos.f .. ";"..fuelLevel..";"..status)
end

return modem