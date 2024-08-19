mudlet = mudlet or {}; mudlet.mapper_script = true

local GenericMapper = {}
GenericMapper.__index = GenericMapper

function GenericMapper.new()
    local self = setmetatable({}, GenericMapper)
    self.room_info = {}
    self.aliases = {}
    self.configs = {speedwalk_delay = 5.0}
    self.EventHandlers = {}
    self.current_room = -1
    return self
end

-- Terrain types for room environments with RGBA color codes
GenericMapper.terrain_types = {
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
for terrain, data in pairs(GenericMapper.terrain_types) do
    setCustomEnvColor(data.id, data.color[1], data.color[2], data.color[3], data.color[4])
end

local exitmap = {
    n = 'north',    ne = 'northeast', nw = 'northwest',
    e = 'east',     w = 'west',
    s = 'south',    se = 'southeast', sw = 'southwest',
    u = 'up',       d = 'down',
    ["in"] = 'in',  out = 'out',      l = 'look',
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

function GenericMapper:make_room(hash)
    local info = self.room_info
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
        envID = GenericMapper.terrain_types[info.environment] and GenericMapper.terrain_types[info.environment].id or GenericMapper.terrain_types["default"].id
    else
        envID = GenericMapper.terrain_types["default"].id
    end

    if getRoomEnv(roomID) ~= envID then
        setRoomEnv(roomID, envID)
    end

    return roomID
end

function GenericMapper:update_exits(roomID, info)
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
                connectExitStub(exitRoomID, roomID)
            elseif currentExits[dir] ~= exitRoomID then
                connectExitStub(roomID, exitRoomID)
            end
        else
            -- This is an unexplored exit
            if not table_contains(currentStubs, stubmap[dir]) then
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

function GenericMapper:handle_move()
    local info = self.room_info
    if not info.roomhash then
        return
    end

    local roomID = self:make_room(info.roomhash)

    self:update_exits(roomID, info)

    centerview(roomID)
    self.current_room = roomID

    updateMap()
end

function GenericMapper:speedwalk(targetHash)
    if not self.room_info or not self.room_info.roomhash then
        return
    end

    local startRoomID = getRoomIDbyHash(self.room_info.roomhash)
    local targetRoomID = getRoomIDbyHash(targetHash)

    if startRoomID == -1 or targetRoomID == -1 then
        self:echo("Error: Invalid start or target room.", false, true)
        return
    end

    local pathExists = getPath(startRoomID, targetRoomID)

    if not pathExists then
        self:echo("No path to chosen room found.", false, true)
        return
    end

    -- Convert speedWalkDir to a string format that speedwalk() can use
    local dirString = table.concat(speedWalkDir, ",")

    -- Use the built-in speedwalk function
    speedwalk(dirString, false, self.configs.speedwalk_delay or 0, true)
end

-- doSpeedWalk remains a local function
function doSpeedWalk()
    display("Calling doSpeedWalk")
    if not gmap.room_info or not gmap.room_info.roomhash then
        return
    end

    local startRoomID = getRoomIDbyHash(gmap.room_info.roomhash)

    if type(speedWalkPath) ~= "table" or #speedWalkPath == 0 then
        gmap:echo("No path to chosen room found.", false, true)
        return
    end

    local targetRoomID = speedWalkPath[#speedWalkPath]

    local pathExists = getPath(startRoomID, targetRoomID)

    if pathExists then
        local targetHash = getRoomHashByID(targetRoomID)
        if targetHash then
            gmap:speedwalk(targetHash)
        end
    else
        gmap:echo("No path to chosen room found.", false, true)
    end
end

function GenericMapper:setSpeedwalkDelay(delay)
    self.configs.speedwalk_delay = tonumber(delay) or 0
    echo("Speedwalk delay set to " .. self.configs.speedwalk_delay .. " seconds.\n")
end

function GenericMapper:eventHandler(event, ...)
    if event == "gmcp.Room.Info" then
        self.room_info = {
            roomhash = gmcp.Room.Info.roomhash,
            area = gmcp.Room.Info.area,
            name = gmcp.Room.Info.name,
            environment = gmcp.Room.Info.environment,
            symbol = gmcp.Room.Info.symbol,
            exits = table.deepcopy(gmcp.Room.Info.exits),
            coords = gmcp.Room.Info.coords
        }
        self:handle_move()
    end
end

function GenericMapper:Install(_, package)
    if package == "gmap" then
        self:setup()
        cecho("<green>Generic Mapper installed and initialized.\n")
    end
end

function GenericMapper:Uninstall(_, package)
    if package == "gmap" then
        self:teardown()
        cecho("<red>Generic Mapper uninstalled.\n")
        gmap = {}
    end
end

function GenericMapper:setup()
    -- Register event handlers
    local handler

    handler = "gmap:gmcp.Room.Info"
    if registerNamedEventHandler("gmap", handler, "gmcp.Room.Info", function(...) self:eventHandler(...) end) then
        table.insert(self.EventHandlers, handler)
    end

    handler = "gmap:sysConnectionEvent"
    if registerNamedEventHandler("gmap", handler, "sysConnectionEvent", function(...) self:eventHandler(...) end) then
        table.insert(self.EventHandlers, handler)
    end

    -- Setup the map widget
    openMapWidget("l")

    -- Create temporary aliases for speedwalk delay
    self.aliases.setSpeedwalkDelay = tempAlias("^speedwalk delay (.+)$", function()
        self:setSpeedwalkDelay(matches[2])
    end)

    self.aliases.checkSpeedwalkDelay = tempAlias("^speedwalk delay$", function()
        echo("Current speedwalk delay is " .. (self.configs.speedwalk_delay or 0) .. " seconds.\n")
    end)
end

function GenericMapper:teardown()
    -- Kill event handlers
    for _, handler in ipairs(self.EventHandlers) do
        deleteNamedEventHandler("gmap", handler)
    end
    self.EventHandlers = {}

    -- Remove the temporary aliases
    for name, id in pairs(self.aliases) do
        killAlias(id)
    end
    self.aliases = {}

    -- Close the map widget if needed
    closeMapWidget() -- Uncomment if you have a function to close the map widget
end

-- Helper functions
function table_keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function table_contains(t, element)
    for _, value in pairs(t) do
        if value == element then
            return true
        end
    end
    return false
end

-- Create an instance of GenericMapper
gmap = GenericMapper.new()

-- Register install and uninstall handlers
local handler

handler = "gmap:Install"
registerNamedEventHandler(
    "gmap",
    handler,
    "sysInstallPackage",
    function(...) gmap:Install(...) end,
    true
)

handler = "gmap:Uninstall"
if registerNamedEventHandler(
    "gmap",
    handler,
    "sysUninstallPackage",
    function(...) gmap:Uninstall(...) end
) then
    table.insert(gmap.EventHandlers, handler)
end

-- Add this with your other event handler registrations
registerAnonymousEventHandler("sysExitEvent", function()
    if gmap and gmap.teardown then
        gmap:teardown()
    end
end)

-- Call gmap:setup() at the bottom of the file
gmap:setup()

function GenericMapper:getCurrentRoom()
    return self.current_room or -1
end

function GenericMapper:displayCurrentRoom()
    local roomID = self:getCurrentRoom()
    if roomID == -1 then
        echo("No current room set.\n")
        return
    end

    local info = self.room_info
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

function GenericMapper:displayRoom(roomID)
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

function GenericMapper:displayMapGrid()
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

function GenericMapper:testSpeedwalk(from, to)
    local startRoom = from == 1 and 1 or (from == 2 and 4 or 8)
    local endRoom = to == 1 and 1 or (to == 2 and 4 or 8)

    local pathExists = getPath(startRoom, endRoom)

    if pathExists then
        local dirString = table.concat(speedWalkDir, ",")
        speedwalk(dirString, false, self.configs.speedwalk_delay or 0, true)
    else
        self:echo("No path to chosen room found.", false, true)
    end
end

function GenericMapper:checkRoomExits(roomID)
    local exits = getRoomExits(roomID)
    for dir, targetID in pairs(exits) do
        echo("  " .. dir .. " -> " .. targetID .. "\n")
    end
end

function GenericMapper:displayAllRooms()
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
