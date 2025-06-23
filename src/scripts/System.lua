GLPUI.init_gmcp = function()
  tempTimer(1, function()
    sendGMCP("Char.Status")
    sendGMCP("Char.Vitals")
    sendGMCP("Char.Items.Inv")
    sendGMCP("Char.Items.Room")
  end)
end

local function install(_, package)
  if not GLPUI or package ~= GLPUI.config.package_name then return end

  setBorderBottom(GLPUI.metrics.height)
  cecho("<steel_blue>Thank you for installing gLPUi!\n")

  GLPUI.setupStyles()
  GLPUI.buildUi()
  setProfileStyleSheet(GLPUI.styles.Profile)

  local host, port, status = getConnectionInfo()
  if host and port and status then
    GLPUI.init_gmcp()
  end
end

local function uninstall(_, package)
  if not GLPUI or package ~= GLPUI.config.package_name then return end

  -- Delete all named event handlers
  deleteAllNamedEventHandlers(GLPUI.config.package_name)
  deleteAllNamedTimers(GLPUI.config.package_name)

  GLPUI.event_handlers = nil

  GLPUI.PanelWindow:hide()
  GLPUI.PanelWindow = nil

  setBorderBottom(0)

  GLPUI.MainContainer:hide()
  GLPUI.MainContainer = nil

  cecho("<orange_red>You have uninstalled gLPUi.\n")
  GLPUI = nil
end

local function load(event)
  GLPUI.setupStyles()
  GLPUI.buildUi()
end

local function connection(event)
  GLPUI.init_gmcp()
end

-- Register event handlers
local function registerHandlers()
  local handler

  handler = GLPUI.config.package_name .. ":Install"
  registerNamedEventHandler(
    GLPUI.config.package_name,
    handler,
    "sysInstallPackage",
    install,
    true
  ) -- We don't need to record this, as it is a oneshot.

  handler = GLPUI.config.package_name .. ":Uninstall"
  if registerNamedEventHandler(
    GLPUI.config.package_name,
    handler,
    "sysUninstallPackage",
    uninstall,
    true
  ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":Load"
  if registerNamedEventHandler(
    GLPUI.config.package_name,
    handler,
    "sysLoadEvent",
    load,
    false
  ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end

  handler = GLPUI.config.package_name .. ":Connection"
  if registerNamedEventHandler(
    GLPUI.config.package_name,
    handler,
    "sysConnectionEvent",
    connection,
    false
  ) then
    GLPUI.event_handlers[#GLPUI.event_handlers + 1] = handler
  end
end

function GLPUI.UpdateBar(bar, value, max, text)
  -- We need at least these values to proceed
  if not bar or not value or not max then
    return
  end

  -- This is the percentage of the bar that is full
  -- and also the percentage displayed if no text is
  -- provided.
  local per = (value / max) * 100.0
  local bar_max = 100

  if per > 100 then
    per = 100
  elseif per < 0 then
    per = 0
  end

  local adjusted_value = per

  if not text then
    text = string.format("%.1f%%", per)
  end

  bar:setValue(adjusted_value, bar_max, text)
end

registerHandlers()
