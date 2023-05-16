--[[
    Setup script for ComputerCraft Turtles
    Developed by Rudi Hansen, Start 2023-03-18

    TODO

    CHANGE LOG
    2023-05-16 : Initial Version.
]]
local lable         = ""
local homePos       = {x=0,z=0,y=0,f="N"}
local fuelLevel     = 0

-- Setup Turtle Label
lable = os.getComputerLabel()
term.clear()
term.setCursorPos(1,1)
print("Label ="..lable)
print("Enter new label, or enter to keep current label")
local input = read()
print(input)
if input ~= "" then
    os.setComputerLabel(input)
end

-- Setup Turtle Position
term.clear()
term.setCursorPos(1,1)
print("Input Turtles x position")
input = read()
homePos.x = input
print("Input Turtles z position")
input = read()
homePos.z = input
print("Input Turtles y position")
input = read()
homePos.y= input
print("Input Turtles facing(N/S/E/W)")
input = read()
homePos.f= input
print(homePos.x,homePos.z,homePos.y,homePos.f)

-- Setup Turtle Fuellevel
fuelLevel = turtle.getFuelLevel()

-- Write location to file
local locationFileName = "location.dat"
local locationData = homePos.x .. "\n" .. homePos.z .. "\n" .. homePos.y .. "\n".. homePos.f .. "\n"

local locationFile = fs.open(locationFileName, "w")
if locationFile then
    locationFile.write(locationData)
    locationFile.flush()
    locationFile.close()
else
    print "ERROR WRITING LOCATION DATA"
end
