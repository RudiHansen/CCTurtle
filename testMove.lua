modem     = require("lib.modem")
location  = require("lib.location")
inventory = require("lib.inventory")
move      = require("lib.move")
util      = require("lib.util")
logFile   = require("lib.logFile")
blocks    = require("lib.blocks")
gridMap   = require("lib.gridMap")

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
inventory.checkFuelLevelAndRefuel()
inventory.checkInventoryAndEmpty()

local result     = ""
local startDig   = {x=71,z=35,y=66,f="E"}
local areaStart  = {x=73,z=35,y=63,f="E"}
local areaEnd    = {x=83,z=45,y=73,f="E"}

--result = move.moveToPos(startDig)

--result = move.traverseArea(areaStart,areaEnd,"xzy",true)
--result = move.traverseArea(areaStart,areaEnd,"zyx",true)



result = move.moveToPos(location.getHomePos(),"zxy",false)
--print("moveToPos "..tostring(result))
--sleep(1)

modem.sendStatus("Idle")
location.writeLocationToFile()
logFile.logFileClose()