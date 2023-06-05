util      = require("lib.util")

-- Create an empty grid table
local grid = {}

-- Function to set the value at given coordinates (x, y, z)
local function setGridValue(x, y, z, value)
    if not grid[x] then
        grid[x] = {}
    end
    if not grid[x][y] then
        grid[x][y] = {}
    end
    grid[x][y][z] = value
end

-- Function to get the value at given coordinates (x, y, z)
local function getGridValue(x, y, z)
    if not grid[x] or not grid[x][y] then
        return nil
    end
    return grid[x][y][z]
end

-- Set value at coordinates (2, 3, 4)
setGridValue(2, 3, 4, "A")
setGridValue(2, 3, 7, "B")

-- Get value at coordinates (2, 3, 4)
local value = getGridValue(2, 3, 4)
print(value) -- Output: 42
print(getGridValue(2,3,7))
print(getGridValue(2,3,8))

print(util.any2String(grid))