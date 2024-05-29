-- Configuration
local quarry_start_distance = 3
local quarry_size = 3
local quarry_depth = 1
local startingX, startingY, startingZ

-- GPS Stuff
local function trackStartingCoordinates()
 startingX, startingY, startingZ = gps.locate()
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
   if IsInventoryFull() then
    print("Inventory is full. Returning to the surface.")
    return false;
   end
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

function ReturnToSurface(customDepth)
 for i = 1, (customDepth or quarry_depth) do
  moveUp()
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

 MoveTo(startingX, startingY, startingZ)
 turtle.turnRight()
 turtle.turnRight()
 print("Returned to starting coordinates.")
end

function MoveTo(targetX, targetY, targetZ)
 print("Moving to coordinates: ", targetX, targetY, targetZ)
 print(gps.locate())
 local currentX, currentY, currentZ = gps.locate()
 print("Current coordinates: ", currentX, currentY, currentZ)
 if not currentX then
  print("GPS signal lost! Cannot move to target.")
  return
 end

 print("Matching y coordinate", targetY, currentY)
 -- Move vertically to the target y coordinate
 while currentY < targetY do
  if turtle.detectUp() then turtle.digUp() end
  turtle.up()
  currentX, currentY, currentZ = gps.locate()
  print("Moved up to: ", currentY, "Target: ", targetY)
 end
 while currentY > targetY do
  if turtle.detectDown() then turtle.digDown() end
  turtle.down()
  currentX, currentY, currentZ = gps.locate()
  print("Moved down to: ", currentY, "Target: ", targetY)
 end

 print("Matching x coordinate", targetY, currentY)
 -- Move horizontally to the target x coordinate
 if currentX < targetX then
  turtle.turnTo(1)   -- East
  while currentX < targetX do
   if turtle.detect() then turtle.dig() end
   turtle.forward()
   currentX, currentY, currentZ = 0, 0, 0 
   currentX, currentY, currentZ = gps.locate()
   print("Moved X across to: ", currentX, "Target: ", targetX)
  end
 elseif currentX > targetX then
  turtle.turnTo(3)   -- West
  while currentX > targetX do
   if turtle.detect() then turtle.dig() end
   turtle.forward()
   currentX, currentY, currentZ = gps.locate()
   print("Moved X across to: ", currentX, "Target: ", targetX)
  end
 end

 -- Move horizontally to the target z coordinate
 print("Matching z coordinate", targetZ, currentZ)
 if currentZ < targetZ then
  turtle.turnTo(2)   -- South
  while currentZ < targetZ do
   if turtle.detect() then turtle.dig() end
   turtle.forward()
   currentX, currentY, currentZ = gps.locate()
   print("Moved z across to: ", currentZ, "Target: ", targetZ)
  end
 elseif currentZ > targetZ then
  turtle.turnTo(0)   -- North
  while currentZ > targetZ do
   if turtle.detect() then turtle.dig() end
   turtle.forward()
   currentX, currentY, currentZ = gps.locate()
   print("Moved z across to: ", currentZ, "Target: ", targetZ)
  end
 end
end

function turtle.turnTo(direction)
 local currentHeading = select(2, gps.locate())
 local turnDirection = (direction - currentHeading + 4) % 4
 if turnDirection == 1 then
  turtle.turnRight()
 elseif turnDirection == 2 then
  turtle.turnRight()
  turtle.turnRight()
 elseif turnDirection == 3 then
  turtle.turnLeft()
 end
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
