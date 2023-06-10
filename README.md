# CCTurtle
Computercraft Turtle, used in minecraft for controlling a Turtle.

# Information a turtle should know.
Its Label
Its Position
Its Fuel level
Its Inventory level

# Plan
Make setup script for turtle to set Turtle label, and get Turtle position and save position to .dat file
Report status into to Computer

Make move function, for now thinking that its one function called with direction to move, and the method then updates turtles position and reports it to main computer.

# Next Step
Perhaps something about if last move was a bypass, the priority should change.
Also might need to change priority to also contain + and - (x+,x-,z+,z-,...)

Need to add a way to stop a turtle from working.
Need to add refuel and empty storage functionality to a turtle while it is working.

All these checks for fuel, storage and stop command, has to be done in one method
There might have to be some sort of status value set so one does not run when the others are running, had a problem with it in the old system
Then I need to find the right place to run this check, might be in function move.move might not?

Would also like turtle to report fuel level to computer, to display in status

