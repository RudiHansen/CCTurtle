-- Load the module to be tested
local gridMap     = require("lib.gridMap")
logFile     = require("lib.logFile")
util        = require("lib.util")

-- Helper function to check if two tables are equal
local function tablesEqual(t1, t2)
    if #t1 ~= #t2 then
        return false
    end

    for i, v in ipairs(t1) do
        if v ~= t2[i] then
            return false
        end
    end

    return true
end

-- Test the setGridMapValue and getGridMapValue functions
function testSetAndGetGridMapValue()
    gridMap.setGridMapValue(0, 0, 0, 42)
    assert(gridMap.getGridMapValue(0, 0, 0) == 42)

    gridMap.setGridMapValue(1, 1, 1, 99)
    assert(gridMap.getGridMapValue(1, 1, 1) == 99)

    -- Test a non-existing coordinate, should return default value 9
    assert(gridMap.getGridMapValue(2, 2, 2) == 9)
end

-- Test the initGridMap function
function testInitGridMap()
    -- Define a test range
    -- initGridMap  { ["y"] = 68,["x"] = 1,["f"] = N,["z"] = -35,}  
    --              { ["y"] = 80,["x"] = -16,["f"] = N,["z"] = -100,} 
    -- initGridMap set 15444  values
    local startPos = {x=1, y=68, z=-35}
    local endPos = {x=-16, y=80, z=-100}

    -- Initialize the grid map
    gridMap.initGridMap(startPos, endPos)

    -- Test if the values were set correctly
    assert(gridMap.getGridMapValue(-6, -35, 68) == 0) -- x, z, y
    assert(gridMap.getGridMapValue(-16, -36, 68) == 0)
    assert(gridMap.getGridMapValue(-17, -36, 68) == 9)
    assert(gridMap.getGridMapValue(0, -38, 67) == 0)
end

-- Run the tests
function runTests()
    logFile.logFileOpen()
    local success, errorMessage

    success, errorMessage = pcall(testSetAndGetGridMapValue)
    if success then
        print("testSetAndGetGridMapValue passed")
    else
        print("testSetAndGetGridMapValue failed: " .. errorMessage)
    end

    success, errorMessage = pcall(testInitGridMap)
    if success then
        print("testInitGridMap passed")
    else
        print("testInitGridMap failed: " .. errorMessage)
    end
end

-- Call the runTests function to execute the tests
runTests()
