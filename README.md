# CCTurtle
Computercraft Turtle, used in minecraft for controlling a Turtle.

# How to setup a new turtle.
Give the turtle a label with:
label set Miner1    (Miner1 is the label the turtle should have)

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
Work on block avoidance.
Inside move.moveToPos and move.traverseArea the BYPASS section needs to work better.
And I may have to look at this before I can start digging in my new world, since right now when working on jobs the turtle can't get home from refueling, look at the logfile line 1133

So this is the data:
Call to move.byPassBlock
nextMove E
areaStart { ["y"] = -57,["x"] = 1,["f"] = N,["z"] = 102,} 
areaEnd { ["y"] = -47,["x"] = -54,["f"] = N,["z"] = 0,} 
axisPriority { [1] = x,[2] = y,[3] = z,} 
dig true

And my expectation is that the turtle has to go South one step, then East two steps, and back North, and should then be able to continue.
Turtle pos was x -40 z 101 y -47


