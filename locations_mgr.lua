-- locations_mgr v1.0

local utils = dofile("myfiles/utils.lua")

local M = {}

function M.setHome()

    -- Get current location from utils
    local x, y, z = utils.initializeGPS()
    local facing = utils.getOrientation()
    utils.sendStatus("Orientation: ", facing)
    
    if not x or not y or not z then
        error("Unable to get GPS location.")
    end


    -- Save home location to locations file
    local file = fs.open("/myfiles/locations/home.txt", "w")
    file.writeLine(x)
    file.writeLine(y)
    file.writeLine(z)
    file.writeLine(facing)
    file.close()
end

function M.getHome()
    local locations = "/myfiles/locations/home.txt"
    if not fs.exists(locations) then
        error("Locations file not found (at locations_mgr.lua - home.txt)")
    end

    local file = fs.open(locations, "r")
    local x = tonumber(file.readLine())
    local y = tonumber(file.readLine())
    local z = tonumber(file.readLine())
    local facing = file.readLine()
    file.close()

    return x, y, z, facing
end

function M.setFuelStorage(item, distance)
    local x, y, z = utils.invSearch(item, distance)
    -- Reverse 1 to get orientation
    turtle.back()
    local facing = utils.getOrientation()
    if not x or not y or not z then
        error("Unable to get fuel storage location.")
    end

    print("Saving Fuel Storage Location: ", x, y, z, facing)
    sleep(5)
    -- Save fuel storage location to file
    local fuelLoc = fs.open("myfiles/locations/fuelstorage.txt", "w")
    fuelLoc.writeLine(x)
    fuelLoc.writeLine(y)
    fuelLoc.writeLine(z)
    fuelLoc.writeLine(facing)
    fuelLoc.close()
end

function M.getFuelStorage()
    local locations = "myfiles/locations/fuelstorage.txt"
    if not fs.exists(locations) then
        error("Locations file not found (at locations_mgr.lua - fuelstorage.txt)")
    end

    local file = fs.open(locations, "r")
    local x = tonumber(file.readLine())
    local y = tonumber(file.readLine())
    local z = tonumber(file.readLine())
    local facing = file.readLine()
    file.close()

    print("Loaded Fuel Storage Location:", x, y, z, facing)
    return x, y, z, facing
end

function M.setProductStorage(item, distance)
    local x, y, z = utils.invSearch(item, distance)
    print("Getting orientation for Product Storage ", itemName)
    -- Reverse 1 to get orientation
    turtle.back()
    local facing = utils.getOrientation()
    if not x or not y or not z then
        error("Unable to get product storage location.")
    end

    print("Saving Product Storage Location: ", x, y, z, facing)
    -- Save product storage location to file
    local prodLoc = fs.open("myfiles/locations/productstorage.txt", "w")
    print("Opened file")
    prodLoc.writeLine(x)
    prodLoc.writeLine(y)
    prodLoc.writeLine(z)
    prodLoc.writeLine(facing)
    prodLoc.close()
end

function M.getProductStorage()
    local locations = "myfiles/locations/productstorage.txt"
    if not fs.exists(locations) then
        error("Locations file not found (at locations_mgr.lua - productstorage.txt)")
    end

    local file = fs.open(locations, "r")
    local x = tonumber(file.readLine())
    local y = tonumber(file.readLine())
    local z = tonumber(file.readLine())
    local facing = file.readLine()
    file.close()

    print("Loaded Product Storage Location:", x, y, z, facing)
    return x, y, z, facing
end

-- Export functions
return M
