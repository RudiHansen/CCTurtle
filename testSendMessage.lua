rednet.open("left") --enable the modem attached to the right side of the PC

local lable         = os.getComputerLabel()
local homePos       = {x=0,y=0,z=0,f=""}
local fuelLevel     = turtle.getFuelLevel()

-- Read location from file
local locationFileName = "location.dat"
local locationFile = fs.open(locationFileName, "r")
homePos.x = locationFile.readLine()
homePos.y = locationFile.readLine()
homePos.z = locationFile.readLine()
homePos.f = locationFile.readLine()


while(true) do
    rednet.broadcast("TurtleStatus;"..lable..";"..homePos.x..";"..homePos.y..";"..homePos.z..";"..homePos.f .. ";"..fuelLevel)
    fuelLevel = fuelLevel - 1
    sleep(2)
end