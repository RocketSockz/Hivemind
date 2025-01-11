Turtle = {} 
Turtle.__index = Turtle

-- This is the constructor for the Turtle class
function Turtle.new(id)
    local instance = setmetatable({}, Turtle)
    -- First we figure out the things that we want to persist.
    instance.id = id
    instance.name = GetRandomName()

    instance.position = {x = 0, y = 0, z = 0}  

    return instance
end

function Turtle:setLabel() 
    -- Set the computer label to the turtle's name
    ---@diagnostic disable-next-line: undefined-field
    os.setComputerLabel(self.name)
end

function Turtle:mineOrMoveForward()
  while turtle.detect() do
      turtle.dig()
  end
  turtle.forward()
end

function Turtle:mineOrMoveDown()
  while turtle.detectDown() do
      turtle.digDown()
  end
  turtle.down()
end

function Turtle:mineOrMoveUp()
  while turtle.detectUp() do
      turtle.digUp()
  end
  turtle.up()
end

function GetRandomName()
  return TurtleNames[math.random(#TurtleNames)]
end

TurtleNames = {
  "Dennis", "Greg", "Alan", "Bruce", "Carl", "Derek", "Eddie", "Frank", "Hank", "Ivan",
  "Jack", "Ken", "Lenny", "Marty", "Ned", "Oscar", "Paul", "Quinn", "Ralph", "Steve",
  "Tony", "Victor", "Walter", "Xavier", "Yancy", "Zane", "Andy", "Benny", "Charlie", "Doug",
  "Ernie", "Felix", "Gus", "Harold", "Irving", "Jerry", "Keith", "Larry", "Miles", "Norman",
  "Oliver", "Peter", "Quincy", "Roger", "Stan", "Theo", "Ulysses", "Vinnie", "Wally", "Xander",
  "Yale", "Zack", "Archie", "Bernie", "Cedric", "Don", "Earl", "Floyd", "Gordon", "Herb",
  "Isaac", "Joey", "Karl", "Leon", "Milton", "Neville", "Otto", "Percy", "Quentin", "Reggie",
  "Sammy", "Timmy", "Urban", "Vern", "Will", "Xenon", "York", "Zeb", "Arthur", "Bart",
  "Cecil", "Dennis Jr.", "Eli", "Fred", "George", "Harry", "Iggy", "Jonah", "Kirk", "Louis",
  "Morgan", "Nate", "Oscar Jr.", "Phil", "Ronnie", "Saul", "Todd", "Ulric", "Vince", "Wyatt"
}