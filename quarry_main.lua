-- quarry.lua

local locations_mgr = dofile("myfiles/locations_mgr.lua")
local utils = dofile("myfiles/utils.lua")
local config = dofile("myfiles/config.lua")

local M = {}

function M.refuelCheck()
    local fuel = turtle.getFuelLevel()

    if fuel < config.fuelThreshold then
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(0) then
                turtle.refuel()
                utils.sendStatus("Turtle refueled from inventory.")
                return
            end
        end
        
        -- If no fuel was found in the inventory, move to the fuel storage
        utils.sendStatus("No fuel within inventory. Moving to fuel storage.")
        local fx, fy, fz, ffacing = locations.getFuelStorage()
        utils.moveTo(fx, fy, fz)
        utils.turnTo(ffacing)

        -- Attempt to refuel from the storage inventory
        turtle.suck()
        if turtle.refuel(0) then
            turtle.refuel()
            utils.sendStatus("Turtle refueled from fuel storage.")
        else
            utils.sendStatus("Failed to refuel from fuel storage.")
        end
    end
end

return M

local function unloadItems()
    local storageX, storageY, storageZ, facing = locations_mgr.getProductStorage()
    if not storageX or not storageY or not storageZ then
        error("Product storage location not set.")
    end

    -- Move to product storage and unload items
    utils.moveTo(storageX, storageY, storageZ)
    for slot = 2, 16 do
        turtle.select(slot)
        turtle.drop() -- Drop items into the storage
    end
end

local function quarry(boundary)
    -- Retrieve home location
    local homeX, homeY, homeZ = locations_mgr.getHome()

    -- Move to starting position
    local startX, startY, startZ = homeX, homeY, homeZ -- Or any defined start position

    -- Define quarry dimensions and pattern
    local length = 10 -- Define quarry length
    local width = 10 -- Define quarry width
    local depth = 5 -- Define quarry depth

    -- Quarry loop
    for y = startY, startY - depth, -1 do
        for x = startX, startX + length do
            for z = startZ, startZ + width do
                moveAndMine(x, y, z)

                -- Check if turtle needs refueling
                if turtle.getFuelLevel() < 10 then -- Replace 10 with the threshold you want
                    checkAndRefuel()
                end

                -- If inventory is full, unload items
                local isFull = true
                for slot = 1, 16 do
                    if turtle.getItemCount(slot) == 0 then
                        isFull = false
                        break
                    end
                end
                if isFull then
                    unloadItems()
                end
            end
        end
        -- Move to the next layer or row
        utils.moveTo(startX, y - 1, startZ + width)
    end

    -- Return to home location
    utils.moveTo(homeX, homeY, homeZ)
end

