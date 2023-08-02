 --[[
    inventory Function Library
    Note this library also handle fuel
    Developed by Rudi Hansen, Start 2023-03-18

    TODO

    CHANGE LOG
    2023-03-18 : Initial Version, functions copied from turtleMiner and cleaned up.
]]

local inventory = {}

local maxFuelLevel = 4000
local minFuelLevel = 400
local refuelItems  = 4
local checkAll     = true
local checkCounter = 1

function inventory.getRemainingEmptyStorageSlots()
    local startTime = os.epoch()
    local remainingEmptySlots = 0
    for i=1,16 do
        if(turtle.getItemCount(i) == 0) then
            remainingEmptySlots = remainingEmptySlots + 1            
        end
    end
    --logFile.logWrite("inventory.getRemainingEmptyStorageSlots took ",os.epoch()-startTime)
    --logFile.logWrite("remainingEmptySlots",remainingEmptySlots)
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
    local saveStatus = modem.getStatus()
    modem.sendStatus("Refuel")
    --logFile.logWrite("Start refuel.")
    --logFile.logWrite("Fuel level = " .. turtle.getFuelLevel())

    -- Move to the fuel storage
    move.moveToPos(location.getRefuelPos())

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
        modem.sendStatus("ERROR!")
        local errorMessage = "Error refueling please fix!"
        print(errorMessage)
        --logFile.logWrite(errorMessage)
        --logFile.logWrite("At pos : ",location.getCurrentPos())
        location.writeLocationToFile()
        return false
    end

    --logFile.logWrite("Picked up fuel, now returning to work.")
    modem.sendStatus(saveStatus)
    --logFile.logWrite("OriginalPos = " .. util.any2String(originalPos))
    return true
end

function inventory.emptyStorageSlots()
    local saveStatus = modem.getStatus()
    modem.sendStatus("Empty")
    --logFile.logWrite("Drop off items")

    -- Move to the drop storage
    move.moveToPos(location.getDropOffPos())

    -- Test if there is a chest.
    local success, data = turtle.inspect()
    if success and string.match(data.name,"chest") then
        --logFile.logWrite("Found a chest")
    else
        modem.sendStatus("ERROR!")
        local errorMessage = "Drop off chest not found"
        print(errorMessage)
        --logFile.logWrite(errorMessage)
        --logFile.logWrite("At pos : ",location.getCurrentPos())
        --location.writeLocationToFile()
        return false
    end

    -- Drop all items from slot 1-16
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end

    --logFile.logWrite("Dropped of all items, now returning to work.")
    modem.sendStatus(saveStatus)
    --logFile.logWrite("OriginalPos = " .. util.any2String(originalPos))
    return true
end

function inventory.checkFuelLevel()
    local fuelLevel = turtle.getFuelLevel()

    if(fuelLevel < minFuelLevel) then
        return true
    end
    return false
end

function inventory.checkInventoryStatus()
    if(inventory.getRemainingEmptyStorageSlots() <= 1) then
        return true
    end
    return false
end

-- TODO : Should perhaps change this to ask the server instead of checking the file
function inventory.checkForStopCommand()
    if(fs.exists("STOP.dat")) then
        fs.move("STOP.dat","STOPNOT.dat")
        return true
    end
    return false
end

function inventory.checkAll(force)
    local checkStop         = false
    local checkFuel         = false
    local checkInventory    = false
    
    if(force==nil)then
        force=false
    end

    if(checkAll == false) then
        return
    end
    
    if(checkCounter % 5 == 0 or force) then
        checkStop         = inventory.checkForStopCommand()
    end
    if(checkCounter % 20 == 0 or force) then
        checkFuel         = inventory.checkFuelLevel()
        checkInventory    = inventory.checkInventoryStatus()
    end
    checkCounter = checkCounter + 1
    
    if((checkStop or checkFuel or checkInventory)==false) then
        return
    end
    
    --logFile.logWrite("inventory.checkAll ",checkAll)
    --logFile.logWrite("checkStop=",checkStop)
    --logFile.logWrite("checkFuel=",checkFuel)
    --logFile.logWrite("checkInventory=",checkInventory)

    checkAll = false

    if(checkStop==true)then
        modem.sendStatus("STOP")
        inventory.emptyStorageSlots()
        inventory.pickUpFuel()
        move.moveToPos(location.getHomePos(),"zxy",false)
        location.writeLocationToFile()
        logFile.logFileClose()
        modem.sendStatus("Idle")
        error()
    end

    -- Save current position
    local originalPos = location.getCurrentPosCopy()
    --logFile.logWrite("OriginalPos = " .. util.any2String(originalPos))

    if(checkFuel == true or checkInventory == true)then
        inventory.emptyStorageSlots()
        checkInventory = false
        inventory.pickUpFuel()
    end

    move.moveToPos(originalPos,"yzx")
    checkAll = true
    --logFile.logWrite("Ended checkAll")
end


return inventory
