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
    logFile.logWrite("setGridMapValue ",x,z,y,value)
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
    if not gridMapData[x] or not gridMapData[x][z] then
        return nil
    end
    return gridMapData[x][z][y]
end

function gridMap.initGridMap(startPos, endPos)
    logFile.logWrite("initGridMap ",startPos,endPos)

    local startTime = os.clock()
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

    logFile.logWrite("initGridMap ",incX,incZ,incY)

    for ix = startPos.x, endPos.x,incX do
        for iy = startPos.y, endPos.y,incY do
            for iz = startPos.z, endPos.z,incZ do
                gridMap.setGridMapValue(ix,iz,iy,0)
                values = values + 1
            end
        end
    end
    logFile.logWrite("initGridMap set",values," values")
    logFile.logWrite("in ",os.clock()-startTime)
end

return gridMap