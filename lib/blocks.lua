 --[[
    blocks Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    TODO

    CHANGE LOG
    2023-03-18 : Initial Version.
    2023-06-01 : New version for new turtles.
]]

local blocks = {}

local dataFileNameIgnore    = "blocksTurtleCanIgnore.dat"
local dataFileNameCanMine   = "blocksTurtleCanMine.dat"
local dataFileNameCantMine  = "blocksTurtleCantMine.dat"

local blocksTurtleCanIgnore     = {}
local blocksTurtleCanMine       = {}
local blocksTurtleCantMine      = {}

-- Inspect if it possible to move in direction (W/E/N/S/D/U), if dig then try to dig block.
-- Return values ("OK"-Path free turtle can move, "BYPASS"-Something is blocking turtle cant move that direction
-- "ERROR"-This should not happen)
function blocks.inspectDig(direction,dig)
    --logFile.logWrite("in blocks.inspectDig",direction,dig)

    local result
    local inspectData
    local blockAction
    local waitForTurtle = 1

    result, inspectData = blocks.inspectDirection(direction)
    if(inspectData.name=="computercraft:turtle_normal")then
        logFile.logWrite("result ",result)
        logFile.logWrite("inspectData.name",inspectData.name)
        logFile.logWrite("waitForTurtle",waitForTurtle)
        logFile.logWrite("waitForTurtle<3",waitForTurtle<3)
    end

    -- If the inspectData.name is a Turtle, then try one time to see if it moves.
    while(waitForTurtle<3 and result==true and inspectData.name=="computercraft:turtle_normal")do
        logFile.logWrite("In loop")
        logFile.logWrite("waitForTurtle",waitForTurtle)
        sleep(waitForTurtle)
        waitForTurtle = waitForTurtle + 1
        result, inspectData = blocks.inspectDirection(direction)
        logFile.logWrite("result",result)
    end

    if(result==false) then -- There is no block in front of the turtle
        --logFile.logWrite("*Return OK")
        return "OK"
    elseif (dig==true) then
        --logFile.logWrite("Calling inspectedBlokMatchCanDig "..inspectData.name)
        blockAction = blocks.inspectedBlokMatchCanDig(inspectData.name)
        --logFile.logWrite("blockAction",blockAction)

        if(blockAction=="mine") then
            if(direction=="W" or direction=="E" or direction=="N" or direction =="S")then
                result = turtle.dig()
                result = turtle.detect()
                while(result) do
                    result = turtle.dig()
                    result = turtle.detect()
                end
                result = true
            elseif(direction=="U")then
                result = turtle.digUp()
                result = turtle.detectUp()
                while(result) do
                    result = turtle.digUp()
                    result = turtle.detectUp()
                end
                result = true
            elseif(direction=="D")then
                result = turtle.digDown()
                result = turtle.detectDown()
                while(result) do
                    result = turtle.digDown()
                    result = turtle.detectDown()
                end
                result = true
            else
                logFile.logWrite("Problem in blocks.inspectDig")
                logFile.logWrite("direction " .. tostring(direction))
                logFile.logWrite("inspectData.Name " .. tostring(inspectData.Name))
                modem.sendStatus("ERROR!")
                location.writeLocationToFile()
                error()
            end
            if(result==true) then
                --logFile.logWrite("*2Return OK")
                return "OK"
            else
                logFile.logWrite("Problem in blocks.inspectDig with result from dig")
                modem.sendStatus("ERROR!")
                location.writeLocationToFile()
                error()
            end
        elseif(blockAction=="ignore") then
            --logFile.logWrite("*3Return OK")
            return "OK"
        elseif(blockAction=="pass") then
            --logFile.logWrite("*Return BYPASS")
            return "BYPASS"
        end
        return true
    elseif (dig==false) then
        blockAction = blocks.inspectedBlokMatchCanDig(inspectData.name)
        if(blockAction=="mine") then
            --logFile.logWrite("*4Return BYPASS")
            return "BYPASS"
        elseif(blockAction=="ignore") then
            --logFile.logWrite("*4Return OK")
            return "OK"
        elseif(blockAction=="pass") then
            --logFile.logWrite("*5Return BYPASS")
            return "BYPASS"
        end

    end
    logFile.logWrite("Problem in blocks.inspectDig")
    logFile.logWrite("Should newer be here in the code")
    modem.sendStatus("ERROR!")
    location.writeLocationToFile()
    error()
end

function blocks.inspectDirection(direction)
    if(direction=="W" or direction=="E" or direction=="N" or direction =="S")then
        move.turnToFace(direction)
        result, inspectData = turtle.inspect()
    elseif(direction=="U")then
        result, inspectData = turtle.inspectUp()
    elseif(direction=="D")then
        result, inspectData = turtle.inspectDown()
    else
        logFile.logWrite("Error in blocks.inspectDig")
        error()
    end
    return result, inspectData
end

function blocks.inspectedBlokMatchCanDig(blockName)
    --logFile.logWrite("In inspectedBlokMatchCanDig blockName=" .. blockName)
    for i, value in ipairs(blocksTurtleCanMine) do
        if blockName == value then
            --logFile.logWrite("return mine")
            return "mine"
        end
    end
    for i, value in ipairs(blocksTurtleCanIgnore) do
        if blockName == value then
            --logFile.logWrite("return ignore")
            return "ignore"
        end
    end
    for i, value in ipairs(blocksTurtleCantMine) do
        if blockName == value then
            --logFile.logWrite("return pass")
            return "pass"
        end
    end

    --logFile.logWrite("Call  askQuestionBlockAction blockName=" .. blockName)
    local saveStatus = modem.getStatus()
    modem.sendStatus("?")
    local blockAction = modem.askQuestionBlockAction(blockName)
    --logFile.logWrite("blockAction",blockAction)
    modem.sendStatus(saveStatus)
    if(blockAction=="mine")then
        table.insert(blocksTurtleCanMine,blockName)
        blocks.saveData()
        --logFile.logWrite("2return mine")
        return "mine"
    elseif(blockAction=="ignore")then
        table.insert(blocksTurtleCanIgnore,blockName)
        blocks.saveData()
        --logFile.logWrite("2return ignore")
        return "ignore"
    elseif(blockAction=="pass")then
        table.insert(blocksTurtleCantMine,blockName)
        blocks.saveData()
        --logFile.logWrite("2return pass")
        return "pass"
    else
        logFile.logWrite("Problem in blocks.inspectedBlokMatchCanDig")
        modem.sendStatus("ERROR!")
        location.writeLocationToFile()
        error()
    end
end

function blocks.saveData()
    -- Open file for writing
    local fileIgnore    = io.open(dataFileNameIgnore,   "w")
    local fileCanMine   = io.open(dataFileNameCanMine,  "w")
    local fileCantMine  = io.open(dataFileNameCantMine, "w")

    -- Convert list to string and write to file
    fileIgnore:write(table.concat(blocksTurtleCanIgnore, ","))
    fileCanMine:write(table.concat(blocksTurtleCanMine, ","))
    fileCantMine:write(table.concat(blocksTurtleCantMine, ","))

    -- Close file
    fileIgnore:close()
    fileCanMine:close()
    fileCantMine:close()
end

function blocks.loadData()
    -- Open file for reading
    local fileIgnore    = io.open(dataFileNameIgnore,   "r")
    local fileCanMine   = io.open(dataFileNameCanMine,  "r")
    local fileCantMine  = io.open(dataFileNameCantMine, "r")

    -- Read contents of file into a string
    local contentsIgnore    = fileIgnore:read("*all")
    local contentsCanMine   = fileCanMine:read("*all")
    local contentsCantMine  = fileCantMine:read("*all")

    -- Close file
    fileIgnore:close()
    fileCanMine:close()
    fileCantMine:close()

    -- Create new table and add elements from string
    blocksTurtleCanIgnore = {}
    for element in string.gmatch(contentsIgnore, "[^,]+") do
        table.insert(blocksTurtleCanIgnore, element)
    end

    blocksTurtleCanMine = {}
    for element in string.gmatch(contentsCanMine, "[^,]+") do
        table.insert(blocksTurtleCanMine, element)
    end

    blocksTurtleCantMine = {}
    for element in string.gmatch(contentsCantMine, "[^,]+") do
        table.insert(blocksTurtleCantMine, element)
    end
end

function blocks.createInitialData()

    blocksTurtleCanIgnore     = { "minecraft:lava","minecraft:water" }

    blocksTurtleCanMine       = { "extractinator:silt","minecraft:cobbled_deepslate","minecraft:cobblestone",
                                "minecraft:deepslate","minecraft:dirt","minecraft:grass_block","minecraft:sand",
                                "minecraft:sand","minecraft:stone","minecraft:torch","minecraft:tuff","minecraft:wall_torch",
                                "tconstruct:sky_slime_dirt","tconstruct:sky_slime_dirt","tconstruct:sky_vanilla_slime_grass",
                                "tconstruct:sky_slime_leaves","minecraft:kelp_plant","tconstruct:earth_slime_leaves",
                                "tconstruct:greenheart_log","tconstruct:earth_sky_slime_grass","tconstruct:earth_congealed_slime",
                                "tconstruct:sky_slime_vine","tconstruct:earth_slime_dirt","tconstruct:sky_earth_slime_grass",
                                "tconstruct:sky_congealed_slime","tconstruct:skyroot_log","ad_astra:moon_sand",
                                "ad_astra:moon_cobblestone","minecraft:basalt","create:scoria"}

    blocksTurtleCantMine      = {"minecraft:deepslate_iron_ore"}
end

return blocks
