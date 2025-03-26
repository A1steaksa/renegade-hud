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

--[Menu Font Names]
STATIC.Fonts.Title = "RENEGADE_Title"
surface.CreateFont ( STATIC.Fonts.Title, {
    font = "Regatta Condensed LET",
    size = math.floor( 52 * fontScaleMultiplier ),
    weight = 500
} )

STATIC.Fonts.LargeControls = "LargeControls"
surface.CreateFont( STATIC.Fonts.LargeControls, {
    font = "Arial MT",
    size = math.floor( 12 * fontScaleMultiplier ),
    weight = 1000
} )

STATIC.Fonts.Controls = "Controls"
surface.CreateFont( STATIC.Fonts.Controls, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 1000
} )

STATIC.Fonts.Lists = "Lists"
surface.CreateFont( STATIC.Fonts.Lists, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 400
} )

STATIC.Fonts.Tooltips = "Tooltips"
surface.CreateFont( STATIC.Fonts.Tooltips, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 400
} )

STATIC.Fonts.Menu = "Menu"
surface.CreateFont( STATIC.Fonts.Menu, {
    font = "Regatta Condensed LET",
    size = math.floor( 32 * fontScaleMultiplier ),
    weight = 500
} )

STATIC.Fonts.SmallMenu = "SmallMenu"
surface.CreateFont( STATIC.Fonts.SmallMenu, {
    font = "Regatta Condensed LET",
    size = math.floor( 20 * fontScaleMultiplier ),
    weight = 500
} )

STATIC.Fonts.Header = "Header"
surface.CreateFont( STATIC.Fonts.Header, {
    font = "Arial MT",
    size = math.floor( 9 * fontScaleMultiplier ),
    weight = 1000
} )

STATIC.Fonts.LargeHeader = "LargeHeader"
surface.CreateFont( STATIC.Fonts.LargeHeader, {
    font = "Arial MT",
    size = math.floor( 12 * fontScaleMultiplier ),
    weight = 1000
} )

STATIC.Fonts.Credits = "Credits"
surface.CreateFont( STATIC.Fonts.Credits, {
    font = "Arial MT",
    size = math.floor( 10 * fontScaleMultiplier ),
    weight = 400
} )

STATIC.Fonts.CreditsBold = "CreditsBold"
surface.CreateFont( STATIC.Fonts.CreditsBold, {
    font = "Arial MT",
    size = math.floor( 10 * fontScaleMultiplier ),
    weight = 1000
} )

--[Ingame Font fonts]
STATIC.Fonts.IngameText = "IngameText"
surface.CreateFont( STATIC.Fonts.IngameText, {
    font = "Arial MT",
    size = math.floor( 8 * fontScaleMultiplier ),
    weight = 400,
    antialias = false
} )

STATIC.Fonts.IngameBigText = "IngameBigText"
surface.CreateFont( STATIC.Fonts.IngameBigText, {
    font = "Arial MT",
    size = math.floor( 16 * fontScaleMultiplier ),
    weight = 400
} )

STATIC.Fonts.IngameSubtitleText = "IngameSubtitleText"
surface.CreateFont( STATIC.Fonts.IngameSubtitleText, {
    font = "Arial MT",
    size = math.floor( 14 * fontScaleMultiplier ),
    weight = 400
} )

STATIC.Fonts.IngameHeaderText = "IngameHeaderText"
surface.CreateFont( STATIC.Fonts.IngameHeaderText, {
    font = "Arial MT",
    size = math.floor( 18 * fontScaleMultiplier ),
    weight = 1000
} )


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