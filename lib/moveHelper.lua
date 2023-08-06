 --[[
    moveHelper Function Library
    Developed by Rudi Hansen, Start 2023-08-05

    For helper functions used in the move library
]]

local moveHelper = {}

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
function moveHelper.calculateNextMove(axisPriority)
    local currentPos    = location.getCurrentPosCopy()
    local val1
    local val2

    logFile.logWrite("In moveHelper.calculateNextMove",axisPriority)
    logFile.logWrite("axisPriority[priorityIdx]",axisPriority[priorityIdx])
    logFile.logWrite("currentPos",currentPos)

    -- First loop trying to find an unexplored cell to move to
    logFile.logWrite("In moveHelper.calculateNextMove",axisPriority)
    logFile.logWrite("First loop")
    for priorityIdx=1,3,1 do 
        nextMove = ""
        if(axisPriority[priorityIdx] == "x") then
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
        elseif(axisPriority[priorityIdx] == "z") then
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
        elseif(axisPriority[priorityIdx] == "y") then
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
    for priorityIdx=1,3,1 do 
        if(axisPriority[priorityIdx] == "x") then
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
        elseif(axisPriority[priorityIdx] == "z") then
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
        elseif(axisPriority[priorityIdx] == "y") then
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
