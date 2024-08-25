Gmap.OneShotEventHandlers = Gmap.OneShotEventHandlers or {
    "sysInstallPackage"
}

Gmap.PermEventHandlers = Gmap.PermEventHandlers or {
    -- System events that we want to handle
    "sysUninstallPackage", "sysExitEvent", "sysSpeedwalkStarted",
    "sysSpeedwalkFinished", "sysSpeedwalkStopped", "sysSpeedwalkPaused",
    "sysSpeedwalkResumed",
    -- GMCP events that we want to handle
    "gmcp.Room.Info", "gmcp.Room.Travel"
}

function Gmap:eventHandler(event, ...)
    if event == "sysInstallPackage" then
        self:Install(...)
    elseif event == "sysUninstallPackage" then
        self:Uninstall(...)
    elseif event == "sysExitEvent" then
        self:Teardown()
    elseif event == "sysSpeedwalkStarted" then
        self:SpeedwalkStarted(...)
    elseif event == "sysSpeedwalkFinished" then
        self:SpeedwalkFinished(...)
    elseif event == "sysSpeedwalkStopped" then
        self:SpeedwalkStopped(...)
    elseif event == "sysSpeedwalkPaused" then
        self:SpeedwalkPaused(...)
    elseif event == "sysSpeedwalkResumed" then
        self:SpeedwalkResumed(...)
    end

    -- Ignore events that are not gmcp.Room.Info
    if event ~= "gmcp.Room.Info" and event ~= "gmcp.Room.Travel" then return end

    if event == "gmcp.Room.Travel" then
        self.travel_destinations = {}
        for _, destination in ipairs(gmcp.Room.Travel or {}) do
            if not getRoomIDbyHash(destination) then
                cecho("<red>Invalid destination.\n")
                return
            end
            table.insert(self.travel_destinations, destination)
        end

        local first_destination = self.travel_destinations[1]
        -- remove the first destination from the list
        table.remove(self.travel_destinations, 1)
        self:Speedwalk(first_destination)
        return
    end

    if self.room_info and gmcp.Room.Info.roomhash == self.room_info.roomhash then
        cecho("<green>You have stopped walking.\n")
        stopSpeedwalk()
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
        coords = gmcp.Room.Info.coords,
        type = gmcp.Room.Info.type,
        subtype = gmcp.Room.Info.subtype,
        icon = gmcp.Room.Info.icon,
    }

    self:HandleMove()
end

function Gmap:Install(package, package_path)
    if package == "gLPUi" then
        -- self:setup()
        cecho("<green>Mapper installed and initialized.\n")
    end
end

function Gmap:Uninstall(package, package_path)
    if package ~= "gLPUi" then return end

    self:Teardown()
    cecho("<red>Mapper uninstalled.\n")
    self = {}
end

function Gmap:MakeRoom(hash)
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

    if utf8.len(info.icon) > 0 then
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

function Gmap:UpdateExits(room_id, info, prev_info)
    local current_exits = getRoomExits(room_id)
    local current_stubs = getExitStubs(room_id)
    local prev_exits

    if prev_info and prev_info.exits then
        prev_exits = prev_info.exits
    else
        prev_exits = {}
    end

    -- Update or add new exits
    for dir, hash in pairs(info.exits) do
        local exit_room_id = getRoomIDbyHash(hash)

        -- This exit leads to a room we've seen before
        if exit_room_id ~= -1 then
            -- Neither exit nor stub exists, set exit
            local stub_num = self.stub_map[dir]
            if not current_exits[dir] and not current_stubs[stub_num] then
                -- echo("Neither exit nor stub exists, setting exit from "..dir.." to "..exit_room_id.."\n")
                setExitStub(room_id, dir, true)
                connectExitStub(room_id, exit_room_id, dir)
            -- Else if a stub exists, but not an exit, connect the stub
            elseif current_stubs[stub_num] and not current_exits[dir] then
                -- echo("Stub exists, but not exit, connecting stub from "..dir.." to "..exit_room_id.."\n")
                connectExitStub(exit_room_id, room_id, dir)
            -- That should cover everything!
            end
        else
            -- This is an unexplored exit
            if not table.contains(current_stubs, self.stub_map[dir]) then
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

function Gmap:HandleMove()
    local prev_info = self.prev_info
    local info = self.room_info
    if not info.roomhash then
        return
    end

    local room_id = self:MakeRoom(info.roomhash)

    self:UpdateExits(room_id, info, prev_info)

    centerview(room_id)
    self.current_room = room_id

    updateMap()
end

function Gmap:Speedwalk(targetHash)
    if not self.room_info or not self.room_info.roomhash then
        return
    end

    local startRoomID = getRoomIDbyHash(self.room_info.roomhash)
    local targetRoomID = getRoomIDbyHash(targetHash)

    if startRoomID == -1 or targetRoomID == -1 then
        cecho("<red>Error: Invalid start or target room.\n")
        return
    end

    local pathExists = getPath(startRoomID, targetRoomID)
    if not pathExists then
        cecho("<red>No path to chosen room found.\n")
        return
    end

    -- Convert speedWalkDir to a string format that speedwalk() can use
    local dirString = table.concat(speedWalkDir, ",")
    -- Use the built-in speedwalk function
    self.speedwalk_path = table.deepcopy(speedWalkPath)
    speedwalk(dirString, false, self.configs.speedwalk_delay, true)
end

-- doSpeedWalk remains a local function
function doSpeedWalk()
    stopSpeedwalk()

    if not gmap.room_info or not gmap.room_info.roomhash then
        return
    end

    local start_room_id = getRoomIDbyHash(gmap.room_info.roomhash)

    if type(speedWalkPath) ~= "table" or #speedWalkPath == 0 then
        cecho("<red>No path to chosen room found.\n")
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
        cecho("<red>No path to chosen room found.\n")
    end
end

function Gmap:setSpeedwalkDelay(delay)
    self.configs.speedwalk_delay = tonumber(delay) or 0
    if self.configs.speedwalk_delay == 1 then
        cecho("<green>Walk speed set to " .. self.configs.speedwalk_delay .. " second per step.\n")
    else
        cecho("<green>Walk speed set to " .. self.configs.speedwalk_delay .. " seconds per step.\n")
    end
end

function Gmap:SpeedwalkStarted(package)
    cecho("<green>Speedwalk started\n")
end

function Gmap:SpeedwalkFinished(package)
    local last_room_id = speedWalkPath[#speedWalkPath]

    local name = getRoomName(last_room_id)

    if #self.travel_destinations > 0 then
        tempTimer(0.01, function() cecho("<green>You pause your travel at " .. name .. "\n") end)
        tempTimer(2, function() self:ContinueTravel() end)
    else
        tempTimer(0.01, function() cecho("<green>You have arrived at " .. name .. "\n") end)
    end
end

function Gmap:ContinueTravel()
    local next_destination = self.travel_destinations[1]
    self:Speedwalk(next_destination)

    -- Remove the first destination from the list
    table.remove(self.travel_destinations, 1)
end

function Gmap:SpeedwalkStopped(package)
    cecho("<green>Speedwalk stopped\n")
end

function Gmap:SpeedwalkPaused(package)
    cecho("<green>Speedwalk paused\n")
end

function Gmap:SpeedwalkResumed(package)
    cecho("<green>Speedwalk resumed\n")
end
