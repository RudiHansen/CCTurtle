modem     = require("lib.modem")
location  = require("lib.location")
move      = require("lib.move")

modem.init()
location.init()

-- Test Stuff
--turnToFace("N")
--sleep(2)
--turnToFace("E")
modem.sendStatus("Move")

move.move("U")
move.move("U")

move.move("E")
move.move("E")
move.move("E")
move.move("E")

move.move("W")
move.move("W")
move.move("W")
move.move("W")

move.move("D")
move.move("D")

move.turnToFace("E")
modem.sendStatus("Idle")
location.writeLocationToFile()
