-- Configuration
local quarry_start_distance = 5
local quarry_size = 20

-- Ensure the turtle is refueled
local function refuelIfNeeded()
    if turtle.getFuelLevel() < (quarry_start_distance + quarry_size * quarry_size * 3) then
        print("Not enough fuel. Please refuel the turtle.")
        return false
    end
    return true
end

-- Function to mine forward
local function mineForward()
    while turtle.detect() do
        turtle.dig()
    end
    turtle.forward()
end

-- Function to mine down
local function mineDown()
    while turtle.detectDown() do
        turtle.digDown()
    end
    turtle.down()
end

-- Function to move up
local function moveUp()
    while not turtle.up() do
        turtle.digUp()
    end
end

-- Move to the quarry start position
local function moveToQuarryStart()
    for i = 1, quarry_start_distance do
        mineForward()
    end
end

-- Mine a 20x20 quarry
local function mineQuarry()
    for x = 1, quarry_size do
        for y = 1, quarry_size - 1 do
            mineForward()
            if x % 2 == 1 then
                turtle.turnRight()
                mineForward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                mineForward()
                turtle.turnLeft()
            end
        end
        if x < quarry_size then
            mineDown()
            turtle.turnRight()
            turtle.turnRight()
        end
    end
end

-- Return to surface
local function returnToSurface()
    for i = 1, quarry_size do
        moveUp()
    end
end

-- Return to the starting position
local function returnToStart()
    for i = 1, quarry_start_distance do
        turtle.forward()
    end
end

-- Main function
local function main()
    if not refuelIfNeeded() then
        return
    end

    moveToQuarryStart()
    mineQuarry()
    returnToSurface()
    returnToStart()
    print("Quarrying complete. Returned to the starting position.")
end

-- Run the main function
main()
