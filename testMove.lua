modem     = require("lib.modem")
location  = require("lib.location")
inventory = require("lib.inventory")
move      = require("lib.move")
util      = require("lib.util")
logFile   = require("lib.logFile")
blocks    = require("lib.blocks")

logFile.logFileOpen()
modem.init()
location.init()
location.setHomePos(23,10,63,"E")
location.setRefuelPos(24,14,63,"W")
location.setDropOffPos(24,9,63,"W")
blocks.loadData()

location.setCurrentPos(23,10,63,"E")
location.writeLocationToFile()

--inventory.emptyStorageSlots()
--inventory.pickUpFuel()
--inventory.checkFuelLevelAndRefuel()

local result     = ""
local endPos     = {x=28,z=14,y=63,f="E"}

result = move.moveToPos(endPos)
print("moveToPos "..tostring(result))
sleep(1)

endPos = {x=30,z=18,y=63,f="E"}
result = move.traverseToPos(endPos)
print("traverseToPos "..tostring(result))
sleep(1)

result = move.moveToPos(location.getHomePos(),"zxy")
print("moveToPos "..tostring(result))
sleep(1)

modem.sendStatus("Idle")
location.writeLocationToFile()
logFile.logFileClose()