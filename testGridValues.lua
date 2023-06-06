util      = require("lib.util")
logFile   = require("lib.logFile")

-- Create an empty gridMap table
local gridMap = {}

-- Function to set the value at given coordinates (x, y, z)
local function setGridMapValue(x, y, z, value)
    --logFile.logWrite("setGridMapValue ",x,y,z,value)
    if not gridMap[x] then
        gridMap[x] = {}
    end
    if not gridMap[x][y] then
        gridMap[x][y] = {}
    end
    gridMap[x][y][z] = value
end

-- Function to get the value at given coordinates (x, y, z)
local function getGridMapValue(x, y, z)
    if not gridMap[x] or not gridMap[x][y] then
        return nil
    end
    return gridMap[x][y][z]
end

local function initGridMap(startPos, endPos)
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
                setGridMapValue(ix,iz,iy,0)
                values = values + 1
            end
        end
    end
    logFile.logWrite("initGridMap set",values," values")
    logFile.logWrite("in ",os.clock()-startTime)
end

logFile.logFileOpen()


local startPos     = {x=-30,z=10,y=63,f="E"}
local endPos       = {x=32,z=12,y=66,f="E"}

initGridMap(startPos,endPos)


setGridMapValue(30, 10, 63, "A")

logFile.logWrite("Val ",getGridMapValue(-30,10,63))
logFile.logWrite("Val ",getGridMapValue(31,10,63))
logFile.logWrite("Val ",getGridMapValue(32,10,63))
logFile.logWrite("Val ",getGridMapValue(30,11,63))
logFile.logWrite("Val ",getGridMapValue(31,11,63))
logFile.logWrite("Val ",getGridMapValue(32,11,63))
logFile.logWrite("Val ",getGridMapValue(30,12,63))
logFile.logWrite("Val ",getGridMapValue(31,12,63))
logFile.logWrite("Val ",getGridMapValue(32,12,63))
