MODE_FILE = "rednet_mode.txt"
SERVER_ID = 1000 -- ID for the server in rednet communication

-- Function to find and open the modem
local function openModem()
  -- Attempt to find a normal modem first
  local modemSide = peripheral.find("modem", rednet.open)
  print("Peripherals: ",  dump(peripheral.getNames()))
  if modemSide then
      print("Standard modem detected on side: " .. modemSide)
      return true
  end

  -- If no normal modem is found, attempt to find an ender modem
  modemSide = peripheral.find("ender_modem", rednet.open)

  if modemSide then
      print("Ender modem detected on side: " .. modemSide)
      return true
  end

  -- No modem found
  print("No modem found. Please attach a modem or ender modem and try again.")
  return false
end

function dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end


-- Function to read the mode from a file
local function readModeFromFile()
    if fs.exists(MODE_FILE) then
        local file = fs.open(MODE_FILE, "r")
        local mode = file.readLine()
        file.close()
        return mode
    end
    return nil
end

-- Function to write the mode to a file
local function writeModeToFile(mode)
    local file = fs.open(MODE_FILE, "w")
    file.writeLine(mode)
    file.close()
end

-- Server function to listen for incoming messages
function SetupRednetServer()
    if not openModem() then return end
    print("Rednet server started. Listening for messages...")

    while true do
        local senderId, message = rednet.receive()
        print("Received message from ID " .. senderId .. ": " .. message)

        if message == "exit" then
            print("Exiting server.")
            rednet.close()
            break
        end

        -- Send a response back
        rednet.send(senderId, "Message received: " .. message)
    end
end

-- Client function to send messages to the server
function RednetClient()
    if not openModem() then return end

    while true do
        print("Type a message to send to the server (or type 'exit' to quit):")
        local input = read()

        if input == "exit" then
            print("Closing client.")
            rednet.close()
            break
        end

        -- Send the message to the server
        rednet.send(SERVER_ID, input)
        print("Message sent: " .. input)

        -- Wait for a response
        local senderId, response = rednet.receive()
        print("Received response from ID " .. senderId .. ": " .. response)
    end
end

-- Main function to determine mode
function Main()
    -- Check if mode is already set
    local mode = readModeFromFile()

    if not mode then
        print("Choose mode: [1] Server, [2] Client")
        mode = read()
        if mode == "1" then
            writeModeToFile("1")
            SetupRednetServer()
        elseif mode == "2" then
            writeModeToFile("2")
            RednetClient()
        else
            print("Invalid choice. Exiting.")
        end
    else
        if mode == "1" then
            print("Starting in Server mode (saved).")
            SetupRednetServer()
        elseif mode == "2" then
            print("Starting in Client mode (saved).")
            RednetClient()
        else
            print("Invalid mode in file. Exiting.")
        end
    end
end

-- Run the main function
Main()
