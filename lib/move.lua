 --[[
    move Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-22 : Initial Version.
]]

local move = {}

-- Move to a Position using axisPriority, if dig=true then dig block
function move.moveToPos(endPos,axisPriority,dig)
    logFile.logWrite("in move.moveToPos",endPos, axisPriority, dig)
    if(axisPriority == nil or axisPriority == "") then
        axisPriority = "xzy"
    end
    if(dig == nil or dig == "") then
        dig = false
    end

    local startPos          = location.getCurrentPos()
    local nextStep          = ""
    local result            = true
    local moveErrors        = 0
    local axisPriorityIdx   = 1

    while(location.comparePos(startPos, endPos) == false)do
        currentAxisPriority     = string.sub(axisPriority,axisPriorityIdx,axisPriorityIdx)

        nextStep    = move.getNextStep(startPos, endPos, currentAxisPriority)
        logFile.logWrite("startPos =",startPos)
        logFile.logWrite("endPos   =",endPos)
        logFile.logWrite("nextStep =",nextStep)

        if(nextStep~="") then
            result      = blocks.inspectDig(nextStep,true)
            logFile.logWrite("inspectDig ",result)
            if(result == "OK") then
                result      = move.move(nextStep)
                logFile.logWrite("move ",result)
            else
                result = false
                axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
            end
        else
            axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
            moveErrors = moveErrors + 1
            if (moveErrors > 3) then
                modem.sendStatus("Blocked")
                print("Can't move, please remove the obstacles!")
                util.waitForUserKey()
                moveErrors = 0
                modem.sendStatus("Move")
            end
        end
        startPos = location.getCurrentPos()    
    end

    if(startPos.f ~= endPos.f) then
        move.turnToFace(endPos.f)
    end
end

-- Get the next step to get from startPos to endPos using axis
-- TODO : Add parameter for how to move, direct path or traverse
function move.getNextStep(startPos, endPos, axis)
    logFile.logWrite("in move.getNextStep")
    logFile.logWrite("startPos",startPos)
    logFile.logWrite("endPos",endPos)
    logFile.logWrite("axis",axis)

    local nextStep              = ""

    logFile.logWrite("1-axisPriorityIdx",axisPriorityIdx)
    logFile.logWrite("1-currentAxisPriority",currentAxisPriority)
    logFile.logWrite("1-nextStep",nextStep)
    if( axis == "x" ) then
        if(startPos.x > endPos.x) then
            nextStep = "W"
        elseif(startPos.x < endPos.x) then
            nextStep = "E"
        end
    elseif( axis == "z" ) then
        if(startPos.z > endPos.z) then
            nextStep = "N"
        elseif(startPos.z < endPos.z) then
            nextStep = "S"
        end
    elseif( axis == "y" ) then
        if(startPos.y > endPos.y) then
            nextStep = "D"
        elseif(startPos.y < endPos.y) then
            nextStep = "U"
        end
    end
    logFile.logWrite("1-return",nextStep)
    return nextStep
end

function move.move(direction)
    --logFile.logWrite("in move.move",direction)
    local result = true;

    if(direction=="E")then
        move.turnToFace(direction)
        result = turtle.forward()
        if(result == true) then
            location.stepX(1)
        end
    elseif(direction=="W")then
        move.turnToFace(direction)
        result = turtle.forward()
        if(result == true) then
            location.stepX(-1)
        end
    elseif(direction=="N")then
        move.turnToFace(direction)
        result = turtle.forward()
        if(result == true) then
            location.stepZ(-1)
        end
    elseif(direction=="S")then
        move.turnToFace(direction)
        result = turtle.forward()
        if(result == true) then
            location.stepZ(1)
        end
    elseif(direction=="U")then
        result = turtle.up()
        if(result == true) then
            location.stepY(1)
        end
    elseif(direction=="D")then
        result = turtle.down()
        if(result == true) then
            location.stepY(-1)
        end
    end
    location.writeLocationToFile()
    modem.sendStatus("Move")
    return result
end

function move.turnToFace(newFace)
    local currentPos = location.getCurrentPos()

    newHeading = move.face2Int(newFace)
    currentHeading = move.face2Int(currentPos.f)

    local rotations = (newHeading - currentHeading) % 4
    if rotations < 0 then
        rotations = rotations + 4
    end
    if rotations == 3 then
        turtle.turnLeft()
    else
        for i = 1, rotations do
            turtle.turnRight()
        end
    end
    location.setCurrentPosFace(newFace)
    location.writeLocationToFile()
end

function move.face2Int(face)
    if(face=="N")then
        return 0
    elseif(face=="E")then
        return 1
    elseif(face=="S")then
        return 2
    elseif(face=="W")then
        return 3
    end
end

return move