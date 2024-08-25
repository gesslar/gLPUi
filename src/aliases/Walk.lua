local input = matches[2]:trim()
local command, value = input:match("^(%S+)%s*(.*)$")

if command == "slow" then
    command = "speed"
    value = 1.0
elseif command == "fast" then
    command = "speed"
    value = 0.01
end

if command == "stop" then
    -- Stop the speedwalk
    local ok, err = stopSpeedwalk()

    if not ok then
        -- Regex out the first part of the system message that might
        -- begin with "stopSpeedwalk(): "
        local message = err:match("^stopSpeedwalk%(%): (.+)$")
        if message then
            cecho("<red>Unable to stop speedwalk: " .. message .. "\n")
        else
            cecho("<red>Unable to stop speedwalk: " .. err .. "\n")
        end
    else
        cecho("<green>Speedwalk stopped.\n")
    end
elseif command == "speed" then
    if value ~= "" then
        -- Set new speed (delay)
        gmap:setSpeedwalkDelay(value)
    else
        -- Check current speed (delay)
        if gmap.configs.speedwalk_delay == 1 then
            cecho("<green>Current walk speed is " .. gmap.configs.speedwalk_delay .. " second per step.\n")
        else
            cecho("<green>Current walk speed is " .. gmap.configs.speedwalk_delay .. " seconds per step.\n")
        end
    end
elseif command == "to" and tonumber(value) then
    local roomNumber = tonumber(value)
    local result, message = gotoRoom(roomNumber)

    -- Walk to a specific room number
    if not result then
        cecho("<red>Error: Room " .. message .. "\n")
    end
else
    -- Print out the walk instructions
    cecho("<red>Syntax: walk [stop|slow|fast|speed|speed <seconds>|to <room number>]\n")
end
