-- Load all library's
modem       = require("lib.modem")
location    = require("lib.location")
inventory   = require("lib.inventory")
move        = require("lib.move")
util        = require("lib.util")
logFile     = require("lib.logFile")
blocks      = require("lib.blocks")
gridMap     = require("lib.gridMap")
turtleJobs  = require("lib.turtleJobs")

-- Init Variables
local noJobsCount   = 0
local turtleJobData = {}
local startDig      = {x=80,z=41,y=63,f="S"}
local endDig        = {x=73,z=48,y=63,f="S"}
-- Init library's
logFile.logFileOpen()
modem.init()
location.init()
blocks.loadData()

-- Send initial status message
location.resetCurrentPosToHome()
modem.sendStatus("Idle")


move.traverseArea(startDig,endDig,xyz,true)

-- End action for turtle
logFile.logWrite("moveHome")
inventory.emptyStorageSlots()
inventory.pickUpFuel()
move.moveToPos(location.getHomePos(),xyz,false)

-- Finalize script
logFile.logFileClose()
