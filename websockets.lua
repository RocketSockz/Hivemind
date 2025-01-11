URL = "wss://localhost:2048"
MODE_FILE = "websocket_mode.txt"

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

-- Server function to listen for incoming WebSocket messages
function SetupWebsocketServer()
    local websocket, err = http.websocket(URL)
    -- Crash out if we failed.
    if not websocket then
        print("Failed to connect to WebSocket: " .. (err or "Unknown error"))
        return
    end

    print("Connected to WebSocket server at " .. URL)

    while true do
        local event, r_url, message = os.pullEvent("websocket_message")
        if r_url == URL then
            if message == "exit" then
                print("Exiting WebSocket listener.")
                websocket.close()
                break
            end
            print("Received message from " .. r_url .. ": " .. message)
        end
    end
end

-- Client function to send messages to the WebSocket server
function WebSocketClient()
    local websocket, err = http.websocket(URL)
    -- Crash out if we failed.
    if not websocket then
        print("Failed to connect to WebSocket: " .. (err or "Unknown error"))
        return
    end

    print("Connected to WebSocket server at " .. URL)

    while true do
        print("Type a message to send (or type 'exit' to quit):")
        local input = read()

        if input == "exit" then
            print("Closing connection.")
            websocket.close()
            break
        end

        -- Send the message
        local success, sendErr = websocket.send(input)
        if not success then
            print("Failed to send message: " .. (sendErr or "Unknown error"))
        else
            print("Message sent: " .. input)
        end

        -- Check for a response
        ---@diagnostic disable-next-line: undefined-field
        local event, r_url, response = os.pullEvent("websocket_message")
        if r_url == URL then
            print("Received response: " .. response)
        end
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
          SetupWebsocketServer()
      elseif mode == "2" then
          writeModeToFile("2")
          WebSocketClient()
      else
          print("Invalid choice. Exiting.")
      end
  else
      if mode == "1" then
          print("Starting in Server mode (saved).")
          SetupWebsocketServer()
      elseif mode == "2" then
          print("Starting in Client mode (saved).")
          WebSocketClient()
      else
          print("Invalid mode in file. Exiting.")
      end
  end
end

-- Run the main function
Main()
