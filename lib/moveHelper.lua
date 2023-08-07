 --[[
    moveHelper Function Library
    Developed by Rudi Hansen, Start 2023-08-05

    For helper functions used in the move library
]]

local moveHelper = {}

-- General helper functions
function moveHelper.tryMoveDig(moveToDo)
    logFile.logWrite("In moveHelper.tryMoveDig moveToDo",moveToDo)
    result      = blocks.inspectDig(moveToDo,true)
    logFile.logWrite("inspectDig ",result)

    if(result == "OK") then
        result      = move.move(moveToDo)
        logFile.logWrite("move ",result)
        return result
    else
        logFile.logWrite("return ",false)
        return false
    end
end

function moveHelper.getMove(axisPriority,axisIdx,startPos,endPos,reverseX,reverseY)
    local currentPos    = location.getCurrentPos()
    local targetCoordinate
    local retVal        = ""
    local reverseZ      = false -- TODO: Perhaps I do at some point need to look at this also doing like the reverseX and Z

    -- Write debug info
    logFile.logWrite("In moveHelper.getMove")
    logFile.logWrite("axisPriority=",axisPriority)
    logFile.logWrite("axisIdx=",axisIdx)
    logFile.logWrite("startPos=",startPos)
    logFile.logWrite("endPos=",endPos)
    logFile.logWrite("currentPos=",currentPos)
    logFile.logWrite("reverseX=",reverseX)
    logFile.logWrite("reverseY=",reverseY)

    while(retVal=="")do
        if(axisPriority[axisIdx] == "x")then
            if(reverseX==false)then
                targetCoordinate = endPos.x 
            else
                targetCoordinate = startPos.x 
            end
            logFile.logWrite("x-targetCoordinate=",targetCoordinate)

            --1 < -18
            if(currentPos.x < targetCoordinate)then
                retVal = "E"
            elseif(currentPos.x > targetCoordinate)then
                retVal = "W"
            else
                axisIdx     = util.incNumberMax(axisIdx,4)
                reverseX    = not reverseX
            end
        end

        if(axisPriority[axisIdx] == "y")then
            if(reverseY==false)then
                targetCoordinate = endPos.y 
            else
                targetCoordinate = startPos.y
            end
            logFile.logWrite("y-targetCoordinate=",targetCoordinate)

            if(currentPos.y > targetCoordinate)then
                retVal = "D"
            elseif(currentPos.y < targetCoordinate)then
                retVal = "U"
            else
                axisIdx     = util.incNumberMax(axisIdx,4)
                reverseY    = not reverseY
            end
        end
    
        if(axisPriority[axisIdx] == "z")then
            if(reverseZ==false)then
                targetCoordinate = endPos.z
            else
                targetCoordinate = startPos.z
            end
            logFile.logWrite("z-targetCoordinate=",targetCoordinate)

            if(currentPos.z > endPos.z)then
                retVal = "N"
            elseif(currentPos.z < endPos.z)then
                retVal = "S"
            else
                axisIdx     = util.incNumberMax(axisIdx,4)
            end
        end
    end

    -- Check if turtle is at endPos, if it is then return retVal="" to end digging.
    if(location.comparePos(location.getCurrentPos(),endPos))then
        retVal = ""
    end
    logFile.logWrite("retVal=",retVal)
    logFile.logWrite("reverseX=",reverseX)
    logFile.logWrite("reverseY=",reverseY)
    return retVal, reverseX, reverseY
end

-- Helper Functions for move.byPassBlock
function moveHelper.calculateMoves(nextMove,endPos)
    local origMove = nextMove
    local sideMove1 = ""
    local sideMove2 = ""

    if(origMove=="E")then
        sideMove1 = "S"
        sideMove2 = "N"
    elseif(origMove=="W")then
        sideMove1 = "S"
        sideMove2 = "N"
    elseif(origMove=="N")then
        sideMove1 = "W"
        sideMove2 = "E"
    elseif(origMove=="S")then
        sideMove1 = "W"
        sideMove2 = "E"
    elseif(origMove=="U")then
        logFile.logWrite("in moveHelper.calculateMoves U not implemented.")
        sideMove1 = "S"
        sideMove2 = "N"
    elseif(origMove=="D")then
        logFile.logWrite("in moveHelper.calculateMoves D not implemented.")
        sideMove1 = "S"
        sideMove2 = "N"
    end

    logFile.logWrite("moveHelper.calculateMoves",nextMove)
    logFile.logWrite("origMove,sideMove1,sideMove2",origMove,sideMove1,sideMove2)

    return origMove, sideMove1, sideMove2
end

function moveHelper.reverseMoveDirection(moveVal)
    if(moveVal=="S")then
        return "N"
    end
    if(moveVal=="N")then
        return "S"
    end
    if(moveVal=="W")then
        return "E"
    end
    if(moveVal=="E")then
        return "W"
    end
    if(moveVal=="U")then
        return "D"
    end
    if(moveVal=="D")then
        return "U"
    end
end

-- Helper Functions for move.traverseArea
function moveHelper.calculateNextMove(axisPriority,lastMove)
    local currentPos    = location.getCurrentPosCopy()
    local val1
    local val2
    local axisPriorityIdx = 1

    logFile.logWrite("In moveHelper.calculateNextMove",axisPriority)
    logFile.logWrite("lastMove",lastMove)
    logFile.logWrite("currentPos",currentPos)

    -- Check if we can simply repeat lastMove
    if(lastMove~="" and lastMove~=nil)then
        val1 = gridMap.getGridMapDirection(lastMove)
        if(val1 == 0 or val1 == 1)then
            logFile.logWrite("lastMove can be repeated",lastMove)        
            return lastMove
        end
    end

    -- Then we try to find the nextMove
    logFile.logWrite("First loop")
    for axisPriorityIdx=1,3,1 do 
        nextMove = ""
        if(axisPriority[axisPriorityIdx] == "x") then
            val1 = gridMap.getGridMapValue(currentPos.x+1, currentPos.z, currentPos.y)
            val2 = gridMap.getGridMapValue(currentPos.x-1, currentPos.z, currentPos.y)
            logFile.logWrite("val1,val2",val1,val2)
            if(val1==0) then
                nextMove = "E"
            elseif(val2==0) then
                nextMove = "W"
            end
            if(nextMove~="")then
                logFile.logWrite("x,nextMove",nextMove)
                return nextMove
            end
        elseif(axisPriority[axisPriorityIdx] == "z") then
            val1 = gridMap.getGridMapValue(currentPos.x, currentPos.z+1, currentPos.y)
            val2 = gridMap.getGridMapValue(currentPos.x, currentPos.z-1, currentPos.y)
            logFile.logWrite("val1,val2",val1,val2)
            if(val1==0) then
                nextMove = "S"
            elseif(val2==0) then
                nextMove = "N"
            end
            if(nextMove~="")then
                logFile.logWrite("z,nextMove",nextMove)
                return nextMove
            end
        elseif(axisPriority[axisPriorityIdx] == "y") then
            val1 = gridMap.getGridMapValue(currentPos.x, currentPos.z, currentPos.y+1)
            val2 = gridMap.getGridMapValue(currentPos.x, currentPos.z, currentPos.y-1)
            logFile.logWrite("val1,val2",val1,val2)
            if(val1==0) then
                nextMove = "U"
            elseif(val2==0) then
                nextMove = "D"
            end
            if(nextMove~="")then
                logFile.logWrite("y,nextMove",nextMove)
                return nextMove
            end
        end
    end

    -- Second loop trying to find a free cell to move to.
    logFile.logWrite("In moveHelper.calculateNextMove",axisPriority)
    logFile.logWrite("Second loop")
    for axisPriorityIdx=1,3,1 do 
        if(axisPriority[axisPriorityIdx] == "x") then
            val1 = gridMap.getGridMapValue(currentPos.x+1, currentPos.z, currentPos.y)
            val2 = gridMap.getGridMapValue(currentPos.x-1, currentPos.z, currentPos.y)
            logFile.logWrite("val1,val2",val1,val2)
            if(val1==1) then
                nextMove = "E"
            elseif(val2==1) then
                nextMove = "W"
            end
            if(nextMove~="")then
                logFile.logWrite("x,nextMove",nextMove)
                return nextMove
            end
        elseif(axisPriority[axisPriorityIdx] == "z") then
            val1 = gridMap.getGridMapValue(currentPos.x, currentPos.z+1, currentPos.y)
            val2 = gridMap.getGridMapValue(currentPos.x, currentPos.z-1, currentPos.y)
            logFile.logWrite("val1,val2",val1,val2)
            if(val1==1) then
                nextMove = "S"
            elseif(val2==1) then
                nextMove = "N"
            end
            if(nextMove~="")then
                logFile.logWrite("z,nextMove",nextMove)
                return nextMove
            end
        elseif(axisPriority[axisPriorityIdx] == "y") then
            val1 = gridMap.getGridMapValue(currentPos.x, currentPos.z, currentPos.y+1)
            val2 = gridMap.getGridMapValue(currentPos.x, currentPos.z, currentPos.y-1)
            logFile.logWrite("val1,val2",val1,val2)
            if(val1==1) then
                nextMove = "U"
            elseif(val2==1) then
                nextMove = "D"
            end
            if(nextMove~="")then
                logFile.logWrite("y,nextMove",nextMove)
                return nextMove
            end
        end
    end

    logFile.logWrite("In moveHelper.calculateNextMove",axisPriority)
    logFile.logWrite("ERROR WE SHOULD NOT GET HERE")
end

return moveHelper
