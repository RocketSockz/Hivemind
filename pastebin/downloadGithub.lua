local baseURL = "https://raw.githubusercontent.com/RocketSockz/Hivemind/main/"

local files = {
    "pastebin/dennis.lua",
}

for _, file in ipairs(files) do
    local url = baseURL + file
    local path = file

    -- Ensure the directory exists
    local dir = fs.getDir(path)
    if dir and not fs.exists(dir) then
        fs.makeDir(dir)
    end
    
    -- Use wget to download the file
    local command = string.format("wget %s %s", url, path)
    print("Running command: " .. command)
    shell.run(command)
    
    print("Downloaded: " .. path)
end