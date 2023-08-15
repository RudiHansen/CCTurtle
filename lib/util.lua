 --[[
    util Function Library   
    Developed by Rudi Hansen, Start 2023-03-18

    TODO

    CHANGE LOG
    2023-05-22 : Initial Version.
]]

local util = {}

function util.waitForUserKey()
    print("And press a key for next step")
    os.pullEvent("key")
end

-- TODO: Find all places in existing code where this method can be used, there must be some.
function util.SendStatusAndWaitForUserKey(status,message)
    local saveStatus = modem.getStatus()
    modem.sendStatus(status)
    print(message)
    logFile.logWrite(status,message)
    util.waitForUserKey()
    modem.sendStatus(saveStatus)
end

function util.incNumberMax(number,max)
    number = number + 1
    if(number==max)then
        number = 1
    end
    return number
end

function util.incNumber(number,incValue)
    incValue = util.setDefaultValueIfEmpty(incValue,1)
    number = number + incValue
    return number
end

function util.any2String(anyType)
    if type(anyType) == 'table' then
       local s = '{ '
       for k,v in pairs(anyType) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. util.any2String(v) .. ','
       end
       return s .. '} '
    else
       return tostring(anyType)
    end
end

function util.stringLen(txt,length)
    if(length>100)then
        print("ERROR IN util.stringLen, length more than 100")
        error()
    end
    txt = string.format( "%-100s", txt )
    txt = string.sub(txt,1,length)
    return txt
end

function util.getIndexOfValue(dataTable,valueToFind)
    for k,v in pairs(dataTable) do
        if(v==valueToFind)then
            return k
        end
    end
    logFile.logWrite("ERROR in util.getIndexOfValue",dataTable,valueToFind)
    modem.sendStatus("ERROR!")
    location.writeLocationToFile()
    error()
end

function util.setDefaultValueIfEmpty(value,default)
    if(value == nil or value == "") then
        return default
    else
        return value
    end
end

-- TODO: Do I really need this method? Is it used anywhere?
function util.addToPositionAxis(position,axis,value)
    if(axis=="x") then
        position.x          = position.x + value
    elseif(axis=="y") then
        position.y          = position.y + value
    elseif(axis=="z") then
        position.z          = position.z + value
    end
    return position
end

-- Function to check if a value is within a range (even with wrap-around)
function util.isValueInRange(value, rangeStart, rangeEnd)
    value = tonumber(value)
    rangeStart = tonumber(rangeStart)
    rangeEnd = tonumber(rangeEnd)
    
    --logFile.logWrite("type(value)",type(value))
    --logFile.logWrite("type(rangeStart)",type(rangeStart))
    --logFile.logWrite("type(rangeEnd)",type(rangeEnd))

    --logFile.logWrite("util.isValueInRange",value,rangeStart,rangeEnd)
    --logFile.logWrite("rangeStart <= rangeEnd",rangeStart <= rangeEnd)

    if rangeStart <= rangeEnd then
        --logFile.logWrite("value >= rangeStart",value >= rangeStart)
        --logFile.logWrite("value <= rangeEnd",value <= rangeEnd)
        return value >= rangeStart and value <= rangeEnd
    else
        --logFile.logWrite("value <= rangeStart",value <= rangeStart)
        --logFile.logWrite("value >= rangeEnd",value >= rangeEnd)
        return value <= rangeStart and value >= rangeEnd
    end
end


return util