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
Expand blockActions from the current mine/ignore/pass to 

mine
ignore
pass
secure

blocksTurtleCanMine         blockTypeMine
blocksTurtleCanIgnore       blockTypeIgnore
blocksTurtleCantMine        blockTypePass
                            blockTypeSecure