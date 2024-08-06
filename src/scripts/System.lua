function GLPUI:Install(_, package)
    if package == self.appName then
      setBorderBottom(GLPUI.metrics.height)
      sendGMCP("Char.Status")
      sendGMCP("Char.Vitals")
      cecho("<green>Thank you for installing gLPUi!\n")
    end
end

function GLPUI:Uninstall(_, package)
    if package == self.appName then
        -- Delete all named event handlers
        for _, v in ipairs(self.EventHandlers) do
            if v ~= nil then
                deleteNamedEventHandler(self.appName, v)
            end
        end
        setBorderBottom(0)
        self.MainContainer:hide()
        cecho("<red>You have uninstalled gLPUi.\n")
        GLPUI = {}
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
    GLPUI.EventHandlers[#GLPUI.EventHandlers+1] = handler
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

    local value = per
    if per > 100 then
        value = 100
    elseif per < 5 then
        if value <= 0 then
            value = 0
        else
            value = 5
        end
    end

    if not text then
        text = string.format("%.1f%%", per)
    end

    bar:setValue(value, bar_max, text)
end
