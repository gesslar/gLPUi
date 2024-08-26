-- Letting Mudlet know that this is a mapper script
mudlet = mudlet or {}; mudlet.mapper_script = true
table.unpack = unpack

-- Gmap setup
Gmap = Gmap or {
    room_info = nil,                -- Current room info
    prev_info = nil,                -- Previous room info
    expect_coordinates = true,      -- Expect coordinates from GMCP
    expect_size = true,            -- Expect size from GMCP
    expect_hash = true,             -- Expect hash from GMCP. If false, will expect vnums.
    default_size = {1, 1, 1},       -- Default size for rooms
    speedwalk_path = {},            -- Speedwalk path
    speedwalk_delay = 0.5,          -- Speedwalk delay
    speedwalk_delay_min = 0.1,      -- Minimum speedwalk delay
    walk_timer = nil,               -- Walk timer
    walk_timer_name = nil,          -- Walk timer name
    walk_step = nil,                -- The next room id for the speedwalk
    event_handlers = {},            -- Event handlers
    name = "Gmap",                  -- Script name
    prefix = "Gmap.",               -- Prefix for handlers
    walking = false,                -- Walking status
    travel_destinations = nil,      -- Travel destinations
    travel_pause = 3.0,             -- Travel pause
    glyphs = {},                    -- Glyphs for rooms
    terrain_types = {},             -- Terrain types for room environments
    exit_map = {},                  -- Mapping of exit abbreviations to full names
    stub_map = {},                  -- Mapping of direction names to their numeric representations and back
    move_vectors = {},              -- Move vectors for room movements
    move_tracking = nil,             -- Move tracking for room movements
}

Gmap.glyphs = {
    name = "Gmap",
    prefix = "Gmap.",
    walking = false
}

-- Glyphs for room environments
Gmap.glyphs = {
    bank    = utf8.escape("%x{1F3E6}"),
    shop    = utf8.escape("%x{1F4B0}"),
    food    = utf8.escape("%x{1F956}"),
    drink   = utf8.escape("%x{1F377}"),
    library = utf8.escape("%x{1F4D6}"),
    tavern  = utf8.escape("%x{1F378}"),
    inn     = utf8.escape("%x{1F3EB}"),
    storage = utf8.escape("%x{1F4E6}"),
}

-- Terrain types for room environments with RGBA color codes
Gmap.terrain_types = {
    ["default"]   = {id = 500, color = {220, 220, 220, 255}}, -- Light Gray
    ["beach"]     = {id = 501, color = {255, 223, 186, 255}}, -- Light Sand
    ["desert"]    = {id = 502, color = {244, 164, 96, 255}},  -- Sandy Brown
    ["dirt road"] = {id = 503, color = {139, 69, 19, 255}},   -- Saddle Brown
    ["forest"]    = {id = 504, color = {34, 139, 34, 255}},   -- Forest Green
    ["grass"]     = {id = 505, color = {144, 238, 144, 255}}, -- Light Green
    ["indoor"]    = {id = 506, color = {60, 42, 33, 255}},    -- Rich Mocha
    ["mountain"]  = {id = 507, color = {169, 169, 169, 255}}, -- Dark Gray
    ["mud"]       = {id = 508, color = {101, 67, 33, 255}},   -- Dark Brown
    ["path"]      = {id = 509, color = {210, 180, 140, 255}}, -- Light Brown
    ["road"]      = {id = 510, color = {160, 120, 90, 255}},  -- Soft Brown
    ["sand"]      = {id = 511, color = {238, 214, 175, 255}}, -- Soft Sand
    ["snow"]      = {id = 512, color = {255, 250, 250, 255}}, -- Snow White
    ["swamp"]     = {id = 513, color = {86, 125, 70, 255}},   -- Dark Olive Green
    ["water"]     = {id = 514, color = {173, 216, 230, 255}}, -- Light Blue
    ["tunnels"]   = {id = 515, color = {102, 85, 68, 255}},   -- Greyish Brown
}

-- Mapping of exit abbreviations to full names
Gmap.exit_map = {
    n = 'north',    ne = 'northeast', nw = 'northwest',
    e = 'east',     w = 'west',
    s = 'south',    se = 'southeast', sw = 'southwest',
    u = 'up',       d = 'down',
    ["in"] = 'in',  out = 'out',
}

Gmap.exit_map_reverse = {
    north = 'n', northeast = 'ne', northwest = 'nw',
    east = 'e', west = 'w',
    south = 's', southeast = 'se', southwest = 'sw',
    up = 'u', down = 'd',
    ["in"] = 'in', out = 'out',
}

-- Mapping of direction names to their numeric representations and vice versa
Gmap.stub_map = {
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

Gmap.move_vectors = {
    north     = { 0,  1,  0},
    south     = { 0, -1,  0},
    east      = { 1,  0,  0},
    west      = {-1,  0,  0},
    northwest = {-1,  1,  0},
    northeast = { 1,  1,  0},
    southwest = {-1, -1,  0},
    southeast = { 1, -1,  0},
    up        = { 0,  0,  1},
    down      = { 0,  0, -1},
}

Gmap.default_event_handlers = {
    -- System events that we want to handle
    "sysUninstall",
    "sysConnectionEvent",
    "sysExitEvent",
    -- GMCP events that we want to handle
    "gmcp.Room.Info",
    "gmcp.Room.Travel"
}

function Gmap:isEmpty(t)
    if t == nil or next(t) == nil then
        return true
    end
    return false
end

function Gmap:EventHandler(event, arg1, arg2)
    if event == "sysUninstall" then
        self:Uninstall(arg1, arg2) -- arg1 is package, arg2 is package_path
    elseif event == "sysConnectionEvent" then
        self:Setup() -- no args
    elseif event == "sysExitEvent" then
        self:Teardown() -- no args
    elseif event == "gmcp.Room.Info" then
        self:Move(arg1) -- arg1 is the GMCP package name
    elseif event == "gmcp.Room.Travel" then
        self:Travel(arg1) -- arg1 is the GMCP package name
    end
end

function Gmap:Uninstall(package, package_path)
    self:Teardown()
    Gmap = nil
end

function Gmap:Setup()
    -- Set custom environment colors for terrain types
    for _, data in pairs(self.terrain_types) do
        local r, g, b, a = table.unpack(data.color)
        setCustomEnvColor(data.id, r, g, b, a)
    end

    -- Register event handlers
    local handler

    -- Register persistent event handlers
    for _, event in ipairs(self.default_event_handlers) do
        handler = self.prefix .. event
        if registerNamedEventHandler(self.name, handler, event, function(...) self:EventHandler(...) end) then
            table.insert(self.event_handlers, handler)
        end
    end

    self.walk_timer_name = self.prefix .. "walk_timer"
    gmod.enableModule(self.name, "Room")
end

function Gmap:Teardown()
    -- Kill event handlers
    deleteAllNamedEventHandlers(self.name)
    self.event_handlers = {}
    self:ResetWalking()
end

function Gmap:Move(gmcp_package)
    self.prev_info = self.room_info

    if self.expect_hash then
        if not gmcp.Room.Info.hash then return end
    else
        if not gmcp.Room.Info.vnum then return end
    end

    self.room_info = {
        hash = gmcp.Room.Info.hash,
        area = gmcp.Room.Info.area,
        name = gmcp.Room.Info.name,
        environment = gmcp.Room.Info.environment,
        symbol = gmcp.Room.Info.symbol,
        exits = table.deepcopy(gmcp.Room.Info.exits),
        type = gmcp.Room.Info.type,
        subtype = gmcp.Room.Info.subtype,
        icon = gmcp.Room.Info.icon,
    }

    if self.expect_coordinates then
        self.room_info.coords = gmcp.Room.Info.coords
    else
        self.room_info.coords = self:CalculateCoordinates()
    end

    if self.expect_size then
        self.room_info.size = gmcp.Room.Info.size
    else
        self.room_info.size = self.default_size
    end

    local room_id = self:AddOrUpdateRoom(self.room_info)

    self:UpdateExits(room_id)

    centerview(room_id)

    self.room_info.room_id = room_id

    -- Keep track of the path we're walking so we can detect if we've veered
    -- off the path. Only record the move if we're actually walking.
    if self.walking then
        -- If the room we've entered is the room we're expected to be in,
        -- then record the move for later comparison.
        if self.walk_step == self.room_info.room_id then
            if not self.move_tracking then
                self.move_tracking = {}
            end

            table.insert(self.move_tracking, {
                prev_room_id = self.room_info.room_id,
                current_room_id = self.room_info.room_id,
            })
        end
    end

    updateMap()
end

function Gmap:AddOrUpdateRoom(info)
    local room_id

    if self.expect_hash then
        room_id = getRoomIDbyHash(info.hash)
        if room_id == -1 then
            room_id = createRoomID()
            addRoom(room_id)
            setRoomIDbyHash(room_id, info.hash)
        end
    else
        if not getRoomName(info.vnum) then
            addRoom(info.vnum)
            room_id = info.vnum
        end
    end

    -- Update room name if it has changed
    if getRoomName(room_id) ~= info.name then
        setRoomName(room_id, info.name or "Unexplored Room")
    end

    -- Update room area if it has changed
    local area_name = info.area or "Undefined"
    local area_id = getAreaTable()[area_name]
    if not area_id then
        area_id = addAreaName(area_name)
    end
    if getRoomArea(room_id) ~= area_id then
        setRoomArea(room_id, area_id)
    end

    -- Update room coordinates if they have changed, otherwise calculate them
    local coords = {}
    if self.expect_coordinates then
        if info.coords then
            coords = info.coords
        end
    else
        -- Calculate coordinates based on previous room
        coords = self:CalculateCoordinates(room_id)
    end

    if #coords == 3 then
        local x, y, z = table.unpack(coords)
        setRoomCoordinates(room_id, x, y, z)
    end

    local env_id
    if info.environment then
        if self.terrain_types[info.environment] then
            env_id = self.terrain_types[info.environment].id
        else
            env_id = self.terrain_types["default"].id
        end
    else
        env_id = self.terrain_types["default"].id
    end

    if getRoomEnv(room_id) ~= env_id then
        setRoomEnv(room_id, env_id)
    end

    if info.icon and utf8.len(info.icon) > 0 then
        setRoomChar(room_id, info.icon)
    elseif info.subtype and table.contains(self.glyphs, info.subtype) then
        setRoomChar(room_id, self.glyphs[info.subtype])
    elseif info.type and table.contains(self.glyphs, info.type) then
        setRoomChar(room_id, self.glyphs[info.type])
    else
        setRoomChar(room_id, "")
    end

    return room_id
end

function Gmap:CalculateCoordinates(roomID)
    local default_coordinates = {0, 0, 0}

    if not self.prev_info then
        return default_coordinates
    end

    local prev_room_id = self.prev_info.room_id

    local coords = {getRoomCoordinates(prev_room_id)} or default_coordinates
    local shift = {0, 0, 0}
    local compare_field
    if self.expect_hash then
        compare_field = "hash"
    else
        compare_field = "vnum"
    end

    for k, v in pairs(self.room_info.exits) do
        if v == self.prev_info[compare_field] and self.move_vectors[k] then
            shift = self.move_vectors[k]
            break
        end
    end

    for n = 1, 3 do
        coords[n] = coords[n] - shift[n]
    end

    return coords
end

function Gmap:UpdateExits(room_id)
    local prev = self.prev_info or {}
    local current = self.room_info or {}

    local current_exits = getRoomExits(room_id) or {}
    local current_stubs = getExitStubs(room_id) or {}
    local prev_exits

    if prev.exits then
        prev_exits = prev.exits
    else
        prev_exits = {}
    end

    -- Update or add new exits
    for dir, id in pairs(current.exits) do
        local exit_room_id

        if self.expect_hash then
            exit_room_id = getRoomIDbyHash(id)
        else
            local tmp = getRoomName(id)
            if tmp then
                exit_room_id = id
            else
                exit_room_id = -1
            end
        end

        -- This exit leads to a room we've seen before
        if exit_room_id ~= -1 then
            -- Neither exit nor stub exists, set exit
            local stub_num = self.stub_map[dir]
            if stub_num then
                if not current_exits[dir] and not current_stubs[stub_num] then
                    setExitStub(room_id, dir, true)
                    connectExitStub(room_id, exit_room_id, dir)
                -- Else if a stub exists, but not an exit, connect the stub
                elseif current_stubs[stub_num] and not current_exits[dir] then
                    connectExitStub(exit_room_id, room_id, dir)
                end
            end
        else
            -- This is an unexplored exit
            if not table.contains(current_stubs, self.stub_map[dir]) then
                setExitStub(room_id, dir, true)
            end
        end
    end

    -- Remove exits that no longer exist
    for dir, _ in pairs(current_exits) do
        if not current.exits[dir] then
            setExit(room_id, -1, dir)
        end
    end
end

-- doSpeedWalk remains a local function
function doSpeedWalk()
    Gmap:Speedwalk()
end

local Step = function() Gmap:Step() end
local Pause = function() Gmap:Pause() end

function Gmap:ResetWalking()
    if table.contains(getNamedTimers(self.name), self.walk_timer_name) then
        deleteNamedTimer(self.name, self.walk_timer_name)
    end

    self.walking = false
    self.speedwalk_path = {}
    self.walk_timer = nil
    self.walk_step = nil
    self.travel_destinations = nil
    self.move_tracking = nil
end

function Gmap:Speedwalk()
    if self:isEmpty(self.room_info) then return end

    if self.walking then
        cecho("<orange_red>You are already walking!\n")
        return
    end

    self.walking = true

    self.speedwalk_path = {}
    if self:isEmpty(speedWalkDir) then
        cecho("<orange_red>No speedwalk direction found.\n")
        self:ResetWalking()
        return
    end
    for i, dir in ipairs(speedWalkDir) do
        table.insert(self.speedwalk_path, { dir, tonumber(speedWalkPath[i]) })
    end

    -- Get the first exit, because speedWalkDir does not include the current room
    -- Inserts {nil, room_id} at the beginning of the path
    local room_exits = getRoomExits(self.room_info.room_id) or {}
    if self:isEmpty(room_exits) then
        cecho("<orange_red>No exits found.\n")
        self:ResetWalking()
        return
    end

    for dir, room_id in pairs(room_exits) do
        if room_id == self.speedwalk_path[1][2] then
            table.insert(self.speedwalk_path, 1, { nil, self.room_info.room_id })
            break
        end
    end

    local timer = self.walk_timer_name
    self.walk_timer = registerNamedTimer(
        self.name, timer, self.speedwalk_delay, Step, false
    )

    if not self.walk_timer then
        cecho("<orange_red>Failed to start walking.\n")
        self:ResetWalking()
        return
    end

    self.walking = true

    local destination_id = self.speedwalk_path[#self.speedwalk_path][2]
    local destination_name = getRoomName(destination_id)
    cecho("<aquamarine>Walking to " .. destination_name .. ".\n")
end

function Gmap:Step()
    if self:isEmpty(self.speedwalk_path) then
        if not self:isEmpty(self.travel_destinations) then
            local destinations = self.travel_destinations or {}

            if self:isEmpty(destinations) then
                cecho("<orange_red>No travel destinations found.\n")
                self:ResetWalking()
                return
            end

            self:ResetWalking()

            local timer = self.walk_timer_name
            registerNamedTimer(
                self.name, timer, self.travel_pause, function() gotoRoom(destinations[1]) end, false
            )
            cecho("<aquamarine>You pause at the " .. self.room_info.name .. ".\n")
            return
        end

        self:ResetWalking()
        cecho("<aquamarine>You have arrived at "..self.room_info.name..".\n")
        return
    end

    local current_room_id = self.room_info.room_id
    if not current_room_id then
        cecho("<orange_red>Unable to determine your current location.\n")
        self:ResetWalking()
        return
    end

    local current_step = self.speedwalk_path[1]

    -- Check if this is the starting room (which doesn't have a direction)
    if not current_step[1] then
        if current_room_id ~= current_step[2] then
            cecho("<orange_red>You are not in the expected starting room.\n")
            self:ResetWalking()
            return
        end
        table.remove(self.speedwalk_path, 1)
        if self:isEmpty(self.speedwalk_path) then
            cecho("<aquamarine>You have arrived at "..self.room_info.name..".\n")
            return
        end
        self.walk_step = current_room_id

        self:Step() -- Recursively call Step to move to the next actual step
        return
    end

    -- Check if we're in the expected room before moving
    if current_room_id ~= self.walk_step then
        if self.move_tracking then
            local last_move = self.move_tracking[#self.move_tracking]
            if last_move then
                if current_room_id == last_move.prev_room_id then
                    cecho("<orange_red>Something prevents you from continuing.\n")
                else
                    cecho("<orange_red>You have veered off the expected path.\n")
                end
            else
                cecho("<orange_red>You have veered off the expected path.\n")
            end
        else
            cecho("<orange_red>You have veered off the expected path.\n")
        end
        self:ResetWalking()
        return
    end

    -- Now we're dealing with a regular step
    local dir, next_room_id = table.unpack(current_step)

    self.walk_step = next_room_id

    local full_dir = self.exit_map[dir] or self.exit_map_reverse[dir]
    if not full_dir then
        cecho("<orange_red>Invalid direction.\n")
        self:ResetWalking()
        return
    end

    send(full_dir, true)

    -- Remove the current step as we've just executed it
    table.remove(self.speedwalk_path, 1)

    -- Set up the timer for the next step
    local timer = self.walk_timer_name
    self.walk_timer = registerNamedTimer(
        self.name, timer, self.speedwalk_delay, function()
            self:Step()
        end,
        false
    )

    -- This should never happen, but it's good to have a fallback
    if not self.walk_timer then
        cecho("<orange_red>Failed to continue walking.\n")
        self:ResetWalking()
        return
    end
end

function Gmap:Travel(gmcp_package)
    if self.walking then
        cecho("<orange_red>You are already walking.\n")
        return
    end

    self.travel_destinations = {}
    for _, destination in ipairs(gmcp.Room.Travel or {}) do
        local room_id
        if self.expect_hash then
            room_id = getRoomIDbyHash(destination)
            if not room_id then
                cecho("<orange_red>Invalid destination.\n")
                return
            end
        else
            room_id = destination
            if not getRoomName(destination) then
                cecho("<orange_red>Invalid destination.\n")
                return
            end
        end
        table.insert(self.travel_destinations, room_id)
    end

    local first_destination = self.travel_destinations[1]

    local path = getPath(self.room_info.room_id, first_destination)
    if not path then
        cecho("<orange_red>Unable to find path to destination.\n")
        self:ResetWalking()
        return
    end

    -- remove the first destination from the list
    table.remove(self.travel_destinations, 1)
    self:Speedwalk()
end

function Gmap:Pause()
    cecho("Pause!\n")
end

function Gmap:SetSpeedwalkDelay(delay)
    delay = tonumber(delay) or 0
    if delay < self.speedwalk_delay_min then
        delay = self.speedwalk_delay_min
    end

    self.speedwalk_delay = delay

    if self.speedwalk_delay == 1 then
        cecho("<aquamarine>Walk speed set to " .. self.speedwalk_delay .. " second per step.\n")
    else
        cecho("<aquamarine>Walk speed set to " .. self.speedwalk_delay .. " seconds per step.\n")
    end
end

-- Finally, let's just do the setup script
Gmap:Setup()
