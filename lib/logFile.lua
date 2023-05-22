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

function logFile.logWrite(message)
    log.writeLine(message)
    log.flush()
end

function logFile.logFileClose()
    log.close()
end

return logFile