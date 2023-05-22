 --[[
    location Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    CHANGE LOG
    2023-05-19 : Initial Version.
]]

local location  = {}
local homePos   = {x=0,z=0,y=0,f=""}
local fuelLevel = 0

function location.init()
    -- Read location from file
    local locationFileName = "location.dat"
    local locationFile = fs.open(locationFileName, "r")
    homePos.x = locationFile.readLine()
    homePos.z = locationFile.readLine()
    homePos.y = locationFile.readLine()
    homePos.f = locationFile.readLine()

    -- Get current fuel level
    fuelLevel = turtle.getFuelLevel()
end

function location.writeLocationToFile()
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

function location.getHomePos()
    return homePos
end

function location.setHomePosFace(face)
    homePos.f = face
end

function location.getFuelLevel()
    return fuelLevel
end

function location.stepX(step)
    homePos.x = homePos.x + step
    fuelLevel = fuelLevel - 1
end

function location.stepZ(step)
    homePos.z = homePos.z + step
    fuelLevel = fuelLevel - 1
end

function location.stepY(step)
    homePos.y = homePos.y + step
    fuelLevel = fuelLevel - 1
end

return location