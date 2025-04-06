-- Based on Data/stylemgr.ini

--- @class Renegade
--- @field StyleManager StyleManager

CNC_RENEGADE.StyleManager = CNC_RENEGADE.StyleManager or {}

--- @class StyleManager
local STATIC = CNC_RENEGADE.StyleManager
STATIC.Fonts = {}
STATIC.Audio = {}


--[Font File List]
STATIC.File01 = "resource/fonts/54251___.ttf"
STATIC.File02 = "resource/fonts/ARI_____.ttf"

-- Garry's Mod appears to use a different font scaling from Renegade
local fontScaleMultiplier = 1.75

--- Creates a new font using values converted to Garry's Mod's expected ranges and returns its name
---@param name string
---@param baseFont string
---@param size integer
---@param isBold boolean
---@return string fontName
local function MakeFont( name, baseFont, size, isBold )
    local fontName = "Renegade_" .. name

    surface.CreateFont ( fontName, {
        font = baseFont,
        size = math.floor( size * fontScaleMultiplier ),
        weight = isBold and 1000 or 400
    } )

    return fontName
end

--[Menu Font Names]
STATIC.Fonts.Title          = MakeFont( "Title",         "Regatta Condensed LET", 52, false )
STATIC.Fonts.LargeControls  = MakeFont( "LargeControls", "Arial MT", 12, true  )
STATIC.Fonts.Controls       = MakeFont( "Controls",      "Arial MT", 8,  true  )
STATIC.Fonts.Lists          = MakeFont( "Lists",         "Arial MT", 8,  false )
STATIC.Fonts.Tooltips       = MakeFont( "Tooltips",      "Arial MT", 8,  false )
STATIC.Fonts.Menu           = MakeFont( "Menu",          "Regatta Condensed LET", 32, false )
STATIC.Fonts.SmallMenu      = MakeFont( "SmallMenu",     "Regatta Condensed LET", 20, false )
STATIC.Fonts.Header         = MakeFont( "Header",        "Arial MT", 9,  true  )
STATIC.Fonts.LargeHeader    = MakeFont( "LargeHeader",   "Arial MT", 12, true  )
STATIC.Fonts.Credits        = MakeFont( "Credits",       "Arial MT", 10, false )
STATIC.Fonts.CreditsBold    = MakeFont( "CreditsBold",   "Arial MT", 10, true  )

--[Ingame Font fonts]
STATIC.Fonts.IngameText         = MakeFont( "IngameText",         "Arial MT", 8,  false )
STATIC.Fonts.IngameBigText      = MakeFont( "IngameBigText",      "Arial MT", 16, false )
STATIC.Fonts.IngameSubtitleText = MakeFont( "IngameSubtitleText", "Arial MT", 14, false )
STATIC.Fonts.IngameHeaderText   = MakeFont( "IngameHeaderText",   "Arial MT", 18, true  )


--[Audio]
STATIC.Audio.CLICK = {
    path = "interface_mouseclick.wav",
    volume = 60
}

STATIC.Audio.MOUSEOVER = {
    path = "interface_rollover.wav",
    volume = 70
}

STATIC.Audio.BACK = {
    path = "interface_escape.wav",
    volume = 80
}

STATIC.Audio.POPUP = {
    path = "interface_alert1.wav",
    volume = 80
}