-- Main table
GLPUI = GLPUI or {}

-- Threshold App Name
GLPUI.appName = GLPUI.appName or "gLPUi"
GLPUI.EventHandlers = GLPUI.EventHandlers or {}
GLPUI.metrics = {
    height = 66,
    label_font_size = 10,
    gauge_font_size = 10,
}

-- Styles
local MainBackground = "background-color: rgba(18,22,25,100%);"
local border = "border-top: 1px solid rgba(255, 255, 255, 10%); border-bottom: 1px solid rgba(255, 255, 255, 10%);"
local fontColor = "color: rgba(192, 192, 192, 85%);"
local center = "qproperty-alignment: 'AlignCenter | AlignVCenter';"
local right = "qproperty-alignment: 'AlignRight | AlignVCenter';"
local labelFont = "Ubuntu"
local gaugeFont = "Ubuntu"

local labelText = f[[ font-weight: 400; {fontColor} background-color: rgba(0,0,0,0); ]]

local gauge = "border-radius: 5px; margin: 2.75px;"
local gaugeText = f[[ font-family: '{gaugeFont}'; {fontColor} {center} font-weight: 600; ]]

GLPUI.Styles = {
    MainBG    = f[[ {MainBackground} {border} ]],
    Label     = f[[ {labelText} {center} ]],
    GaugeText = f[[ {gaugeText} ]],
    HPFront   = f[[ background-color: rgba(147, 58, 58, 80%); {gauge} ]],
    HPBack    = f[[ background-color: rgba(80, 0, 0, 100%); {gauge}  ]],
    SPFront   = f[[ background-color: rgba(58, 102, 147, 80%); {gauge} ]],
    SPBack    = f[[ background-color: rgba(0, 34, 68, 100%); {gauge}  ]],
    MPFront   = f[[ background-color: rgba(147, 88, 116, 80%); {gauge} ]],
    MPBack    = f[[ background-color: rgba(77, 0, 44, 100%); {gauge}  ]],
    FoeFront  = f[[ background-color: rgba(147, 58, 58, 80%); {gauge} ]],
    FoeBack   = f[[ background-color: rgba(92, 0, 0, 100%); {gauge} ]],
    XPFront   = f[[ background-color: rgba(116, 88, 147, 80%); {gauge} ]],
    XPBack    = f[[ background-color: rgba(50, 0, 50, 100%); {gauge} ]],
    CapFront  = f[[ background-color: rgba(191, 87, 0, 80%); {gauge} ]],
    CapBack   = f[[ background-color: rgba(115, 51, 0, 100%); {gauge} ]],
    VolFront  = f[[ background-color: rgba(51, 102, 51, 80%); {gauge} ]],
    VolBack   = f[[ background-color: rgba(24, 48, 24, 100%); {gauge} ]],
}

GLPUI.Vitals = GLPUI.Vitals or {
    HP = { current = 0, max = 0 },
    SP = { current = 0, max = 0 },
    MP = { current = 0, max = 0 },
    Foe = { current = 0, max = 0 },
    XP = { current = 0, max = 0 }
}
