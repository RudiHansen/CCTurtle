 --[[
    moveHelper Function Library
    Developed by Rudi Hansen, Start 2023-08-05

    For helper functions used in the move library
]]

local moveHelper = {}

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

return moveHelper
