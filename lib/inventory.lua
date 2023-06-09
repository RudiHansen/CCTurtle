 --[[
    inventory Function Library
    Note this library also handle fuel
    Developed by Rudi Hansen, Start 2023-03-18

    TODO

    CHANGE LOG
    2023-03-18 : Initial Version, functions copied from turtleMiner and cleaned up.
]]

local inventory = {}

local maxFuelLevel = 1000
local minFuelLevel = 200
local refuelItems  = 2

function inventory.getRemainingEmptyStorageSlots()
    local startTime = os.epoch()
    local remainingEmptySlots = 0
    for i=1,16 do
        if(turtle.getItemCount(i) == 0) then
            remainingEmptySlots = remainingEmptySlots + 1            
        end
    end
    logFile.logWrite("inventory.getRemainingEmptyStorageSlots took ",os.epoch()-startTime)
    logFile.logWrite("remainingEmptySlots",remainingEmptySlots)
    return remainingEmptySlots
end

function inventory.selectFirstEmptyStorageSlot()
    for i=1,16 do
        turtle.select(i)
        if(turtle.getItemCount(i) == 0) then
            return
        end
    end
end

function inventory.pickUpFuel()
    local result = true
    modem.sendStatus("Refuel")
    --logFile.logWrite("Start refuel.")
    --logFile.logWrite("Fuel level = " .. turtle.getFuelLevel())

    -- Save current position
    local originalPos = location.getCurrentPosCopy()
    --logFile.logWrite("OriginalPos = " .. util.any2String(originalPos))

    -- Move to the fuel storage
    move.moveToPos(location.getRefuelPos())
    modem.sendStatus("Refuel")

    inventory.selectFirstEmptyStorageSlot()
    while( result == true and turtle.getFuelLevel() < maxFuelLevel) do
        result = turtle.suck(refuelItems)
        --logFile.logWrite("Suck =" .. tostring(result))
        if(result == true) then
            result = turtle.refuel(refuelItems)
            --logFile.logWrite("Refuel =" .. tostring(result))
        end
        --logFile.logWrite("Fuel level = " .. turtle.getFuelLevel())
    end

    if(result == false) then
        move.moveToPos(originalPos)
        modem.sendStatus("ERROR!")
        local errorMessage = "Error refueling please fix!"
        print(errorMessage)
        --logFile.logWrite(errorMessage)
        location.writeLocationToFile()
        error()
    end

    --logFile.logWrite("Picked up fuel, now returning to work.")
    modem.sendStatus("Work")
    --logFile.logWrite("OriginalPos = " .. util.any2String(originalPos))
    move.moveToPos(originalPos)
    --logFile.logWrite("Ended refuel.")
end

function inventory.emptyStorageSlots()
    modem.sendStatus("Empty")
    --logFile.logWrite("Drop off items")

    -- Save current position
    local originalPos = location.getCurrentPosCopy()
    --logFile.logWrite("OriginalPos = " .. util.any2String(originalPos))

    -- Move to the drop storage
    move.moveToPos(location.getDropOffPos())
    modem.sendStatus("Empty")

    -- Test if there is a chest.
    local success, data = turtle.inspect()
    if success and string.match(data.name,"chest") then
        --logFile.logWrite("Found a chest")
    else
        move.moveToPos(originalPos)
        modem.sendStatus("ERROR!")
        local errorMessage = "Drop off chest not found"
        print(errorMessage)
        --logFile.logWrite(errorMessage)
        location.writeLocationToFile()
        error()
    end

    -- Drop all items from slot 1-16
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end

    --logFile.logWrite("Dropped of all items, now returning to work.")
    modem.sendStatus("Work")
    --logFile.logWrite("OriginalPos = " .. util.any2String(originalPos))
    move.moveToPos(originalPos)
    --logFile.logWrite("Ended refuel.")
end

function inventory.checkFuelLevelAndRefuel()
    local fuelLevel = turtle.getFuelLevel()

    if(fuelLevel < minFuelLevel) then
        inventory.pickUpFuel()
    end
end

function inventory.checkInventoryAndEmpty()
    if(inventory.getRemainingEmptyStorageSlots() <= 1) then
        inventory.emptyStorageSlots()
    end
end

-- TODO : Right now this is called in move.traverseArea
-- TODO : But a more permanent and robust solution needs to be found.
function inventory.checkForStopCommand()
    if(fs.exists("STOP.dat")) then
        fs.move("STOP.dat","STOPNOT.dat")
        move.moveToPos(location.getHomePos(),"zxy",false)
        modem.sendStatus("STOP")
        location.writeLocationToFile()
        logFile.logFileClose()
        error
    end
end



return inventory
