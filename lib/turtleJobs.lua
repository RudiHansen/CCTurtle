 --[[
    turtleJobs Function Library
    Developed by Rudi Hansen, Start 2023-06-13
]]

local turtleJobs = {}

local turtleJobsData        = {TurtleName="",Status="",JobType="",x1=0,z1=0,y1=0,f1="",x2=0,z2=0,y2=0,f2=""}

function turtleJobs.Msg2TurtleJob(message)
    fields = {}
    for field in string.gmatch(message, "[^,]+") do
        table.insert(fields, field)
    end
    turtleJobsData              = {}
    turtleJobsData.TurtleName   = fields[1]
    turtleJobsData.Status       = fields[2]
    turtleJobsData.JobType      = fields[3]
    turtleJobsData.x1           = fields[4]
    turtleJobsData.z1           = fields[5]
    turtleJobsData.y1           = fields[6]
    turtleJobsData.f1           = fields[7]
    turtleJobsData.x2           = fields[8]
    turtleJobsData.z2           = fields[9]
    turtleJobsData.y2           = fields[10]
    turtleJobsData.f2           = fields[11]
    turtleJobsData.axisPriority = fields[12]

    return turtleJobsData
end

return turtleJobs