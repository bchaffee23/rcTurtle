-- utils.lua
-- this is currently a clusterf

local config = dofile("myfiles/config.lua")

local function checkInv(itemName)
    local checkBlock, data = turtle.inspect()
    if checkBlock then
        local inventory = peripheral.wrap("front")
        if inventory then
            local itemList = inventory.list()
            for slot, item in pairs(itemList) do
                if item.name == itemName then
                    return true
                end
            end
        end
    end
    return false
end

local M = {}

-- Function to save the initial direction
function M.saveInitialDirection()
    local direction = M.getOrientation()
    local file = fs.open("myfiles/direction.txt", "w")
    file.writeLine(direction)
    file.close()
end

function M.initializeGPS()
    local x, y, z = gps.locate(2)
    if not x then
        error("Failed to locate GPS. Please ensure GPS is set up correctly.")
    end

    M.saveInitialDirection()

    return x, y, z
end


-- Function to update the direction after a turn
function M.updateDirection(turnDirection)
    local currentDirection = M.getSavedDirection()
    local newDirection

    if turnDirection == "left" then
        if currentDirection == "north" then newDirection = "west"
        elseif currentDirection == "west" then newDirection = "south"
        elseif currentDirection == "south" then newDirection = "east"
        elseif currentDirection == "east" then newDirection = "north"
        end
    elseif turnDirection == "right" then
        if currentDirection == "north" then newDirection = "east"
        elseif currentDirection == "east" then newDirection = "south"
        elseif currentDirection == "south" then newDirection = "west"
        elseif currentDirection == "west" then newDirection = "north"
        end
    end

    local file = fs.open("myfiles/direction.txt", "w")
    file.writeLine(newDirection)
    file.close()
end

-- Function to update the saved direction after turning
function M.saveDirection(newDirection)
    local file = fs.open("myfiles/direction.txt", "w")
    file.writeLine(newDirection)
    file.close()
end

-- Function to get the saved direction
function M.getSavedDirection()
    if not fs.exists("myfiles/direction.txt") then
        error("Direction file not found.")
    end

    local file = fs.open("myfiles/direction.txt", "r")
    local direction = file.readLine()
    file.close()
    return direction
end

-- Function to get the turtle's current orientation
function M.getOrientation()
    -- Move forward, check GPS, and move back to determine direction
    local x1, y1, z1 = gps.locate(2)
    turtle.forward()
    local x2, y2, z2 = gps.locate(2)
    turtle.back()  -- Return to the original position

    if x2 > x1 then
        return "east"
    elseif x2 < x1 then
        return "west"
    elseif z2 > z1 then
        return "south"
    elseif z2 < z1 then
        return "north"
    end
end

-- Function to move forward and update position
function M.moveForward()
    turtle.forward()

    -- Update direction after moving forward
    local direction = M.getSavedDirection()
    M.saveDirection(direction)
end

function M.moveTo(x, y, z)
    -- Get current location from GPS
    local currentX, currentY, currentZ = gps.locate(2)
    if not currentX then
        error("GPS signal lost. Unable to move.")
    end

    -- Get saved direction
    local direction = M.getSavedDirection()

    -- Function to move forward with obstacle handling
    local function moveWithObstacleCheck()
        while not turtle.forward() do
            if turtle.detect() then
                -- If there's a block in front, try to dig it
                --turtle.dig()
            --else
                -- If still blocked, try to navigate around
                local turnLeftOrRight = math.random(2)
                if turnLeftOrRight == 1 then
                    M.turnLeft()
                else
                    M.turnRight()
                end

                if not turtle.forward() then
                    -- If still blocked after turning, turn back to original direction
                    if turnLeftOrRight == 1 then
                        turtle.back()
                        M.turnLeft()
                        return
                    else
                        turtle.back()
                        M.turnLeft()
                        turtle.back(3)
                        return -- Undo right turn
                    end
                    -- Attempt to move forward again
                    turtle.forward()
                end
                --for i = 1, 3 do
                  --  M.turnRight()
                    --M.moveForward
                    --if not turtle.detect() then
                    --    break
                    --end
                --end
            end
        end
    end

    -- Move along the X-axis
    while currentX ~= x do
        if currentX < x then
            -- Move East
            if direction ~= "east" then
                M.turnTo("east")
                direction = "east"
            end
            moveWithObstacleCheck()
        elseif currentX > x then
            -- Move West
            if direction ~= "west" then
                M.turnTo("west")
                direction = "west"
            end
            moveWithObstacleCheck()
        end
        currentX, currentY, currentZ = gps.locate(2)
    end

    -- Move along the Y-axis (up or down)
    while currentY ~= y do
        if currentY < y then
            turtle.up()
        elseif currentY > y then
            turtle.down()
        end
        currentX, currentY, currentZ = gps.locate(2)
    end

    -- Move along the Z-axis
    while currentZ ~= z do
        if currentZ < z then
            -- Move South
            if direction ~= "south" then
                M.turnTo("south")
                direction = "south"
            end
            moveWithObstacleCheck()
        elseif currentZ > z then
            -- Move North
            if direction ~= "north" then
                M.turnTo("north")
                direction = "north"
            end
            moveWithObstacleCheck()
        end
        currentX, currentY, currentZ = gps.locate(2)
    end
end


-- Function to turn to a specific direction based on the saved direction
function M.turnTo(targetDirection)
    local currentDirection = M.getSavedDirection()

    if currentDirection == targetDirection then
        return
    elseif (currentDirection == "north" and targetDirection == "east") or
           (currentDirection == "east" and targetDirection == "south") or
           (currentDirection == "south" and targetDirection == "west") or
           (currentDirection == "west" and targetDirection == "north") then
        M.turnRight()
    elseif (currentDirection == "north" and targetDirection == "west") or
           (currentDirection == "west" and targetDirection == "south") or
           (currentDirection == "south" and targetDirection == "east") or
           (currentDirection == "east" and targetDirection == "north") then
        M.turnLeft()
    elseif (currentDirection == "north" and targetDirection == "south") or
           (currentDirection == "south" and targetDirection == "north") or
           (currentDirection == "east" and targetDirection == "west") or
           (currentDirection == "west" and targetDirection == "east") then
        M.turnLeft()
        M.turnLeft()
    end

    -- Update saved direction after turning
    M.saveDirection(targetDirection)
end

function M.turnLeft()
    turtle.turnLeft()
    M.updateDirection("left")
end

function M.turnRight()
    turtle.turnRight()
    M.updateDirection("right")
end

function M.invSearch(itemName, maxDistance)

    local startX, startY, startZ = M.initializeGPS()
    print("Starting coordinates: ", startX, startY, startZ)
    print("Looking for: ", itemName)
    sleep(0.5)
    local step = 1
    local distance = 0

    while distance <= maxDistance do
    print(distance, maxDistance)
        for _ = 1, 2 do
            for _ = 1, distance do
                if checkInv(itemName) then
                    local foundX, foundY, foundZ = M.initializeGPS()
                    return foundX, foundY, foundZ
                end
                M.moveForward()
                sleep(0.05)
            end
            M.turnRight()
            sleep(0.05)
        end
        distance = distance + step
    end

    return nil, nil, nil, nil -- Return nil if no inventory is found within maxDistance
end

function M.calculateBoundaries()
    -- Scan for GPS hosts and calculate boundaries
    local boundary = {
        minX = math.huge,
        maxX = -math.huge,
        minZ = math.huge,
        maxZ = -math.huge
    }

    local gpsHosts = {
        { x = 10, z = 10 },
        { x = 100, z = 10 },
        { x = 10, z = 100 },
        { x = 100, z = 100 }
    }

    for _, host in ipairs(gpsHosts) do
        boundary.minX = math.min(boundary.minX, host.x)
        boundary.maxX = math.max(boundary.maxX, host.x)
        boundary.minZ = math.min(boundary.minZ, host.z)
        boundary.maxZ = math.max(boundary.maxZ, host.z)
    end

    return boundary
end

function M.isWithinBoundary(x, z, boundary)
    return x >= boundary.minX and x <= boundary.maxX and z >= boundary.minZ and z <= boundary.maxZ
end

-- Function to send status updates
function M.sendStatus(message)
    print(message) -- Print to the console for debugging
    
    local targetID = config.remoteID
    local channel = config.statusChannel

    --rednet.open(config.modemSide)
    rednet.send(tonumber(targetID), message, channel)
    -- else
        -- Optionally, send to a broadcast if no targetID is provided
    --    rednet.broadcast(message, "status")
    -- end
end

-- Export functions as a table
return M
