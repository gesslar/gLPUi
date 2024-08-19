-- generic GMCP mapping script for Mudlet
-- by Blizzard. https://worldofpa.in
-- based upon an MSDP script from the Mudlet forums in the generic mapper thread
-- with pieces from the generic mapper script and the mmpkg mapper by breakone9r
-- Updated with help from Paradox@DuneMUD
gmap = gmap or {}
gmap.room_info = gmap.room_info or {}
gmap.aliases = gmap.aliases or {}
gmap.configs = gmap.configs or {}
gmap.configs.speedwalk_delay = 5.0
gmap.EventHandlers = gmap.EventHandlers or {}

-- Terrain types for room environments with RGBA color codes
local terrain_types = {
    ["grass"] = {id = 500, color = {0, 255, 0, 255}},    -- Green
    ["forest"] = {id = 501, color = {0, 100, 0, 255}},   -- Dark Green
    ["road"] = {id = 502, color = {139, 69, 19, 255}},   -- Brown
    ["path"] = {id = 503, color = {210, 180, 140, 255}}, -- Light Brown
    ["dirt road"] = {id = 504, color = {165, 42, 42, 255}}, -- Dark Brown
    ["mud"] = {id = 505, color = {101, 67, 33, 255}},    -- Dark Brown
    ["indoor"] = {id = 506, color = {255, 223, 186, 255}}, -- Light Peach
    ["default"] = {id = 507, color = {200, 200, 200, 255}} -- Light Gray
}

-- Set custom environment colors for terrain types
for terrain, data in pairs(terrain_types) do
    setCustomEnvColor(data.id, data.color[1], data.color[2], data.color[3], data.color[4])
end

local exitmap = {
    n = 'north',    ne = 'northeast', nw = 'northwest',
    e = 'east',     w = 'west',
    s = 'south',    se = 'southeast', sw = 'southwest',
    u = 'up',       d = 'down',
    ["in"] = 'in',  out = 'out',      l = 'look',
}

local reverseDir = {
    north = "south", northeast = "southwest", northwest = "southeast",
    east = "west", west = "east",
    south = "north", southeast = "northwest", southwest = "northeast",
    up = "down", down = "up",
    ["in"] = "out", out = "in",
}

-- Mapping of direction names to their numeric representations and vice versa
local stubmap = {
    [1] = "north", [2] = "northeast", [3] = "northwest", [4] = "east", [5] = "west",
    [6] = "south", [7] = "southeast", [8] = "southwest", [9] = "up", [10] = "down",
    [11] = "in", [12] = "out", [13] = "northup", [14] = "southdown",
    [15] = "southup", [16] = "northdown", [17] = "eastup", [18] = "westdown",
    [19] = "westup", [20] = "eastdown",
    north = 1, northeast = 2, northwest = 3, east = 4, west = 5,
    south = 6, southeast = 7, southwest = 8, up = 9, down = 10,
    ["in"] = 11, out = 12, northup = 13, southdown = 14,
    southup = 15, northdown = 16, eastup = 17, westdown = 18,
    westup = 19, eastdown = 20
}

local function make_room(hash)
    local info = gmap.room_info
    local roomID = getRoomIDbyHash(hash)
    if roomID == -1 then
        roomID = createRoomID()
        addRoom(roomID)
        setRoomIDbyHash(roomID, hash)
    end

    if getRoomName(roomID) ~= info.name then
        setRoomName(roomID, info.name or "Unexplored Room")
    end

    local areaName = info.area or "Olum"
    local areaID = getAreaTable()[areaName]
    if not areaID then
        areaID = addAreaName(areaName)
    end
    if getRoomArea(roomID) ~= areaID then
        setRoomArea(roomID, areaID)
    end

    local x, y, z = tonumber(info.coords[1]), tonumber(info.coords[2]), tonumber(info.coords[3])
    local currentX, currentY, currentZ = getRoomCoordinates(roomID)
    if x ~= currentX or y ~= currentY or z ~= currentZ then
        setRoomCoordinates(roomID, x, y, z)
    end

    local envID
    if info.environment then
        envID = terrain_types[info.environment] and terrain_types[info.environment].id or terrain_types["default"].id
    else
        envID = terrain_types["default"].id
    end

    if getRoomEnv(roomID) ~= envID then
        setRoomEnv(roomID, envID)
    end

    return roomID
end

local function update_exits(roomID, info)
    local currentExits = getRoomExits(roomID)
    local currentStubs = getExitStubs(roomID)

    -- Update or add new exits
    for dir, hash in pairs(info.exits) do
        local exitRoomID = getRoomIDbyHash(hash)

        if exitRoomID ~= -1 then
            -- This is a room we've seen before

            -- Check if the exit already exists
            if not currentExits[dir] then
                setExitStub(roomID, dir, true)
                display(connectExitStub(exitRoomID, roomID))
            elseif currentExits[dir] ~= exitRoomID then
                connectExitStub(roomID, exitRoomID)
            end
        else
            -- This is an unexplored exit
            if not table.contains(currentStubs, stubmap[dir]) then
                setExitStub(roomID, dir, true)
            end
        end
    end

    -- Remove exits that no longer exist
    for dir, exitRoomID in pairs(currentExits) do
        if not info.exits[dir] then
            setExit(roomID, -1, dir)
        end
    end
end

local function handle_move()
    local info = gmap.room_info
    if not info.roomhash then
        return
    end

    local roomID = make_room(info.roomhash)

    update_exits(roomID, info)

    centerview(roomID)
    gmap.current_room = roomID

    updateMap()
end

function gmap.speedwalk(targetHash)
    if not gmap.room_info or not gmap.room_info.roomhash then
        return
    end

    local startRoomID = getRoomIDbyHash(gmap.room_info.roomhash)
    local targetRoomID = getRoomIDbyHash(targetHash)

    if startRoomID == -1 or targetRoomID == -1 then
        gmap.echo("Error: Invalid start or target room.", false, true)
        return
    end

    local pathExists = getPath(startRoomID, targetRoomID)

    if not pathExists then
        gmap.echo("No path to chosen room found.", false, true)
        return
    end

    -- Convert speedWalkDir to a string format that speedwalk() can use
    local dirString = table.concat(speedWalkDir, ",")

    -- Use the built-in speedwalk function
    speedwalk(dirString, false, gmap.configs.speedwalk_delay or 0, true)
end

function doSpeedWalk()
    if not gmap.room_info or not gmap.room_info.roomhash then
        return
    end

    local startRoomID = getRoomIDbyHash(gmap.room_info.roomhash)

    if type(speedWalkPath) ~= "table" or #speedWalkPath == 0 then
        gmap.echo("No path to chosen room found.", false, true)
        return
    end

    local targetRoomID = speedWalkPath[#speedWalkPath]

    local pathExists = getPath(startRoomID, targetRoomID)

    if pathExists then
        local targetHash = getRoomHashByID(targetRoomID)
        if targetHash then
            gmap.speedwalk(targetHash)
        end
    else
        gmap.echo("No path to chosen room found.", false, true)
    end
end

function gmap.setSpeedwalkDelay(delay)
    gmap.configs.speedwalk_delay = tonumber(delay) or 0
    echo("Speedwalk delay set to " .. gmap.configs.speedwalk_delay .. " seconds.\n")
end

function gmap.eventHandler(event, ...)
    if event == "gmcp.Room.Info" then
        gmap.room_info = {
            roomhash = gmcp.Room.Info.roomhash,
            area = gmcp.Room.Info.area,
            name = gmcp.Room.Info.name,
            environment = gmcp.Room.Info.environment,
            symbol = gmcp.Room.Info.symbol,
            exits = table.deepcopy(gmcp.Room.Info.exits),
            coords = gmcp.Room.Info.coords
        }
        handle_move()
    end
end

gmap.EventHandlers = gmap.EventHandlers or {}

function gmap:Install(_, package)
    if package == "gmap" then
        self.setup()
        cecho("<green>Generic Mapper installed and initialized.\n")
    end
end

function gmap:Uninstall(_, package)
    if package == "gmap" then
        self.teardown()
        cecho("<red>Generic Mapper uninstalled.\n")
        gmap = {}
    end
end

function gmap.setup()
    -- Register event handlers
    local handler

    handler = "gmap:gmcp.Room.Info"
    if registerNamedEventHandler("gmap", handler, "gmcp.Room.Info", "gmap.eventHandler") then
        gmap.EventHandlers[#gmap.EventHandlers+1] = handler
    end

    handler = "gmap:sysConnectionEvent"
    if registerNamedEventHandler("gmap", handler, "sysConnectionEvent", "gmap.eventHandler") then
        gmap.EventHandlers[#gmap.EventHandlers+1] = handler
    end

    -- Setup the map widget
    openMapWidget("l")

    -- Create temporary aliases for speedwalk delay
    gmap.aliases.setSpeedwalkDelay = tempAlias("^speedwalk delay (.+)$", function()
        gmap.setSpeedwalkDelay(matches[2])
    end)

    gmap.aliases.checkSpeedwalkDelay = tempAlias("^speedwalk delay$", function()
        echo("Current speedwalk delay is " .. (gmap.configs.speedwalk_delay or 0) .. " seconds.\n")
    end)
end

function gmap.teardown()
    -- Kill event handlers
    for _, handler in ipairs(gmap.EventHandlers) do
        deleteNamedEventHandler("gmap", handler)
    end
    gmap.EventHandlers = {}

    -- Remove the temporary aliases
    for name, id in pairs(gmap.aliases) do
        killAlias(id)
    end
    gmap.aliases = {}

    -- Close the map widget if needed
    closeMapWidget() -- Uncomment if you have a function to close the map widget
end

-- Register install and uninstall handlers
local handler

handler = "gmap:Install"
registerNamedEventHandler(
    "gmap",
    handler,
    "sysInstallPackage",
    "gmap:Install",
    true
)

handler = "gmap:Uninstall"
if registerNamedEventHandler(
    "gmap",
    handler,
    "sysUninstallPackage",
    "gmap:Uninstall"
) then
    gmap.EventHandlers[#gmap.EventHandlers+1] = handler
end

-- Add this with your other event handler registrations
registerAnonymousEventHandler("sysExitEvent", function()
    if gmap and gmap.teardown then
        gmap.teardown()
    end
end)

-- Call gmap.setup() at the bottom of the file
gmap.setup()

function gmap.getCurrentRoom()
    return gmap.current_room or -1
end

function gmap.displayCurrentRoom()
    local roomID = gmap.getCurrentRoom()
    if roomID == -1 then
        echo("No current room set.\n")
        return
    end

    local info = gmap.room_info
    echo("Current Room:\n")
    echo("  Name: " .. info.name .. "\n")
    echo("  Area: " .. info.area .. "\n")
    echo("  ID: " .. roomID .. "\n")
    echo("  Hash: " .. info.roomhash .. "\n")
    echo("  Coordinates: " .. table.concat(info.coords, ", ") .. "\n")
    echo("  Environment: " .. info.environment .. "\n")
    echo("  Exits:\n")
    for dir, hash in pairs(info.exits) do
        local exitID = getRoomIDbyHash(hash)
        local exitName = exitID ~= -1 and getRoomName(exitID) or "Unexplored Room"
        echo("    " .. dir .. ": " .. exitName .. " (ID: " .. (exitID ~= -1 and exitID or "N/A") .. ")\n")
    end
end

function gmap.checkExits()
    local roomID = gmap.getCurrentRoom()
    if roomID == -1 then
        echo("No current room set.\n")
        return
    end

    local exits = getRoomExits(roomID)

    for dir, exitID in pairs(exits) do
        local reverseExits = getRoomExits(exitID)
        if reverseExits[reverseDir[dir]] ~= roomID then
            echo("Warning: Exit " .. dir .. " to room " .. exitID .. " is not bidirectional.\n")
        end
    end

    echo("Exit check complete.\n")
end

function gmap.displayRoom(roomID)
    if not roomID then
        echo("No room ID provided.\n")
        return
    end

    local name = getRoomName(roomID) or "Unknown"
    local area = getRoomArea(roomID)
    local areaName = getAreaTableSwap()[area] or "Unknown"
    local hash = getRoomHashByID(roomID) or "Unknown"
    local x, y, z = getRoomCoordinates(roomID)
    local env = getRoomEnv(roomID) or "Unknown"
    local exits = getRoomExits(roomID) or {}
    local stubs = getExitStubs1(roomID) or {}

    echo("Room Information:\n")
    echo("  Name: " .. name .. "\n")
    echo("  Area: " .. areaName .. "\n")
    echo("  ID: " .. roomID .. "\n")
    echo("  Hash: " .. hash .. "\n")
    echo("  Coordinates: " .. x .. ", " .. y .. ", " .. z .. "\n")
    echo("  Environment: " .. env .. "\n")
    echo("  Exits:\n")
    for dir, exitID in pairs(exits) do
        local exitName = getRoomName(exitID) or "Unknown"
        local exitHash = getRoomHashByID(exitID) or "Unknown"
        echo("    " .. dir .. ": " .. exitName .. " (ID: " .. exitID .. ", Hash: " .. exitHash .. ")\n")
    end
    for _, stubNum in ipairs(stubs) do
        local dir = stubmap[stubNum]
        if dir then
            echo("    " .. dir .. ": Unexplored\n")
        end
    end
end

function gmap.displayMapGrid()
    local rooms = getRooms()
    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    local grid = {}

    for id, room in pairs(rooms) do
        local x, y = getRoomCoordinates(id)
        minX, maxX = math.min(minX, x), math.max(maxX, x)
        minY, maxY = math.min(minY, y), math.max(maxY, y)
        grid[y] = grid[y] or {}
        grid[y][x] = string.format("%d", id)
    end

    for y = maxY, minY, -1 do
        local row = ""
        for x = minX, maxX do
            row = row .. string.format("%3s ", grid[y] and grid[y][x] or "  ")
        end
        echo(row .. "\n")
    end
end

function gmap.testSpeedwalk(from, to)
    local startRoom = from == 1 and 1 or (from == 2 and 4 or 8)
    local endRoom = to == 1 and 1 or (to == 2 and 4 or 8)

    local pathExists = getPath(startRoom, endRoom)

    if pathExists then
        local dirString = table.concat(speedWalkDir, ",")
        speedwalk(dirString, false, gmap.configs.speedwalk_delay or 0, true)
    else
        gmap.echo("No path to chosen room found.", false, true)
    end
end

function gmap.checkRoomExits(roomID)
    local exits = getRoomExits(roomID)
    for dir, targetID in pairs(exits) do
        echo("  " .. dir .. " -> " .. targetID .. "\n")
    end
end

function gmap.displayAllRooms()
    local rooms = getRooms()
    for id, room in pairs(rooms) do
        local name = getRoomName(id) or "Unnamed Room"
        local area = getRoomArea(id)
        local areaName = getAreaTableSwap()[area] or "Unknown Area"
        local hash = getRoomHashByID(id) or "Unknown"
        local x, y, z = getRoomCoordinates(id)
        local env = getRoomEnv(id) or "Unknown"
        local exits = getRoomExits(id) or {}
        local exitStubs = getExitStubs(id) or {}

        echo("Room ID: " .. id .. "\n")
        echo("  Name: " .. name .. "\n")
        echo("  Area: " .. areaName .. "\n")
        echo("  Hash: " .. hash .. "\n")
        echo("  Coordinates: " .. x .. ", " .. y .. ", " .. z .. "\n")
        echo("  Environment: " .. env .. "\n")
        echo("  Exits:\n")
        for dir, exitID in pairs(exits) do
            local exitName = getRoomName(exitID) or "Unknown Room"
            echo("    " .. dir .. " -> Room " .. exitID .. " (" .. exitName .. ")\n")
        end
        if next(exitStubs) then
            echo("  Exit Stubs:\n")
            for _, dir in ipairs(exitStubs) do
                echo("    " .. dir .. "\n")
            end
        end
        echo("\n")
    end
end

function table.keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function table.contains(t, element)
    for _, value in pairs(t) do
        if value == element then
            return true
        end
    end
    return false
end
