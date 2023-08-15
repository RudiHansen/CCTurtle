 --[[
    modem Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-19 : Initial Version.
]]

local modem = {}

local status = "Idle"
local progressCounter = 0
local progressCounterMax = 20

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

    rednet.send(0,statusMessage,"S")
end

function modem.sendTurtleJobStatus(turtleJobData,status)
    logFile.logWrite("modem.sendTurtleJobStatus",turtleJobData.Id,status)
    local statusMessage = turtleJobData.Id .. "," .. status
    rednet.send(0,statusMessage,"SJ")
end

function modem.sendTurtleJobProgress(force)
    local force = util.setDefaultValueIfEmpty(force,false)
    progressCounter = progressCounter + 1

    --logFile.logWrite("In modem.sendTurtleJobProgress",force,progressCounter)

    if(progressCounter > progressCounterMax or force == true) then
        progressCounter = 0
        local label         = os.getComputerLabel()
        local currentPos    = location.getCurrentPos()

        local progressMessage = "TurtleProgress;"..label..";"..currentPos.x..";"..currentPos.z..";"..currentPos.y..";"..currentPos.f

        rednet.send(0,progressMessage,"SP")
        --logFile.logWrite("Send TurtleProgress",progressMessage)
    end
end

function modem.getStatus()
    return status
end

function modem.askQuestionBlockAction(blockName)
    logFile.logWrite("in modem.askQuestionBlockAction ",blockName)
    local saveStatus = status
    modem.sendStatus("?QB")

    rednet.send(0,blockName,"QB")
    logFile.logWrite("rednet.send QB")

    id,message, protocol = rednet.receive("AB") --wait until a message is received
    logFile.logWrite("Received",id,message,protocol)
    modem.sendStatus(saveStatus)
    return message    
end

function modem.askQuestionTurtleJob()
    --logFile.logWrite("in modem.askQuestionTurtleJob()")
    local saveStatus = status
    modem.sendStatus("?QJ")
    rednet.send(0," ","QJ")
    --logFile.logWrite("Send QJ")

    id,message, protocol = rednet.receive("AJ") --wait until a message is received
    --logFile.logWrite("id",id)
    --logFile.logWrite("message",message)
    --logFile.logWrite("protocol",protocol)
    modem.sendStatus(saveStatus)

    if(id==0)then
        --logFile.logWrite("if id==",id)
        if(protocol=="AJ")then
            --logFile.logWrite("protocol AJ")
            local turtleJobData = turtleJobs.Msg2TurtleJob(message)
            --logFile.logWrite("turtleJobData",turtleJobData)
            return turtleJobData
        end
    end
end

function modem.askQuestionAboutLocation(locationName)
    --logFile.logWrite("in modem.askQuestionAboutLocation",locationName)
    local saveStatus = status
    modem.sendStatus("?QL")
    rednet.send(0,locationName,"QL")
    --logFile.logWrite("rednet.send QL")

    id,message, protocol = rednet.receive("AL") --wait until a message is received
    --logFile.logWrite("Received",id,message,protocol)
    modem.sendStatus(saveStatus)
    return message    
end

function modem.askAboutStopCommand()
    --logFile.logWrite("In modem.askAboutStopCommand")
    rednet.send(0,"ShouldIStop","QS")
    id,message, protocol = rednet.receive("AS") --wait until a message is received
    --logFile.logWrite("AS=",id,message,protocol)
    --logFile.logWrite("type(message)=",type(message))

    if(message == true)then
        return true
    else
        return false
    end
end

return modem