-- Main table
---@class GLPUI
GLPUI = GLPUI or {}

-- Threshold App Name
GLPUI.appName = GLPUI.appName or "gLPUi"
GLPUI.EventHandlers = GLPUI.EventHandlers or {}
GLPUI.metrics = {
  height = 66,
  label_font_size = 10,
  gauge_font_size = 10,
  coin_font_size = 15,
  inventory_font_size = 8,
}

GLPUI.CoinConfig = {
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
}

local PlatinumRGB = f "rgb({GLPUI.CoinConfig.colours.platinum[1]}, {GLPUI.CoinConfig.colours.platinum[2]}, {GLPUI.CoinConfig.colours.platinum[3]})"
local GoldRGB = f "rgb({GLPUI.CoinConfig.colours.gold[1]}, {GLPUI.CoinConfig.colours.gold[2]}, {GLPUI.CoinConfig.colours.gold[3]})"
local SilverRGB = f "rgb({GLPUI.CoinConfig.colours.silver[1]}, {GLPUI.CoinConfig.colours.silver[2]}, {GLPUI.CoinConfig.colours.silver[3]})"
local CopperRGB = f "rgb({GLPUI.CoinConfig.colours.copper[1]}, {GLPUI.CoinConfig.colours.copper[2]}, {GLPUI.CoinConfig.colours.copper[3]})"

GLPUI.Coins = {
  platinum = 0,
  gold = 0,
  silver = 0,
  copper = 0,
}

-- Styles
local MainBackground = "background-color: rgba(18,22,25,100%);"
local border = "border-top: 1px solid rgba(255, 255, 255, 10%); border-bottom: 1px solid rgba(255, 255, 255, 10%);"
local panel_border = "border: 1px solid rgba(255, 255, 255, 10%);"
local fontColor = "color: rgba(192, 192, 192, 85%);"
local center = "qproperty-alignment: 'AlignCenter | AlignVCenter';"
local right = "qproperty-alignment: 'AlignRight | AlignVCenter';"
local labelFont = "Ubuntu"
local gaugeFont = "Ubuntu"

local labelText = f [[ font-weight: 400; {fontColor} background-color: rgba(0,0,0,0); ]]

local gauge = "border-radius: 5px; margin: 2.75px;"
local gaugeText = f [[ font-family: '{gaugeFont}'; {fontColor} {center} font-weight: 600; ]]

GLPUI.Styles = {
  MainFontName   = f [[ {labelFont} ]],
  WidgetFontName = f [[ {gaugeFont} ]],
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
}

GLPUI.Vitals = GLPUI.Vitals or {
  HP = { current = 0, max = 0 },
  SP = { current = 0, max = 0 },
  MP = { current = 0, max = 0 },
  Foe = { current = 0, max = 0 },
  XP = { current = 0, max = 0 }
}

GLPUI.InventoryAttributes = {
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
}
