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

function blocks.inspectDig(direction,dig)
    --util.outputVariable(0,"In inspectDig","")
    --util.outputVariable(0,"direction",direction)
    --util.outputVariable(0,"dig",dig)

    local result
    local inspectData
    local blockAction

    if(direction=="forward")then
        result, inspectData = turtle.inspect()
    elseif(direction=="up")then
        result, inspectData = turtle.inspectUp()
    elseif(direction=="down")then
        result, inspectData = turtle.inspectDown()
    else
        util.outputVariable(2,"Error in move.inspectDig, on turtle.inspect")
        util.outputVariable(2,"Called with wrong direction=",direction)
        error()
    end
    --util.outputVariable(0,"result",result)

    if(result==false) then
        return true
    elseif (dig==true) then
        blockAction = blocks.inspectedBlokMatchCanDig(inspectData.name)
        if(blockAction=="mine") then
            if(direction=="forward")then
                result = turtle.dig()
                result = turtle.detect()
                while(result) do
                    result = turtle.dig()
                    result = turtle.detect()
                end
                result = true
            elseif(direction=="up")then
                result = turtle.digUp()
                result = turtle.detectUp()
                while(result) do
                    result = turtle.digUp()
                    result = turtle.detectUp()
                end
                result = true
            elseif(direction=="down")then
                result = turtle.digDown()
                result = turtle.detectDown()
                while(result) do
                    result = turtle.digDown()
                    result = turtle.detectDown()
                end
                result = true
            else
                util.outputVariable(2,"Error in move.inspectDig, on turtle.inspect")
                util.outputVariable(2,"Called with wrong direction=",direction)
                error()
            end
            return result
        elseif(blockAction=="ignore") then
            return true
        elseif(blockAction=="pass") then
            return false
        end
        return true
    elseif (dig==false) then
        blockAction = blocks.inspectedBlokMatchCanDig(inspectData.name)

        blockAction = blocks.inspectedBlokMatchCanDig(inspectData.name)
        if(blockAction=="mine") then
            return false
        elseif(blockAction=="ignore") then
            return true
        elseif(blockAction=="pass") then
            return false
        end

    end
    util.outputVariable(2,"Error in move.inspectDig, we should newer be here in the code.")
    error()
end

function blocks.inspectedBlokMatchCanDig(blockName)

    for i, value in ipairs(blocksTurtleCanMine) do
        if blockName == value then
            return "mine"
        end
    end
    for i, value in ipairs(blocksTurtleCanIgnore) do
        if blockName == value then
            return "ignore"
        end
    end
    for i, value in ipairs(blocksTurtleCantMine) do
        if blockName == value then
            return "pass"
        end
    end

    status.setJobStatus("Waiting for user")
    status.updateStatus()
    status.writeStatusFile()

    print("I found this block ("..blockName..") what should i do?")
    print("m=mine i=ignore p=pass a=abort")
    local event, key, is_held = os.pullEvent("key")
    util.outputVariable(0,"KeyPressed was ",keys.getName(key))
    if(keys.getName(key)=="m")then
        util.outputVariable(0,"Adding to canmine list")
        table.insert(blocksTurtleCanMine,blockName)
        blocks.saveData()
        status.setJobStatus("Working")
        status.updateStatus()
        status.writeStatusFile()
            return "mine"
    elseif(keys.getName(key)=="i")then
        util.outputVariable(0,"Adding to ignore list")
        table.insert(blocksTurtleCanIgnore,blockName)
        blocks.saveData()
        status.setJobStatus("Working")
        status.updateStatus()
        status.writeStatusFile()
            return "ignore"
    elseif(keys.getName(key)=="p")then
        util.outputVariable(0,"Adding to cantmine list")
        table.insert(blocksTurtleCantMine,blockName)
        blocks.saveData()
        status.setJobStatus("Working")
        status.updateStatus()
        status.writeStatusFile()
            return "pass"
    elseif(keys.getName(key)=="a")then
        move.moveToHomePosition(false)
        inventory.emptyStorageSlots()
        move.turnToHeading(0)
        status.setJobStatus("Error..")
        status.updateStatus()
        status.writeStatusFile()
            error()
    end

    status.setJobStatus("Working")
    status.updateStatus()
    status.writeStatusFile()

    return "pass"
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
