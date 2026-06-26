__PKGNAME__.glu = require("__PKGNAME__/vendor/Glu-single")("__PKGNAME__")

__PKGNAME__.InitGmcp = function()
  tempTimer(1, function()
    sendGMCP("Char.Status")
    sendGMCP("Char.Vitals")
    sendGMCP("Char.Items.Inv")
    sendGMCP("Char.Items.Room")
  end)
end

__PKGNAME__.BuildUi = function()
  __PKGNAME__.BuildStatusBar()
  __PKGNAME__.BuildPanelWindow()
end

local function Install(_, package)
  if not __PKGNAME__ or package ~= __PKGNAME__.config.package_name then return end

  cecho("<steel_blue>Thank you for installing __PKGNAME__!\n")

  __PKGNAME__.SetupStyles()
  __PKGNAME__.BuildUi()

  setProfileStyleSheet(__PKGNAME__.styles.profile)

  local host, port, status = getConnectionInfo()
  if host and port and status then
    __PKGNAME__.InitGmcp()
  end
end

local function Uninstall(_, package)
  if not __PKGNAME__ or package ~= __PKGNAME__.config.package_name then return end

  -- Delete all named event handlers
  deleteAllNamedEventHandlers(__PKGNAME__.config.package_name)
  deleteAllNamedTimers(__PKGNAME__.config.package_name)

  __PKGNAME__.event_handlers = nil

  __PKGNAME__.TeardownStatusBar()
  __PKGNAME__.TeardownPanelWindow()

  cecho("<orange_red>You have uninstalled __PKGNAME__.\n")

---@diagnostic disable-next-line: assign-type-mismatch
  __PKGNAME__ = nil
end

local function LoadProfile(event, newProfile)
  __PKGNAME__.SetupStyles()
  __PKGNAME__.BuildUi()
end

local function Connected(event)
  __PKGNAME__.InitGmcp()
end

-- Register event handlers
local function RegisterHandlers()
  local handler

  handler = __PKGNAME__.config.package_name .. ":Install"
  registerNamedEventHandler(
    __PKGNAME__.config.package_name,
    handler,
    "sysInstallPackage",
    Install,
    true
  ) -- We don't need to record this, as it is a oneshot.

  handler = __PKGNAME__.config.package_name .. ":Uninstall"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name,
        handler,
        "sysUninstallPackage",
        Uninstall,
        true
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":Load"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name,
        handler,
        "sysLoadEvent",
        LoadProfile,
        false
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end

  handler = __PKGNAME__.config.package_name .. ":Connection"
  if registerNamedEventHandler(
        __PKGNAME__.config.package_name,
        handler,
        "sysConnectionEvent",
        Connected,
        false
      ) then
    __PKGNAME__.event_handlers[#__PKGNAME__.event_handlers + 1] = handler
  end
end

function __PKGNAME__.UpdateBar(bar, value, max, text)
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

RegisterHandlers()
