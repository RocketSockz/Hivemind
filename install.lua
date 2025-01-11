local baseURL = "https://raw.githubusercontent.com/RocketSockz/Hivemind/main/"

local files = {
    "scripts/dennis.lua",
    "websockets.lua",
    "turtle.lua",
    "hive.lua",
    "rednet_coms.lua",
}

for _, file in ipairs(files) do
    local url = baseURL .. file .. "?nocache=" .. os.epoch("utc")
    local path = file

    -- Ensure the directory exists
    local dir = fs.getDir(path)
    if dir and not fs.exists(dir) then
        fs.makeDir(dir)
    end

    -- Delete the existing file if it exists
    if fs.exists(path) then
        print("File already exists: " .. path)
        print("Overwriting...")
        fs.delete(path)
    end

    -- Use wget to download the file
    local command = string.format("wget %s %s", url, path)
    print("Running command: " .. command)
    shell.run(command)

    print("Downloaded: " .. path)
end

print("All files have been updated.")
