 --[[
    location Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-19 : Initial Version.
]]

local location      = {}
local homePos       = {x=0,z=0,y=0,f=""}
local refuelPos     = {x=0,z=0,y=0,f=""}
local dropOffPos    = {x=0,z=0,y=0,f=""}
local currentPos    = {x=0,z=0,y=0,f=""}

function location.init()
    -- Read location from file
    local locationFileName = "location.dat"
    local locationFile = fs.open(locationFileName, "r")
    currentPos.x = tonumber(locationFile.readLine())
    currentPos.z = tonumber(locationFile.readLine())
    currentPos.y = tonumber(locationFile.readLine())
    currentPos.f = locationFile.readLine()

    -- Get current fuel level
    fuelLevel = turtle.getFuelLevel()
end

function location.writeLocationToFile()
    -- Write location to file
    local locationFileName = "location.dat"
    local locationData = currentPos.x .. "\n" .. currentPos.z .. "\n" .. currentPos.y .. "\n".. currentPos.f .. "\n"

    local locationFile = fs.open(locationFileName, "w")
    if locationFile then
        locationFile.write(locationData)
        locationFile.flush()
        locationFile.close()
    else
        print "ERROR WRITING LOCATION DATA"
    end
end

function location.setCurrentPos(x,z,y,f)
    currentPos.x = x
    currentPos.z = z
    currentPos.y = y
    currentPos.f = f
end

function location.setHomePos(x,z,y,f)
    homePos.x = x
    homePos.z = z
    homePos.y = y
    homePos.f = f
end

function location.setRefuelPos(x,z,y,f)
    refuelPos.x = x
    refuelPos.z = z
    refuelPos.y = y
    refuelPos.f = f
end

function location.setDropOffPos(x,z,y,f)
    dropOffPos.x = x
    dropOffPos.z = z
    dropOffPos.y = y
    dropOffPos.f = f
end

function location.getCurrentPos()
    if ( type(currentPos.x) ~= "number" and type(currentPos.z) ~= "number" and type(currentPos.y) ~= "number" ) then
        print("ERROR")
        print(type(currentPos.x))
        print(type(currentPos.z))
        print(type(currentPos.y))
        error()
    end
    return currentPos
end

function location.getCurrentPosCopy()
    local posCopy = {}
    for k, v in pairs(currentPos) do
        posCopy[k] = v
    end
    return posCopy
end

function location.copyPos(pos)
    local posCopy = {}
    for k, v in pairs(pos) do
        posCopy[k] = v
    end
    return posCopy
end

function location.getHomePos()
    return homePos
end

function location.getRefuelPos()
    return refuelPos
end

function location.getDropOffPos()
    return dropOffPos
end

function location.comparePos(pos1, pos2)
    if(pos1.x == pos2.x and pos1.z == pos2.z and pos1.y == pos2.y)then
        return true 
    else
        return false
    end
end

function location.setCurrentPosFace(face)
    currentPos.f = face
end

function location.stepX(step)
    currentPos.x    = currentPos.x + step
    fuelLevel       = fuelLevel - 1
end

function location.stepZ(step)
    currentPos.z    = currentPos.z + step
    fuelLevel       = fuelLevel - 1
end

function location.stepY(step)
    currentPos.y    = currentPos.y + step
    fuelLevel       = fuelLevel - 1
end

return location