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

function util.incNumberMax(number,max)
    number = number + 1
    if(number==max)then
        number = 1
    end
    return number
end

function util.any2String(anyType)
    if type(anyType) == 'table' then
       local s = '{ '
       for k,v in pairs(anyType) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(anyType)
    end
 end


return util