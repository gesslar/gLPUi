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
    GLPUI.metrics.label_font_size,
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
    if gmcp.Char.Vitals.hp ~= nil then GLPUI.Vitals.HP.current = tonumber(gmcp.Char.Vitals.hp) end
    if gmcp.Char.Vitals.max_hp ~= nil then GLPUI.Vitals.HP.max = tonumber(gmcp.Char.Vitals.max_hp) end
    if gmcp.Char.Vitals.sp ~= nil then GLPUI.Vitals.SP.current = tonumber(gmcp.Char.Vitals.sp) end
    if gmcp.Char.Vitals.max_sp ~= nil then GLPUI.Vitals.SP.max = tonumber(gmcp.Char.Vitals.max_sp) end
    if gmcp.Char.Vitals.mp ~= nil then GLPUI.Vitals.MP.current = tonumber(gmcp.Char.Vitals.mp) end
    if gmcp.Char.Vitals.max_mp ~= nil then GLPUI.Vitals.MP.max = tonumber(gmcp.Char.Vitals.max_mp) end

    if GLPUI.Vitals.HP.current ~= nil and GLPUI.Vitals.HP.max ~= nil then
        self:UpdateBar(
            self.HPBar,
            self.Vitals.HP.current,
            self.Vitals.HP.max
        )
    end

    if GLPUI.Vitals.SP.current ~= nil and GLPUI.Vitals.SP.max ~= nil then
        self:UpdateBar(
            self.SPBar,
            self.Vitals.SP.current,
            self.Vitals.SP.max
        )
    end

    if GLPUI.Vitals.MP.current ~= nil and GLPUI.Vitals.MP.max ~= nil then
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
    if gmcp.Char.Status.xp == nil or gmcp.Char.Status.tnl == nil then return end

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
    local cap = tonumber(gmcp.Char.Status.capacity)
    local max = tonumber(gmcp.Char.Status.max_capacity)
    local per = 100-math.floor((cap / max) * 100)

    self:UpdateBar(self.CapBar, cap, max)
end

local handler

handler = GLPUI.appName .. ":UpdateVitals"
if registerNamedEventHandler(
    GLPUI.appName,
    handler,
    "gmcp.Char.Vitals",
    "GLPUI:UpdateVitals"
) then
    GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler
end

handler = GLPUI.appName .. ":UpdateXP"
if registerNamedEventHandler(
    GLPUI.appName,
    handler,
    "gmcp.Char.Status",
    "GLPUI:UpdateXP"
) then
    GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler
end

handler = GLPUI.appName .. ":UpdateFoe"
if registerNamedEventHandler(
    GLPUI.appName,
    handler,
    "gmcp.Char.Status",
    "GLPUI:UpdateFoe"
) then
    GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler
end

handler = GLPUI.appName .. ":UpdateCapacity"
if registerNamedEventHandler(
    GLPUI.appName,
    handler,
    "gmcp.Char.Status",
    "GLPUI:UpdateCapacity"
) then
    GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler
end
