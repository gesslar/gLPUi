-- Letting Mudlet know that this is a mapper script
mudlet = mudlet or {}; mudlet.mapper_script = true

Gmap = Gmap or {}
Gmap.__index = Gmap

function Gmap.New()
    local self = setmetatable({}, Gmap)
    self.room_info = nil
    self.prev_info = nil
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

Gmap.glyphs = Gmap.glyphs or {
    bank = utf8.escape("%x{1F3E6}"),
    shop = utf8.escape("%x{1F4B0}"),
    food = utf8.escape("%x{1F956}"),
    drink = utf8.escape("%x{1F377}"),
    library = utf8.escape("%x{1F4D6}"),
    tavern = utf8.escape("%x{1F378}"),
    inn = utf8.escape("%x{1F3EB}"),
    storage = utf8.escape("%x{1F4E6}"),
}

-- Terrain types for room environments with RGBA color codes
Gmap.terrain_types = {
    ["default"] = {id = 500, color = {220, 220, 220, 255}},  -- Light Gray
    ["beach"] = {id = 501, color = {255, 223, 186, 255}},    -- Light Sand
    ["desert"] = {id = 502, color = {244, 164, 96, 255}},    -- Sandy Brown
    ["dirt road"] = {id = 503, color = {139, 69, 19, 255}},  -- Saddle Brown
    ["forest"] = {id = 504, color = {34, 139, 34, 255}},     -- Forest Green
    ["grass"] = {id = 505, color = {144, 238, 144, 255}},    -- Light Green
    ["indoor"] = {id = 506, color = {60, 42, 33, 255}},      -- Rich Mocha
    ["mountain"] = {id = 507, color = {169, 169, 169, 255}}, -- Dark Gray
    ["mud"] = {id = 508, color = {101, 67, 33, 255}},        -- Dark Brown
    ["path"] = {id = 509, color = {210, 180, 140, 255}},     -- Light Brown
    ["road"] = {id = 510, color = {160, 120, 90, 255}},      -- Soft Brown
    ["sand"] = {id = 511, color = {238, 214, 175, 255}},     -- Soft Sand
    ["snow"] = {id = 512, color = {255, 250, 250, 255}},     -- Snow White
    ["swamp"] = {id = 513, color = {86, 125, 70, 255}},      -- Dark Olive Green
    ["water"] = {id = 514, color = {173, 216, 230, 255}},    -- Light Blue
    ["tunnels"] = {id = 515, color = {102, 85, 68, 255}},    -- Greyish Brown
}

-- Mapping of exit abbreviations to full names
Gmap.exit_map = {
    n = 'north',    ne = 'northeast', nw = 'northwest',
    e = 'east',     w = 'west',
    s = 'south',    se = 'southeast', sw = 'southwest',
    u = 'up',       d = 'down',
    ["in"] = 'in',  out = 'out',      l = 'look',
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

function Gmap:Setup()
    -- Set custom environment colors for terrain types
    for _, data in pairs(self.terrain_types) do
        local r, g, b, a = unpack(data.color)
        setCustomEnvColor(data.id, r, g, b, a)
    end

    -- Register event handlers
    local handler

    self.event_handlers = {}

    -- Register one-shot event handlers
    for _, event in ipairs(self.OneShotEventHandlers) do
        handler = "Gmap:" .. event
        if registerNamedEventHandler("Gmap", handler, event, function(...) self:eventHandler(...) end, true) then
            table.insert(self.event_handlers, handler)
        end
    end

    -- Register persistent event handlers
    for _, event in ipairs(self.PermEventHandlers) do
        handler = "Gmap:" .. event
        if registerNamedEventHandler("Gmap", handler, event, function(...) self:eventHandler(...) end) then
            table.insert(self.event_handlers, handler)
        end
    end
end

function Gmap:Teardown()
    -- Kill event handlers
    deleteAllNamedEventHandlers("Gmap")
    self.event_handlers = nil
end
