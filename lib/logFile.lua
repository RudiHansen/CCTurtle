 --[[
    logFile Function Library   
    Developed by Rudi Hansen

    TODO
    
    CHANGE LOG
    2023-05-22 : Initial Version
]]

local logFile = {}

local logFileName = "logFile.txt"

function logFile.logFileOpen()
    log = fs.open(logFileName, "w")
end

function logFile.logWrite(message,var1,var2,var3,var4)
    if(var1 ~= nil)then
        message = message .. " " .. util.any2String(var1)
    end
    if(var2 ~= nil)then
        message = message .. " " .. util.any2String(var2)
    end
    if(var3 ~= nil)then
        message = message .. " " .. util.any2String(var3)
    end
    if(var4 ~= nil)then
        message = message .. " " .. util.any2String(var4)
    end

    log.writeLine(message)
    log.flush()
end

function logFile.logFileClose()
    log.close()
end

return logFile