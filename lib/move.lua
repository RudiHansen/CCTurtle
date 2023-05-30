 --[[
    move Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-22 : Initial Version.
]]

local move = {}

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