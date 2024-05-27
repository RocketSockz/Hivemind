-- Configuration
local quarry_start_distance = 3
local quarry_size = 3
local quarry_depth = 3

-- We import the module to get the warnings out of the way

local function refuelIfNeeded()
    if turtle.getFuelLevel() < (quarry_start_distance + quarry_size * quarry_size * 3) then
        print("Not enough fuel. Please refuel the turtle.")
        return false
    end
    return true
end


---
--- Looks to see if there is a block, if there is it mines it - then moves forward. 
--- If no block is present, it just moves forward.
---
--- @return void
---
local function mineOrMoveForward()
    while turtle.detect() do
        turtle.dig()
    end
    turtle.forward()
end

---
--- Looks to see if there is a block, if there is it mines it - then moves down. 
--- If no block is present, it just moves down.
---
--- @return void
---
local function mineOrMoveDown()
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
        mineOrMoveForward()
    end
end

local function mineLayer()
    -- We treat 0 as right, and 1 as left
    local direction = 0
    for x = 0, quarry_size - 1 do
        for y = 0, quarry_size - 1 do
            if y < quarry_size - 1 then
                mineOrMoveForward()
            end
            -- mineOrMoveForward()
        end
        if x < quarry_size - 1 then
            if direction == 0 then
                turtle.turnRight()
                mineOrMoveForward()
                turtle.turnRight()
                direction = 1
            else
                turtle.turnLeft()
                mineOrMoveForward()
                turtle.turnLeft()
                direction = 0
            end
        -- We do the inverse to keep the mining going
        elseif direction == 0 then
            turtle.turnLeft()
            turtle.turnLeft()
        elseif direction == 1 then
            turtle.turnRight()
            turtle.turnRight()
        end
    end
end

local function mineQuarry()
    for z = 1, quarry_depth do
        mineLayer()
        if z < quarry_depth then
            mineOrMoveDown()
        end
    end
end

local function returnToSurface()
    for i = 1, quarry_depth do
        moveUp()
    end
end

local function returnToStart()
    for i = 1, quarry_size - 1 do
        turtle.forward()
    end
    turtle.turnRight()
    for i = 1, quarry_size - 1 do
        turtle.forward()
    end
    turtle.turnLeft()
    for i = 1, quarry_start_distance do
        turtle.forward()
    end
    turtle.turnRight()
    turtle.turnRight()
end

local function main()
    if not refuelIfNeeded() then
        return
    end

    moveToQuarryStart()
    mineOrMoveDown()
    mineQuarry()
    returnToSurface()
    returnToStart()
    print("Quarrying complete. Returned to the starting position.")
end

main()
