 --[[
    move Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-22 : Initial Version.
]]

local move = {}

-- Traverse the area to a Position using axisPriority.
function move.traverseToPos(endPos,axisPriority)
    if(axisPriority == nil or axisPriority == "") then
        axisPriority = "xzy"
    end

    local startPos      = location.getCurrentPos()
    local nextStep      = ""
    local result        = true
    local moveErrors    = 0

    while(location.comparePos(startPos, endPos) == false)do
        nextStep = move.getNextStep(startPos, endPos, axisPriority)
        result = move.move(moveToDo)
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
        startPos = location.getCurrentPos()    
    end
end

-- Get the next step to get from startPos to endPos using axisPriority
-- TODO : Perhaps add check for it move is possible. (blocks.inspectDig("forward",true))
-- TODO : Parameter for if turtle should dig out blocks
-- TODO : Add parameter for how to move, direct path or traverse
function move.getNextStep(startPos, endPos, axisPriority)
    local nextStep              = ""
    local axisPriorityIdx       = 0
    local currentAxisPriority   = ""

    while(nextStep ~= "")do
        axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
        currentAxisPriority     = string.sub(axisPriority,axisPriorityIdx,axisPriorityIdx)
        if( currentAxisPriority == "x" ) then
            if(startPos.x > endPos.x) then
                nextStep = "W"
            elseif(startPos.x < endPos.x) then
                nextStep = "E"
            end
        elseif( currentAxisPriority == "z" ) then
            if(startPos.z > endPos.z) then
                nextStep = "N"
            elseif(startPos.z < endPos.z) then
                nextStep = "S"
            end
        elseif( currentAxisPriority == "y" ) then
            if(startPos.y > endPos.y) then
                nextStep = "D"
            elseif(startPos.y < endPos.y) then
                nextStep = "U"
            end
        end
        -- TODO : Perhaps add check for it move is possible.
    end
    return nextStep
end

-- Move to endPos based on axisPriority 
-- TODO: Refactor look at move.traverseToPos, this method should use same method, and might even be more or less the same
-- TODO: and perhaps the two methods needs to be one method.
function move.moveToPos(endPos,axisPriority)
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
            --logFile.logWrite("moveToDo="..tostring(moveToDo).." result="..tostring(result))            
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

function move.move(direction)
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