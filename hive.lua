Hive = {} 
Hive.__index = Hive

function Hive:new() 
  local instance = setmetatable({}, Hive)
  instance.turtles = {}
  return instance
end

function Hive:printTurtles()
  for i, turtle in ipairs(self.turtles) do
    print("Turtle " .. turtle.id .. " is named " .. turtle.name)
  end
end

function Hive:spawnTurtle()
  table.insert(self.turtles, turtle)
  print("Turtle " .. turtle.id .. " added to the Hivemind.")
end