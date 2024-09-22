Highlighter = {
  config = {
    name = "Highlighter",
    package_name = "__PKGNAME__",

    fade = {
      step = 10,
      delay = 0.05
    },
  },
  route = {},
  event_handlers = {
    "sysUninstall",
    "sysConnectionEvent",
    "onMoveMap",
    "onSpeedwalkReset",
    "sysSpeedwalkStarted",
    "sysSpeedwalkFinished",
  },
  fade_timers = {},
  highlighting = false,
}

function Highlighter:Init()
  self:SetupEventHandlers()
end

-- ----------------------------------------------------------------------------
-- Event handler for all events
-- ----------------------------------------------------------------------------

function Highlighter:SetupEventHandlers()
  -- Registered event handlers
  local registered_handlers = getNamedEventHandlers(self.config.name) or {}
  -- Register persistent event handlers
  for _, event in ipairs(self.event_handlers) do
    local handler = self.config.name .. "." .. event
    if not registered_handlers[handler] then
      local result, err = registerNamedEventHandler(self.config.name, handler, event, function(...) self:EventHandler(...) end)
      if not result then
        cecho("<orange_red>Failed to register event handler for " .. event .. "\n")
      end
    end
  end
end

function Highlighter:EventHandler(event, ...)
  if event == "sysUninstall" then
    self:Uninstall(...)
    return
  end
  if event == "sysConnectionEvent" then
    self:OnConnected(...)
    return
  end
  if event == "onMapMove" then
    self:OnMoved(...)
    return
  end
  if event == "onSpeedwalkReset" then
    self:OnReset(...)
    return
  end
  if event == "sysSpeedwalkStarted" then
    self:OnStarted(...)
    return
  end
  if event == "sysSpeedwalkFinished" then
    self:OnComplete(...)
    return
  end
end

-- ----------------------------------------------------------------------------
-- Event handlers for specific events
-- ----------------------------------------------------------------------------

function Highlighter:Uninstall(package, package_path)
  if package ~= self.config.package_name then
    return
  end

  deleteAllNamedEventHandlers(self.config.name)

  self:Reset()
end

function Highlighter:OnConnected(...)
  self.route = {}
end

function Highlighter:OnStarted(room_id)
  self:HighlightRoute(room_id)
  self.highlighting = true
end

function Highlighter:OnMoved(current_room_id, previous_room_id)
  if not self.highlighting or not next(self.route) then
    return
  end

  if previous_room_id then
    if self.route[previous_room_id] then
      if not self.route[previous_room_id].timer then
        self:UnhighlightRoom(previous_room_id)
      end
    end
  end

  if current_room_id then
    if not self.route[current_room_id] or (self.route[current_room_id] and not self.route[current_room_id].timer) then
      self:HighlightRoom(current_room_id)
    end
  end
end

function Highlighter:OnReset(exception, reason)
  self.highlighting = false
  self:Reset(exception)
end

function Highlighter:OnComplete(current_room_id)
  self.highlighting = false
  self:Reset(false)
end

-- ----------------------------------------------------------------------------
-- Highlighter functions
-- ----------------------------------------------------------------------------

function Highlighter:Reset(force)
  self:RemoveHighlights(force)
end

function Highlighter:HighlightRoom(room_id)
  highlightRoom(room_id, 255, 215, 0, 0, 0, 0, 1, 125, 0)
  self.route[room_id] = {}
end

function Highlighter:HighlightRoute(start_room_id)
  if next(self.route) then
    self:RemoveHighlights(true)
  end

  self:HighlightRoom(start_room_id)
  ---@diagnostic disable-next-line: param-type-mismatch
  for i, dir in ipairs(speedWalkDir) do
    local room_id = tonumber(speedWalkPath[i])
    self:HighlightRoom(room_id)
  end
end

function Highlighter:FadeOutHighlight(room_id)
  if not self.route[room_id] then
    return
  end

  if not self.route[room_id].step then
    return
  end

  local fade_step = self.route[room_id].step + 1

  local r, g, b, a = 255, 215, 0, 255 - fade_step * self.config.fade.step

  if a <= 0 then
    unHighlightRoom(room_id)
    table.remove(self.route, room_id)
    return
  end

  highlightRoom(room_id, r, g, b, 0, 0, 0, 1, a, 0)
  self.route[room_id].timer = tempTimer(self.config.fade.delay,
    function() self:FadeOutHighlight(room_id) end,
    false)
  self.route[room_id].step = fade_step
end

function Highlighter:UnhighlightRoom(room_id)
  if self.route[room_id] and self.route[room_id].timer then
    return
  end

  highlightRoom(room_id, 255, 215, 0, 0, 0, 0, 1, 125, 0)

  self.route[room_id] = {
    step = 0,
    timer = tempTimer(0.1, function() self:FadeOutHighlight(room_id) end, false)
  }
end

function Highlighter:RemoveHighlights(force)
  if not next(self.route) then
    return
  end

  for room_id, highlight in pairs(self.route) do
    if force then
      unHighlightRoom(room_id)
      if highlight.timer then
        killTimer(highlight.timer)
      end
      table.remove(self.route, room_id)
    else
      if not highlight.timer then
        self:UnhighlightRoom(room_id)
      end
    end
  end

  if force then
    self.route = {}
  end
end

-- Start it up
Highlighter:Init()
