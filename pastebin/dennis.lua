-- Configuration
local quarry_start_distance = 3
local quarry_size = 3
local quarry_depth = 1
local startingX, startingY, startingZ

-- GPS Stuff
local function trackStartingCoordinates()
  startingX, startingY, startingZ = gps.locate()
  print("Set starting coordinates to: ", startingX, startingY, startingZ)
  if not startingX then
    print("GPS signal not found! Make sure you are in range of GPS satellites.")
  end
end

local function refuelIfNeeded()
  if turtle.getFuelLevel() < (quarry_start_distance + (quarry_size * quarry_size * quarry_depth)) then
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
function MineOrMoveForward()
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

local function mineOrMoveUp()
  while turtle.detectUp() do
    turtle.digUp()
  end
  turtle.up()
end

local function moveUp()
  while not turtle.up() do
    turtle.digUp()
  end
end

local function moveToQuarryStart()
  for i = 1, quarry_start_distance do
    MineOrMoveForward()
  end
end

local function mineLayer()
  -- We treat 0 as right, and 1 as left
  local direction = 0
  for x = 0, quarry_size - 1 do
    for y = 0, quarry_size - 1 do
      if IsInventoryFull() then
        print("Inventory is full. Returning to the surface.")
        return false;
      end
      if y < quarry_size - 1 then
        MineOrMoveForward()
      end
      -- MineOrMoveForward()
    end
    if x < quarry_size - 1 then
      if direction == 0 then
        turtle.turnRight()
        MineOrMoveForward()
        turtle.turnRight()
        direction = 1
      else
        turtle.turnLeft()
        MineOrMoveForward()
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
  return true;
end

function IsInventoryFull()
  for i = 1, 16 do
    local slot = turtle.getItemDetail(i)
    if not slot then
      return false
    end
  end
  return true
end

local function mineQuarry()
  for z = 1, quarry_depth do
    local mineNoWorky = mineLayer()
    if not mineNoWorky then
      ReturnToStart()
    end
    if z < quarry_depth then
      mineOrMoveDown()
    end
  end
end

function GetCurrentPosition()
  local x, y, z = gps.locate()
  if x and y and z then
    return x, y, z
  else
    error("Unable to determine position, ensure the GPS network is setup correctly.")
  end
end

-- local function returnToStart()
--   for i = 1, quarry_size - 1 do
--     turtle.forward()
--   end
--   turtle.turnRight()
--   for i = 1, quarry_size - 1 do
--     turtle.forward()
--   end
--   turtle.turnLeft()
--   for i = 1, quarry_start_distance do
--     turtle.forward()
--   end
--   turtle.turnRight()
--   turtle.turnRight()
-- end

-- Function to return to starting coordinates
function ReturnToStart()
  if not startingX then
    print("Starting coordinates not set. Cannot return to start.")
    return
  end

  print("Current coordinates: ", GetCurrentPosition())
  MoveTo(startingX, startingY, startingZ)
  -- We want the turtle to face west when it returns to the starting position
  turtle.turnTo(3)
  print("Returned to starting coordinates.")
end

-- Calculate the differences
local function calculateDeltas(targetX, targetY, targetZ)
  local currentX, currentY, currentZ = GetCurrentPosition()
  local deltaX = targetX - currentX
  local deltaY = targetY - currentY
  local deltaZ = targetZ - currentZ
  print("Current Deltas", deltaX, deltaY, deltaZ)
  return deltaX, deltaY, deltaZ
end

function MoveTo(targetX, targetY, targetZ)
  print("Moving to target coordinates: ", targetX, targetY, targetZ)
  while true do
    -- Call the function to calculate the deltas
    local deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ)
    local turtleDirectionFacing = nil
    print("Initial Delta", deltaX, deltaY, deltaZ)
    -- Move in the Y direction first (up or down)
    while deltaY ~= 0 do
      print("Moving towards Y")
      if deltaY > 0 then
        mineOrMoveUp()
        deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ)
      elseif deltaY < 0 then
        mineOrMoveDown()
        deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ)
      end
    end

    -- Move in the Z direction last (north or south)
    while deltaZ ~= 0 do
      print("Moving towards Z")
      local directionToFace = nil
      if deltaZ > 0 then
        directionToFace = "south"
      elseif deltaZ < 0 then
        directionToFace = "north"
      end

      if directionToFace then
        turtleDirectionFacing  = FaceDirection(turtleDirectionFacing, directionToFace)
        deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ)
        if deltaZ == 0 then
          break
        end
        MineOrMoveForward()
        deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ)
      end
    end

    while deltaX ~= 0 do
      print("Moving towards X")
      local directionToFace = nil
      if deltaX > 0 then
        directionToFace = "east"
      elseif deltaX < 0 then
        directionToFace = "west"
      end

      if directionToFace then
        turtleDirectionFacing  = FaceDirection(turtleDirectionFacing, directionToFace)
        deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ)
        if deltaX == 0 then
          break
        end
        MineOrMoveForward()
        deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ)
      end
    end

    deltaX, deltaY, deltaZ = calculateDeltas(targetX, targetY, targetZ) -- Check if we've reached the target coordinates
    if deltaX == 0 and deltaY == 0 and deltaZ == 0 then
      print("Reached target coordinates: ", targetX, targetY, targetZ)
      break
    end
  end
end


function FaceDirection(currentDirection, targetDirection)
  if currentDirection == targetDirection then
    return currentDirection
  else 
    return turtle.turnTo(targetDirection, currentDirection)
  end
end

-- Function to turn the turtle to a specific cardinal direction
function turtle.turnTo(direction, cachedDirection)
  local currentDirection
  if cachedDirection == direction then 
    return cachedDirection
  elseif cachedDirection then
    print("Cached direction set to current: ", cachedDirection) 
    currentDirection = cachedDirection
  else 
    print("Locating current direction")
    local currentX, _, currentZ = gps.locate()
    MineOrMoveForward()
    local newX, _, newZ = gps.locate()
  
    local dx = newX - currentX
    local dz = newZ - currentZ
  
    print("dx : ", dx, "\ndz : ", dz)
    if dx == 1 then
      currentDirection = "east"
    elseif dx == -1 then
      currentDirection = "west"
    elseif dz == 1 then
      currentDirection = "south"
    elseif dz == -1 then
      currentDirection = "north"
    end
    print("Current direction set: ", currentDirection)
  end

  -- WEST / NORTH 
 -- NORTH / SOUTH 
-- SOUTH / NORTH \
-- SOUTH / WEST
-- EAST / NORTH 

  local directions = { "north", "east", "south", "west" }
  local currentIndex = nil
  for i, dir in ipairs(directions) do
    if dir == currentDirection then
      currentIndex = i
    end
  end

  local targetIndex = nil
  for i, dir in ipairs(directions) do
    if dir == direction then
      targetIndex = i
    end
  end

  print("Target Direction: ", direction, "Current Direction: ", currentDirection)
  local difference = targetIndex - currentIndex
  print("Difference: ", difference)
  if difference == 1 or difference == -3 then 
    turtle.turnRight()
    sleep(2)
  end

  if math.abs(difference) == 2 then 
    turtle.turnRight()
    turtle.turnRight()
    sleep(2)
  end

  if difference == -1 or difference == 3 then
    turtle.turnLeft()
    sleep(2)
  end

  return currentDirection
end

local function main()
  if not refuelIfNeeded() then
    return
  end

  if IsInventoryFull() then
    print("Inventory is full. Please empty the turtle.")
    return
  end

  trackStartingCoordinates()
  moveToQuarryStart()
  mineOrMoveDown()
  mineQuarry()
  ReturnToStart()
  print("Quarrying complete. Returned to the starting position.")
end

main()
