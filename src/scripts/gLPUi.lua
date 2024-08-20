local u = utf8.escape

GLPUI.MainContainer = GLPUI.MainContainer or Geyser.Label:new({
    name = "MainContainer",
    x = 0, y = -(GLPUI.metrics.height),
    width = "100%", height = GLPUI.metrics.height,
    stylesheet = GLPUI.Styles.MainBG,
})

GLPUI.BarBox = GLPUI.BarBox or Geyser.HBox:new({
    name = "BarBox",
    x = 0, y = 0,
    height = "100%", width = "100%",
}, GLPUI.MainContainer)

-- Char.Vitals information
GLPUI.VitalsBox = GLPUI.VitalsBox or Geyser.VBox:new({
    name = "VitalsBox",
}, GLPUI.BarBox)

-- HP
GLPUI.HPContainer = GLPUI.HPContainer or Geyser.HBox:new({
    name = "HPContainer",
}, GLPUI.VitalsBox);

GLPUI.HPLabel = GLPUI.HPLabel or Geyser.Label:new({
    name = "HPLabel",
    x = 0, y = 0,
    height = "100%", width = 30,
    message = "HP",
    stylesheet = GLPUI.Styles.Label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
}, GLPUI.HPContainer)
GLPUI.HPLabel:echo(nil, "nocolor", nil)

GLPUI.HPBar = GLPUI.HPBar or Geyser.Gauge:new({
    name = "HPBar",
}, GLPUI.HPContainer)
GLPUI.HPBar:setStyleSheet(
    GLPUI.Styles.HPFront,
    GLPUI.Styles.HPBack,
    GLPUI.Styles.GaugeText
)
GLPUI.HPBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
GLPUI.HPBar.text:echo(nil, "nocolor", nil)

-- SP
GLPUI.SPContainer = GLPUI.SPContainer or Geyser.HBox:new({
    name = "SPContainer",
}, GLPUI.VitalsBox);

GLPUI.SPLabel = GLPUI.SPLabel or Geyser.Label:new({
    message = "SP",
    width = 30,
    name = "SPLabel",
    stylesheet = GLPUI.Styles.Label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed,
}, GLPUI.SPContainer)
GLPUI.SPLabel:echo(nil, "nocolor", nil)

GLPUI.SPBar = GLPUI.SPBar or Geyser.Gauge:new({
    name = "SPBar",
}, GLPUI.SPContainer)
GLPUI.SPBar:setStyleSheet(
    GLPUI.Styles.SPFront,
    GLPUI.Styles.SPBack,
    GLPUI.Styles.GaugeText
)
GLPUI.SPBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
GLPUI.SPBar.text:echo(nil, "nocolor", nil)

-- MP
GLPUI.MPContainer = GLPUI.MPContainer or Geyser.HBox:new({
    name = "MPContainer",
}, GLPUI.VitalsBox);

GLPUI.MPLabel = GLPUI.MPLabel or Geyser.Label:new({
    name = "MPLabel",
    width = 30,
    message = "MP",
    stylesheet = GLPUI.Styles.Label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
}, GLPUI.MPContainer)
GLPUI.MPLabel:echo(nil, "nocolor", nil)

GLPUI.MPBar = GLPUI.MPBar or Geyser.Gauge:new({
    name = "MPBar",
}, GLPUI.MPContainer)
GLPUI.MPBar:setStyleSheet(
    GLPUI.Styles.MPFront,
    GLPUI.Styles.MPBack,
    GLPUI.Styles.GaugeText
)
GLPUI.MPBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
GLPUI.MPBar.text:echo(nil, "nocolor", nil)

function GLPUI:UpdateVitals()
    if gmcp.Char.Vitals.hp ~= nil then self.Vitals.HP.current = tonumber(gmcp.Char.Vitals.hp) end
    if gmcp.Char.Vitals.max_hp ~= nil then self.Vitals.HP.max = tonumber(gmcp.Char.Vitals.max_hp) end
    if gmcp.Char.Vitals.sp ~= nil then self.Vitals.SP.current = tonumber(gmcp.Char.Vitals.sp) end
    if gmcp.Char.Vitals.max_sp ~= nil then self.Vitals.SP.max = tonumber(gmcp.Char.Vitals.max_sp) end
    if gmcp.Char.Vitals.mp ~= nil then self.Vitals.MP.current = tonumber(gmcp.Char.Vitals.mp) end
    if gmcp.Char.Vitals.max_mp ~= nil then self.Vitals.MP.max = tonumber(gmcp.Char.Vitals.max_mp) end

    if self.Vitals and self.Vitals.HP and self.Vitals.HP.current and self.Vitals.HP.max then
        self:UpdateBar(
            self.HPBar,
            self.Vitals.HP.current,
            self.Vitals.HP.max
        )
    end

    if self.Vitals and self.Vitals.SP and self.Vitals.SP.current and self.Vitals.SP.max then
        self:UpdateBar(
            self.SPBar,
            self.Vitals.SP.current,
            self.Vitals.SP.max
        )
    end

    if self.Vitals and self.Vitals.MP and self.Vitals.MP.current and self.Vitals.MP.max then
        self:UpdateBar(
            self.MPBar,
            self.Vitals.MP.current,
            self.Vitals.MP.max
        )
    end
end

-- Foe, XP, etc
GLPUI.OtherBox = GLPUI.OtherBox or Geyser.VBox:new({
    name = "OtherBox",
    width = "45%", h_policy = Geyser.Fixed
}, GLPUI.BarBox)

-- Foe
GLPUI.FoeContainer = GLPUI.FoeContainer or Geyser.HBox:new({
    name = "FoeContainer",
}, GLPUI.OtherBox);

GLPUI.FoeLabel = GLPUI.FoeLabel or Geyser.Label:new({
    name = "FoeLabel",
    width = 60,
    message = "Foe",
    stylesheet = GLPUI.Styles.Label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
}, GLPUI.FoeContainer)
GLPUI.FoeLabel:echo(nil, "nocolor", nil)

GLPUI.FoeBar = Geyser.Gauge:new({
    name="FoeBar",
}, GLPUI.FoeContainer)
GLPUI.FoeBar:setStyleSheet(
    GLPUI.Styles.FoeFront,
    GLPUI.Styles.FoeBack,
    GLPUI.Styles.GaugeText
)
GLPUI.FoeBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
GLPUI.FoeBar.text:echo(nil, "nocolor", nil)
GLPUI:UpdateBar(GLPUI.FoeBar, 0, 100, "None")

-- XP
GLPUI.XPContainer = GLPUI.XPContainer or Geyser.HBox:new({
    name = "XPContainer",
}, GLPUI.OtherBox);

GLPUI.XPLabel = GLPUI.XPLabel or Geyser.Label:new({
    name = "XPLabel",
    width = 60,
    message = "XP",
    stylesheet = GLPUI.Styles.Label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
}, GLPUI.XPContainer)
GLPUI.XPLabel:echo(nil, "nocolor", nil)

GLPUI.XPBar = Geyser.Gauge:new({
    name="XPBar",
}, GLPUI.XPContainer)
GLPUI.XPBar:setStyleSheet(
    GLPUI.Styles.XPFront,
    GLPUI.Styles.XPBack,
    GLPUI.Styles.GaugeText
)
GLPUI.XPBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
GLPUI.XPBar.text:echo(nil, "nocolor", nil)

GLPUI.Status = GLPUI.Status or {}
GLPUI.Status.Advancement = GLPUI.Status.Advancement or {}

-- Capacity
GLPUI.CapBox = GLPUI.CapBox or Geyser.HBox:new({
    name = "CapBox",
}, GLPUI.OtherBox)

-- Capacity
GLPUI.CapContainer = GLPUI.CapContainer or Geyser.HBox:new({
    name = "CapContainer",
    x = 0, y = 0,
    height = "100%", width = "100%",
}, GLPUI.CapBox);

GLPUI.CapLabel = GLPUI.CapLabel or Geyser.Label:new({
    name = "CapLabel",
    x = 0, y = 0,
    height = "100%", width = 60,
    message = "Capacity",
    stylesheet = GLPUI.Styles.Label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed,
}, GLPUI.CapContainer)
GLPUI.CapLabel:echo(nil, "nocolor", nil)

GLPUI.CapBar = Geyser.Gauge:new({
    name="CapBar",
    y = "20%",
    height = "75%",
}, GLPUI.CapContainer)
GLPUI.CapBar:setStyleSheet(
    GLPUI.Styles.CapFront,
    GLPUI.Styles.CapBack,
    GLPUI.Styles.GaugeText
)
GLPUI.CapBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
GLPUI.CapBar.text:echo(nil, "nocolor", nil)

function GLPUI:UpdateXP()
    if gmcp.Char.Status.xp == nil or gmcp.Char.Status.tnl == nil then
        return
    end

    local xp = tonumber(gmcp.Char.Status.xp)
    local tnl = tonumber(gmcp.Char.Status.tnl)
    local per = math.floor((xp / tnl) * 100)

    GLPUI.Status.Advancement = {
        xp = xp,
        tnl = tnl,
        per = per
    }

    self:UpdateBar(self.XPBar, xp, tnl)
end

function GLPUI:UpdateFoe()
    local enemy = gmcp.Char.Status.current_enemy
    local enemy_health

    if enemy == nil or enemy == "" then
        enemy = "None"
        enemy_health = 0
    else
        enemy_health = tonumber(gmcp.Char.Status.current_enemy_health)
    end

    self:UpdateBar(self.FoeBar, enemy_health, 100, enemy)
end

function GLPUI:UpdateCapacity()
    local fill = tonumber(gmcp.Char.Status.fill)
    local cap = tonumber(gmcp.Char.Status.capacity)

    self:UpdateBar(self.CapBar, fill, cap) ;
end

local handler

handler = GLPUI.appName .. ":UpdateVitals"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Char.Vitals", "GLPUI:UpdateVitals"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end

handler = GLPUI.appName .. ":UpdateXP"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Char.Status", "GLPUI:UpdateXP"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end

handler = GLPUI.appName .. ":UpdateFoe"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Char.Status", "GLPUI:UpdateFoe"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end

handler = GLPUI.appName .. ":UpdateCapacity"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Char.Status", "GLPUI:UpdateCapacity"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler
end

GLPUI.PanelWindow = GLPUI.PanelWindow or Geyser.UserWindow:new({
    name = "PanelWindow",
    x = 0, y = 0,
    width = 250, height = "100%",
    titleText = "gLPUi",
    docked = true,
    dockPosition = "l",
    restoreLayout = true,
})

GLPUI.Panel = GLPUI.Panel or Geyser.Label:new({
    name = "Panel",
    x = 0, y = 0,
    width = "100%", height = "100%",
    stylesheet = GLPUI.Styles.Panel,
}, GLPUI.PanelWindow)

GLPUI.Container = GLPUI.Container or Geyser.VBox:new({
    name = "Container",
    x = 0, y = 0,
    width = "100%", height = "100%",
}, GLPUI.Panel)

GLPUI.InventoryLabel = GLPUI.InventoryLabel or Geyser.Label:new({
    name = "InventoryLabel",
    width = "100%", height = "100%",
    stylesheet = GLPUI.Styles.Panel,
}, GLPUI.Container)

GLPUI.InventoryContainer = GLPUI.InventoryContainer or Geyser.VBox:new({
    name = "InventoryContainer",
    width = "100%", height = "100%",
}, GLPUI.InventoryLabel)

GLPUI.InventoryRoomLabel = GLPUI.InventoryRoomLabel or Geyser.Label:new({
    name = "InventoryRoomLabel",
    height = 30, v_policy = Geyser.Fixed,
    stylesheet = GLPUI.Styles.Panel,
    message = "Room",
}, GLPUI.InventoryContainer)

GLPUI.InventoryRoom = GLPUI.InventoryRoom or Geyser.MiniConsole:new({
    name = "InventoryRoom",
}, GLPUI.InventoryContainer)

GLPUI.InventoryInvLabel = GLPUI.InventoryInvLabel or Geyser.Label:new({
    name = "InventoryInvLabel",
    height = 30, v_policy = Geyser.Fixed,
    stylesheet = GLPUI.Styles.Panel,
    message = "Inventory",
}, GLPUI.InventoryContainer)

GLPUI.InventoryInv = GLPUI.InventoryInv or Geyser.MiniConsole:new({
    name = "InventoryInv",
}, GLPUI.InventoryContainer)

GLPUI.Map = GLPUI.Map or Geyser.Mapper:new({
    name = "Map",
    width = "100%", height = 300,
    v_policy = Geyser.Fixed,
}, GLPUI.Container)

-- This table is an array of items in the room
GLPUI.RoomInventoryList = GLPUI.RoomInventoryList or {}
-- This table is an array of items in the inventory
GLPUI.InventoryList = GLPUI.InventoryList or {}

function GLPUI:UpdateInventory(event, ...)
    local message, dest, widget

    if not gmcp.Item then return end

    if event == "gmcp.Item.List" then
        message = gmcp.Item.List
    elseif event == "gmcp.Item.Add" then
        message = gmcp.Item.Add
    elseif event == "gmcp.Item.Remove" then
        message = gmcp.Item.Remove
    elseif event == "gmcp.Item.Update" then
        message = gmcp.Item.Update
    end

    if not message then return end

    if message.location == "room" then
        dest = self.RoomInventoryList
        widget = self.InventoryRoom
    elseif message.location == "inventory" then
        dest = self.InventoryList
        widget = self.InventoryInv
    end

    if not dest then return end

    if event == "gmcp.Item.List" then
        dest = table.deepcopy(message.items)
    elseif event == "gmcp.Item.Add" then
        dest[#dest+1] = message
    elseif event == "gmcp.Item.Remove" then
        for i, item in pairs(dest) do
            if item.hash == message.hash then
                table.remove(dest, i)
                break
            end
        end
    elseif event == "gmcp.Item.Update" then
        for i, item in pairs(dest) do
            if item.hash == message.hash then
                dest[i] = message
                break
            end
        end
    end

    self:UpdateInventoryWidget(widget, dest)
end

function GLPUI:UpdateInventoryWidget(widget, inventory)
    widget:clear()
    for i, item in pairs(inventory) do
        local line = ansi2decho(item.name)
        widget:decho(line .. "\n")
    end
end

function GLPUI:Disconnect()
    self.RoomInventoryList = {}
    self.InventoryList = {}

    self:UpdateInventoryWidget(self.InventoryRoom, self.RoomInventoryList)
    self:UpdateInventoryWidget(self.InventoryInv, self.InventoryList)
end

handler = GLPUI.appName .. ":ListInventory"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Item.List", "GLPUI:UpdateInventory"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end

handler = GLPUI.appName .. ":AddInventory"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Item.Add", "GLPUI:UpdateInventory"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end

handler = GLPUI.appName .. ":RemoveInventory"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Item.Remove", "GLPUI:UpdateInventory"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end

handler = GLPUI.appName .. ":UpdateInventory"
if registerNamedEventHandler(
    GLPUI.appName, handler, "gmcp.Item.Update", "GLPUI:UpdateInventory"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end

handler = GLPUI.appName .. ":Disconnect"
if registerNamedEventHandler(
    GLPUI.appName, handler, "sysDisconnectionEvent", "GLPUI:Disconnect"
) then GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler end
