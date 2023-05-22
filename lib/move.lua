 --[[
    move Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-22 : Initial Version.
]]

local move = {}

function move.move(direction)
    --sleep(.5)
    if(direction=="E")then
        move.turnToFace(direction)
        turtle.forward()
        location.stepX(1)
    elseif(direction=="W")then
        move.turnToFace(direction)
        turtle.forward()
        location.stepX(-1)
    elseif(direction=="N")then
        move.turnToFace(direction)
        turtle.forward()
        location.stepZ(-1)
    elseif(direction=="S")then
        move.turnToFace(direction)
        turtle.forward()
        location.stepZ(1)
    elseif(direction=="U")then
        turtle.up()
        location.stepY(1)
    elseif(direction=="D")then
        turtle.down()
        location.stepY(-1)
    end
    location.writeLocationToFile()
    modem.sendStatus("Move")
end

function move.turnToFace(newFace)
    homePos = location.getHomePos()

    newHeading = move.face2Int(newFace)
    currentHeading = move.face2Int(homePos.f)

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
    location.setHomePosFace(newFace)
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