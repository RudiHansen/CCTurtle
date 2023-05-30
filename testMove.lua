modem     = require("lib.modem")
location  = require("lib.location")
move      = require("lib.move")
util      = require("lib.util")
logFile   = require("lib.logFile")

logFile.logFileOpen()
modem.init()
location.init()
location.setHomePos(23,10,63,"E")
location.setRefuelPos(24,14,63,"W")
location.setDropOffPos(24,9,63,"W")

-- Test Stuff
--turnToFace("N")
--sleep(2)
--turnToFace("E")

function printPos(pos)
    print(pos.x .. " " .. pos.z .. " " .. pos.y .. " " .. pos.f)
    print(type(pos.x) .. " " .. type(pos.z) .. " " .. type(pos.y) .. " " .. type(pos.f))
end

-- Calculate movement based on Priority.
function calcMove(endPos,axisPriority)
    if(axisPriority == nil or axisPriority == "") then
        axisPriority = "xzy"
    end

    local axisPriorityIdx       = 1
    local currentAxisPriority   = string.sub(axisPriority,axisPriorityIdx,axisPriorityIdx)
    local moveToDo              = ""
    local startPos              = location.getCurrentPos()
    local result                = true
    local moveErrors            = 0

    while( startPos.x ~= endPos.x or startPos.z ~= endPos.z or startPos.y ~= endPos.y) do
        currentAxisPriority   = string.sub(axisPriority,axisPriorityIdx,axisPriorityIdx)
        if( currentAxisPriority == "x" ) then
            if(startPos.x > endPos.x) then
                moveToDo = "W"
            elseif(startPos.x < endPos.x) then
                moveToDo = "E"
            else
                axisPriorityIdx = util.incNumberMax(axisPriorityIdx,4)
                moveToDo = ""
            end
        elseif( currentAxisPriority == "z" ) then
            if(startPos.z > endPos.z) then
                moveToDo = "N"
            elseif(startPos.z < endPos.z) then
                moveToDo = "S"
            else
                axisPriorityIdx = util.incNumberMax(axisPriorityIdx,4)
                moveToDo = ""
            end
        elseif( currentAxisPriority == "y" ) then
            if(startPos.y > endPos.y) then
                moveToDo = "D"
            elseif(startPos.y < endPos.y) then
                moveToDo = "U"
            else
                axisPriorityIdx = util.incNumberMax(axisPriorityIdx,4)
                moveToDo = ""
            end
        end

        if( moveToDo ~= nil and moveToDo ~= "") then
            result = move.move(moveToDo)
            logFile.logWrite("moveToDo="..tostring(moveToDo).." result="..tostring(result))            
            if(result == false) then
                axisPriorityIdx = util.incNumberMax(axisPriorityIdx,4)
                moveErrors = moveErrors + 1
                if (moveErrors > 3) then
                    modem.sendStatus("Blocked")
                    print("Can't move, please remove the obstacles!")
                    util.waitForUserKey()
                    moveErrors = 0
                    modem.sendStatus("Move")
                end
            end
        end
        startPos = location.getCurrentPos()    
    end
    move.turnToFace(endPos.f)
end

local result     = ""
local endPos     = {x=40,z=12,y=67,f="N"}

modem.sendStatus("Move")
logFile.logWrite("Move to endPos")
result = calcMove(endPos)
sleep(1)
logFile.logWrite("Move to dropOffPos")
result = calcMove(location.getDropOffPos())
sleep(1)
logFile.logWrite("Move to RefuelPos")
result = calcMove(location.getRefuelPos())
sleep(1)
logFile.logWrite("Move to HomePos")
result = calcMove(location.getHomePos())


modem.sendStatus("Idle")
location.writeLocationToFile()
logFile.logFileClose()