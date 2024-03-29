 --[[
    blocks Function Library
    Developed by Rudi Hansen, Start 2023-03-18

    TODO

    CHANGE LOG
    2023-03-18 : Initial Version.
    2023-06-01 : New version for new turtles.
]]

local blocks = {}

local dataFileNameBlockTypeMine     = "blockTypeMine.dat"
local dataFileNameBlockTypeIgnore   = "blockTypeIgnore.dat"
local dataFileNameBlockTypePass     = "blockTypePass.dat"
local dataFileNameBlockTypeSecure   = "blockTypeSecure.dat"

local blockTypeMine     = {}
local blockTypeIgnore   = {}
local blockTypePass     = {}
local blockTypeSecure   = {}

-- Inspect if it possible to move in direction (W/E/N/S/D/U), if dig then try to dig block.
-- Return values ("OK"-Path free turtle can move, "BYPASS"-Something is blocking turtle cant move that direction
-- "ERROR"-This should not happen)
function blocks.inspectDig(direction,dig)
    if(direction == "" or direction==nil)then
        --logFile.logWrite("in blocks.inspectDig",direction,dig)
        util.SendStatusAndWaitForUserKey("ERROR","There is a problem in blocks.inspectDig")
        error()
    end

    local result
    local inspectData
    local blockAction
    local waitForTurtle = 1

    result, inspectData = blocks.inspectDirection(direction)
    --logFile.logWrite("result ",result)
    --logFile.logWrite("inspectData.name",inspectData.name)

    --TODO: Link (Computer README ## Turtle blocking Turtle)
    while(waitForTurtle<3 and result==true and inspectData.name=="computercraft:turtle_normal")do
        --logFile.logWrite("blocks.inspectDig  In loop")
        --logFile.logWrite("waitForTurtle",waitForTurtle)
        sleep(waitForTurtle)
        waitForTurtle = waitForTurtle + 1
        result, inspectData = blocks.inspectDirection(direction)
        --logFile.logWrite("result",result)
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
                --logFile.logWrite("Problem in blocks.inspectDig")
                --logFile.logWrite("direction " .. tostring(direction))
                --logFile.logWrite("inspectData.Name " .. tostring(inspectData.Name))
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
        elseif(blockAction=="secure") then
            --logFile.logWrite("*Return SECURE")
            return "SECURE"
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
        elseif(blockAction=="secure") then
            --logFile.logWrite("*6Return SECURE")
            return "SECURE"
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
        logFile.logWrite("Error in blocks.inspectDirection",direction)
        error()
    end
    return result, inspectData
end

function blocks.inspectedBlokMatchCanDig(blockName)
    --logFile.logWrite("In inspectedBlokMatchCanDig blockName=" .. blockName)
    for i, value in ipairs(blockTypeMine) do
        if blockName == value then
            --logFile.logWrite("return mine")
            return "mine"
        end
    end
    for i, value in ipairs(blockTypeIgnore) do
        if blockName == value then
            --logFile.logWrite("return ignore")
            return "ignore"
        end
    end
    for i, value in ipairs(blockTypePass) do
        if blockName == value then
            --logFile.logWrite("return pass")
            return "pass"
        end
    end

    for i, value in ipairs(blockTypeSecure) do
        if blockName == value then
            --logFile.logWrite("return pass")
            return "secure"
        end
    end


    --logFile.logWrite("Call  askQuestionBlockAction blockName=" .. blockName)
    local blockAction = modem.askQuestionBlockAction(blockName)
    --logFile.logWrite("blockAction",blockAction)
    if(blockAction=="mine")then
        table.insert(blockTypeMine,blockName)
        blocks.saveData()
        --logFile.logWrite("2return mine")
        return "mine"
    elseif(blockAction=="ignore")then
        table.insert(blockTypeIgnore,blockName)
        blocks.saveData()
        --logFile.logWrite("2return ignore")
        return "ignore"
    elseif(blockAction=="pass")then
        table.insert(blockTypePass,blockName)
        blocks.saveData()
        --logFile.logWrite("2return pass")
        return "pass"
    elseif(blockAction=="secure")then
        table.insert(blockTypeSecure,blockName)
        blocks.saveData()
        --logFile.logWrite("3return pass")
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
    local fileMine      = io.open(dataFileNameBlockTypeMine,   "w")
    local fileIgnore    = io.open(dataFileNameBlockTypeIgnore, "w")
    local filePass      = io.open(dataFileNameBlockTypePass,   "w")
    local fileSecure    = io.open(dataFileNameBlockTypeSecure, "w")

    -- Convert list to string and write to file
    fileMine:write(table.concat(blockTypeMine, ","))
    fileIgnore:write(table.concat(blockTypeIgnore, ","))
    filePass:write(table.concat(blockTypePass, ","))
    fileSecure:write(table.concat(blockTypeSecure, ","))

    -- Close file
    fileMine:close()
    fileIgnore:close()
    filePass:close()
    fileSecure:close()
end

function blocks.loadData()
    -- Open file for reading
    local fileMine      = io.open(dataFileNameBlockTypeMine,   "r")
    local fileIgnore    = io.open(dataFileNameBlockTypeIgnore, "r")
    local filePass      = io.open(dataFileNameBlockTypePass,   "r")
    local fileSecure    = io.open(dataFileNameBlockTypeSecure, "r")

    -- Check if the first file exists, if it does not then I am assuming none of the files exist.
    local result = fs.exists(dataFileNameBlockTypeMine)
    if(result==false)then
        return
    end

    -- Read contents of file into a string
    local contentsMine      = fileMine:read("*all")
    local contentsIgnore    = fileIgnore:read("*all")
    local contentsPass      = filePass:read("*all")
    local contentsSecure    = fileSecure:read("*all")


    -- Close file
    fileMine:close()
    fileIgnore:close()
    filePass:close()
    fileSecure:close()

    -- Create new table and add elements from string
    blockTypeMine = {}
    for element in string.gmatch(contentsMine, "[^,]+") do
        table.insert(blockTypeMine, element)
    end

    -- Create new table and add elements from string
    blockTypeIgnore = {}
    for element in string.gmatch(contentsIgnore, "[^,]+") do
        table.insert(blockTypeIgnore, element)
    end

    -- Create new table and add elements from string
    blockTypePass = {}
    for element in string.gmatch(contentsPass, "[^,]+") do
        table.insert(blockTypePass, element)
    end

    -- Create new table and add elements from string
    blockTypeSecure = {}
    for element in string.gmatch(contentsSecure, "[^,]+") do
        table.insert(blockTypeSecure, element)
    end
end

function blocks.createInitialData()

    blockTypeMine   = { "extractinator:silt","minecraft:cobbled_deepslate","minecraft:cobblestone",
                        "minecraft:deepslate","minecraft:dirt","minecraft:grass_block","minecraft:sand",
                        "minecraft:sand","minecraft:stone","minecraft:torch","minecraft:tuff","minecraft:wall_torch",
                        "tconstruct:sky_slime_dirt","tconstruct:sky_slime_dirt","tconstruct:sky_vanilla_slime_grass",
                        "tconstruct:sky_slime_leaves","minecraft:kelp_plant","tconstruct:earth_slime_leaves",
                        "tconstruct:greenheart_log","tconstruct:earth_sky_slime_grass","tconstruct:earth_congealed_slime",
                        "tconstruct:sky_slime_vine","tconstruct:earth_slime_dirt","tconstruct:sky_earth_slime_grass",
                        "tconstruct:sky_congealed_slime","tconstruct:skyroot_log","ad_astra:moon_sand",
                        "ad_astra:moon_cobblestone","minecraft:basalt"}

    blockTypeIgnore = { "minecraft:lava","minecraft:water" }

    blockTypePass   = {"minecraft:deepslate_iron_ore"}

    blockTypeSecure = {"create:scoria"}
end

return blocks
