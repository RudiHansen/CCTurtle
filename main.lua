--[[
    main program for Turtles
    Developed by Rudi Hansen on 2023-06-11
]]

-- Load all library's
modem       = require("lib.modem")
location    = require("lib.location")
inventory   = require("lib.inventory")
move        = require("lib.move")
moveHelper  = require("lib.moveHelper")
util        = require("lib.util")
logFile     = require("lib.logFile")
blocks      = require("lib.blocks")
gridMap     = require("lib.gridMap")
turtleJobs  = require("lib.turtleJobs")

-- Init Variables
local noJobsCount   = 0
local turtleJobData = {}
local startDig      = {x=82,z=-10,y=63,f="S"}
local endDig        = {x=82,z=-10,y=63,f="S"}
-- Init library's
logFile.logFileOpen()
modem.init()
location.init()
blocks.loadData()

-- Send initial status message
location.resetCurrentPosToHome()
modem.sendStatus("Idle")

-- Test Ask about block.
-- modem.askQuestionBlockAction("Rudis stol")

-- Send Turtle status to computer
local doLoop = true

while(doLoop) do
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
            modem.sendTurtleJobStatus(turtleJobData,"RUN")
            logFile.logWrite("From main call1 move.moveToPos")
            move.moveToPos(startDig,turtleJobData.axisPriority)
            modem.sendTurtleJobStatus(turtleJobData,"DONE")
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
            modem.sendTurtleJobStatus(turtleJobData,"RUN")
            move.traverseArea(startDig,endDig,turtleJobData.axisPriority,true)
            modem.sendTurtleJobStatus(turtleJobData,"DONE")
        elseif(turtleJobData.JobType=="moveHome")then
            modem.sendTurtleJobStatus(turtleJobData,"DONE")
            doLoop = false
        end
    else
        if(noJobsCount>5)then
            logFile.logWrite("Exit main.")    
            doLoop = false
        end
        logFile.logWrite("No jobs.")
        noJobsCount = noJobsCount + 1
    end
end

-- End action for turtle
logFile.logWrite("moveHome")
inventory.emptyStorageSlots()
inventory.pickUpFuel()
--move.moveToPos(location.getHomePos(),turtleJobData.axisPriority,false)
logFile.logWrite("From main call2 move.moveToPos")
move.moveToPos(location.getHomePos(),'xzy',false)

-- Finalize script
logFile.logFileClose()
