local u = utf8.escape

-- This table is an array of items in the room
GLPUI.RoomInventoryList = GLPUI.RoomInventoryList or {}
-- This table is an array of items in the inventory
GLPUI.InventoryList = GLPUI.InventoryList or {}

GLPUI.MainContainer = GLPUI.MainContainer or Geyser.Label:new({
  name = "MainContainer",
  x = 0,
  y = -(GLPUI.metrics.height),
  width = "100%",
  height = GLPUI.metrics.height,
  stylesheet = GLPUI.Styles.MainBG,
})

GLPUI.BarBox = GLPUI.BarBox or Geyser.HBox:new({
  name = "BarBox",
  x = 0,
  y = 0,
  height = "100%",
  width = "100%",
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
  x = 0,
  y = 0,
  height = "100%",
  width = 30,
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
  if not self then return end

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
  width = "45%",
  h_policy = Geyser.Fixed
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
  name = "FoeBar",
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
  name = "XPBar",
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
  x = 0,
  y = 0,
  height = "100%",
  width = "100%",
}, GLPUI.CapBox);

GLPUI.CapLabel = GLPUI.CapLabel or Geyser.Label:new({
  name = "CapLabel",
  x = 0,
  y = 0,
  height = "100%",
  width = 60,
  message = "Capacity",
  stylesheet = GLPUI.Styles.Label,
  fontSize = GLPUI.metrics.label_font_size,
  h_policy = Geyser.Fixed,
}, GLPUI.CapContainer)
GLPUI.CapLabel:echo(nil, "nocolor", nil)

GLPUI.CapBar = Geyser.Gauge:new({
  name = "CapBar",
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
  if not self then return end

  if not gmcp.Char.Status.xp or not gmcp.Char.Status.tnl then
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
  if not self then return end

  if not gmcp.Char.Status.current_enemy then
    return
  end

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
  if not self then return end

  if not gmcp.Char.Status.fill or not gmcp.Char.Status.capacity then
    return
  end

  local fill = tonumber(gmcp.Char.Status.fill)
  local cap = tonumber(gmcp.Char.Status.capacity)

  self:UpdateBar(self.CapBar, fill, cap);
end

local handler

handler = GLPUI.appName .. ":UpdateVitals"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Vitals", "GLPUI:UpdateVitals"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

handler = GLPUI.appName .. ":UpdateXP"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Status", "GLPUI:UpdateXP"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

handler = GLPUI.appName .. ":UpdateFoe"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Status", "GLPUI:UpdateFoe"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

handler = GLPUI.appName .. ":UpdateCapacity"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Status", "GLPUI:UpdateCapacity"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

GLPUI.PanelWindow = GLPUI.PanelWindow or Geyser.UserWindow:new({
  name = "PanelWindow",
  x = 0,
  y = 0,
  width = 250,
  height = "100%",
  titleText = "gLPUi",
  docked = true,
  dockPosition = "l",
  restoreLayout = true,
})

GLPUI.Panel = GLPUI.Panel or Geyser.Label:new({
  name = "Panel",
  x = 0,
  y = 0,
  width = "100%",
  height = "100%",
  stylesheet = GLPUI.Styles.Panel,
}, GLPUI.PanelWindow)

GLPUI.Container = GLPUI.Container or Geyser.VBox:new({
  name = "Container",
  x = 0,
  y = 0,
  width = "100%",
  height = "100%",
}, GLPUI.Panel)

GLPUI.InventoryLabel = GLPUI.InventoryLabel or Geyser.Label:new({
  name = "InventoryLabel",
  width = "100%",
  stylesheet = GLPUI.Styles.Panel,
}, GLPUI.Container)

GLPUI.InventoryContainer = GLPUI.InventoryContainer or Geyser.VBox:new({
  name = "InventoryContainer",
  width = "100%",
  height = "100%",
}, GLPUI.InventoryLabel)

GLPUI.InventoryRoomLabel = GLPUI.InventoryRoomLabel or Geyser.Label:new({
  name = "InventoryRoomLabel",
  height = 30,
  v_policy = Geyser.Fixed,
  stylesheet = GLPUI.Styles.Panel,
  message = "Room",
}, GLPUI.InventoryContainer)

GLPUI.InventoryRoom = GLPUI.InventoryRoom or Geyser.MiniConsole:new({
  name = "InventoryRoom",
}, GLPUI.InventoryContainer)

GLPUI.InventoryInvLabel = GLPUI.InventoryInvLabel or Geyser.Label:new({
  name = "InventoryInvLabel",
  height = 30,
  v_policy = Geyser.Fixed,
  stylesheet = GLPUI.Styles.Panel,
  message = "Inventory",
}, GLPUI.InventoryContainer)

GLPUI.InventoryInv = GLPUI.InventoryInv or Geyser.MiniConsole:new({
  name = "InventoryInv",
}, GLPUI.InventoryContainer)

GLPUI.CoinLabel = GLPUI.CoinLabel or Geyser.Label:new({
  name = "CoinLabel",
  height = 25,
  v_policy = Geyser.Fixed,
  stylesheet = GLPUI.Styles.MainBG,
}, GLPUI.Container)

GLPUI.CoinBox = GLPUI.CoinBox or Geyser.HBox:new({
  x = 0,
  y = 0,
  height = "100%",
  width = "100%",
  name = "CoinBox",
}, GLPUI.CoinLabel)

GLPUI.PlatinumBox = GLPUI.PlatinumBox or Geyser.HBox:new({
  name = "PlatinumBox",
  height = "100%",
}, GLPUI.CoinBox)

GLPUI.PlatinumLabel = GLPUI.PlatinumLabel or Geyser.Label:new({
  name = "PlatinumLabel",
  width = 25,
  h_policy = Geyser.Fixed,
  stylesheet = GLPUI.Styles.CoinLabel,
  message = GLPUI.CoinConfig.symbol,
  fontSize = GLPUI.metrics.coin_font_size,
}, GLPUI.PlatinumBox)
GLPUI.PlatinumLabel:echo(nil, "nocolor", nil)
GLPUI.PlatinumLabel:setStyleSheet(f [[
    {GLPUI.Styles.Center}
    color: rgb({GLPUI.CoinConfig.colours.platinum[1]},{GLPUI.CoinConfig.colours.platinum[2]},{GLPUI.CoinConfig.colours.platinum[3]});
]])

GLPUI.PlatinumNumber = GLPUI.PlatinumNumber or Geyser.Label:new({
  name = "PlatinumNumber",
  stylesheet = GLPUI.Styles.CoinLabel,
  message = "0",
}, GLPUI.PlatinumBox)

GLPUI.GoldBox = GLPUI.GoldBox or Geyser.HBox:new({
  name = "GoldBox",
  height = "100%",
}, GLPUI.CoinBox)

GLPUI.GoldLabel = GLPUI.GoldLabel or Geyser.Label:new({
  name = "GoldLabel",
  width = 25,
  h_policy = Geyser.Fixed,
  stylesheet = GLPUI.Styles.CoinLabel,
  message = GLPUI.CoinConfig.symbol,
  fontSize = GLPUI.metrics.coin_font_size,
}, GLPUI.GoldBox)

GLPUI.GoldLabel:echo(nil, "nocolor", nil)
GLPUI.GoldLabel:setStyleSheet(f [[
    {GLPUI.Styles.Center}
    color: rgb({GLPUI.CoinConfig.colours.gold[1]},{GLPUI.CoinConfig.colours.gold[2]},{GLPUI.CoinConfig.colours.gold[3]});
]])

GLPUI.GoldNumber = GLPUI.GoldNumber or Geyser.Label:new({
  name = "GoldNumber",
  stylesheet = GLPUI.Styles.CoinLabel,
  message = "0",
}, GLPUI.GoldBox)

GLPUI.SilverBox = GLPUI.SilverBox or Geyser.HBox:new({
  name = "SilverBox",
}, GLPUI.CoinBox)

GLPUI.SilverLabel = GLPUI.SilverLabel or Geyser.Label:new({
  name = "SilverLabel",
  width = 25,
  h_policy = Geyser.Fixed,
  stylesheet = GLPUI.Styles.CoinLabel,
  message = GLPUI.CoinConfig.symbol,
  fontSize = GLPUI.metrics.coin_font_size,
}, GLPUI.SilverBox)

GLPUI.SilverLabel:echo(nil, "nocolor", nil)
GLPUI.SilverLabel:setStyleSheet(f [[
    {GLPUI.Styles.Center}
    color: rgb({GLPUI.CoinConfig.colours.silver[1]},{GLPUI.CoinConfig.colours.silver[2]},{GLPUI.CoinConfig.colours.silver[3]});
]])

GLPUI.SilverNumber = GLPUI.SilverNumber or Geyser.Label:new({
  name = "SilverNumber",
  stylesheet = GLPUI.Styles.CoinLabel,
  message = "0",
}, GLPUI.SilverBox)

GLPUI.CopperBox = GLPUI.CopperBox or Geyser.HBox:new({
  name = "CopperBox",
  height = "100%",
}, GLPUI.CoinBox)

GLPUI.CopperLabel = GLPUI.CopperLabel or Geyser.Label:new({
  name = "CopperLabel",
  width = 25,
  h_policy = Geyser.Fixed,
  stylesheet = GLPUI.Styles.CoinLabel,
  message = GLPUI.CoinConfig.symbol,
  fontSize = GLPUI.metrics.coin_font_size,
}, GLPUI.CopperBox)

GLPUI.CopperLabel:echo(nil, "nocolor", nil)
GLPUI.CopperLabel:setStyleSheet(f [[
    {GLPUI.Styles.Center}
    color: rgb({GLPUI.CoinConfig.colours.copper[1]},{GLPUI.CoinConfig.colours.copper[2]},{GLPUI.CoinConfig.colours.copper[3]});
]])

GLPUI.CopperNumber = GLPUI.CopperNumber or Geyser.Label:new({
  name = "CopperNumber",
  stylesheet = GLPUI.Styles.CoinLabel,
  message = "0",
}, GLPUI.CopperBox)

local function Capitalize(str)
  return (str:gsub("^%l", string.upper))
end

local function add_commas(number)
  local num_str
  local result = ""
  local len
  local dot_index
  local insert_position
  local is_negative = false

  if type(number) == "number" then
    num_str = tostring(number)
  elseif type(number) == "string" then
    dot_index = string.find(number, "%.", 1, true)
    if dot_index then
      local int_part = string.sub(number, 1, dot_index - 1)
      return string.format("%s.%s", add_commas(tonumber(int_part)), string.sub(number, dot_index + 1))
    else
      number = tonumber(number)
    end
    if not number then
      error("add_commas: Argument 1 must be a number, or a string that can be converted to a number.")
    end
    return add_commas(number)
  else
    error("add_commas: Argument 1 must be a number, or a string that can be converted to a number.")
  end

  -- Check if the number is negative
  if string.sub(num_str, 1, 1) == "-" then
    is_negative = true
    num_str = string.sub(num_str, 2)     -- Remove the negative sign for processing
  end

  len = #num_str
  dot_index = string.find(num_str, "%.", 1, true)

  -- If there's a decimal point, handle the fractional part separately
  if dot_index then
    ---@diagnostic disable-next-line: cast-local-type
    result = add_commas(tonumber(string.sub(num_str, 1, dot_index - 1)))     -- Recurse on the integer part
    ---@diagnostic disable-next-line: cast-local-type
    result = string.format("%s.%s", result, string.sub(num_str, dot_index + 1))
    return is_negative and "-" .. result or result
  end

  -- Calculate where to start inserting commas
  insert_position = (len % 3 == 0) and 3 or (len % 3)

  for i = 1, len do
    result = result .. string.sub(num_str, i, i)
    if i == insert_position and i ~= len then
      result = result .. ","
      insert_position = insert_position + 3
    end
  end

  return is_negative and "-" .. result or result
end

function GLPUI:UpdateCoin(type)
  if not self then return end

  local widget = self[Capitalize(type) .. "Number"]
  local value = self.Coins[type]

  widget:echo(add_commas(value))
end

function GLPUI:UpdateCoins()
  if not self then return end

  if not gmcp.Char.Status.wealth then
    return
  end

  local coins = gmcp.Char.Status.wealth

  if #table.keys(coins) == 0 then
    for type, _ in pairs(self.Coins) do
      self.Coins[type] = 0
      self:UpdateCoin(type)
    end
  else
    for type, _ in pairs(self.Coins) do
      if table.contains(coins, type) then
        self.Coins[type] = tonumber(coins[type])
        self:UpdateCoin(type)
      end
    end
  end
end

handler = GLPUI.appName .. ":UpdateCoins"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Status", "GLPUI:UpdateCoins"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

GLPUI.Map = GLPUI.Map or Geyser.Mapper:new({
  name = "Map",
  width = "100%",
  height = 300,
  v_policy = Geyser.Fixed,
}, GLPUI.Container)

function GLPUI:ConvertAttributes(location, attribute_string)
  if not self then return end

  local attributes = {}

  for str in string.gmatch(attribute_string, "[%S]") do
    if self.InventoryAttributes[location][str] then
      if self.InventoryAttributes[location][str].enabled then
        attributes[#attributes + 1] = self.InventoryAttributes[location][str].name
      end
    end
  end

  return attributes
end

function GLPUI:ListInventory(event, ...)
  if not self then return end

  -- Depending on which inventory we're looking at, we'll need to update
  -- the appropriate table and widget

  local location = gmcp.Char.Items.List.location
  local table_name
  local widget
  if location == "room" then
    table_name = "RoomInventoryList"
    widget = self.InventoryRoom
  elseif location == "inv" then
    table_name = "InventoryList"
    widget = self.InventoryInv
  else
    return
  end

  self[table_name] = table.deepcopy(gmcp.Char.Items.List.items)

  self:UpdateInventoryWidget(location, widget, self[table_name])
end

function GLPUI:AddInventory(event, ...)
  if not self then return end

  -- Add the item to the appropriate table
  local location = gmcp.Char.Items.Add.location
  local table_name, widget
  if location == "room" then
    table_name = "RoomInventoryList"
    widget = self.InventoryRoom
    w = self.InventoryRoom
  elseif location == "inv" then
    table_name = "InventoryList"
    widget = self.InventoryInv
  end

  table.insert(self[table_name], 1, table.deepcopy(gmcp.Char.Items.Add.item))
  self:UpdateInventoryWidget(location, widget, self[table_name])
end

function GLPUI:RemoveInventory(event, ...)
  if not self then return end

  local location = gmcp.Char.Items.Remove.location
  local table_name, widget

  if location == "room" then
    table_name = "RoomInventoryList"
    widget = self.InventoryRoom
  elseif location == "inv" then
    table_name = "InventoryList"
    widget = self.InventoryInv
  else
    return
  end

  for i, item in pairs(self[table_name]) do
    if item.hash == gmcp.Char.Items.Remove.item.hash then
      table.remove(self[table_name], i)
      break
    end
  end

  self:UpdateInventoryWidget(location, widget, self[table_name])
end

function GLPUI:UpdateInventory(event, ...)
  if not self then return end

  local location, table_name, widget

  location = gmcp.Char.Items.Update.location
  if location == "room" then
    table_name = "RoomInventoryList"
    widget = self.InventoryRoom
  elseif location == "inv" then
    table_name = "InventoryList"
    widget = self.InventoryInv
  end

  for i, item in pairs(self[table_name]) do
    if item.hash == gmcp.Char.Items.Update.item.hash then
      self[table_name][i] = table.deepcopy(gmcp.Char.Items.Update.item)
      break
    end
  end

  self:UpdateInventoryWidget(location, widget, self[table_name])
end

function GLPUI:UpdateInventoryWidget(location, widget, inventory)
  if not self then return end

  widget:clear()
  for _, item in pairs(inventory) do
    local line = ansi2decho(item.name)
    local attribs = self:ConvertAttributes(location, item.attrib)

    for _, attr in ipairs(attribs) do
      line = line .. " (" .. attr .. ")"
    end

    widget:decho(line .. "\n")
  end
end

function GLPUI:Disconnect()
  if not self then return end

  self.RoomInventoryList = {}
  self.InventoryList = {}

  self:UpdateInventoryWidget("room", self.InventoryRoom, self.RoomInventoryList)
  self:UpdateInventoryWidget("inv", self.InventoryInv, self.InventoryList)

end

handler = GLPUI.appName .. ":ListInventory"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Items.List", "GLPUI:ListInventory"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

handler = GLPUI.appName .. ":AddInventory"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Items.Add", "GLPUI:AddInventory"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

handler = GLPUI.appName .. ":RemoveInventory"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Items.Remove", "GLPUI:RemoveInventory"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

handler = GLPUI.appName .. ":UpdateInventory"
if registerNamedEventHandler(
      GLPUI.appName, handler, "gmcp.Char.Items.Update", "GLPUI:UpdateInventory"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

handler = GLPUI.appName .. ":Disconnect"
if registerNamedEventHandler(
      GLPUI.appName, handler, "sysDisconnectionEvent", "GLPUI:Disconnect"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end
