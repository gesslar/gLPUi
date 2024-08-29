function GLPUI:Install(_, package)
  if not self then return end

  if package == self.appName then
    setBorderBottom(GLPUI.metrics.height)
    sendGMCP("Char.Status")
    sendGMCP("Char.Vitals")
    sendGMCP("Char.Items.Inv")
    sendGMCP("Char.Items.Room")
    cecho("<steel_blue>Thank you for installing gLPUi!\n")
  end
end

function GLPUI:Uninstall(_, package)
  if not self then return end

  if package == self.appName then
    -- Delete all named event handlers
    deleteAllNamedEventHandlers(self.appName)
    self.EventHandlers = nil

    GLPUI.PanelWindow:hide()
    GLPUI.PanelWindow = nil

    setBorderBottom(0)

    self.MainContainer:hide()
    self.MainContainer = nil

    cecho("<orange_red>You have uninstalled gLPUi.\n")
    GLPUI = nil
  end
end

-- Register install and uninstall handlers
local handler

handler = GLPUI.appName .. ":Install"
registerNamedEventHandler(
  GLPUI.appName,
  handler,
  "sysInstallPackage",
  "GLPUI:Install",
  true
) -- We don't need to record this, as it is a oneshot.

handler = GLPUI.appName .. ":Uninstall"
if registerNamedEventHandler(
      GLPUI.appName,
      handler,
      "sysUninstallPackage",
      "GLPUI:Uninstall"
    ) then
  GLPUI.EventHandlers[#GLPUI.EventHandlers + 1] = handler
end

function GLPUI:UpdateBar(bar, value, max, text)
  -- We need at least these values to proceed
  if not bar or not value or not max then
    return
  end

  -- This is the percentage of the bar that is full
  -- and also the percentage displayed if no text is
  -- provided.
  local per = (value / max) * 100.0
  local bar_max = 100

  local adjusted_value = per
  if per > 100 then
    adjusted_value = 100
  elseif per < 6 then
    if value <= 0 then
      adjusted_value = 0
    else
      adjusted_value = 6
    end
  end

  if not text then
    text = string.format("%.1f%%", per)
  end

  bar:setValue(adjusted_value, bar_max, text)
end
