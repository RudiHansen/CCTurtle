rednet.open("left") --enable the modem attached to the right side of the PC

local lable         = os.getComputerLabel()
local homePos       = {x=0,z=0,y=0,f=""}
local fuelLevel     = turtle.getFuelLevel()

function sendStatus()
    rednet.broadcast("TurtleStatus;"..lable..";"..homePos.x..";"..homePos.z..";"..homePos.y..";"..homePos.f .. ";"..fuelLevel)
end

function readLocationFromFile()
    -- Read location from file
    local locationFileName = "location.dat"
    local locationFile = fs.open(locationFileName, "r")
    homePos.x = locationFile.readLine()
    homePos.z = locationFile.readLine()
    homePos.y = locationFile.readLine()
    homePos.f = locationFile.readLine()
end

function writeLocationToFile()
    -- Write location to file
    local locationFileName = "location.dat"
    local locationData = homePos.x .. "\n" .. homePos.z .. "\n" .. homePos.y .. "\n".. homePos.f .. "\n"

    local locationFile = fs.open(locationFileName, "w")
    if locationFile then
        locationFile.write(locationData)
        locationFile.flush()
        locationFile.close()
    else
        print "ERROR WRITING LOCATION DATA"
    end
end

function move(direction)
    if(direction=="E")then
        turnToFace(direction)
        turtle.forward()
        homePos.x = homePos.x - 1
        fuelLevel = fuelLevel - 1
    elseif(direction=="W")then
        turnToFace(direction)
        turtle.forward()
        homePos.x = homePos.x + 1
        fuelLevel = fuelLevel - 1
    elseif(direction=="N")then
        turnToFace(direction)
        turtle.forward()
        homePos.z = homePos.z + 1
        fuelLevel = fuelLevel - 1
    elseif(direction=="S")then
        turnToFace(direction)
        turtle.forward()
        homePos.z = homePos.z - 1
        fuelLevel = fuelLevel - 1
    elseif(direction=="U")then
        turtle.up()
        homePos.y = homePos.y + 1
        fuelLevel = fuelLevel - 1
    elseif(direction=="D")then
        turtle.down()
        homePos.y = homePos.y - 1
        fuelLevel = fuelLevel - 1
    end
    writeLocationToFile()
    sendStatus()
end

function turnToFace(newFace)
    newHeading = face2Int(newFace)
    currentHeading = face2Int(homePos.f)

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
    homePos.f = newFace
end

function face2Int(face)
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

readLocationFromFile()

-- Test Stuff
--turnToFace("N")
--sleep(2)
--turnToFace("E")
fuelLevel     = turtle.getFuelLevel()
sendStatus()

sleep(2)
move("U")

sleep(2)
move("E")

sleep(2)
move("E")

sleep(2)
move("W")

sleep(2)
move("W")

sleep(2)
move("D")

sleep(2)
turnToFace("E")
sendStatus()
