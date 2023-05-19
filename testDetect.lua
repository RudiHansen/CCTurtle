--print(turtle.detect())
--print(turtle.detectUp())
--print(turtle.detectDown())

--print(turtle.inspect())
--print(turtle.inspectUp())
--print(turtle.inspectDown())

startTime = os.clock()

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

print(os.clock()-startTime)

