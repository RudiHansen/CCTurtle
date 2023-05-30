modem     = require("lib.modem")
location  = require("lib.location")
inventory = require("lib.inventory")
move      = require("lib.move")
util      = require("lib.util")
logFile   = require("lib.logFile")

logFile.logFileOpen()
modem.init()
location.init()
location.setHomePos(23,10,63,"E")
location.setRefuelPos(24,14,63,"W")
location.setDropOffPos(24,9,63,"W")

-- Test Stuff
--turnToFace("N")
--sleep(2)
--turnToFace("E")

function printPos(pos)
    print(pos.x .. " " .. pos.z .. " " .. pos.y .. " " .. pos.f)
    print(type(pos.x) .. " " .. type(pos.z) .. " " .. type(pos.y) .. " " .. type(pos.f))
end


local result     = ""
local endPos     = {x=40,z=12,y=67,f="N"}

modem.sendStatus("Move")
logFile.logWrite("Move to endPos")
result = move.moveToPos(endPos)
sleep(1)
logFile.logWrite("Move to dropOffPos")
result = move.moveToPos(location.getDropOffPos())
sleep(1)
logFile.logWrite("Move to RefuelPos")
result = move.moveToPos(location.getRefuelPos())
sleep(1)
logFile.logWrite("Move to HomePos")
result = move.moveToPos(location.getHomePos())


modem.sendStatus("Idle")
location.writeLocationToFile()
logFile.logFileClose()