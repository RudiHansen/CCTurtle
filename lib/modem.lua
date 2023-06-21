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
    logFile.logWrite("in modem.askQuestionBlockAction ",blockName)
    rednet.send(0,blockName,"QB")
    logFile.logWrite("rednet.send QB")

    id,message, protocol = rednet.receive() --wait until a message is received
    logFile.logWrite("Received",id,message,protocol)
    return message    
end

function modem.askQuestionTurtleJob()
    logFile.logWrite("in modem.askQuestionTurtleJob()")
    rednet.send(0," ","QJ")
    logFile.logWrite("Send QJ")

    id,message, protocol = rednet.receive("AJ") --wait until a message is received
    logFile.logWrite("id",id)
    logFile.logWrite("message",message)
    logFile.logWrite("protocol",protocol)

    if(id==0)then
        logFile.logWrite("if id==",id)
        if(protocol=="AJ")then
            logFile.logWrite("protocol AJ")
            local turtleJobData = turtleJobs.Msg2TurtleJob(message)
            logFile.logWrite("turtleJobData",turtleJobData)
            return turtleJobData
        end
    end
end

return modem