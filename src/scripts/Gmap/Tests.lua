function Gmap:GetCurrentRoom()
  return self.room_info.room_id or -1
end

function Gmap:DisplayCurrentRoom()
  local roomID = self:GetCurrentRoom()
  local stubs = getExitStubs(roomID)

  if roomID == -1 then
    echo("No current room set.\n")
    return
  end

  local info = self.room_info

  if not info then
    echo("No current room set.\n")
    return
  end

  echo("Current Room:\n")
  echo("  Name: " .. info.name .. "\n")
  echo("  Area: " .. info.area .. "\n")
  echo("  ID: " .. roomID .. "\n")
  echo("  Hash: " .. info.hash .. "\n")
  echo("  Coordinates: " .. table.concat(info.coords, ", ") .. "\n")
  echo("  Environment: " .. info.environment .. "\n")
  echo("  Exits:\n")
  for dir, hash in pairs(info.exits) do
    local exitID = getRoomIDbyHash(hash)
    local exitName = exitID ~= -1 and getRoomName(exitID) or "Unexplored Room"
    echo("    " .. dir .. ": " .. exitName .. " (ID: " .. (exitID ~= -1 and exitID or "N/A") .. ")\n")
    echo("    Stub exists: " .. (table.contains(stubs, self.stub_map[dir]) and "Yes" or "No") .. "\n")
  end
end

function Gmap:DisplayMapGrid(roomID)
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

function Gmap:TestSpeedwalk(from, to)
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

function Gmap:CheckRoomExits(roomID)
  local exits = getRoomExits(roomID)
  for dir, target_id in pairs(exits) do
    echo("  " .. dir .. " -> " .. target_id .. "\n")
  end

  local stubs = getExitStubs(roomID)
  for _, stub_num in ipairs(stubs) do
    local dir = self.stub_map[stub_num]
    echo("  " .. dir .. " -> Unexplored\n")
  end
end

function Gmap:DisplayAllRooms()
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
