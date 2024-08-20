mudlet = mudlet or {}; mudlet.mapper_script = true

local GenericMapper = {}
GenericMapper.__index = GenericMapper

function GenericMapper.New()
    local self = setmetatable({}, GenericMapper)
    self.room_info = nil
    self.prev_info = nil
    self.aliases = {}
    self.configs = {speedwalk_delay = 0.5}
    self.event_handlers = {}
    self.current_room = -1
    self.move_vectors = {
        north = {0, 1, 0},
        south = {0, -1, 0},
        east = {1, 0, 0},
        west = {-1, 0, 0},
        northwest = {-1, 1, 0},
        northeast = {1, 1, 0},
        southwest = {-1, -1, 0},
        southeast = {1, -1, 0},
        up = {0, 0, 1},
        down = {0, 0, -1},
    }
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

GenericMapper.exit_map = {
    n = 'north',    ne = 'northeast', nw = 'northwest',
    e = 'east',     w = 'west',
    s = 'south',    se = 'southeast', sw = 'southwest',
    u = 'up',       d = 'down',
    ["in"] = 'in',  out = 'out',      l = 'look',
}

-- Mapping of direction names to their numeric representations and vice versa
GenericMapper.stub_map = {
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

function GenericMapper:MakeRoom(hash)
    local info = self.room_info
    local room_id = getRoomIDbyHash(hash)
    if room_id == -1 then
        room_id = createRoomID()
        addRoom(room_id)
        setRoomIDbyHash(room_id, hash)
    end

    if getRoomName(room_id) ~= info.name then
        setRoomName(room_id, info.name or "Unexplored Room")
    end

    local area_name = info.area or "Undefined"
    local area_id = getAreaTable()[area_name]
    if not area_id then
        area_id = addAreaName(area_name)
    end
    if getRoomArea(room_id) ~= area_id then
        setRoomArea(room_id, area_id)
    end

    local coords
    if info.coords then
        coords = info.coords
    else
        -- Calculate coordinates based on previous room
        coords = self:CalculateCoordinates(room_id)
    end

    local cx, cy, cz = getRoomCoordinates(room_id)
    if coords[1] ~= cx or coords[2] ~= cy or coords[3] ~= cz then
        setRoomCoordinates(room_id, coords[1], coords[2], coords[3])
    end

    local env_id
    if info.environment then
        env_id = self.terrain_types[info.environment] and self.terrain_types[info.environment].id or self.terrain_types["default"].id
    else
        env_id = self.terrain_types["default"].id
    end

    if getRoomEnv(room_id) ~= env_id then
        setRoomEnv(room_id, env_id)
    end

    return room_id
end

function GenericMapper:CalculateCoordinates(roomID)
    local default_coordinates = {0, 0, 0}

    if self.current_room == -1 then
        return default_coordinates
    end

    local prev_room_id = getRoomIDbyHash(self.prev_info.roomhash)

    if prev_room_id == -1 then
        return default_coordinates
    end

    local coords = {getRoomCoordinates(prev_room_id)} or {0, 0, 0}
    local shift = {0, 0, 0}
    for k, v in pairs(self.room_info.exits) do
        if v == self.prev_info.roomhash and self.move_vectors[k] then
            shift = self.move_vectors[k]
            break
        end
    end

    for n = 1, 3 do
        coords[n] = coords[n] - shift[n]
    end

    return coords
end

function GenericMapper:UpdateExits(room_id, info)
    local current_exits = getRoomExits(room_id)
    local current_stubs = getExitStubs(room_id)

    -- Update or add new exits
    for dir, hash in pairs(info.exits) do
        local exit_room_id = getRoomIDbyHash(hash)

        if exit_room_id ~= -1 then
            -- This is a room we've seen before

            -- Check if the exit already exists
            if not current_exits[dir] then
                setExitStub(room_id, dir, true)
                connectExitStub(exit_room_id, room_id)
            elseif current_exits[dir] ~= exit_room_id then
                connectExitStub(room_id, exit_room_id)
            end
        else
            -- This is an unexplored exit
            if not table_contains(current_stubs, self.stub_map[dir]) then
                setExitStub(room_id, dir, true)
            end
        end
    end

    -- Remove exits that no longer exist
    for dir, exit_room_id in pairs(current_exits) do
        if not info.exits[dir] then
            setExit(room_id, -1, dir)
        end
    end
end

function GenericMapper:HandleMove()
    local info = self.room_info
    if not info.roomhash then
        return
    end

    local room_id = self:MakeRoom(info.roomhash)

    self:UpdateExits(room_id, info)

    centerview(room_id)
    self.current_room = room_id

    updateMap()
end

function GenericMapper:Speedwalk(targetHash)
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
    local ok, err = stopSpeedwalk()
    display(ok, err)
    if ok then
        cecho("<red>Current speedwalk interrupted.\n")
    end

    if not gmap.room_info or not gmap.room_info.roomhash then
        return
    end

    local start_room_id = getRoomIDbyHash(gmap.room_info.roomhash)

    if type(speedWalkPath) ~= "table" or #speedWalkPath == 0 then
        echo("No path to chosen room found.\n")
        return
    end

    local target_room_id = speedWalkPath[#speedWalkPath]

    local path_exists = getPath(start_room_id, target_room_id)

    if path_exists then
        local target_hash = getRoomHashByID(target_room_id)
        if target_hash then
            gmap:Speedwalk(target_hash)
        end
    else
        echo("No path to chosen room found.\n")
    end
end

function GenericMapper:setSpeedwalkDelay(delay)
    self.configs.speedwalk_delay = tonumber(delay) or 0
    echo("Speedwalk delay set to " .. self.configs.speedwalk_delay .. " seconds.\n")
end

function GenericMapper:eventHandler(event, ...)
    -- Ignore events that are not gmcp.Room.Info
    if event ~= "gmcp.Room.Info" and event ~= "gmcp.Room.Travel" then return end

    if event == "gmcp.Room.Travel" then
        if not gmcp.Room.Travel.destination or gmcp.Room.Travel.destination == "" then
            return
        end

        self:Speedwalk(gmcp.Room.Travel.destination)
        return
    end

    self.prev_info = self.room_info

    if self.prev_info then
        self.prev_info.room_id = getRoomIDbyHash(self.prev_info.roomhash)
    end

    self.room_info = {
        roomhash = gmcp.Room.Info.roomhash,
        area = gmcp.Room.Info.area,
        name = gmcp.Room.Info.name,
        environment = gmcp.Room.Info.environment,
        symbol = gmcp.Room.Info.symbol,
        exits = table.deepcopy(gmcp.Room.Info.exits),
        coords = gmcp.Room.Info.coords
    }

    self:HandleMove()
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
        table.insert(self.event_handlers, handler)
    end

    handler = "gmap:sysConnectionEvent"
    if registerNamedEventHandler("gmap", handler, "sysConnectionEvent", function(...) self:eventHandler(...) end) then
        table.insert(self.event_handlers, handler)
    end

    handler = "gmap:gmcp.Room.Travel"
    if registerNamedEventHandler("gmap", handler, "gmcp.Room.Travel", function(...) self:eventHandler(...) end) then
        table.insert(self.event_handlers, handler)
    end

    -- Setup the map widget
    -- openMapWidget("l")

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
    for _, handler in ipairs(self.event_handlers) do
        deleteNamedEventHandler("gmap", handler)
    end
    self.event_handlers = {}

    -- Remove the temporary aliases
    for name, id in pairs(self.aliases) do
        killAlias(id)
    end
    self.aliases = {}

    -- Close the map widget if needed
    -- closeMapWidget() -- Uncomment if you have a function to close the map widget
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
gmap = GenericMapper.New()

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
    table.insert(gmap.event_handlers, handler)
end

-- Add this with your other event handler registrations
registerAnonymousEventHandler("sysExitEvent", function()
    if gmap and gmap.teardown then
        gmap:teardown()
    end
end)

-- Call gmap:setup() at the bottom of the file
gmap:setup()

function GenericMapper:GetCurrentRoom()
    return self.current_room or -1
end

function GenericMapper:DisplayCurrentRoom()
    local roomID = self:GetCurrentRoom()
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

function GenericMapper:DisplayMapGrid(roomID)
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
    for _, stub_num in ipairs(stubs) do
        local dir = self.stub_map[stub_num]
        if dir then
            echo("    " .. dir .. ": Unexplored\n")
        end
    end
end

function GenericMapper:DisplayMapGrid()
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
    local start_room = from == 1 and 1 or (from == 2 and 4 or 8)
    local end_room = to == 1 and 1 or (to == 2 and 4 or 8)

    local path_exists = getPath(start_room, end_room)

    if path_exists then
        local dir_string = table.concat(speedWalkDir, ",")
        speedwalk(dir_string, false, self.configs.speedwalk_delay or 0, true)
    else
        echo("No path to chosen room found.\n")
    end
end

function GenericMapper:checkRoomExits(roomID)
    local exits = getRoomExits(roomID)
    for dir, target_id in pairs(exits) do
        echo("  " .. dir .. " -> " .. target_id .. "\n")
    end
end

function GenericMapper:displayAllRooms()
    local rooms = getRooms()
    for id, room in pairs(rooms) do
        local name = getRoomName(id) or "Unnamed Room"
        local area = getRoomArea(id)
        local area_name = getAreaTableSwap()[area] or "Unknown Area"
        local hash = getRoomHashByID(id) or "Unknown"
        local x, y, z = getRoomCoordinates(id)
        local env = getRoomEnv(id) or "Unknown"
        local exits = getRoomExits(id) or {}
        local exit_stubs = getExitStubs(id) or {}

        echo("Room ID: " .. id .. "\n")
        echo("  Name: " .. name .. "\n")
        echo("  Area: " .. area_name .. "\n")
        echo("  Hash: " .. hash .. "\n")
        echo("  Coordinates: " .. x .. ", " .. y .. ", " .. z .. "\n")
        echo("  Environment: " .. env .. "\n")
        echo("  Exits:\n")
        for dir, exit_id in pairs(exits) do
            local exit_name = getRoomName(exit_id) or "Unknown Room"
            echo("    " .. dir .. " -> Room " .. exit_id .. " (" .. exit_name .. ")\n")
        end
        if next(exit_stubs) then
            echo("  Exit Stubs:\n")
            for _, dir in ipairs(exit_stubs) do
                echo("    " .. dir .. "\n")
            end
        end
        echo("\n")
    end
end
