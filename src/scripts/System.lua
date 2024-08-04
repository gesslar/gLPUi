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
