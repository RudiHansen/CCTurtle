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

location.setCurrentPos(77,-41,63,"S")
modem.sendStatus("Idle")
sleep(math.random(1,10))

logFile.logFileOpen()
modem.init()
location.init()

modem.sendStatus("1")

turtleJobData = {}
turtleJobData = modem.askQuestionTurtleJob()
logFile.logWrite("TurtleJob",turtleJobData)
modem.sendStatus("2")
sleep(math.random(2,6))

--blockAction = modem.askQuestionBlockAction("Rudis stol")
--logFile.logWrite("blockAction",blockAction)
modem.sendStatus("3")
sleep(math.random(2,6))

turtleJobData = {}
turtleJobData = modem.askQuestionTurtleJob()
logFile.logWrite("TurtleJob",turtleJobData)
modem.sendStatus("4")
sleep(math.random(2,6))

--blockAction = modem.askQuestionBlockAction("Rudis stol")
--logFile.logWrite("blockAction",blockAction)
modem.sendStatus("5")
sleep(math.random(2,6))


modem.sendStatus("Done")

-- Finalize script
logFile.logFileClose()
