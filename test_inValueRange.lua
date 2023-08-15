-- Load the module to be tested
logFile     = require("lib.logFile")
util        = require("lib.util")
logFile.logFileOpen()

-- Define your values
x1 = 75
x2 = -100
x3 = 100

-- Check if x3 is within the range using the function
--[[
if isValueInRange(58, 47, 58) then
    print("x3 is within the range")
else
    print("x3 is outside the range")
end

if isValueInRange(74, -100, 74) then
    print("x3 is within the range")
else
    print("x3 is outside the range")
end
]]
if util.isValueInRange(113, 68, 118) then
    print("x3 is within the range")
else
    print("x3 is outside the range")
end



logFile.logFileClose()