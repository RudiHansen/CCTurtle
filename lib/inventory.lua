 --[[
    inventory Function Library
    Note this library also handle fuel
    Developed by Rudi Hansen, Start 2023-03-18

    TODO

    CHANGE LOG
    2023-03-18 : Initial Version, functions copyed from turtleMiner and cleaned up.
]]

local inventory = {}

local maxFuelLevel = 1000
local minFuelLevel = 200

function inventory.getRemainingEmptyStorageSlots()
    local remainingEmptySlots = 0
    for i=1,16 do
        if(turtle.getItemCount(i) == 0) then
            remainingEmptySlots = remainingEmptySlots + 1            
        end
    end
    return remainingEmptySlots
end

function inventory.pickUpFuel()
    util.outputVariable(1,"Going to pick up fuel")
    -- Save current position
    local originalPos = location.getCurrentPos()

    -- Move to the fuel storage
    move.moveToFuelPosition(false)

    -- Face the chest
    move.turnToHeading(2)

    -- Test if there is a chest.
    local success, data = turtle.inspect()
    if success and string.match(data.name,"crude_storage_unit") then
        util.outputVariable(0,"Found a crude_storage_unit")
    else
        util.outputVariable(0,"Did not find a crude_storage_unit")
        util.outputVariable(0,"Did find ",data.name)
        util.outputVariable(1,"Ups I seem to be at the wrong position, there is not crude_storage_unit here, stopping all work!")
        util.outputVariable(2,"Error : crude_storage_unit not found")
        logFile.logFileClose()
        error()
    end

    result = turtle.select(1)
    result = turtle.suck()
    local data = turtle.getItemDetail()

    if data then
        if(data.name == "minecraft:charcoal" and data.count == 64)then
            util.outputVariable(0,"Picked up fuel count",data.count)
            util.outputVariable(0,"Name",data.name)
        else
            util.outputVariable(2,"Error1 : problem picking up fuel")
            logFile.logFileClose()
            error()
            end
    else
        util.outputVariable(2,"Error2 : problem picking up fuel")
        logFile.logFileClose()
        error()
    end

    util.outputVariable(1,"Picked up fuel, now returning to work.")
    util.outputVariable(0,"Going back to Pos","")
    util.outputVariable(0,"originalPos.x",originalPos.x)
    util.outputVariable(0,"originalPos.y",originalPos.y)
    util.outputVariable(0,"originalPos.z",originalPos.z)
    move.moveToPosition(originalPos.x,originalPos.y,originalPos.z,false)
    util.outputVariable(1,"Resuming work.")

    -- Face the original direction
    move.turnToHeading(0)
end

function inventory.emptyStorageSlots(refuel)
    util.outputVariable(1,"Returning to drop off items.")

    -- Save current position
    local originalPos = location.getCurrentPos()
    util.outputVariable(0,"Saving Pos","")
    util.outputVariable(0,"1-originalPos.x",originalPos.x)
    util.outputVariable(0,"1-originalPos.y",originalPos.y)
    util.outputVariable(0,"1-originalPos.z",originalPos.z)
    
    move.moveToHomePosition(false)
    util.outputVariable(0,"2-originalPos.x",originalPos.x)
    util.outputVariable(0,"2-originalPos.y",originalPos.y)
    util.outputVariable(0,"2-originalPos.z",originalPos.z)
    
    -- Face the chest
    move.turnToHeading(2)

    -- Test if there is a chest.
    local success, data = turtle.inspect()
    if success and string.match(data.name,"chest") then
        util.outputVariable(0,"Found a chest")
    else
        util.outputVariable(0,"Did not find a chest")
        util.outputVariable(1,"Ups I seem to be at the wrong position, there is not chest here, stopping all work!")
        util.outputVariable(2,"Error : Chest not found")
        logFile.logFileClose()
        error()
    end
    util.outputVariable(0,"3-originalPos.x",originalPos.x)
    util.outputVariable(0,"3-originalPos.y",originalPos.y)
    util.outputVariable(0,"3-originalPos.z",originalPos.z)

    -- Drop all items from slot 2-16
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end

    -- Face the original direction
    move.turnToHeading(0)

    if(refuel==true)then
        inventory.pickUpFuel()
    end

    util.outputVariable(1,"Dropped of all items, now returning to work.")
    util.outputVariable(0,"Going back to Pos","")
    util.outputVariable(0,"originalPos.x",originalPos.x)
    util.outputVariable(0,"originalPos.y",originalPos.y)
    util.outputVariable(0,"originalPos.z",originalPos.z)
    move.moveToPosition(originalPos.x,originalPos.y,originalPos.z,false)
    util.outputVariable(1,"Resuming work.")
end

-- Fuel functions
-- These functions are simply copyed from turtleMiner.lua
-- For right now refuling is simply done from inventory slot 1
function inventory.refuel()
    local refuelStatus = true
    util.outputVariable(1,"Refueling start level",turtle.getFuelLevel())
    turtle.select(1) -- Slot 1 is the fuel slot
    refuelStatus = turtle.refuel()
    util.outputVariable(1,"Refuel result",refuelStatus)
    util.outputVariable(1,"Refueling end level",turtle.getFuelLevel())
    if(refuelStatus == false)then
        inventory.emptyStorageSlots()
        inventory.pickUpFuel()
    end
end

function inventory.checkFuelLevelAndRefuel()
    local fuelLevel = turtle.getFuelLevel()

    if(fuelLevel < minFuelLevel) then
        inventory.refuel()
    end
end


return inventory
