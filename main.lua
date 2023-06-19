--[[
    main program for Turtles
    Developed by Rudi Hansen on 2023-06-11
]]

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
local turtleJobData = {}
local startDig      = {x=82,z=-10,y=63,f="S"}
local endDig        = {x=82,z=-10,y=63,f="S"}
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

-- Send initial status message
location.setCurrentPos(75,-41,63,"S")
modem.sendStatus("Idle")

-- Test Ask about block.
-- modem.askQuestionBlockAction("Rudis stol")

-- Send Turtle status to computer
while(true) do
    turtleJobData = {}
    turtleJobData = modem.askQuestionTurtleJob()
    logFile.logWrite("TurtleJob",turtleJobData)
    if(turtleJobData~=nil and turtleJobData.TurtleName==os.getComputerLabel())then
        if(turtleJobData.JobType=="moveToPos")then
            startDig.x = tonumber(turtleJobData.x1)
            startDig.z = tonumber(turtleJobData.z1)
            startDig.y = tonumber(turtleJobData.y1)
            startDig.f = turtleJobData.f1
            logFile.logWrite("moveToPos",startDig)
            logFile.logWrite("turtleJobsData.axisPriority",turtleJobData.axisPriority)
            move.moveToPos(startDig,turtleJobData.axisPriority)
        elseif(turtleJobData.JobType=="traverseArea")then
            startDig.x = tonumber(turtleJobData.x1)
            startDig.z = tonumber(turtleJobData.z1)
            startDig.y = tonumber(turtleJobData.y1)
            startDig.f = turtleJobData.f1
            endDig.x   = tonumber(turtleJobData.x2)
            endDig.z   = tonumber(turtleJobData.z2)
            endDig.y   = tonumber(turtleJobData.y2)
            endDig.f   = turtleJobData.f2
            logFile.logWrite("traverseArea",startDig,endDig)
            move.traverseArea(startDig,endDig,turtleJobData.axisPriority,true)
        elseif(turtleJobData.JobType=="moveHome")then
            move.moveToPos(location.getHomePos(),turtleJobData.axisPriority,false)
            logFile.logWrite("moveHome")
        end
    else
        sleep(5)
    end
end

-- Finalize script
logFile.logFileClose()