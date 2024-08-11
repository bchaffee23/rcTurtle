-- config.lua

local config = {
    modemSide = "left", -- Side where the wireless modem is attached
    commandChannel = "1", -- Command channel for receiving commands
    statusChannel = "2", -- Status channel for sending status updates
    remoteID = "8", -- ID of personal computer
    localID = "5", -- local turtle ID
    quarryWidth = "4", -- X-axis
    quarryLength = "4", -- Z-axis
    quarryDepth = "4", -- Y-axis
    fuelThreshold = 100 -- Minimum fuel level before returning to refuel
}

-- Export configuration
return config
