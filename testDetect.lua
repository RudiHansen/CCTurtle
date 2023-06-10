util      = require("lib.util")

print(turtle.detect())
--print(turtle.detectUp())
--print(turtle.detectDown())

local success, data = turtle.inspect()
--print(util.any2String(success))
--print(util.any2String(data))
if success and string.match(data.name,"chest") then
    print("Found a chest")
else
    print("Found : " .. data.name)
end


--print(turtle.inspectUp())
--print(turtle.inspectDown())
error()
startTime = os.epoch()

for i = 1, 100, 1 do
    --ret = turtle.detect()
    ret2,data = turtle.inspect()
    turtle.turnLeft()
    ret2,data = turtle.inspect()
    turtle.turnRight()
    turtle.turnRight()
    ret2,data = turtle.inspect()
    turtle.turnLeft()
end

print(os.epoch()-startTime)
