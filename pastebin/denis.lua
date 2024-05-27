-- Configuration
local quarry_start_distance = 5
local quarry_size = 20

local function refuelIfNeeded()
    if turtle.getFuelLevel() < (quarry_start_distance + quarry_size * quarry_size * 3) then
        print("Not enough fuel. Please refuel the turtle.")
        return false
    end
    return true
end

local function mineForward()
    while turtle.detect() do
        turtle.dig()
    end
    turtle.forward()
end

local function mineDown()
    while turtle.detectDown() do
        turtle.digDown()
    end
    turtle.down()
end

local function moveUp()
    while not turtle.up() do
        turtle.digUp()
    end
end

local function moveToQuarryStart()
    for i = 1, quarry_start_distance do
        mineForward()
    end
end

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

local function returnToSurface()
    for i = 1, quarry_size do
        moveUp()
    end
end

local function returnToStart()
    for i = 1, quarry_start_distance do
        turtle.forward()
    end
end

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

main()
