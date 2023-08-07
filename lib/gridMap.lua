 --[[
    gridMap Function Library   
    Developed by Rudi Hansen, Start 2023-06-06

    TODO

    CHANGE LOG
    2023-06-06 : Initial Version.
]]

local gridMap       = {}

-- Create an empty gridMapData table for containing all map points
local gridMapData   = {}

-- Function to set the value at given coordinates (x, z, y)
function gridMap.setGridMapValue(x, z, y, value)
    --logFile.logWrite("setGridMapValue ",x,z,y,value)
    if not gridMapData[x] then
        gridMapData[x] = {}
    end
    if not gridMapData[x][z] then
        gridMapData[x][z] = {}
    end
    gridMapData[x][z][y] = value
end

-- Function to get the value at given coordinates (x, z, y)
function gridMap.getGridMapValue(x, z, y)
    --logFile.logWrite("Call gridMap.getGridMapValue(x, z, y)",x,z,y)
    if not gridMapData[x] or not gridMapData[x][z] then
        --logFile.logWrite("getGridMapValue x,y,z,ret=",x,y,z,9)
        return 9
    end
    --logFile.logWrite("getGridMapValue x,y,z,ret=",x,y,z,gridMapData[x][z][y])
    local retVal = gridMapData[x][z][y]

    if(retVal ~= 0 and retVal ~= 1 and retVal ~= 2 and retVal ~= 9)then
        logFile.logWrite("gridMap.getGridMapValue warning")
        logFile.logWrite("Problem with retVal=(",retVal,")")
        logFile.logWrite("Type=",type(retVal))
        retVal = 9
        logFile.logWrite("Problem with retVal=(",retVal,")")
        --local saveStatus = modem.getStatus()
        --modem.sendStatus("Blocked")
        --util.waitForUserKey()
        --modem.sendStatus(saveStatus)
    end
    return retVal
end

function gridMap.initGridMap(startPos, endPos)
    --logFile.logWrite("initGridMap ",startPos,endPos)

    local startTime = os.epoch()
    local values    = 0
    local incX      = 0
    local incZ      = 0
    local incY      = 0

    if(startPos.x > endPos.x) then
        incX = -1
    else
        incX = 1
    end

    if(startPos.z > endPos.z) then
        incZ = -1
    else
        incZ = 1
    end

    if(startPos.y > endPos.y) then
        incY = -1
    else
        incY = 1
    end

    --logFile.logWrite("initGridMap ",incX,incZ,incY)

    for ix = startPos.x, endPos.x,incX do
        for iy = startPos.y, endPos.y,incY do
            for iz = startPos.z, endPos.z,incZ do
                gridMap.setGridMapValue(ix,iz,iy,0)
                values = values + 1
            end
        end
    end
    --logFile.logWrite("initGridMap set",values," values")
    --logFile.logWrite("in ",os.epoch()-startTime)
end

function gridMap.setGridMapDirection(direction,value)
    local currentPos = location.getCurrentPosCopy()

    if(direction=="W")then
        gridMap.setGridMapValue(currentPos.x-1,currentPos.z,currentPos.y,value)
    elseif(direction=="E")then
        gridMap.setGridMapValue(currentPos.x+1,currentPos.z,currentPos.y,value)
    elseif(direction=="N")then
        gridMap.setGridMapValue(currentPos.x,currentPos.z-1,currentPos.y,value)
    elseif(direction=="S")then
        gridMap.setGridMapValue(currentPos.x,currentPos.z+1,currentPos.y,value)
    elseif(direction=="U")then
        gridMap.setGridMapValue(currentPos.x,currentPos.z,currentPos.y+1,value)
    elseif(direction=="D")then
        gridMap.setGridMapValue(currentPos.x,currentPos.z,currentPos.y-1,value)
    end
end

function gridMap.getGridMapDirection(direction)
    local currentPos = location.getCurrentPosCopy()
    --logFile.logWrite("gridMap.getGridMapDirection",direction)

    if(direction=="W")then
        return gridMap.getGridMapValue(currentPos.x-1,currentPos.z,currentPos.y)
    elseif(direction=="E")then
        return gridMap.getGridMapValue(currentPos.x+1,currentPos.z,currentPos.y)
    elseif(direction=="N")then
        return gridMap.getGridMapValue(currentPos.x,currentPos.z-1,currentPos.y)
    elseif(direction=="S")then
        return gridMap.getGridMapValue(currentPos.x,currentPos.z+1,currentPos.y)
    elseif(direction=="U")then
        return gridMap.getGridMapValue(currentPos.x,currentPos.z,currentPos.y+1)
    elseif(direction=="D")then
        return gridMap.getGridMapValue(currentPos.x,currentPos.z,currentPos.y-1)
    end
    logFile.logWrite("ERROR in gridMap.getGridMapDirection",direction)
    modem.sendStatus("ERROR!")
    location.writeLocationToFile()
    error()

end


return gridMap