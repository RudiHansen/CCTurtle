--[[
    main program for Turtles
    Developed by Rudi Hansen on 2023-06-11
]]

-- Load all library's
modem     = require("lib.modem")
location  = require("lib.location")
inventory = require("lib.inventory")
move      = require("lib.move")
util      = require("lib.util")
logFile   = require("lib.logFile")
blocks    = require("lib.blocks")
gridMap   = require("lib.gridMap")

-- Init library's
logFile.logFileOpen()
modem.init()
location.init()
blocks.loadData()

-- Set positions
-- TODO: Get from Main computer
location.setHomePos(75,-41,63,"S")
location.setRefuelPos(73,-40,63,"N")
location.setDropOffPos(74,-40,63,"N")

-- Send Turtle status to computer
while(true) do
    location.setCurrentPos(math.random(99),math.random(99),math.random(99),"S")
    modem.sendStatus("Test")
    sleep(2)
end
