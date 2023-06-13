 --[[
    modem Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-19 : Initial Version.
]]

local modem = {}

local status = "Idle"

function modem.init()
    rednet.open("right") --enable the modem attached to the right side of the PC
end

function modem.sendStatus(newStatus)
    local label         = os.getComputerLabel()
    local currentPos    = location.getCurrentPos()
    local fuelLevel     = turtle.getFuelLevel()
    local storageSlots  = inventory.getRemainingEmptyStorageSlots()

    if(newStatus ~= nil) then
        status = newStatus
    end

    local statusMessage = "TurtleStatus;"..label..";"..currentPos.x..";"..currentPos.z..";"..currentPos.y..";"..currentPos.f .. ";"..storageSlots..";"..fuelLevel..";"..status

    rednet.broadcast(statusMessage,"S")
end

function modem.getStatus()
    return status
end

function modem.askQuestionBlockAction(blockName)
    rednet.broadcast(blockName,"QB")

    id,message, protocol = rednet.receive() --wait until a message is received
    return message    
end

function modem.askQuestionTurtleJob()
    logFile.logWrite("modem.askQuestionTurtleJob()")
    rednet.broadcast(" ","QJ")

    while(true)do
        id,message, protocol = rednet.receive() --wait until a message is received
        logFile.logWrite("id",id)
        logFile.logWrite("message",message)
        logFile.logWrite("protocol",protocol)

        if(id==0)then
            logFile.logWrite("id",id)
            logFile.logWrite("message",message)
            logFile.logWrite("protocol",protocol)

            if(protocol=="AJ")then
                local turtleJobData = turtleJobs.Msg2TurtleJob(message)
                return turtleJobData
            end
        end
    end
end

return modem