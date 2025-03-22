-- Based on Data/stylemgr.ini

---@class Renegade
---@field StyleManager StyleManager

CNC_RENEGADE.StyleManager = CNC_RENEGADE.StyleManager or {}

---@class StyleManager
local LIB = CNC_RENEGADE.StyleManager
LIB.Fonts = {}
LIB.Audio = {}


--[Font File List]
LIB.File01 = "resource/fonts/54251___.ttf"
LIB.File02 = "resource/fonts/ARI_____.ttf"

-- Garry's Mod appears to use a different font scaling from Renegade
local fontScaleMultiplier = 1.75

--[Menu Font Names]
LIB.Fonts.Title = "RENEGADE_Title"
surface.CreateFont ( LIB.Fonts.Title, {
    font = "Regatta Condensed LET",
    size = math.floor( 52 * fontScaleMultiplier ),
    weight = 500
} )

LIB.Fonts.LargeControls = "LargeControls"
surface.CreateFont( LIB.Fonts.LargeControls, {
    font = "Arial MT",
    size = math.floor( 12 * fontScaleMultiplier ),
    weight = 1000
} )

LIB.Fonts.Controls = "Controls"
surface.CreateFont( LIB.Fonts.Controls, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 1000
} )

LIB.Fonts.Lists = "Lists"
surface.CreateFont( LIB.Fonts.Lists, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 400
} )

LIB.Fonts.Tooltips = "Tooltips"
surface.CreateFont( LIB.Fonts.Tooltips, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 400
} )

LIB.Fonts.Menu = "Menu"
surface.CreateFont( LIB.Fonts.Menu, {
    font = "Regatta Condensed LET",
    size = math.floor( 32 * fontScaleMultiplier ),
    weight = 500
} )

LIB.Fonts.SmallMenu = "SmallMenu"
surface.CreateFont( LIB.Fonts.SmallMenu, {
    font = "Regatta Condensed LET",
    size = math.floor( 20 * fontScaleMultiplier ),
    weight = 500
} )

LIB.Fonts.Header = "Header"
surface.CreateFont( LIB.Fonts.Header, {
    font = "Arial MT",
    size = math.floor( 9 * fontScaleMultiplier ),
    weight = 1000
} )

LIB.Fonts.LargeHeader = "LargeHeader"
surface.CreateFont( LIB.Fonts.LargeHeader, {
    font = "Arial MT",
    size = math.floor( 12 * fontScaleMultiplier ),
    weight = 1000
} )

LIB.Fonts.Credits = "Credits"
surface.CreateFont( LIB.Fonts.Credits, {
    font = "Arial MT",
    size = math.floor( 10 * fontScaleMultiplier ),
    weight = 400
} )

LIB.Fonts.CreditsBold = "CreditsBold"
surface.CreateFont( LIB.Fonts.CreditsBold, {
    font = "Arial MT",
    size = math.floor( 10 * fontScaleMultiplier ),
    weight = 1000
} )

--[Ingame Font fonts]
LIB.Fonts.IngameText = "IngameText"
surface.CreateFont( LIB.Fonts.IngameText, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 400,
    antialias = false
} )

LIB.Fonts.IngameBigText = "IngameBigText"
surface.CreateFont( LIB.Fonts.IngameBigText, {
    font = "Arial MT",
    size = math.floor( 16 * fontScaleMultiplier ),
    weight = 400
} )

LIB.Fonts.IngameSubtitleText = "IngameSubtitleText"
surface.CreateFont( LIB.Fonts.IngameSubtitleText, {
    font = "Arial MT",
    size = math.floor( 14 * fontScaleMultiplier ),
    weight = 400
} )

LIB.Fonts.IngameHeaderText = "IngameHeaderText"
surface.CreateFont( LIB.Fonts.IngameHeaderText, {
    font = "Arial MT",
    size = math.floor( 18 * fontScaleMultiplier ),
    weight = 1000
} )


--[Audio]
LIB.Audio.CLICK = {
    path = "interface_mouseclick.wav",
    volume = 60
}

LIB.Audio.MOUSEOVER = {
    path = "interface_rollover.wav",
    volume = 70
}

LIB.Audio.BACK = {
    path = "interface_escape.wav",
    volume = 80
}

LIB.Audio.POPUP = {
    path = "interface_alert1.wav",
    volume = 80
}