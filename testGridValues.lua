util      = require("lib.util")
logFile   = require("lib.logFile")
gridMap   = require("lib.gridMap")

logFile.logFileOpen()

local startPos     = {x=-30,z=10,y=63,f="E"}
local endPos       = {x=32,z=12,y=66,f="E"}

gridMap.initGridMap(startPos,endPos)


gridMap.setGridMapValue(30, 10, 63, "A")

logFile.logWrite("Val ",gridMap.getGridMapValue(-30,10,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(31,10,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(32,10,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(30,11,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(31,11,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(32,11,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(30,12,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(31,12,63))
logFile.logWrite("Val ",gridMap.getGridMapValue(32,12,63))
