 --[[
    turtleJobs Function Library
    Developed by Rudi Hansen, Start 2023-06-13
]]

local turtleJobs = {}

local turtleJobsData        = {Id=0,TurtleName="",Status="",JobType="",x1=0,z1=0,y1=0,f1="",x2=0,z2=0,y2=0,f2=""}

function turtleJobs.Msg2TurtleJob(message)
    fields = {}
    for field in string.gmatch(message, "[^,]+") do
        table.insert(fields, field)
    end
    turtleJobsData              = {}
    turtleJobsData.Id           = fields[1]
    turtleJobsData.TurtleName   = fields[2]
    turtleJobsData.Status       = fields[3]
    turtleJobsData.JobType      = fields[4]
    turtleJobsData.x1           = fields[5]
    turtleJobsData.z1           = fields[6]
    turtleJobsData.y1           = fields[7]
    turtleJobsData.f1           = fields[8]
    turtleJobsData.x2           = fields[9]
    turtleJobsData.z2           = fields[10]
    turtleJobsData.y2           = fields[11]
    turtleJobsData.f2           = fields[12]
    turtleJobsData.axisPriority = fields[13]

    return turtleJobsData
end

return turtleJobs