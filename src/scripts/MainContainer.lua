function __PKGNAME__.BuildStatusBar()
  setBorderBottom(__PKGNAME__.metrics.height)

  __PKGNAME__.MainContainer = __PKGNAME__.MainContainer or Geyser.Label:new({
    name = "MainContainer",
    x = 0,
    y = -(__PKGNAME__.metrics.height),
    width = "100%",
    height = __PKGNAME__.metrics.height,
    stylesheet = __PKGNAME__.styles.MainBG,
  })

  __PKGNAME__.BarBox = __PKGNAME__.BarBox or Geyser.HBox:new({
    name = "BarBox",
    x = 0,
    y = 0,
    height = "100%",
    width = "100%",
  }, __PKGNAME__.MainContainer)

  -- Char.Vitals information
  __PKGNAME__.VitalsBox = __PKGNAME__.VitalsBox or Geyser.VBox:new({
    name = "VitalsBox",
  }, __PKGNAME__.BarBox)

  -- HP
  __PKGNAME__.HPContainer = __PKGNAME__.HPContainer or Geyser.HBox:new({
    name = "HPContainer",
  }, __PKGNAME__.VitalsBox);

  __PKGNAME__.HPLabel = __PKGNAME__.HPLabel or Geyser.Label:new({
    name = "HPLabel",
    x = 0,
    y = 0,
    height = "100%",
    width = 30,
    message = "HP",
    stylesheet = __PKGNAME__.styles.Label,
    fontSize = __PKGNAME__.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, __PKGNAME__.HPContainer)
  __PKGNAME__.HPLabel:echo(nil, "nocolor", nil)

  __PKGNAME__.HPBar = __PKGNAME__.HPBar or Geyser.Gauge:new({
    name = "HPBar",
  }, __PKGNAME__.HPContainer)
  __PKGNAME__.HPBar:setStyleSheet(
    __PKGNAME__.styles.HPFront,
    __PKGNAME__.styles.HPBack,
    __PKGNAME__.styles.GaugeText
  )
  __PKGNAME__.HPBar.text:setFont(__PKGNAME__.styles.WidgetFontName)
  __PKGNAME__.HPBar.text:setFontSize(__PKGNAME__.metrics.gaugeFontSize)
  __PKGNAME__.HPBar.text:echo(nil, "nocolor", nil)

  -- SP
  __PKGNAME__.SPContainer = __PKGNAME__.SPContainer or Geyser.HBox:new({
    name = "SPContainer",
  }, __PKGNAME__.VitalsBox);

  __PKGNAME__.SPLabel = __PKGNAME__.SPLabel or Geyser.Label:new({
    message = "SP",
    width = 30,
    name = "SPLabel",
    stylesheet = __PKGNAME__.styles.Label,
    fontSize = __PKGNAME__.metrics.label_font_size,
    h_policy = Geyser.Fixed,
  }, __PKGNAME__.SPContainer)
  __PKGNAME__.SPLabel:echo(nil, "nocolor", nil)

  __PKGNAME__.SPBar = __PKGNAME__.SPBar or Geyser.Gauge:new({
    name = "SPBar",
  }, __PKGNAME__.SPContainer)
  __PKGNAME__.SPBar:setStyleSheet(
    __PKGNAME__.styles.SPFront,
    __PKGNAME__.styles.SPBack,
    __PKGNAME__.styles.GaugeText
  )
  __PKGNAME__.SPBar.text:setFontSize(__PKGNAME__.metrics.gaugeFontSize)
  __PKGNAME__.SPBar.text:echo(nil, "nocolor", nil)

  -- MP
  __PKGNAME__.MPContainer = __PKGNAME__.MPContainer or Geyser.HBox:new({
    name = "MPContainer",
  }, __PKGNAME__.VitalsBox);

  __PKGNAME__.MPLabel = __PKGNAME__.MPLabel or Geyser.Label:new({
    name = "MPLabel",
    width = 30,
    message = "MP",
    stylesheet = __PKGNAME__.styles.Label,
    fontSize = __PKGNAME__.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, __PKGNAME__.MPContainer)
  __PKGNAME__.MPLabel:echo(nil, "nocolor", nil)

  __PKGNAME__.MPBar = __PKGNAME__.MPBar or Geyser.Gauge:new({
    name = "MPBar",
  }, __PKGNAME__.MPContainer)
  __PKGNAME__.MPBar:setStyleSheet(
    __PKGNAME__.styles.MPFront,
    __PKGNAME__.styles.MPBack,
    __PKGNAME__.styles.GaugeText
  )
  __PKGNAME__.MPBar.text:setFontSize(__PKGNAME__.metrics.gaugeFontSize)
  __PKGNAME__.MPBar.text:echo(nil, "nocolor", nil)

  function __PKGNAME__.UpdateVitals()
    if gmcp.Char.Vitals.hp ~= nil then __PKGNAME__.vitals.HP.current = tonumber(gmcp.Char.Vitals.hp) end
    if gmcp.Char.Vitals.max_hp ~= nil then __PKGNAME__.vitals.HP.max = tonumber(gmcp.Char.Vitals.max_hp) end
    if gmcp.Char.Vitals.sp ~= nil then __PKGNAME__.vitals.SP.current = tonumber(gmcp.Char.Vitals.sp) end
    if gmcp.Char.Vitals.max_sp ~= nil then __PKGNAME__.vitals.SP.max = tonumber(gmcp.Char.Vitals.max_sp) end
    if gmcp.Char.Vitals.mp ~= nil then __PKGNAME__.vitals.MP.current = tonumber(gmcp.Char.Vitals.mp) end
    if gmcp.Char.Vitals.max_mp ~= nil then __PKGNAME__.vitals.MP.max = tonumber(gmcp.Char.Vitals.max_mp) end

    if __PKGNAME__.vitals and __PKGNAME__.vitals.HP and __PKGNAME__.vitals.HP.current and __PKGNAME__.vitals.HP.max then
      __PKGNAME__.UpdateBar(
        __PKGNAME__.HPBar,
        __PKGNAME__.vitals.HP.current,
        __PKGNAME__.vitals.HP.max
      )
    end

    if __PKGNAME__.vitals and __PKGNAME__.vitals.SP and __PKGNAME__.vitals.SP.current and __PKGNAME__.vitals.SP.max then
      __PKGNAME__.UpdateBar(
        __PKGNAME__.SPBar,
        __PKGNAME__.vitals.SP.current,
        __PKGNAME__.vitals.SP.max
      )
    end

    if __PKGNAME__.vitals and __PKGNAME__.vitals.MP and __PKGNAME__.vitals.MP.current and __PKGNAME__.vitals.MP.max then
      __PKGNAME__.UpdateBar(
        __PKGNAME__.MPBar,
        __PKGNAME__.vitals.MP.current,
        __PKGNAME__.vitals.MP.max
      )
    end
  end

  -- Foe, XP, etc
  __PKGNAME__.OtherBox = __PKGNAME__.OtherBox or Geyser.VBox:new({
    name = "OtherBox",
    width = "45%",
    h_policy = Geyser.Fixed
  }, __PKGNAME__.BarBox)

  -- Foe
  __PKGNAME__.FoeContainer = __PKGNAME__.FoeContainer or Geyser.HBox:new({
    name = "FoeContainer",
  }, __PKGNAME__.OtherBox);

  __PKGNAME__.FoeLabel = __PKGNAME__.FoeLabel or Geyser.Label:new({
    name = "FoeLabel",
    width = 60,
    message = "Foe",
    stylesheet = __PKGNAME__.styles.Label,
    fontSize = __PKGNAME__.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, __PKGNAME__.FoeContainer)
  __PKGNAME__.FoeLabel:echo(nil, "nocolor", nil)

  __PKGNAME__.FoeBar = Geyser.Gauge:new({
    name = "FoeBar",
  }, __PKGNAME__.FoeContainer)
  __PKGNAME__.FoeBar:setStyleSheet(
    __PKGNAME__.styles.FoeFront,
    __PKGNAME__.styles.FoeBack,
    __PKGNAME__.styles.GaugeText
  )
  __PKGNAME__.FoeBar.text:setFontSize(__PKGNAME__.metrics.gaugeFontSize)
  __PKGNAME__.FoeBar.text:echo(nil, "nocolor", nil)
  __PKGNAME__.UpdateBar(__PKGNAME__.FoeBar, 0, 100, "None")

  -- XP
  __PKGNAME__.XPContainer = __PKGNAME__.XPContainer or Geyser.HBox:new({
    name = "XPContainer",
  }, __PKGNAME__.OtherBox);

  __PKGNAME__.XPLabel = __PKGNAME__.XPLabel or Geyser.Label:new({
    name = "XPLabel",
    width = 60,
    message = "XP",
    stylesheet = __PKGNAME__.styles.Label,
    fontSize = __PKGNAME__.metrics.label_font_size,
    h_policy = Geyser.Fixed
  }, __PKGNAME__.XPContainer)
  __PKGNAME__.XPLabel:echo(nil, "nocolor", nil)

  __PKGNAME__.XPBar = Geyser.Gauge:new({
    name = "XPBar",
  }, __PKGNAME__.XPContainer)
  __PKGNAME__.XPBar:setStyleSheet(
    __PKGNAME__.styles.XPFront,
    __PKGNAME__.styles.XPBack,
    __PKGNAME__.styles.GaugeText
  )
  __PKGNAME__.XPBar.text:setFontSize(__PKGNAME__.metrics.gaugeFontSize)
  __PKGNAME__.XPBar.text:echo(nil, "nocolor", nil)

  __PKGNAME__.Status = __PKGNAME__.Status or {}
  __PKGNAME__.Status.Advancement = __PKGNAME__.Status.Advancement or {}

  -- Capacity
  __PKGNAME__.CapBox = __PKGNAME__.CapBox or Geyser.HBox:new({
    name = "CapBox",
  }, __PKGNAME__.OtherBox)

  -- Capacity
  __PKGNAME__.CapContainer = __PKGNAME__.CapContainer or Geyser.HBox:new({
    name = "CapContainer",
    x = 0,
    y = 0,
    height = "100%",
    width = "100%",
  }, __PKGNAME__.CapBox);

  __PKGNAME__.CapLabel = __PKGNAME__.CapLabel or Geyser.Label:new({
    name = "CapLabel",
    x = 0,
    y = 0,
    height = "100%",
    width = 60,
    message = "Capacity",
    stylesheet = __PKGNAME__.styles.Label,
    fontSize = __PKGNAME__.metrics.label_font_size,
    h_policy = Geyser.Fixed,
  }, __PKGNAME__.CapContainer)
  __PKGNAME__.CapLabel:echo(nil, "nocolor", nil)

  __PKGNAME__.CapBar = Geyser.Gauge:new({
    name = "CapBar",
    y = "20%",
    height = "75%",
  }, __PKGNAME__.CapContainer)
  __PKGNAME__.CapBar:setStyleSheet(
    __PKGNAME__.styles.CapFront,
    __PKGNAME__.styles.CapBack,
    __PKGNAME__.styles.GaugeText
  )
  __PKGNAME__.CapBar.text:setFontSize(__PKGNAME__.metrics.gaugeFontSize)
  __PKGNAME__.CapBar.text:echo(nil, "nocolor", nil)

  function __PKGNAME__.UpdateXP()
    if not gmcp.Char.Status.xp or not gmcp.Char.Status.tnl then
      return
    end

    local xp = tonumber(gmcp.Char.Status.xp)
    local tnl = tonumber(gmcp.Char.Status.tnl)
    local per = math.floor((xp / tnl) * 100)

    __PKGNAME__.Status.Advancement = {
      xp = xp,
      tnl = tnl,
      per = per
    }

    __PKGNAME__.UpdateBar(__PKGNAME__.XPBar, xp, tnl)
  end

  function __PKGNAME__.UpdateFoe()
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

    __PKGNAME__.UpdateBar(__PKGNAME__.FoeBar, enemy_health, 100, enemy)
  end

  function __PKGNAME__.UpdateCapacity()
    if not gmcp.Char.Status.fill or not gmcp.Char.Status.capacity then
      return
    end

    local fill = tonumber(gmcp.Char.Status.fill)
    local cap = tonumber(gmcp.Char.Status.capacity)

    __PKGNAME__.UpdateBar(__PKGNAME__.CapBar, fill, cap);
  end

  local handler
  printDebug("", true)
  handler = __PKGNAME__.config.package_name .. ":UpdateVitals"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Vitals", "__PKGNAME__:UpdateVitals"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":UpdateXP"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Status", "__PKGNAME__:UpdateXP"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":UpdateFoe"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Status", "__PKGNAME__:UpdateFoe"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":UpdateCapacity"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name, handler, "gmcp.Char.Status", "__PKGNAME__:UpdateCapacity"
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end
end

function __PKGNAME__.TeardownStatusBar()
  if __PKGNAME__.MainContainer then
    __PKGNAME__.MainContainer:hide()
    __PKGNAME__.MainContainer:delete()
    setBorderBottom(0)
  end
end
