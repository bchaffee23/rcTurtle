-- main.lua

local utils = dofile("myfiles/utils.lua")
local communicator = dofile("myfiles/communicator.lua")
local config = dofile("myfiles/config.lua")
--local inventory_mgr = dofile("myfiles/inventory_mgr.lua")
--local locations_mgr = dofile("myfiles/locations_mgr.lua")

-- Function to log errors to a file
local function logError(message)
    local file = fs.open("/myfiles/error_log.txt", "a")
    if file then
        file.writeLine(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. message)
        file.close()
    else
        print("Failed to open error log file.")
    end
end

-- Protected call wrapper
local function safeRun()
    -- Initialize GPS
    local homeX, homeY, homeZ = utils.initializeGPS()
    local boundary = utils.calculateBoundaries()

    -- Main loop
    while true do
        sleep(0.05)
        communicator.listenForCommands(boundary)
    end
end

-- Main entry point
local success, err = pcall(safeRun)
if not success then
    logError(err)
    print("An error occurred. Check error_log.txt for details.")
end
