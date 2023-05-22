modem     = require("lib.modem")
location  = require("lib.location")
move      = require("lib.move")
util      = require("lib.util")

modem.init()
location.init()

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
    local startPos              = location.getHomePos()

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
            move.move(moveToDo)
        end
        startPos = location.getHomePos()    
    end
end

local result     = ""
local startPos   = {x=23,z=10,y=63,f="E"}
local endPos     = {x=29,z=12,y=67,f="N"}

modem.sendStatus("Move")
result = calcMove(endPos)
result = calcMove(startPos)

move.turnToFace("E")
modem.sendStatus("Idle")
location.writeLocationToFile()
