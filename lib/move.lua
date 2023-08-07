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
        logFile.logWrite("--currentPos",location.getCurrentPos())
        logFile.logWrite("--nextMove",nextMove)
        logFile.logWrite("--reverseX",reverseX)
        logFile.logWrite("--reverseY",reverseY)
        if(nextMove~="")then
            result = moveHelper.tryMoveDig(nextMove)
            logFile.logWrite("--result",result)
            if(result==false)then
                logFile.logWrite("In Bypass")
                logFile.logWrite("move.traverseArea call bypass",result)
                
                local saveStatus = modem.getStatus()
                modem.sendStatus("Blocked")
                print("Can't move blocked, press key to run bypass")
                util.waitForUserKey()
                modem.sendStatus(saveStatus)

                move.byPassBlock(nextMove,areaStart,areaEnd,axisPriority,dig)

                local saveStatus = modem.getStatus()
                modem.sendStatus("Blocked")
                print("Done with bypass, press key to continue.")
                util.waitForUserKey()
                modem.sendStatus(saveStatus)

            end
        end
    end
end

function move.traverseAreaOLD(areaStart,areaEnd,axisPriority,dig)
    -- Setup variables

    if(axisPriority == nil or axisPriority == "") then
        axisPriority = {"x","z","y"}
    else
        axisPriority = {string.sub(axisPriority,1,1),string.sub(axisPriority,2,2),string.sub(axisPriority,3,3)}
    end

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

    -- Get start position.
    -- TODO : Needs also to work on other axisPriority orders.
    startPos = location.copyPos(areaStart)
    if(axisPriority[1]=="y" and axisPriority[2]=="z") then
        startPos.z          = startPos.z-1
        moveAxisPriority    = "zxy"
    end
    logFile.logWrite("startPos",startPos)
    
    -- Move turtle to a starting position.
    modem.sendStatus("Work")
    move.moveToPos(startPos,"",true)
    gridMap.setGridMapValue(startPos.x,startPos.z,startPos.y,1)
    
    -- Calculated steps to traverse the area.
    local nextMove      = ""
    local lastMove      = ""
    
    nextMove = moveHelper.calculateNextMove(axisPriority,lastMove)
    lastMove = nextMove
    logFile.logWrite("In move.traverseArea Start loop nextMove=",nextMove)
    while(nextMove~="")do
        logFile.logWrite("nextMove",nextMove)
        
        if(nextMove~="") then
            result      = blocks.inspectDig(nextMove,true)
            logFile.logWrite("inspectDig ",result)
            if(result == "OK") then
                gridMap.setGridMapDirection(nextMove,1)
                result      = move.move(nextMove)
                logFile.logWrite("move ",result)
            elseif(result=="BYPASS") then
                logFile.logWrite("In Bypass")
                -- Temp fix for bypass, until I get the ByPass to work.
                --local saveStatus = modem.getStatus()
                --modem.sendStatus("Blocked")
                --print("Can't move, please remove the obstacles!")
                --util.waitForUserKey()
                --modem.sendStatus(saveStatus)

                logFile.logWrite("move.traverseArea call bypass",result)
                gridMap.setGridMapDirection(nextMove,2)
                move.byPassBlock(nextMove,areaStart,areaEnd,axisPriority,dig)
            end
            nextMove = ""
        end
        inventory.checkAll()
        
        nextMove = moveHelper.calculateNextMove(axisPriority,lastMove)
        lastMove = nextMove
        logFile.logWrite("In move.traverseArea end of loop nextMove=",nextMove)
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
                --logFile.logWrite("Check ok move result",result)
            elseif(result == "BYPASS") then
                -- TODO: This is a tmp fix of bypass
                if(moveErrors > 2) then
                    logFile.logWrite("move.move call bypass",result)
                    move.byPassBlock(nextStep,startPos,endPos,axisPriority,dig)
                    moveErrors = 0
                else
                    result = false
                    axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
                end
            else
                result = false
                axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
            end
        else
            axisPriorityIdx         = util.incNumberMax(axisPriorityIdx,4)
            moveErrors = moveErrors + 1
            logFile.logWrite("moveErrors ",moveErrors)
            if (moveErrors > 3) then
                logFile.logWrite("move.move call bypass when blocked",result)
                move.byPassBlock(nextStep,startPos,endPos,axisPriority,dig)
                moveErrors = 0

                --local saveStatus = modem.getStatus()
                --logFile.logWrite("Blocked")
                --modem.sendStatus("Blocked")
                --print("Can't move, please remove the obstacles!")
                --util.waitForUserKey()
                --moveErrors = 0
                modem.sendStatus(saveStatus)
            end
        end
        startPos = location.getCurrentPos()    
    end

    if(startPos.f ~= endPos.f) then
        move.turnToFace(endPos.f)
    end
end

-- TODO : First some refactoring of this code.
--        New lib moveHelper for some of the functions.
-- TODO : Then make it handle the case where it does not get back on track
-- TODO : Improve the setting of origMove, sideMove1 and sideMove2
--        Thinking it may have to set them differently in some way.
--        From the result in my first test when it kind of dug into the wall
--        When it could have moved to the other side with no digging.
--        
-- TODO : Fix problem in bypass U and D
--        It kind of skips a complete level of digging 
--        I actually think this might go for 2 of the 3 directions.
--        Like this job, where E&W are lets call it the main move direction, 
--        the two other S&N, U&D might not be able to use the same method, without
--        it causing some digging to be skipped.
--
-- TODO : There is also a problem sometimes when trying to bypass a 2x2 block
--        The problem is that it only tries to move sideMove1 one time
--        May need to add some sort of check to fix that.

function move.byPassBlock(nextMove,startPos,endPos,axisPriority,dig)
    logFile.logWrite("move.byPassBlock")
    logFile.logWrite("Start At pos : ",location.getCurrentPos())
    logFile.logWrite("nextMove",nextMove)
    logFile.logWrite("startPos",startPos)
    logFile.logWrite("endPos",endPos)
    logFile.logWrite("axisPriority",axisPriority)
    logFile.logWrite("dig",dig)

    local startPosition = location.getCurrentPosCopy()
    logFile.logWrite("startPosition",startPosition)

    local origMove, sideMove1, sideMove2 = moveHelper.calculateMoves(nextMove,endPos)
    local doSideMove1   = true
    local keepMoving    = true
    local doNext        = true

    if(origMove=="U" or origMove=="D")then
        -- TODO: Try to find some way to handle this.
        logFile.logWrite("In move.byPassBlock blocked")
        local saveStatus = modem.getStatus()
        modem.sendStatus("Blocked")
        print("Can't move, please remove the obstacles!")
        util.waitForUserKey()
        modem.sendStatus(saveStatus)
        return
    end
    --[[
    origMode    W
    sideMove1   S
    sideMove2   N
    Current:
        Try to move sideMove1
            YES : LOOP
                Try origMove
                YES : Try move sideMove2
                    NO : Do nothing
                NO  : Break Look
            END LOOP

    New:
        Try to move sideMove1
            NO : Reverse sideMove1
            YES: LOOP
                Try origMove
                YES : Try move sideMove2
                    NO : No nothing
                NO  : Break Look
            END LOOP

    ]]

    -- Try to move sideMove1
    while(doSideMove1==true)do
        logFile.logWrite("Try to move sideMove1=",sideMove1)
        result      = blocks.inspectDig(sideMove1,dig)
        logFile.logWrite("result",result)
        if(result == "OK") then
            --gridMap.setGridMapDirection(sideMove1,1)
            result      = move.move(sideMove1)
            logFile.logWrite("Pos : ",location.getCurrentPos())
            keepMoving  = true
            doSideMove1 = false
        else
            -- TODO: Try to find some way to handle this.
            logFile.logWrite("In move.byPassBlock blocked")
            local saveStatus = modem.getStatus()
            modem.sendStatus("Blocked")
            print("Can't move, please remove the obstacles!")
            util.waitForUserKey()
            modem.sendStatus(saveStatus)
            move.move(startPosition,axisPriority,dig)
            return
            --gridMap.setGridMapDirection(sideMove1,2)
            --keepMoving      = false
            --logFile.logWrite("moveHelper.reverseMoveDirection",sideMove1)
            --sideMove1       = moveHelper.reverseMoveDirection(sideMove1)
            --logFile.logWrite("Result",sideMove1)
            --doSideMove1 = true
        end
        -- Test if origMove Is possible
        logFile.logWrite("Test origMove=",origMove)
        result      = blocks.inspectDig(origMove,dig)
        logFile.logWrite("result",result)
        if(result ~= "OK")then
            doSideMove1=true
        end
        logFile.logWrite("doSideMove1",doSideMove1)
    end

    while(keepMoving==true) do
        -- Try to move origMove
        doNext=true
        logFile.logWrite("Try to move origMove=",origMove)
        result      = blocks.inspectDig(origMove,dig)
        logFile.logWrite("result",result)
        if(result == "OK") then
            --gridMap.setGridMapDirection(origMove,1)
            result      = move.move(origMove)
            logFile.logWrite("Pos : ",location.getCurrentPos())
        else
            gridMap.setGridMapDirection(origMove,2)
            --keepMoving=false
            --doNext=false
        end
        if(doNext==true)then
            -- Try to move sideMove2
            logFile.logWrite("Try to move sideMove2=",sideMove2)
            logFile.logWrite("result",result)
            if(keepMoving==true) then
                result      = blocks.inspectDig(sideMove2,dig)
                if(result == "OK") then
                    --gridMap.setGridMapDirection(sideMove2,1)
                    result      = move.move(sideMove2)
                    logFile.logWrite("Pos : ",location.getCurrentPos())
                    keepMoving=false
                else
                    --gridMap.setGridMapDirection(sideMove2,2)
                end
            end
        end
    end
    logFile.logWrite("End At pos : ",location.getCurrentPos())
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