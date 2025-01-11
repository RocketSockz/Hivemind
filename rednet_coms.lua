MODE_FILE = "rednet_mode.txt"
SERVER_ID = 1000 -- Logical ID for the server in rednet communication

-- Function to find and open the modem
local function openModem()
    -- Attempt to find a normal modem first
    peripheral.find("modem", rednet.open)
    print(rednet.isOpen())
    if not rednet.isOpen() then
        print("Rednet failed to open.")
        return false
    end 
    print("Rednet opened.")
    return true
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
        local senderId, message = rednet.receive() -- Receive any message
        if not senderId then
            print("No message received.")
        else
            print("Received message from ID " .. senderId .. ": " .. message)

            if message == "exit" then
                print("Exiting server.")
                rednet.close()
                break
            end

            -- Send a response back to the sender
            rednet.send(senderId, "Message received: " .. message)
        end
    end
end

function SetupRednetServer()
    if not openModem() then return end
    print("Rednet server started. Listening for messages...")

    while true do
        local senderId, message = rednet.receive() -- Receive any message
        if not senderId then
            print("No message received.")
        else
            print("Received message from ID " .. senderId .. ": " .. message)

            if message == "exit" then
                print("Exiting server.")
                rednet.close()
                break
            end

            -- Send a response back to the sender
            rednet.send(senderId, "Message received: " .. message)
        end
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
        print("Message sent: " , input)

        -- Wait for a response (timeout after 5 seconds)
        local senderId, response = rednet.receive(nil, 5)
        if response then
            print("Received response from ID " , senderId , ": " , response)
        else
            print("No response received.")
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
