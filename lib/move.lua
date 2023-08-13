 --[[
    move Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-22 : Initial Version.
]]

local move = {}

local moveAxisPriority   = "zxy"

-- TODO: On performing this job, 1,Miner1,NEW,traverseArea,1,9,68,N,-4,5,71,N,xyz
--       There was a problem with the last few blocks, they where not mined.
function move.traverseArea(areaStart,areaEnd,axisPriority,dig)
    -- Setup variables
    axisPriority = util.setDefaultValueIfEmpty(axisPriority,"xyz")
    axisPriority = {string.sub(axisPriority,1,1),string.sub(axisPriority,2,2),string.sub(axisPriority,3,3)}
    dig = util.setDefaultValueIfEmpty(dig,false)
    local startPos = {};

    -- Write debug info
    logFile.logWrite("in move.traverseArea")
    logFile.logWrite("areaStart=",areaStart)
    logFile.logWrite("areaEnd=",areaEnd)
    logFile.logWrite("axisPriority=",axisPriority)
    logFile.logWrite("dig=",dig)

    -- Initialize the Grid map
    gridMap.initGridMap(areaStart,areaEnd)

    -- Find the position to which the turtle must move to start its work.
    startPos = location.copyPos(areaStart)
    logFile.logWrite("startPos",startPos)
    startPos = util.addToPositionAxis(startPos,axisPriority[3],1)
    logFile.logWrite("startPos",startPos)
    
    -- Move turtle to a starting position.
    modem.sendStatus("Work")
    
    logFile.logWrite("From move.traverseArea call move.moveToPos")
    move.moveToPos(startPos,"",false)
    --gridMap.setGridMapValue(startPos.x,startPos.z,startPos.y,1)

    -- Then do the first dig into the area to work on.
    -- TODO: Right now this move into the working area is hardcoded
    --       but I need to add a method that will calculate this
    --       so that no matter where the turtle is it can to to the
    --       area start position.
    moveHelper.tryMoveDig("N")

    -- Work on actually traversing the area
    logFile.logWrite("Start digging the area",areaStart,areaEnd)
    local nextMove = "N"
    local result
    local reverseX = false
    local reverseY = false
    while(nextMove~="")do
        nextMove, reverseX, reverseY = moveHelper.getMove(axisPriority,1,areaStart,areaEnd,reverseX, reverseY)
        --logFile.logWrite("--currentPos",location.getCurrentPos())
        --logFile.logWrite("--nextMove",nextMove)
        --logFile.logWrite("--reverseX",reverseX)
        --logFile.logWrite("--reverseY",reverseY)
        if(nextMove~="")then
            result = moveHelper.tryMoveDig(nextMove)
            --logFile.logWrite("--result",result)
            if(result==false)then
                logFile.logWrite("From Bypass")
                logFile.logWrite("move.traverseArea call bypass result,nextMove",result,nextMove)
                move.byPassBlock(nextMove,areaStart,areaEnd,axisPriority,dig)
            end
        end
        inventory.checkAll()
    end
    modem.sendStatus("Idle")
end

-- Move to a Position using axisPriority, if dig=true then dig block
function move.moveToPos(endPos,axisPriority,dig)
    logFile.logWrite("in move.moveToPos")
    logFile.logWrite("CurrentPos   :",location.getCurrentPos())
    logFile.logWrite("endPos       :",endPos)
    logFile.logWrite("axisPriority :",axisPriority)
    logFile.logWrite("dig          :",dig)
    if(axisPriority == nil or axisPriority == "") then
        axisPriority = moveAxisPriority -- "zxy"
    end
    if(dig == nil or dig == "") then
        dig = false
    end

    local startPos      = location.getCurrentPosCopy()
    local midPos        = location.copyPos(endPos)
    local diffPosAxis   = 0

    if(string.sub(axisPriority,1,1) == "z")then
        diffPosAxis = startPos.z - midPos.z
        if(diffPosAxis > 5)then
            midPos.z = midPos.z + 2
        elseif(diffPosAxis < -5)then
            midPos.z = midPos.z - 2
        end
    elseif(string.sub(axisPriority,1,1) == "x")then
        diffPosAxis = startPos.x - midPos.x
        if(diffPosAxis > 5)then
            midPos.x = midPos.x + 2
        elseif(diffPosAxis < -5)then
            midPos.x = midPos.x - 2
        end
    elseif(string.sub(axisPriority,1,1) == "y")then
        diffPosAxis = startPos.y - midPos.y
        if(diffPosAxis > 5)then
            midPos.y = midPos.y + 1
        elseif(diffPosAxis < -5)then
            midPos.y = midPos.y - 1
        end
    else
        logFile.logWrite("ERROR","Problem in move.moveToPos with calculating midPos")
        logFile.logWrite("axisPriority=",axisPriority)
        logFile.logWrite("string.sub(axisPriority,1,1)=",string.sub(axisPriority,1,1))
        util.SendStatusAndWaitForUserKey("ERROR","Problem in move.moveToPos with calculating midPos")
        error()
    end

    logFile.logWrite("From move.moveToPos1 call moveHelper.moveToPosWorker",midPos,axisPriority,dig)
    moveHelper.moveToPosWorker(midPos,axisPriority,dig)
    if(location.comparePos(midPos,endPos)==false)then
        logFile.logWrite("From move.moveToPos2 call moveHelper.moveToPosWorker",endPos,axisPriority,dig)
        moveHelper.moveToPosWorker(endPos,axisPriority,dig)
    end
end

function move.byPassBlock(nextMove,startPos,endPos,axisPriority,dig)
    --[[
        We need to bypass an obstacle with a process like this.
        There are 3 types of moves that needs to be done.
        First sideMove1 as meany times needed until origMove can be made
        Then origMove until sideMove2 can be made, if origMove can't be made, make one more sideMove1
        And then sideMove2 as meany times as we did sideMove1

        moveHelper.calculateMoves calculates what origMove, sideMove1 and sideMove2 are.

        I will start with this, there might be problems that needs to be fixed after,
        but for now this will do.

        TODO: In the cases where i ask for user assistance, (util.SendStatusAndWaitForUserKey)
              I do need to try to see if i can fix this, or at least the turtle has to return
              to the original position it started at, or it seems to resume digging in the wrong place.
    ]]
    logFile.logWrite("In move.byPassBlock")
    logFile.logWrite("Start At pos : ",location.getCurrentPos())
    logFile.logWrite("nextMove",nextMove)
    logFile.logWrite("startPos",startPos)
    logFile.logWrite("endPos",endPos)
    logFile.logWrite("axisPriority",axisPriority)
    logFile.logWrite("dig",dig)

    local startPosition = location.getCurrentPosCopy()
    logFile.logWrite("startPosition",startPosition)

    local origMove, sideMove1, sideMove2    = moveHelper.calculateMoves(nextMove,endPos)
    local sideMove1Count    = 0
    local result            = ""

    -- First sideMove1 as meany times needed until sideMove2 can be made
    while(result~="OK")do
        result = moveHelper.tryMoveDig(sideMove1)
        logFile.logWrite("sideMove1 result=",result)
        if(result==false)then
            result = moveHelper.tryMoveForceDig(sideMove1)
        end
        sideMove1Count = util.incNumber(sideMove1Count)
        if(sideMove1Count > 5)then
            util.SendStatusAndWaitForUserKey("ERROR","Might be a problem with to meany sideMove1's")
            error()
        end
        logFile.logWrite("2 -calling inspectDig ",nextStep,dig)
        result = blocks.inspectDig(origMove,dig)
        logFile.logWrite("inspectDig origMove result=",result)
    end

    --Then origMove until sideMove2 can be made
    result = ""
    while(result~="OK")do
        result = moveHelper.tryMoveDig(origMove)
        logFile.logWrite("origMove result=",result)
        if(result==false)then
            result = moveHelper.tryMoveDig(sideMove1)
            logFile.logWrite("extra sideMove1 result=",result)
            sideMove1Count = util.incNumber(sideMove1Count)
            if(sideMove1Count > 5)then
                util.SendStatusAndWaitForUserKey("ERROR","Might be a problem with to meany extra sideMove1's")
                error()
            end
            --util.SendStatusAndWaitForUserKey("Blocked","Problem in origMove")
            if(result==false)then
                result = moveHelper.tryMoveForceDig(sideMove1)
                --logFile.logWrite("Problem in origMove after extra sideMove1")
                --util.SendStatusAndWaitForUserKey("Blocked","Problem in origMove after extra sideMove1")
            end
        end
        logFile.logWrite("3 -calling inspectDig ",nextStep,dig)
        result = blocks.inspectDig(sideMove2,dig)
        logFile.logWrite("inspectDig sideMove2 result=",result)
    end

    --And then sideMove2 as meany times as we did sideMove1
    for i=1, sideMove1Count, 1 do
        result = moveHelper.tryMoveDig(sideMove2)
        logFile.logWrite("sideMove2 result=",result)
        if(result==false)then
            result = moveHelper.tryMoveForceDig(sideMove2)
            --util.SendStatusAndWaitForUserKey("Blocked","Problem in sideMove2")
        end
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