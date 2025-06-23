--- Splitter is a class that implements a splitter widget, joining
--- two widgets together with a movable bar between them. As you move the
--- middle widget, the widgets on either side of it are resized to maintain
--- a constant total width.
--- Construction:
--- local splitter = Splitter:new({
---   name - The name of the splitter
---   enabled - Whether the splitter is enabled upon creation (defaults to
---             true)
---   cursor - The cursor to use for when the mouse is over the middle
---            widget (defaults to ResizeHorizontal)
---   orientation - The orientation of the splitter (horizontal or vertical,
---                 defaults to horizontal)
---   middle - The widget for the middle of the splitter - required always
---   top - The widget for the top of the splitter - required for vertical
---   bottom - The widget for the bottom of the splitter - required for vertical
---   left - The widget for the left of the splitter - required for horizontal
---   right - The widget for the right of the splitter - required for
---           horizontal
---   left_margin - The margin size for the left of the splitter (defaults to 0)
---   right_margin - The margin size for the right of the splitter (defaults to 0)
---   top_margin - The margin size for the top of the splitter (defaults to 0)
---   bottom_margin - The margin size for the bottom of the splitter (defaults to 0)
--- }
-- @module Splitter
-- @field name - The name of the splitter
-- @field widgets - The widgets that make up the splitter
-- @field cursor - The cursor to use for when the mouse is over the middle
--                 widget
-- @field orientation - The orientation of the splitter
-- @field moving - Whether the splitter is moving
-- @field enabled - Whether the splitter is enabled
-- @field mouse_property - The property of the mouse event that holds the
--                         position of the mouse (x or y)

-- For declarations of local functions
local _percent, _percent_of
local get_start, get_size
local update_widgets, mouse_event
local get_min_bound, get_max_bound

---@diagnostic disable-next-line: undefined-global
local Splitter = Splitter or {
  _VERSION = "0.1",
  _DESCRIPTION = "A splitter widget for Geyser",
  _LICENSE = "IDGAF",
  name = "UtilityClass",
  widgets = {},
}

-- Orientation constants
local orientations = {
  horizontal = 1, h = 1, ["1"] = 1, [1] = 1,
  vertical   = 2, v = 2, ["2"] = 2, [2] = 2,
}
local orientations_reverse = { "horizontal", "vertical" }

-- descriptors
local descriptors = {
  { "left", "middle", "right" },
  { "top", "middle", "bottom" },
}
local coords = { "x", "y" }

-- Widget element constants
local widget_elements = {
  first = 1,  left = 1,   top = 1,    up = 1,     ["1"] = 1, [1] = 1,
  middle = 2, second = 2, center = 2, centre = 2, ["2"] = 2, [2] = 2,
  last = 3,   right = 3,  bottom = 3, down = 3,   ["3"] = 3, [3] = 3,
}

-- Update the widgets.
-- @param splitter - The splitter instance of the Geyser.Splitter class
-- @param override - The override position (optional). If no override is
--                   provided, then the splitter will use the current mouse
--                   position. Otherwise, the override value will be used.
function update_widgets(splitter, cursor)
  if not splitter.enabled and not cursor then return end
  local orientation = splitter.orientation

  local widgets = splitter.widgets

  -- Get the bar information first
  local bar = widgets[2]
  local bar_size = get_size(orientation, bar)
  local bar_start = get_start(orientation, bar)
  local bar_end = bar_start + bar_size
  local position = cursor

  -- If the mouse is on the bar, don't move anything.
  if position >= bar_start and position <= bar_end then
    return
  end

  local total_size = get_size(splitter.orientation, splitter.widgets[3]) +
      get_size(splitter.orientation, splitter.widgets[2]) +
      get_size(splitter.orientation, splitter.widgets[1])

  -- Left or top
  local first = widgets[1]
  local first_start = get_start(splitter.orientation, first)
  local first_size = get_size(splitter.orientation, first)
  local first_min_bound = get_min_bound(splitter, first)
  local first_max_bound = get_max_bound(splitter, first)
  local first_min_position = first_start + first_min_bound
  local first_max_position = bar_start - first_max_bound

  -- Right or bottom
  local last = widgets[3]
  local last_start = get_start(splitter.orientation, last)
  local last_size = get_size(splitter.orientation, last)
  local last_min_bound = get_min_bound(splitter, last)
  local last_max_bound = get_max_bound(splitter, last)
  local last_min_position = bar_end + last_min_bound
  local last_max_position = total_size - last_max_bound - bar_size

  -- Get the mouse position relative to the left/top edge of the first widget
  local local_position = position - first_start

  -- Calculate the new values
  -- The new position of the bar is where the mouse is.
  local new_position = local_position

  -- Let's make sure that the new position would not result in a negative width
  -- for the left or right side, or that we're not on the bar itself.
  local new_first_end = new_position
  local new_first_size = new_first_end - first_start
  local new_last_start = new_position + bar_size
  local new_last_size = total_size - new_first_size - bar_size
  local new_total_size = new_first_size + new_last_size + bar_size

  -- Ensure new_position respects the bounds of the first widget
  if new_position < bar_start then
    if new_position < first_min_position then
      new_position = first_min_position
    elseif new_position > first_max_position then
      new_position = first_max_position
    end
  elseif new_position > bar_end then
    if new_position < last_min_position then
      new_position = last_min_position
    elseif new_position > last_max_position then
      new_position = last_max_position
    end
  end

  -- Recalculate sizes for both widgets
  local new_first_size = new_position - first_start
  local new_last_start = new_position + bar_size
  local new_last_size = total_size - new_first_size - bar_size

  -- Move the bar and the bounding widgets
  if splitter.orientation == orientations.horizontal then
    -- Horizontal
    bar:move(new_position, nil)
    first:resize(string.format("%dpx", new_first_size), nil)
    last:move(string.format("%dpx", new_last_start), nil)
    last:resize(string.format("%dpx", new_last_size), nil)
  else
    -- Vertical
    bar:move(nil, new_position)
    first:resize(nil, string.format("%dpx", new_first_size))
    last:move(nil, string.format("%dpx", new_last_start))
    last:resize(nil, string.format("%dpx", new_last_size))
  end
end

-- Mouse event types
local types = { "click", "move", "release" }
-- This function handles the mouse events for the splitter
-- @param type {string} - The type of mouse event
-- @param self {table} - The splitter instance
-- @param mouse {table} - The information from the mouse event in a table
function mouse_event(self, event_type, mouse)
  if not self.enabled then return end
  if not table.index_of(types, event_type) then return end

  -- If this was a regular click event, check if it was a left button click,
  -- and if so, set the moving flag to true.
  if event_type == "click" then
    if mouse.button ~= "LeftButton" then return end
    self.moving = true
    return
  end

  -- If we aren't moving, then don't do anything.
  if not self.moving then return end

  -- Update the display of the widgets
  local start_of_middle = get_start(self.orientation, self.widgets[2])
  local position = mouse[self.mouse_property]
  update_widgets(self, start_of_middle + position)

  -- If this was a release event, stop moving.
  if event_type == "release" then
    self.moving = false
    return
  end

  -- Since we can only get 3 event types and we've handled click and release,
  -- this must be a move event. But we've already moved everything.
  -- So, we don't need to do anything here. Cya.
end

-- Enable the splitter
function Splitter:enable() self.enabled = true end

-- Disable the splitter
function Splitter:disable() self.enabled = false end

-- Get the minimum local coordinate possible for the splitter related to
-- the first widget's start position.
-- x for horizontal, y for vertical
function Splitter:getMin() return 0 end

-- Get the maximum local coordinate possible for the splitter related to
-- the last widget's end position.
-- x for horizontal, y for vertical
function Splitter:getMax()
  return self:getMin() +
         get_size(self.orientation, self.widgets[3]) +
         get_size(self.orientation, self.widgets[2]) +
         get_size(self.orientation, self.widgets[1])
end

-- Get the absolute minimum coordinate possible for the splitter related to
-- the first widget's start position related to the application window.
-- x for horizontal, y for vertical
function Splitter:getAbsoluteMin()
  return get_start(self.orientation, self.widgets[1])
end

-- Get the absolute maximum coordinate possible for the splitter related to
-- the last widget's end position related to the application window.
-- x for horizontal, y for vertical
function Splitter:getAbsoluteMax()
  return self:getAbsoluteMin() +
         get_size(self.orientation, self.widgets[3]) +
         get_size(self.orientation, self.widgets[2]) +
         get_size(self.orientation, self.widgets[1])
end

-- Set the position of the splitter.
-- x for horizontal, y for vertical
-- @param position - The position to set the splitter to. The number passed
--                   is local to the first widget.
function Splitter:setPosition(position)
  assert(position ~= nil, "position is a required argument")
  assert(type(position) == "number", "position must be a number")

  update_widgets(self, position)
end

-- Adjust the position of the splitter.
-- x for horizontal, y for vertical
-- @param position - The position to adjust the splitter by. The amount is
--                   relative to the current position of the splitter.
function Splitter:adjustPosition(position)
  assert(position ~= nil, "position is a required argument")
  assert(type(position) == "number", "position must be a number")

  local current_position = get_start(self.orientation, self.widgets[2])
  local new_position = current_position + position
  update_widgets(self, new_position)
end

-- Get the position of the splitter.
-- x for horizontal, y for vertical
function Splitter:getPosition()
  return get_start(self.orientation, self.widgets[2]) -
      get_start(self.orientation, self.widgets[1])
end

-- Set the position of the splitter as a ratio of the total size of all
-- three widgets.
-- @param position - The position to set the splitter to as a ratio of the
--                   total size of all three widgets.
function Splitter:setPositionRatio(position)
  assert(position ~= nil, "position is a required argument")
  assert(type(position) == "number", "position must be a number")

  local max = self:getMax()
  local ratio = _percent_of(position, max)
  self:setPosition(ratio)
end

-- Get the position of the splitter as a ratio of the total size of all
-- three widgets.
function Splitter:getPositionRatio()
  -- Get the position as a percentage of the total size
  local total_size = get_size(self.orientation, self.widgets[3]) +
                     get_size(self.orientation, self.widgets[2]) +
                     get_size(self.orientation, self.widgets[1])

  return _percent(self:getPosition(), total_size)
end

-- Get the absolute position of the splitter (the position of the middle
-- widget)
-- x for horizontal, y for vertical
function Splitter:getAbsolutePosition()
  return get_start(self.orientation, self.widgets[2])
end

-- Constructor for the splitter
-- @param cons - The constructor arguments asd a table. At a minimum, the
--               three widgets are required.
function Splitter:new(cons)
  local me = Geyser.copyTable(cons)

  assert(me.orientation == nil or orientations[me.orientation],
    "invalid orientation")
  assert(me.enabled == nil or type(me.enabled) == "boolean",
    "enabled must be a boolean")
  assert(me.cursor == nil or mudlet.cursor[me.cursor],
    "invalid cursor")

  me.type = me.type or "splitter"
  me.name = me.name or Geyser.nameGen()

  me.orientation = orientations[cons.orientation] or orientations.horizontal

  local orientation = me.orientation
  local orientation_string = orientations_reverse[orientation]
  local coord, descriptor = coords[orientation], descriptors[orientation]

  for _, v in ipairs(descriptor) do
    assert(me[v], "[" .. me.name .. "] " .. table.concat(descriptor, ", ") .. " are required for " .. orientation_string .. " splitters")
  end

  me.widgets = {}
  for _, v in ipairs(descriptor) do
    table.insert(me.widgets, me[v])
  end
  local first, bar, last = me.widgets[1], me.widgets[2], me.widgets[3]
  me.cursor = me.cursor or ("Resize" .. orientation_string:gsub("^%l", string.upper))
  me.mouse_property = coord

  -- Setup the margins
  local temp_margins = {}
  if me.margins then
    local min, max = 1, 2
    local margins_to_check = { descriptor[1], descriptor[3] }
    for _, v in ipairs(margins_to_check) do
      if not me.margins[v] then
        temp_margins[v] = { 0, 0 }
      else
        local num_margins = #me.margins[v]
        if num_margins > 2 then
          error("Invalid number of margins for " .. v .. ". Expected 1 or 2, got " .. num_margins)
        elseif num_margins == 0 then
          temp_margins[v] = { 0, 0 }
        elseif num_margins == 1 then
          temp_margins[v] = { me.margins[v][1], 0 }
        else
          temp_margins[v] = { me.margins[v][1], me.margins[v][2] }
        end
      end
    end
  else
    temp_margins = {
      [descriptor[1]] = { 0, 0 },
      [descriptor[3]] = { 0, 0 },
    }
  end
  display(temp_margins)
  me.margins = {
    first = temp_margins[descriptor[1]],
    last = temp_margins[descriptor[3]],
  }

  bar:setCursor(mudlet.cursor[me.cursor])
  me.moving = false
  me.enabled = me.enabled or true

  ---@diagnostic disable-next-line: redundant-parameter
  setLabelClickCallback(bar.name, mouse_event, me, "click")
  ---@diagnostic disable-next-line: redundant-parameter
  setLabelMoveCallback(bar.name, mouse_event, me, "move")
  ---@diagnostic disable-next-line: redundant-parameter
  setLabelReleaseCallback(bar.name, mouse_event, me, "release")

  setmetatable(me, self)
  self.__index = self

  return me
end

-- Get the constraints for a widget
-- @param widget - The widget to get the constraints for
-- @return - A table with the min and max bounds of the widget
function Splitter:getConstraints(widget)
  return {
    min_bound = get_min_bound(self, widget),
    max_bound = get_max_bound(self, widget),
  }
end

-- Get the minimum bound of a widget
-- @param splitter - The splitter instance
-- @param widget - The widget to get the minimum bound of
-- @return - The minimum bound of the widget
function get_min_bound(splitter, widget)
  if widget.name == splitter.widgets[1].name then
    return splitter.margins.first[1]
  elseif widget.name == splitter.widgets[3].name then
    return splitter.margins.last[1]
  else
    error("Invalid widget name: " .. widget.name)
  end
end

-- Get the maximum bound of a widget
-- @param splitter - The splitter instance
-- @param widget - The widget to get the maximum bound of
-- @return - The maximum bound of the widget
function get_max_bound(splitter, widget)
  if widget.name == splitter.widgets[1].name then
    return splitter.margins.first[2]
  elseif widget.name == splitter.widgets[3].name then
    return splitter.margins.last[2]
  else
    error("Invalid widget name: " .. widget.name)
  end
end

-- Get the start position of a widget
-- x - for horizontal, y - for vertical
function get_start(orientation, widget)
  if orientation == orientations.horizontal then
    return widget.get_x()
  elseif orientation == orientations.vertical then
    return widget.get_y()
  else
    error("Invalid orientation")
  end
end

-- Get the size of a widget
-- width - for horizontal, height - for vertical
function get_size(orientation, widget)
  if orientation == orientations.horizontal then
    return widget.get_width()
  elseif orientation == orientations.vertical then
    return widget.get_height()
  else
    error("Invalid orientation")
  end
end

-- Return a percentage a number represents of another number
function _percent(num, den) return num * 100 / den end

-- Return the given percentage of a number
function _percent_of(num, den) return num * den / 100 end

return Splitter

--- Demo widgets

--[[
-- TESTING 1
function test1()
  local Head = Head or Geyser.Label:new({
    name = "Head",
    x = 100, y = 75,
    width = 200, height = 25,
  })
  Head:echo("Random Horizontal", nil, "c")

  -- Container for the widgets
  local Box = Box or Geyser.HBox:new({
    name = "Box",
    x = 100, y = 100,
    width = 200, height = 200,
  })

  -- A label for the left hand side
  local Left = Left or Geyser.Label:new({
    name = "Left",
    width = "100%",
    height = "100%",
    color = "orange",
  }, Box)

  -- A label for the splitter bar
  local Bar = Bar or Geyser.Label:new({
    name = "Bar",
    width = 20,
    height = "100%",
    h_policy = Geyser.Fixed,
    stylesheet = "margin: 6px 2px; background-color: rgb(255,255,255);"
  }, Box)

  -- A label for the right hand side
  local Right = Right or Geyser.Label:new({
    name = "Right",
    color = "aquamarine",
    width = "100%",
    height = "100%",
  }, Box)

  -- Now a splitter
  local Splitter = Geyser.Splitter:new({
    orientation = "horizontal",
    left = Left,
    middle = Bar,
    right = Right,
  })
  tempTimer(0.5, function()
    local pos = math.random(0, 100)
    Splitter:setPositionRatio(pos)
    pos = Splitter:getPositionRatio()
  end, true)
end

-- TESTING 2
function test2()
  local Head = Head or Geyser.Label:new({
    name = "Head2",
    x = 350, y = 75,
    width = 200, height = 25,
  })
  Head:echo("Bouncing Vertical", nil, "c")

  -- Container for the widgets
  local Box = Box or Geyser.VBox:new({
    name = "Box2",
    x = 350, y = 100,
    width = 200, height = 200,
  })

  -- A label for the left hand side
  local Up = Up or Geyser.Label:new({
    name = "Up2",
    width = "100%",
    height = "100%",
    color = "orange",
  }, Box)

  -- A label for the splitter bar
  local Bar2 = Bar2 or Geyser.Label:new({
    name = "Bar2",
    width = "100%",
    height = 20,
    v_policy = Geyser.Fixed,
    stylesheet = "margin: 6px 2px; background-color: rgb(255,255,255);"
  }, Box)

  -- A label for the right hand side
  local Down = Down or Geyser.Label:new({
    name = "Down2",
    color = "aquamarine",
    width = "100%",
    height = "100%",
  }, Box)

  -- Now a splitter
  local Splitter2 = Geyser.Splitter:new({
    orientation = "vertical",
    up = Up,
    middle = Bar2,
    down = Down,
  })

  local initial_position = 1
  Splitter2:setPosition(initial_position)

  local direction = 1
  local step = 2

  tempTimer(0.01, function()
    local current = Splitter2:getPosition()
    local new_pos = current + step * direction
    local max = Splitter2:getMax() -
                get_size(Splitter2, widget_elements.middle)
    local min = Splitter2:getMin()

    if new_pos > max then
      new_pos = max
      direction = -direction
    elseif new_pos < min then
      new_pos = min
      direction = -direction
    end

    Splitter2:setPosition(new_pos)
    current = Splitter2:getPosition()
  end, true)
end

-- TESTING 1
function test3()
  local Head = Head or Geyser.Label:new({
    name = "Head3",
    x = 100, y = 325,
    width = 200, height = 25,
  })
  Head:echo("Manual Horizontal", nil, "c")

    -- Container for the widgets
  local Box = Box or Geyser.HBox:new({
    name = "Box3",
    x = 100, y = 350,
    width = 200, height = 200,
  })

  -- A label for the left hand side
  local Left = Left or Geyser.Label:new({
    name = "Left3",
    width = "100%",
    height = "100%",
    color = "orange",
  }, Box)

  -- A label for the splitter bar
  local Bar = Bar or Geyser.Label:new({
    name = "Bar3",
    width = 20,
    height = "100%",
    h_policy = Geyser.Fixed,
    stylesheet = "margin: 6px 2px; background-color: rgb(255,255,255);"
  }, Box)

  -- A label for the right hand side
  local Right = Right or Geyser.Label:new({
    name = "Right3",
    color = "aquamarine",
    width = "100%",
    height = "100%",
  }, Box)

  -- Now a splitter
  local Splitter3 = Geyser.Splitter:new({
    orientation = "horizontal",
    left = Left,
    middle = Bar,
    right = Right,
  })
end

-- TESTING
function test4()
    local Head = Head or Geyser.Label:new({
    name = "Head4",
    x = 350, y = 325,
    width = 200, height = 25,
  })
  Head:echo("Manual Horizontal", nil, "c")

  -- Container for the widgets
  local Box = Box or Geyser.VBox:new({
    name = "Box4",
    x = 350, y = 350,
    width = 200, height = 200,
  })

  -- A label for the up hand side
  local Up = Up or Geyser.Label:new({
    name = "Up4",
    width = "100%",
    height = "100%",
    color = "orange",
  }, Box)

  -- A label for the splitter bar
  local Bar = Bar or Geyser.Label:new({
    name = "Bar4",
    width = "100%",
    height = 20,
    v_policy = Geyser.Fixed,
    stylesheet = "margin: 6px 2px; background-color: rgb(255,255,255);"
  }, Box)

  -- A label for the down hand side
  local Down = Down or Geyser.Label:new({
    name = "Down4",
    color = "aquamarine",
    width = "100%",
    height = "100%",
  }, Box)

  -- Now a splitter
  local Splitter4 = Geyser.Splitter:new({
    orientation = "vertical",
    up = Up,
    middle = Bar,
    down = Down,
  })
end

test1()
test2()
test3()
test4()
--]]
