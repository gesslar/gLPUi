function __PKGNAME__.BuildPanelWindow()
  -- This table is an array of items in the room
  __PKGNAME__.RoomInventoryList = __PKGNAME__.RoomInventoryList or {}
  -- This table is an array of items in the inventory
  __PKGNAME__.InventoryList = __PKGNAME__.InventoryList or {}

  __PKGNAME__.PanelWindow = __PKGNAME__.PanelWindow or Geyser.UserWindow:new({
    name = "PanelWindow",
    x = 0,
    y = 0,
    width = 250,
    height = "100%",
    titleText = "__PKGNAME__",
    docked = true,
    dockPosition = "r",
    restoreLayout = false,
  })

  __PKGNAME__.Panel = __PKGNAME__.Panel or Geyser.Label:new({
    name = "Panel",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
    stylesheet = __PKGNAME__.styles.Panel,
  }, __PKGNAME__.PanelWindow)

  __PKGNAME__.Container = __PKGNAME__.Container or Geyser.VBox:new({
    name = "Container",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
  }, __PKGNAME__.Panel)

  __PKGNAME__.InventoryLabel = __PKGNAME__.InventoryLabel or Geyser.Label:new({
    name = "InventoryLabel",
    width = "100%",
    stylesheet = __PKGNAME__.styles.Panel,
  }, __PKGNAME__.Container)

  __PKGNAME__.InventoryContainer = __PKGNAME__.InventoryContainer or Geyser.VBox:new({
    name = "InventoryContainer",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
  }, __PKGNAME__.InventoryLabel)

  __PKGNAME__.InventoryRoomContainer = __PKGNAME__.InventoryRoomContainer or Geyser.VBox:new({
    name = "InventoryRoomContainer",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
  }, __PKGNAME__.InventoryContainer)

  __PKGNAME__.InventoryRoomLabel = __PKGNAME__.InventoryRoomLabel or Geyser.Label:new({
    name = "InventoryRoomLabel",
    height = 30,
    v_policy = Geyser.Fixed,
    stylesheet = __PKGNAME__.styles.Panel,
    message = "Room",
  }, __PKGNAME__.InventoryRoomContainer)

  __PKGNAME__.InventoryRoom = __PKGNAME__.InventoryRoom or Geyser.MiniConsole:new({
    name = "InventoryRoom",
    scrollBar = true,
    width = "100%",
  }, __PKGNAME__.InventoryRoomContainer)
  __PKGNAME__.InventoryRoom:setFont(__PKGNAME__.styles.MainFontName)
  __PKGNAME__.InventoryRoom:setFontSize(__PKGNAME__.metrics.inventory_font_size)
  __PKGNAME__.InventoryRoom:disableScrolling()

  -- Splitter
  __PKGNAME__.SplitterLabel1 = __PKGNAME__.SplitterLabel1 or Geyser.Label:new({
    name = "SplitterLabel1",
    height = __PKGNAME__.splitter.size,
    v_policy = Geyser.Fixed,
  }, __PKGNAME__.InventoryContainer)
  __PKGNAME__.SplitterLabel1:setFontSize(__PKGNAME__.splitter.font_size)
  __PKGNAME__.SplitterLabel1:echo(nil, "nocolor", nil)
  __PKGNAME__.SplitterLabel1:setStyleSheet(__PKGNAME__.styles.SplitterLabel)
  __PKGNAME__.SplitterLabel1:echo(__PKGNAME__.splitter.symbol)

  __PKGNAME__.InventoryInvContainer = __PKGNAME__.InventoryInvContainer or Geyser.VBox:new({
    name = "InventoryInvContainer",
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
  }, __PKGNAME__.InventoryContainer)

  __PKGNAME__.InventoryInvLabel = __PKGNAME__.InventoryInvLabel or Geyser.Label:new({
    name = "InventoryInvLabel",
    height = 30,
    v_policy = Geyser.Fixed,
    stylesheet = __PKGNAME__.styles.Panel,
    message = "Inventory",
  }, __PKGNAME__.InventoryInvContainer)

  __PKGNAME__.InventoryInv = __PKGNAME__.InventoryInv or Geyser.MiniConsole:new({
    name = "InventoryInv",
    scrollBar = true,
  }, __PKGNAME__.InventoryInvContainer)
  __PKGNAME__.InventoryInv:setFont(__PKGNAME__.styles.MainFontName)
  __PKGNAME__.InventoryInv:setFontSize(__PKGNAME__.metrics.inventory_font_size)
  __PKGNAME__.InventoryInv:disableScrolling()

  -- Keep the section header borders (styles.Panel) above their Lists. Each List
  -- sits directly below its header and, created later, is on top in z-order, so
  -- as the VBox re-rounds positions on resize the List's top edge can clip the
  -- header's 1px bottom border. Raising the headers lets their border always win.
  raiseWindow(__PKGNAME__.InventoryRoomLabel.name)
  raiseWindow(__PKGNAME__.InventoryInvLabel.name)

  __PKGNAME__.CoinLabel = __PKGNAME__.CoinLabel or Geyser.Label:new({
    name = "CoinLabel",
    height = 25,
    v_policy = Geyser.Fixed,
    stylesheet = __PKGNAME__.styles.MainBG,
  }, __PKGNAME__.InventoryInvContainer)

  __PKGNAME__.Splitter1 = __PKGNAME__.Splitter1 or Geyser.Splitter:new({
    name = "__PKGNAME__:Splitter1",
    orientation = "vertical",
    anchor = "bottom",
    top = __PKGNAME__.InventoryRoomContainer,
    middle = __PKGNAME__.SplitterLabel1,
    bottom = __PKGNAME__.InventoryInvContainer,
    margins = {
      top = {
        __PKGNAME__.InventoryRoomLabel.get_height(),
        0,
      },
      bottom = {
        0,
        __PKGNAME__.InventoryInvLabel.get_height() +
        __PKGNAME__.CoinLabel.get_height(),
      }
    }
  })

  __PKGNAME__.CoinBox = __PKGNAME__.CoinBox or Geyser.HBox:new({
    x = 0,
    y = 0,
    height = "100%",
    width = "100%",
    name = "CoinBox",
  }, __PKGNAME__.CoinLabel)

  __PKGNAME__.PlatinumBox = __PKGNAME__.PlatinumBox or Geyser.HBox:new({
    name = "PlatinumBox",
    height = "100%",
  }, __PKGNAME__.CoinBox)

  __PKGNAME__.PlatinumLabel = __PKGNAME__.PlatinumLabel or Geyser.Label:new({
    name = "PlatinumLabel",
    width = 25,
    h_policy = Geyser.Fixed,
    stylesheet = __PKGNAME__.styles.CoinLabel,
    message = "",
  }, __PKGNAME__.PlatinumBox)
  __PKGNAME__.PlatinumLabel:setBackgroundImage(
    __PKGNAME__.config.package_path .. "coins/platinum.png"
  )

  __PKGNAME__.PlatinumNumber = __PKGNAME__.PlatinumNumber or Geyser.Label:new({
    name = "PlatinumNumber",
    stylesheet = __PKGNAME__.styles.CoinNumber,
    message = "0",
  }, __PKGNAME__.PlatinumBox)

  __PKGNAME__.GoldBox = __PKGNAME__.GoldBox or Geyser.HBox:new({
    name = "GoldBox",
    height = "100%",
  }, __PKGNAME__.CoinBox)

  __PKGNAME__.GoldLabel = __PKGNAME__.GoldLabel or Geyser.Label:new({
    name = "GoldLabel",
    width = 25,
    h_policy = Geyser.Fixed,
    stylesheet = __PKGNAME__.styles.CoinLabel,
    message = "",
  }, __PKGNAME__.GoldBox)
  __PKGNAME__.GoldLabel:setBackgroundImage(
    __PKGNAME__.config.package_path .. "coins/gold.png"
  )

  __PKGNAME__.GoldNumber = __PKGNAME__.GoldNumber or Geyser.Label:new({
    name = "GoldNumber",
    stylesheet = __PKGNAME__.styles.CoinNumber,
    message = "0",
  }, __PKGNAME__.GoldBox)

  __PKGNAME__.SilverBox = __PKGNAME__.SilverBox or Geyser.HBox:new({
    name = "SilverBox",
    height = "100%",
  }, __PKGNAME__.CoinBox)

  __PKGNAME__.SilverLabel = __PKGNAME__.SilverLabel or Geyser.Label:new({
    name = "SilverLabel",
    width = 25,
    h_policy = Geyser.Fixed,
    stylesheet = __PKGNAME__.styles.CoinLabel,
    message = "",
  }, __PKGNAME__.SilverBox)
  __PKGNAME__.SilverLabel:setBackgroundImage(
    __PKGNAME__.config.package_path .. "coins/silver.png"
  )

  __PKGNAME__.SilverNumber = __PKGNAME__.SilverNumber or Geyser.Label:new({
    name = "SilverNumber",
    stylesheet = __PKGNAME__.styles.CoinNumber,
    message = "0",
  }, __PKGNAME__.SilverBox)

  __PKGNAME__.CopperBox = __PKGNAME__.CopperBox or Geyser.HBox:new({
    name = "CopperBox",
    height = "100%",
  }, __PKGNAME__.CoinBox)

  __PKGNAME__.CopperLabel = __PKGNAME__.CopperLabel or Geyser.Label:new({
    name = "CopperLabel",
    width = 25,
    h_policy = Geyser.Fixed,
    stylesheet = __PKGNAME__.styles.CoinLabel,
    message = "",
  }, __PKGNAME__.CopperBox)
  __PKGNAME__.CopperLabel:setBackgroundImage(
    __PKGNAME__.config.package_path .. "coins/copper.png"
  )

  __PKGNAME__.CopperNumber = __PKGNAME__.CopperNumber or Geyser.Label:new({
    name = "CopperNumber",
    stylesheet = __PKGNAME__.styles.CoinNumber,
    message = "0",
  }, __PKGNAME__.CopperBox)

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
      num_str = string.sub(num_str, 2) -- Remove the negative sign for processing
    end

    len = #num_str
    dot_index = string.find(num_str, "%.", 1, true)

    -- If there's a decimal point, handle the fractional part separately
    if dot_index then
      ---@diagnostic disable-next-line: cast-local-type
      result = add_commas(tonumber(string.sub(num_str, 1, dot_index - 1))) -- Recurse on the integer part
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

  function __PKGNAME__.UpdateCoin(type)
    local widget = __PKGNAME__[Capitalize(type) .. "Number"]
    local value = __PKGNAME__.purse[type]

    widget:echo(add_commas(value))
  end

  function __PKGNAME__.UpdateCoins()
    if not gmcp.Char.Status.wealth then
      return
    end

    local coins = gmcp.Char.Status.wealth

    if #table.keys(coins) == 0 then
      for type, _ in pairs(__PKGNAME__.purse) do
        __PKGNAME__.purse[type] = 0
        __PKGNAME__.UpdateCoin(type)
      end
    else
      for type, _ in pairs(__PKGNAME__.purse) do
        if table.contains(coins, type) then
          __PKGNAME__.purse[type] = tonumber(coins[type])
          __PKGNAME__.UpdateCoin(type)
        end
      end
    end
  end

  local handler

  handler = __PKGNAME__.config.package_name .. ":UpdateCoins"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Status", "__PKGNAME__:UpdateCoins"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  -- -- Splitter
  -- __PKGNAME__.SplitterLabel2 = __PKGNAME__.SplitterLabel2 or Geyser.Label:new({
  --   name = "SplitterLabel2",
  --   height = __PKGNAME__.splitter.size,
  --   stylesheet = __PKGNAME__.styles.SplitterLabel,
  --   v_policy = Geyser.Fixed,
  --   fontSize = __PKGNAME__.splitter.font_size,
  -- }, __PKGNAME__.Container)
  -- __PKGNAME__.SplitterLabel2:echo(nil, "nocolor", nil)
  -- __PKGNAME__.SplitterLabel2:setStyleSheet(__PKGNAME__.styles.SplitterLabel)
  -- __PKGNAME__.SplitterLabel2:echo(__PKGNAME__.splitter.symbol)

  -- __PKGNAME__.Map = __PKGNAME__.Map or Geyser.Mapper:new({
  --   name = "Map",
  --   width = "100%",
  --   height = 300,
  --   v_policy = Geyser.Fixed,
  -- }, __PKGNAME__.Container)

  -- __PKGNAME__.Splitter2 = __PKGNAME__.Splitter2 or Splitter:new({
  --   name = "__PKGNAME__:Splitter2",
  --   orientation = "vertical",
  --   top = __PKGNAME__.InventoryContainer,
  --   middle = __PKGNAME__.SplitterLabel2,
  --   bottom = __PKGNAME__.Map,
  -- })

  function __PKGNAME__.ConvertAttributes(location, attribute_string)
    local attributes = {}

    for str in string.gmatch(attribute_string, "[%S]") do
      if __PKGNAME__.inventory_attributes[location][str] then
        if __PKGNAME__.inventory_attributes[location][str].enabled then
          attributes[#attributes + 1] = __PKGNAME__.inventory_attributes[location][str].name
        end
      end
    end

    return attributes
  end

  function __PKGNAME__.DetermineUpdateInfo(gmcp_message)
    local location = gmcp_message.location
    if location == "room" then
      return location, __PKGNAME__.InventoryRoom, "RoomInventoryList"
    elseif location == "inv" then
      return location, __PKGNAME__.InventoryInv, "InventoryList"
    end
  end

  function __PKGNAME__.ListInventory(event, ...)
    -- Depending on which inventory we're looking at, we'll need to update
    -- the appropriate table and widget
    local location, widget, table_name = __PKGNAME__.DetermineUpdateInfo(gmcp.Char.Items.List)
    if not table_name then return end
    __PKGNAME__[table_name] = table.deepcopy(gmcp.Char.Items.List.items)
    __PKGNAME__.ScheduleInventoryUpdate(location, widget, table_name)
  end

  function __PKGNAME__.AddInventory(event, ...)
    if not __PKGNAME__ then return end

    local location, widget, table_name = __PKGNAME__.DetermineUpdateInfo(gmcp.Char.Items.Add)
    if not table_name then return end
    table.insert(__PKGNAME__[table_name], 1, table.deepcopy(gmcp.Char.Items.Add.item))
    __PKGNAME__.ScheduleInventoryUpdate(location, widget, table_name)
  end

  function __PKGNAME__.RemoveInventory(event, ...)
    local location, widget, table_name = __PKGNAME__.DetermineUpdateInfo(gmcp.Char.Items.Remove)
    if not table_name then return end

    for i, item in pairs(__PKGNAME__[table_name]) do
      if item.hash == gmcp.Char.Items.Remove.item.hash then
        table.remove(__PKGNAME__[table_name], i)
        break
      end
    end

    __PKGNAME__.ScheduleInventoryUpdate(location, widget, table_name)
  end

  function __PKGNAME__.UpdateInventory(event, ...)
    local location, widget, table_name = __PKGNAME__.DetermineUpdateInfo(gmcp.Char.Items.Update)
    if not table_name then return end
    for i, item in pairs(__PKGNAME__[table_name]) do
      if item.hash == gmcp.Char.Items.Update.item.hash then
        __PKGNAME__[table_name][i] = table.deepcopy(gmcp.Char.Items.Update.item)
        break
      end
    end

    __PKGNAME__.ScheduleInventoryUpdate(location, widget, table_name)
  end

  __PKGNAME__.update_timers = __PKGNAME__.update_timers or {}

  -- Coalesce bursts of GMCP item events (e.g. "drop all" / "get all", which fire
  -- a flurry of Char.Items.Add/Remove) into a single widget rebuild. Every event
  -- still mutates the data table immediately; only the expensive row rebuild is
  -- debounced -- without this, dropping N items triggers N full rebuilds (O(n^2)
  -- Label churn). Keyed by location so room and inv debounce independently. The
  -- table is re-read at fire time (not captured) since ListInventory replaces it.
  function __PKGNAME__.ScheduleInventoryUpdate(location, widget, table_name)
    local pending = __PKGNAME__.update_timers[location]
    if pending then
      killTimer(pending)
    end

    __PKGNAME__.update_timers[location] = tempTimer(__PKGNAME__.metrics.inventory_debounce, function()
      __PKGNAME__.update_timers[location] = nil
      if not __PKGNAME__ then return end
      __PKGNAME__.UpdateInventoryWidget(location, widget, __PKGNAME__[table_name])
    end)
  end

  function __PKGNAME__.UpdateInventoryWidget(location, widget, inventory)
    local old_count = widget:getLineCount()
    local scroll_position = widget:getScroll()

    widget:clear()
    for i, item in pairs(inventory) do
      local line = string.format("%3d %s", i, ansi2decho(item.name))
      local attribs = __PKGNAME__.ConvertAttributes(location, item.attrib)

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

  function __PKGNAME__.Disconnect()
    __PKGNAME__.RoomInventoryList = {}
    __PKGNAME__.InventoryList = {}

    __PKGNAME__.UpdateInventoryWidget("room", __PKGNAME__.InventoryRoom, __PKGNAME__.RoomInventoryList)
    __PKGNAME__.UpdateInventoryWidget("inv", __PKGNAME__.InventoryInv, __PKGNAME__.InventoryList)
  end

  handler = __PKGNAME__.config.package_name .. ":ListInventory"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Items.List", "__PKGNAME__:ListInventory"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":AddInventory"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Items.Add", "__PKGNAME__:AddInventory"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":RemoveInventory"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Items.Remove", "__PKGNAME__:RemoveInventory"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":UpdateInventory"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Items.Update", "__PKGNAME__:UpdateInventory"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":Disconnect"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "sysDisconnectionEvent", "__PKGNAME__:Disconnect"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end
end

function __PKGNAME__.TeardownPanelWindow()
  if __PKGNAME__.Splitter1 then
    __PKGNAME__.Splitter1:disconnect()
  end

  if __PKGNAME__.PanelWindow then
    __PKGNAME__.PanelWindow:delete()
  end
end
