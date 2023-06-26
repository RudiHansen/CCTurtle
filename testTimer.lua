--[[
local startTime = os.clock()
sleep(1.5)
print("os.clock = " .. os.clock()-startTime)


startTime = os.time()
sleep(1.5)
print("os.time = " .. os.time()-startTime)

startTime = os.epoch()
sleep(1.5)
print("os.epoch = " .. os.epoch()-startTime)
]]
local waitForTurtle = 1
local result = false
local name = "computercraft:turtle_normal"

while(waitForTurtle<3 and result==false and name=="computercraft:turtle_normal")do
    print("In loop")
    waitForTurtle = waitForTurtle + 1    
end
