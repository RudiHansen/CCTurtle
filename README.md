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
Make system for giving Turtles jobs from the computer.
So the turtle should be able to ask the computer for jobs.
Also the computer should be able to handle more than one turtle, and split a big dig job into smaller jobs for more than one Turtle.

Also have a pocket computer that can be used for getting status of a turtle, and send jobs for Turtles to perform.
One of the purposes of this is to be able to get a Turtle unstuck.

Perhaps something about if last move was a bypass, the priority should change.
Also might need to change priority to also contain + and - (x+,x-,z+,z-,...)
Quite clearly I need to work on the bypass system, since the tmp fix is not working, and sometimes makes the turtle run off.
Right now what I did with changing axisPriorityIdx on bypass in move.moveToPos works better than before, so lets see where it gets us.

Implement a system for synchronizing block data files, so all turtles has the same data files.