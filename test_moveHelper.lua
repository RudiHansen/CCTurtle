-- Load the module to be tested
location    = require("lib.location")
moveHelper  = require("lib.moveHelper")
util        = require("lib.util")
logFile     = require("lib.logFile")


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

function test_getMove()
    -- getMove(axisPriority,axisIdx,startPos,endPos,reverse)
    local axisPriority  = {"x","z","y"}
    local startPos      = {x=1,   y=68, z=-36}
    local endPos        = {x=-18, y=80, z=-55}

    location.setCurrentPos(1,-36,68,"W") -- x,z,y,f
    assert(moveHelper.getMove(axisPriority, 1, startPos, endPos, false) == "W")

    location.setCurrentPos(0,-36,68,"W") -- x,z,y,f
    assert(moveHelper.getMove(axisPriority, 1, startPos, endPos, false) == "W")

    location.setCurrentPos(-18,-36,68,"W") -- x,z,y,f
    assert(moveHelper.getMove(axisPriority, 1, startPos, endPos, false) == "U")

    location.setCurrentPos(-18,-37,68,"W") -- x,z,y,f
    assert(moveHelper.getMove(axisPriority, 1, startPos, endPos, true) == "E")

    location.setCurrentPos(1,-37,68,"W") -- x,z,y,f
    assert(moveHelper.getMove(axisPriority, 1, startPos, endPos, true) == "U")

    location.setCurrentPos(1,-55,68,"E") -- x,z,y,f
    assert(moveHelper.getMove(axisPriority, 1, startPos, endPos, true) == "N")
end

-- Run the tests
function runTests()
    term.clear()
    logFile.logFileOpen()
    location.init()
    local success, errorMessage

    success, errorMessage = pcall(test_getMove)
    if success then
        print("test_getMove passed")
    else
        print("test_getMove failed: " .. errorMessage)
    end

end

-- Call the runTests function to execute the tests
runTests()
