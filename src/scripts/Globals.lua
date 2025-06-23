local script_name = "gLPUi"

-- Main table
---@class GLPUI
---@field config table
---@field event_handlers table
---@field metrics table
---@field coin table
---@field purse table
---@field vitals table
---@field inventory_attributes table
---@field inventory table
---@field splitter table
GLPUI = GLPUI or {
  config = {
    name = script_name,                                    -- Name of the script
    package_name = "__PKGNAME__",                          -- Name of the package
    package_path = getMudletHomeDir() .. "/__PKGNAME__/",
    prefix = f [[{script_name}.]],                         -- Prefix for handlers
    preferences_file = f [[{script_name}.Preferences.lua]], -- Name of the preferences file
  },
  event_handlers = {},
  metrics = {
    height = 66,
    label_font_size = 10,
    gauge_font_size = 10,
    coin_font_size = 15,
    inventory_font_size = 8,
  },
  coin = {
    colours = {
      platinum = { 229, 228, 226 },
      gold = { 255, 215, 0 },
      silver = { 192, 192, 192 },
      copper = { 184, 115, 51 },
    },
    names = {
      platinum = "Platinum",
      gold = "Gold",
      silver = "Silver",
      copper = "Copper",
    },
    symbol = utf8.escape("%x{25CF}")
  },
  purse = {
    platinum = 0,
    gold = 0,
    silver = 0,
    copper = 0,
  },
  vitals = {
    HP = { current = 0, max = 0 },
    SP = { current = 0, max = 0 },
    MP = { current = 0, max = 0 },
    Foe = { current = 0, max = 0 },
    XP = { current = 0, max = 0 }
  },
  inventory_attributes = {
    room = {
      W = { name = "wearable", enabled = true },
      c = { name = "container", enabled = true },
      t = { name = "takeable", enabled = true },
      m = { name = "monster", enabled = true },
      d = { name = "dead monster", enabled = true },
    },
    inv = {
      w = { name = "worn", enabled = true },
      W = { name = "wearable", enabled = true },
      l = { name = "wielded", enabled = true },
      c = { name = "container", enabled = true },
      d = { name = "dead monster", enabled = true },
    },
  },
  splitter = {
    symbol = utf8.escape("%x{25CF}%x{25CF}%x{25CF}%x{25CF}%x{25CF}"),
    font_size = 4,
    size = 10,
  },
  inventory = {
    room = {},
    inv = {},
  }
}

function GLPUI.setupStyles()
  -- Styles
  local MainBackground = "background-color: rgba(18,22,25,100%);"
  local border = "border-top: 1px solid rgba(255, 255, 255, 10%); border-bottom: 1px solid rgba(255, 255, 255, 10%);"
  local panel_border = "border: 1px solid rgba(255, 255, 255, 10%);"
  local fontColor = "color: rgba(192, 192, 192, 85%);"
  local center = "qproperty-alignment: 'AlignCenter';"
  local right = "qproperty-alignment: 'AlignRight | AlignVCenter';"
  local labelFont = "Ubuntu"
  local gaugeFont = "Ubuntu"
  local PlatinumRGB = f "rgb({table.concat(GLPUI.coin.colours.platinum, ',')})"
  local GoldRGB = f "rgb({table.concat(GLPUI.coin.colours.gold, ',')})"
  local SilverRGB = f "rgb({table.concat(GLPUI.coin.colours.silver, ',')})"
  local CopperRGB = f "rgb({table.concat(GLPUI.coin.colours.copper, ',')})"
  local labelText = f [[ font-weight: 400; {fontColor} background-color: rgba(0,0,0,0); ]]
  local gauge = "margin: 2.75px; border: 1px solid rgba(53, 53, 53, 75%);"
  local gaugeText = f [[ font-family: '{gaugeFont}'; {fontColor} {center} font-weight: 600; ]]
  local splitter = f "color: rgb({table.concat(GLPUI.coin.colours.silver, ',')});"

  GLPUI.styles = {
    MainFontName   = labelFont,
    WidgetFontName = gaugeFont,
    MainBG         = f [[ {MainBackground} {border} ]],
    Label          = f [[ {labelText} {center} ]],
    GaugeText      = f [[ {gaugeText} ]],
    HPFront        = f [[ background-color: rgba(147, 58, 58, 80%); {gauge} ]],
    HPBack         = f [[ background-color: rgba(80, 0, 0, 100%); {gauge}  ]],
    SPFront        = f [[ background-color: rgba(58, 102, 147, 80%); {gauge} ]],
    SPBack         = f [[ background-color: rgba(0, 34, 68, 100%); {gauge}  ]],
    MPFront        = f [[ background-color: rgba(147, 88, 116, 80%); {gauge} ]],
    MPBack         = f [[ background-color: rgba(77, 0, 44, 100%); {gauge}  ]],
    FoeFront       = f [[ background-color: rgba(147, 58, 58, 80%); {gauge} ]],
    FoeBack        = f [[ background-color: rgba(92, 0, 0, 100%); {gauge} ]],
    XPFront        = f [[ background-color: rgba(116, 88, 147, 80%); {gauge} ]],
    XPBack         = f [[ background-color: rgba(50, 0, 50, 100%); {gauge} ]],
    CapFront       = f [[ background-color: rgba(191, 87, 0, 80%); {gauge} ]],
    CapBack        = f [[ background-color: rgba(115, 51, 0, 100%); {gauge} ]],
    Center         = f [[ {center} ]],
    CoinPlatinum   = f [[ color:{PlatinumRGB}; ]],
    CoinGold       = f [[ color:{GoldRGB}; ]],
    CoinSilver     = f [[ color:{SilverRGB}; ]],
    CoinCopper     = f [[ color:{CopperRGB}; ]],
    CoinLabel      = f [[ {labelText} {center} ]],
    Panel          = f [[ {MainBackground} {panel_border} ]],
    SplitterLabel  = f [[ {splitter} {center} ]],
  }

  local background_color = "rgb(18, 22, 25)"
  local border_color = "rgb(82, 100, 0)"

  GLPUI.styles.Profile = [[
    QMainWindow {
      background: ]] .. background_color .. [[;
    }
    QToolBar {
      background: ]] .. background_color .. [[;
    }
    QToolButton {
      background: ]] .. background_color .. [[;
      border-style: outset;
      font-family: Ubuntu;
      color: white;
      margin: 2px;
      font-size: 10pt;
    }
    QToolButton:hover { background-color: ]] .. border_color .. [[;}
    QToolButton:focus { background-color: ]] .. border_color .. [[;}

    QTreeView {
      background: ]] .. background_color .. [[;
      color: white;
    }

    QMenuBar{ background-color: ]] .. background_color .. [[;}

    QMenuBar::item{ background-color: ]] .. background_color .. [[;}

    QDockWidget::title {
      background: ]] .. border_color .. [[;
    }
    QStatusBar {
      background: ]] .. border_color .. [[;
    }
    QScrollBar:vertical {
      background: ]] .. background_color .. [[;
      width: 15px;
      margin: 22px 0 22px 0;
    }
    QScrollBar::handle:vertical {
      background-color: ]] .. background_color .. [[;
      min-height: 20px;
      border-width: 2px;
      border-style: solid;
      border-color: ]] .. border_color .. [[;
      border-radius: 7px;
    }
      QScrollBar::add-line:vertical {
      background-color: ]] .. background_color .. [[;
      border-width: 2px;
      border-style: solid;
      border-color: ]] .. border_color .. [[;
      border-bottom-left-radius: 7px;
      border-bottom-right-radius: 7px;
      height: 15px;
      subcontrol-position: bottom;
      subcontrol-origin: margin;
    }
    QScrollBar::sub-line:vertical {
      background-color: ]] .. background_color .. [[;
      border-width: 2px;
      border-style: solid;
      border-color: ]] .. border_color .. [[;
      border-top-left-radius: 7px;
      border-top-right-radius: 7px;
      height: 15px;
      subcontrol-position: top;
      subcontrol-origin: margin;
    }
    QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical {
      background: none;
    }
  ]]
end
