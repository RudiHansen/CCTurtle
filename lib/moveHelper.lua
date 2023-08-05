 --[[
    moveHelper Function Library
    Developed by Rudi Hansen, Start 2023-08-05

    For helper functions used in the move library
]]

local moveHelper = {}

function moveHelper.calculateMoves(nextMove)
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
        sideMove1 = "E"
        sideMove2 = "W"
    elseif(origMove=="S")then
        sideMove1 = "E"
        sideMove2 = "W"
    elseif(origMove=="U")then
        sideMove1 = "S"
        sideMove2 = "N"
    elseif(origMove=="D")then
        sideMove1 = "S"
        sideMove2 = "N"
    end

    logFile.logWrite("moveHelper.calculateMoves",nextMove)
    logFile.logWrite("origMove,sideMove1,sideMove2",origMove,sideMove1,sideMove2)

    return origMove, sideMove1, sideMove2
end

return moveHelper
