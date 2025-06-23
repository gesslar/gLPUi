---@diagnostic disable-next-line: param-type-mismatch
local Splitter = require(f"__PKGNAME__/GeyserSplitter")

function GLPUI.buildUi()
  -- This table is an array of items in the room
  GLPUI.inventory.room = GLPUI.inventory.room or {}
  -- This table is an array of items in the inventory
  GLPUI.inventory.inv = GLPUI.inventory.inv or {}

  GLPUI.MainContainer = GLPUI.MainContainer or Geyser.Label:new({
    name = "MainContainer",
    x = 0,
    y = -(GLPUI.metrics.height),
    width = "100%",
    height = GLPUI.metrics.height,
    stylesheet = GLPUI.styles.MainBG,
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
    stylesheet = GLPUI.styles.label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, GLPUI.HPContainer)
  GLPUI.HPLabel:echo(nil, "nocolor", nil)

  GLPUI.HPBar = GLPUI.HPBar or Geyser.Gauge:new({
    name = "HPBar",
  }, GLPUI.HPContainer)
  GLPUI.HPBar:setStyleSheet(
    GLPUI.styles.HPFront,
    GLPUI.styles.HPBack,
    GLPUI.styles.GaugeText
  )
  GLPUI.HPBar.text:setFont(GLPUI.styles.WidgetFontName)
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
    stylesheet = GLPUI.styles.label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed,
  }, GLPUI.SPContainer)
  GLPUI.SPLabel:echo(nil, "nocolor", nil)

  GLPUI.SPBar = GLPUI.SPBar or Geyser.Gauge:new({
    name = "SPBar",
  }, GLPUI.SPContainer)
  GLPUI.SPBar:setStyleSheet(
    GLPUI.styles.SPFront,
    GLPUI.styles.SPBack,
    GLPUI.styles.GaugeText
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
    stylesheet = GLPUI.styles.label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, GLPUI.MPContainer)
  GLPUI.MPLabel:echo(nil, "nocolor", nil)

  GLPUI.MPBar = GLPUI.MPBar or Geyser.Gauge:new({
    name = "MPBar",
  }, GLPUI.MPContainer)
  GLPUI.MPBar:setStyleSheet(
    GLPUI.styles.MPFront,
    GLPUI.styles.MPBack,
    GLPUI.styles.GaugeText
  )
  GLPUI.MPBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
  GLPUI.MPBar.text:echo(nil, "nocolor", nil)

  function GLPUI.UpdateVitals()
    if gmcp.Char.Vitals.hp ~= nil then GLPUI.vitals.HP.current = tonumber(gmcp.Char.Vitals.hp) end
    if gmcp.Char.Vitals.max_hp ~= nil then GLPUI.vitals.HP.max = tonumber(gmcp.Char.Vitals.max_hp) end
    if gmcp.Char.Vitals.sp ~= nil then GLPUI.vitals.SP.current = tonumber(gmcp.Char.Vitals.sp) end
    if gmcp.Char.Vitals.max_sp ~= nil then GLPUI.vitals.SP.max = tonumber(gmcp.Char.Vitals.max_sp) end
    if gmcp.Char.Vitals.mp ~= nil then GLPUI.vitals.MP.current = tonumber(gmcp.Char.Vitals.mp) end
    if gmcp.Char.Vitals.max_mp ~= nil then GLPUI.vitals.MP.max = tonumber(gmcp.Char.Vitals.max_mp) end

    if GLPUI.vitals and GLPUI.vitals.HP and GLPUI.vitals.HP.current and GLPUI.vitals.HP.max then
      GLPUI.UpdateBar(
        GLPUI.HPBar,
        GLPUI.vitals.HP.current,
        GLPUI.vitals.HP.max
      )
    end

    if GLPUI.vitals and GLPUI.vitals.SP and GLPUI.vitals.SP.current and GLPUI.vitals.SP.max then
      GLPUI.UpdateBar(
        GLPUI.SPBar,
        GLPUI.vitals.SP.current,
        GLPUI.vitals.SP.max
      )
    end

    if GLPUI.vitals and GLPUI.vitals.MP and GLPUI.vitals.MP.current and GLPUI.vitals.MP.max then
      GLPUI.UpdateBar(
        GLPUI.MPBar,
        GLPUI.vitals.MP.current,
        GLPUI.vitals.MP.max
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
    stylesheet = GLPUI.styles.label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, GLPUI.FoeContainer)
  GLPUI.FoeLabel:echo(nil, "nocolor", nil)

  GLPUI.FoeBar = Geyser.Gauge:new({
    name = "FoeBar",
  }, GLPUI.FoeContainer)
  GLPUI.FoeBar:setStyleSheet(
    GLPUI.styles.FoeFront,
    GLPUI.styles.FoeBack,
    GLPUI.styles.GaugeText
  )
  GLPUI.FoeBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
  GLPUI.FoeBar.text:echo(nil, "nocolor", nil)
  GLPUI.UpdateBar(GLPUI.FoeBar, 0, 100, "None")

  -- XP
  GLPUI.XPContainer = GLPUI.XPContainer or Geyser.HBox:new({
    name = "XPContainer",
  }, GLPUI.OtherBox);

  GLPUI.XPLabel = GLPUI.XPLabel or Geyser.Label:new({
    name = "XPLabel",
    width = 60,
    message = "XP",
    stylesheet = GLPUI.styles.label,
    fontSize = GLPUI.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, GLPUI.XPContainer)
  GLPUI.XPLabel:echo(nil, "nocolor", nil)

  GLPUI.XPBar = Geyser.Gauge:new({
    name = "XPBar",
  }, GLPUI.XPContainer)
  GLPUI.XPBar:setStyleSheet(
    GLPUI.styles.XPFront,
    GLPUI.styles.XPBack,
    GLPUI.styles.GaugeText
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
    stylesheet = GLPUI.styles.label,
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
    GLPUI.styles.CapFront,
    GLPUI.styles.CapBack,
    GLPUI.styles.GaugeText
  )
  GLPUI.CapBar.text:setFontSize(GLPUI.metrics.gauge_font_size)
  GLPUI.CapBar.text:echo(nil, "nocolor", nil)

  function GLPUI.UpdateXP()
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

    GLPUI.UpdateBar(GLPUI.XPBar, xp, tnl)
  end

  function GLPUI.UpdateFoe()
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

    GLPUI.UpdateBar(GLPUI.FoeBar, enemy_health, 100, enemy)
  end

  function GLPUI.UpdateCapacity()
    if not gmcp.Char.Status.fill or not gmcp.Char.Status.capacity then
      return
    end

    local fill = tonumber(gmcp.Char.Status.fill)
    local cap = tonumber(gmcp.Char.Status.capacity)

    GLPUI.UpdateBar(GLPUI.CapBar, fill, cap);
  end

  local handler
printDebug("", true)
  handler = GLPUI.config.package_name .. ":UpdateVitals"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Vitals", "GLPUI:UpdateVitals"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":UpdateXP"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Status", "GLPUI:UpdateXP"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":UpdateFoe"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Status", "GLPUI:UpdateFoe"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":UpdateCapacity"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Status", "GLPUI:UpdateCapacity"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
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
    stylesheet = GLPUI.styles.Panel,
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
    stylesheet = GLPUI.styles.Panel,
  }, GLPUI.Container)

  GLPUI.InventoryContainer = GLPUI.InventoryContainer or Geyser.VBox:new({
    name = "InventoryContainer",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
  }, GLPUI.InventoryLabel)

  GLPUI.InventoryRoomContainer = GLPUI.InventoryRoomContainer or Geyser.VBox:new({
    name = "InventoryRoomContainer",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
  }, GLPUI.InventoryContainer)

  GLPUI.InventoryRoomLabel = GLPUI.InventoryRoomLabel or Geyser.Label:new({
    name = "InventoryRoomLabel",
    height = 30,
    v_policy = Geyser.Fixed,
    stylesheet = GLPUI.styles.Panel,
    message = "Room",
  }, GLPUI.InventoryRoomContainer)

  GLPUI.InventoryRoom = GLPUI.InventoryRoom or Geyser.MiniConsole:new({
    name = "InventoryRoom",
    scrollBar = true,
    width = "100%",
  }, GLPUI.InventoryRoomContainer)
  GLPUI.InventoryRoom:setFont(GLPUI.styles.MainFontName)
  GLPUI.InventoryRoom:setFontSize(GLPUI.metrics.inventory_font_size)
  GLPUI.InventoryRoom:disableScrolling()

  -- Splitter
  GLPUI.SplitterLabel1 = GLPUI.SplitterLabel1 or Geyser.Label:new({
    name = "SplitterLabel1",
    height = GLPUI.splitter.size,
    v_policy = Geyser.Fixed,
  }, GLPUI.InventoryContainer)
  GLPUI.SplitterLabel1:setFontSize(GLPUI.splitter.font_size)
  GLPUI.SplitterLabel1:echo(nil, "nocolor", nil)
  GLPUI.SplitterLabel1:setStyleSheet(GLPUI.styles.SplitterLabel)
  GLPUI.SplitterLabel1:echo(GLPUI.splitter.symbol)

  GLPUI.InventoryInvContainer = GLPUI.InventoryInvContainer or Geyser.VBox:new({
    name = "InventoryInvContainer",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
  }, GLPUI.InventoryContainer)

  GLPUI.InventoryInvLabel = GLPUI.InventoryInvLabel or Geyser.Label:new({
    name = "InventoryInvLabel",
    height = 30,
    v_policy = Geyser.Fixed,
    stylesheet = GLPUI.styles.Panel,
    message = "Inventory",
  }, GLPUI.InventoryInvContainer)

  GLPUI.InventoryInv = GLPUI.InventoryInv or Geyser.MiniConsole:new({
    name = "InventoryInv",
    scrollBar = true,
  }, GLPUI.InventoryInvContainer)
  GLPUI.InventoryInv:setFont(GLPUI.styles.MainFontName)
  GLPUI.InventoryInv:setFontSize(GLPUI.metrics.inventory_font_size)
  GLPUI.InventoryInv:disableScrolling()

  GLPUI.CoinLabel = GLPUI.CoinLabel or Geyser.Label:new({
    name = "CoinLabel",
    height = 25,
    v_policy = Geyser.Fixed,
    stylesheet = GLPUI.styles.MainBG,
  }, GLPUI.InventoryInvContainer)

  GLPUI.Splitter1 = GLPUI.Splitter1 or Splitter:new({
    name = "GLPUI:Splitter1",
    orientation = "vertical",
    top = GLPUI.InventoryRoomContainer,
    middle = GLPUI.SplitterLabel1,
    bottom = GLPUI.InventoryInvContainer,
    margins = {
      top = {
        GLPUI.InventoryRoomLabel.get_height(),
        0,
      },
      bottom = {
        0,
        GLPUI.InventoryInvLabel.get_height() +
        GLPUI.CoinLabel.get_height(),
      }
    }
  })

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
    stylesheet = GLPUI.styles.CoinLabel,
    message = GLPUI.coin.symbol,
    fontSize = GLPUI.metrics.coin_font_size,
  }, GLPUI.PlatinumBox)
  GLPUI.PlatinumLabel:echo(nil, "nocolor", nil)
  GLPUI.PlatinumLabel:setStyleSheet(f"{GLPUI.styles.Center} {GLPUI.styles.CoinPlatinum}")

  GLPUI.PlatinumNumber = GLPUI.PlatinumNumber or Geyser.Label:new({
    name = "PlatinumNumber",
    stylesheet = GLPUI.styles.CoinLabel,
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
    stylesheet = GLPUI.styles.CoinLabel,
    message = GLPUI.coin.symbol,
    fontSize = GLPUI.metrics.coin_font_size,
  }, GLPUI.GoldBox)

  GLPUI.GoldLabel:echo(nil, "nocolor", nil)
  GLPUI.GoldLabel:setStyleSheet(f"{GLPUI.styles.Center} {GLPUI.styles.CoinGold}")

  GLPUI.GoldNumber = GLPUI.GoldNumber or Geyser.Label:new({
    name = "GoldNumber",
    stylesheet = GLPUI.styles.CoinLabel,
    message = "0",
  }, GLPUI.GoldBox)

  GLPUI.SilverBox = GLPUI.SilverBox or Geyser.HBox:new({
    name = "SilverBox",
  }, GLPUI.CoinBox)

  GLPUI.SilverLabel = GLPUI.SilverLabel or Geyser.Label:new({
    name = "SilverLabel",
    width = 25,
    h_policy = Geyser.Fixed,
    stylesheet = GLPUI.styles.CoinLabel,
    message = GLPUI.coin.symbol,
    fontSize = GLPUI.metrics.coin_font_size,
  }, GLPUI.SilverBox)

  GLPUI.SilverLabel:echo(nil, "nocolor", nil)
  GLPUI.SilverLabel:setStyleSheet(f"{GLPUI.styles.Center} {GLPUI.styles.CoinSilver}")

  GLPUI.SilverNumber = GLPUI.SilverNumber or Geyser.Label:new({
    name = "SilverNumber",
    stylesheet = GLPUI.styles.CoinLabel,
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
    stylesheet = GLPUI.styles.CoinLabel,
    message = GLPUI.coin.symbol,
    fontSize = GLPUI.metrics.coin_font_size,
  }, GLPUI.CopperBox)

  GLPUI.CopperLabel:echo(nil, "nocolor", nil)
  GLPUI.CopperLabel:setStyleSheet(f"{GLPUI.styles.Center} {GLPUI.styles.CoinCopper}")

  GLPUI.CopperNumber = GLPUI.CopperNumber or Geyser.Label:new({
    name = "CopperNumber",
    stylesheet = GLPUI.styles.CoinLabel,
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

  function GLPUI.UpdateCoin(type)
    local widget = GLPUI[Capitalize(type) .. "Number"]
    local value = GLPUI.purse[type]

    widget:echo(add_commas(value))
  end

  function GLPUI.UpdateCoins()
    if not gmcp.Char.Status.wealth then
      return
    end

    local coins = gmcp.Char.Status.wealth

    if #table.keys(coins) == 0 then
      for type, _ in pairs(GLPUI.purse) do
        GLPUI.purse[type] = 0
        GLPUI.UpdateCoin(type)
      end
    else
      for type, _ in pairs(GLPUI.purse) do
        if table.contains(coins, type) then
          GLPUI.purse[type] = tonumber(coins[type])
          GLPUI.UpdateCoin(type)
        end
      end
    end
  end

  handler = GLPUI.config.package_name .. ":UpdateCoins"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Status", "GLPUI:UpdateCoins"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  -- Splitter
  GLPUI.SplitterLabel2 = GLPUI.SplitterLabel2 or Geyser.Label:new({
    name = "SplitterLabel2",
    height = GLPUI.splitter.size,
    stylesheet = GLPUI.styles.SplitterLabel,
    v_policy = Geyser.Fixed,
    fontSize = GLPUI.splitter.font_size,
  }, GLPUI.Container)
  GLPUI.SplitterLabel2:echo(nil, "nocolor", nil)
  GLPUI.SplitterLabel2:setStyleSheet(GLPUI.styles.SplitterLabel)
  GLPUI.SplitterLabel2:echo(GLPUI.splitter.symbol)

  GLPUI.Map = GLPUI.Map or Geyser.Mapper:new({
    name = "Map",
    width = "100%",
    height = 300,
    v_policy = Geyser.Fixed,
  }, GLPUI.Container)

  GLPUI.Splitter2 = GLPUI.Splitter2 or Splitter:new({
    name = "GLPUI:Splitter2",
    orientation = "vertical",
    top = GLPUI.InventoryContainer,
    middle = GLPUI.SplitterLabel2,
    bottom = GLPUI.Map,
  })

  function GLPUI.ConvertAttributes(location, attribute_string)
    local attributes = {}

    for str in string.gmatch(attribute_string, "[%S]") do
      if GLPUI.inventory_attributes[location][str] then
        if GLPUI.inventory_attributes[location][str].enabled then
          attributes[#attributes + 1] = GLPUI.inventory_attributes[location][str].name
        end
      end
    end

    return attributes
  end

  function GLPUI.DetermineUpdateInfo(gmcp_message)
    local location = gmcp_message.location
    if location == "room" then
      return location, GLPUI.InventoryRoom, "RoomInventoryList"
    elseif location == "inv" then
      return location, GLPUI.InventoryInv, "InventoryList"
    end
  end

  function GLPUI.ListInventory(event, ...)
    -- Depending on which inventory we're looking at, we'll need to update
    -- the appropriate table and widget
    local location, widget, table_name = GLPUI.DetermineUpdateInfo(gmcp.Char.Items.List)
    GLPUI[table_name] = table.deepcopy(gmcp.Char.Items.List.items)
    GLPUI.UpdateInventoryWidget(location, widget, GLPUI[table_name])
  end

  function GLPUI.AddInventory(event, ...)
    if not GLPUI then return end

    local location, widget, table_name = GLPUI.DetermineUpdateInfo(gmcp.Char.Items.Add)
    table.insert(GLPUI[table_name], 1, table.deepcopy(gmcp.Char.Items.Add.item))
    GLPUI.UpdateInventoryWidget(location, widget, GLPUI[table_name])
  end

  function GLPUI.RemoveInventory(event, ...)
    local location, widget, table_name = GLPUI.DetermineUpdateInfo(gmcp.Char.Items.Remove)

    for i, item in pairs(GLPUI[table_name]) do
      if item.hash == gmcp.Char.Items.Remove.item.hash then
        table.remove(GLPUI[table_name], i)
        break
      end
    end

    GLPUI.UpdateInventoryWidget(location, widget, GLPUI[table_name])
  end

  function GLPUI.UpdateInventory(event, ...)
    local location, widget, table_name = GLPUI.DetermineUpdateInfo(gmcp.Char.Items.Update)
    for i, item in pairs(GLPUI[table_name]) do
      if item.hash == gmcp.Char.Items.Update.item.hash then
        GLPUI[table_name][i] = table.deepcopy(gmcp.Char.Items.Update.item)
        break
      end
    end

    GLPUI.UpdateInventoryWidget(location, widget, GLPUI[table_name])
  end

  function GLPUI.UpdateInventoryWidget(location, widget, inventory)
    local old_count = widget:getLineCount()
    local scroll_position = widget:getScroll()

    widget:clear()
    for i, item in pairs(inventory) do
      local line = string.format("%3d %s", i, ansi2decho(item.name))
      local attribs = GLPUI.ConvertAttributes(location, item.attrib)

      for _, attr in ipairs(attribs) do
        line = line .. " (" .. attr .. ")"
      end

      widget:decho(line .. "\n")
    end

    widget:scrollTo(0)
    local new_count = widget:getLineCount()
    if new_count > old_count then
      scroll_position = scroll_position + (new_count - old_count)
    end
    tempTimer(0.001, function() widget:scrollTo(scroll_position) end)

    -- This is included in the hack, but we want to keep this once the
    -- Mudlet issue is fixed. Showing/hiding the scrollbar depending
    -- on whether the widget has more lines than rows.
    if widget:getLineCount() > widget:getRowCount() then
      widget:enableScrollBar()
    else
      widget:disableScrollBar()
    end
  end

  function GLPUI.Disconnect()
    GLPUI.inventory.room = {}
    GLPUI.inventory.inv = {}

    GLPUI.UpdateInventoryWidget("room", GLPUI.InventoryRoom, GLPUI.RoomInventoryList)
    GLPUI.UpdateInventoryWidget("inv", GLPUI.InventoryInv, GLPUI.InventoryList)
  end

  handler = GLPUI.config.package_name .. ":ListInventory"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Items.List", "GLPUI:ListInventory"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":AddInventory"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Items.Add", "GLPUI:AddInventory"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":RemoveInventory"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Items.Remove", "GLPUI:RemoveInventory"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":UpdateInventory"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "gmcp.Char.Items.Update", "GLPUI:UpdateInventory"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":Disconnect"
  if registerNamedEventHandler(
        GLPUI.config.package_name, handler, "sysDisconnectionEvent", "GLPUI:Disconnect"
      ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end
end
