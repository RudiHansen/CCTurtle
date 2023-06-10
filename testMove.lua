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
location.setHomePos(75,-41,63,"S")
location.setRefuelPos(73,-40,63,"N")
location.setDropOffPos(74,-40,63,"N")
blocks.loadData()

location.setCurrentPos(75,-41,63,"S")
location.writeLocationToFile()

logFile.logWrite("1")
inventory.checkAll(true)
logFile.logWrite("2")

local result     = ""
local startDig   = {x=82,z=-30,y=63,f="S"}
local areaStart  = {x=82,z=-29,y=63,f="S"}
local areaEnd    = {x=73,z=-19,y=69,f="S"}

result = move.moveToPos(startDig,"yzx")
logFile.logWrite("3")

--result = move.traverseArea(areaStart,areaEnd,"xzy",true)
result = move.traverseArea(areaStart,areaEnd,"xyz",true)
logFile.logWrite("4")



result = move.moveToPos(location.getHomePos(),"zxy",false)
logFile.logWrite("5")

--print("moveToPos "..tostring(result))
--sleep(1)

modem.sendStatus("Idle")
location.writeLocationToFile()
logFile.logFileClose()