 --[[
    move Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-22 : Initial Version.
]]

local move = {}

local moveAxisPriority   = "zxy"

function move.traverseArea(areaStart,areaEnd,axisPriority,dig)
    -- Setup variables
    if(axisPriority == nil or axisPriority == "") then
        axisPriority = {"x","z","y"}
    else
        axisPriority = {string.sub(axisPriority,1,1),string.sub(axisPriority,2,2),string.sub(axisPriority,3,3)}
    end

    if(dig == nil or dig == "") then
        dig = false
    end
    local startPos = {};

    -- Write debug info
    --logFile.logWrite("in move.traverseArea")
    --logFile.logWrite("areaStart=",areaStart)
    --logFile.logWrite("areaEnd=",areaEnd)
    --logFile.logWrite("axisPriority=",axisPriority)
    --logFile.logWrite("dig=",dig)

    -- Initialize the Grid map
    gridMap.initGridMap(areaStart,areaEnd)

    -- Get start position.
    -- TODO : Needs also to work on other axisPriority orders.
    startPos = location.copyPos(areaStart)
    if(axisPriority[1]=="y" and axisPriority[2]=="z") then
        startPos.z          = startPos.z-1
        moveAxisPriority    = "zxy"
    end
    --logFile.logWrite("startPos",startPos)
    
    -- Move turtle to a starting position.
    modem.sendStatus("Work")
    move.moveToPos(startPos,"",true)
    gridMap.setGridMapValue(startPos.x,startPos.z,startPos.y,1)
    
    -- Calculated steps to traverse the area.
    local nextMove      = ""
    local priorityIdx   = 1
    local currentPos    = location.getCurrentPosCopy()
    local val1          = 9
    local val2          = 9
    local checkedX      = false
    local checkedZ      = false
    local checkedY      = false
    
    while(checkedX==false or checkedZ==false or checkedY==false)do
        --logFile.logWrite("axisPriority[priorityIdx]",axisPriority[priorityIdx])
        if(axisPriority[priorityIdx] == "x") then
            val1 = gridMap.getGridMapValue(currentPos.x+1, currentPos.z, currentPos.y)
            val2 = gridMap.getGridMapValue(currentPos.x-1, currentPos.z, currentPos.y)
            --logFile.logWrite("val1=",val1)
            --logFile.logWrite("val2=",val2)
            if(val1==0) then
                nextMove = "E"
            elseif(val2==0) then
                nextMove = "W"
            end
            checkedX = true
        elseif(axisPriority[priorityIdx] == "z") then
            val1 = gridMap.getGridMapValue(currentPos.x, currentPos.z+1, currentPos.y)
            val2 = gridMap.getGridMapValue(currentPos.x, currentPos.z-1, currentPos.y)
            if(val1==0) then
                nextMove = "S"
            elseif(val2==0) then
                nextMove = "N"
            end
            checkedZ = true
        elseif(axisPriority[priorityIdx] == "y") then
            val1 = gridMap.getGridMapValue(currentPos.x, currentPos.z, currentPos.y+1)
            val2 = gridMap.getGridMapValue(currentPos.x, currentPos.z, currentPos.y-1)
            if(val1==0) then
                nextMove = "U"
            elseif(val2==0) then
                nextMove = "D"
            end
            checkedY = true
        end
        --logFile.logWrite("nextMove",nextMove)
        
        if(nextMove~="") then
            result      = blocks.inspectDig(nextMove,true)
            --logFile.logWrite("inspectDig ",result)
            if(result == "OK") then
                gridMap.setGridMapDirection(nextMove,1)
                result      = move.move(nextMove)
                --logFile.logWrite("move ",result)
            elseif(result=="BYPASS") then
                --logFile.logWrite("bypass",result)
                gridMap.setGridMapDirection(nextMove,2)
            end
            nextMove = ""
            priorityIdx = 1
            checkedX = false
            checkedZ = false
            checkedY = false
        else
            priorityIdx         = util.incNumberMax(priorityIdx,4)
        end
        currentPos    = location.getCurrentPosCopy()
        inventory.checkAll()
    end
    modem.sendStatus("Idle")
end

-- Move to a Position using axisPriority, if dig=true then dig block
function move.moveToPos(endPos,axisPriority,dig)
    --logFile.logWrite("in move.moveToPos")
    --logFile.logWrite("CurrentPos   :",location.getCurrentPos())
    --logFile.logWrite("endPos       :",endPos)
    --logFile.logWrite("axisPriority :",axisPriority)
    --logFile.logWrite("dig          :",dig)

    if(axisPriority == nil or axisPriority == "") then
        axisPriority = moveAxisPriority
    end
    if(dig == nil or dig == "") then
        dig = false
    end

    local startPos              = location.getCurrentPos()
    local nextStep              = ""
    local result                = true
    local moveErrors            = 0
    local currentAxisPriority   = ""
    local axisPriorityIdx       = 1

    while(location.comparePos(startPos, endPos) == false)do
        currentAxisPriority     = string.sub(axisPriority,axisPriorityIdx,axisPriorityIdx)

        nextStep    = move.getNextStep(startPos, endPos, currentAxisPriority)
        --logFile.logWrite("startPos =",startPos)
        --logFile.logWrite("endPos   =",endPos)
        --logFile.logWrite("nextStep =",nextStep)

        if(nextStep~="") then
            result      = blocks.inspectDig(nextStep,dig)
            --logFile.logWrite("inspectDig ",result)
            if(result == "OK") then
                result      = move.move(nextStep)
                --logFile.logWrite("move ",result)
            elseif(result == "BYPASS") then
                -- TODO: This is a tmp fix of bypass
                -- nextStep = "U"
                --result      = move.move(nextStep)
                result = false
                axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
            else
                result = false
                axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
            end
        else
            axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
            moveErrors = moveErrors + 1
            if (moveErrors > 3) then
                local saveStatus = modem.getStatus()
                modem.sendStatus("Blocked")
                print("Can't move, please remove the obstacles!")
                util.waitForUserKey()
                moveErrors = 0
                modem.sendStatus(saveStatus)
            end
        end
        startPos = location.getCurrentPos()    
    end

    if(startPos.f ~= endPos.f) then
        move.turnToFace(endPos.f)
    end
end

-- Get the next step to get from startPos to endPos using axis
function move.getNextStep(startPos, endPos, axis)
    --logFile.logWrite("in move.getNextStep")
    --logFile.logWrite("startPos",startPos)
    --logFile.logWrite("endPos",endPos)
    --logFile.logWrite("axis",axis)

    local nextStep              = ""

    --logFile.logWrite("1-axisPriorityIdx",axisPriorityIdx)
    --logFile.logWrite("1-currentAxisPriority",currentAxisPriority)
    --logFile.logWrite("1-nextStep",nextStep)
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
    --logFile.logWrite("1-return",nextStep)
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
    modem.sendStatus()
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