-- Based on Code/ww3d2/render2dsentence.cpp

---@class Renegade
---@field Render2DSentence Render2DSentence

CNC_RENEGADE.Render2DSentence = CNC_RENEGADE.Render2DSentence or {}

---@class Render2DSentence
local LIB = CNC_RENEGADE.Render2DSentence

--#region Surface Get Font

---The currently active Surface font
---@type string
SURFACE_FONT = ""

local oldSetFont = surface.SetFont


---@param fontName string
function surface.SetFont( fontName )
    SURFACE_FONT = fontName
    oldSetFont( fontName )
end

---Retrives the font that is currently active in the Surface library
---@return string # The currently active font name
function surface.GetFont()
    return SURFACE_FONT
end
--#endregion

---Format is (Font Name) -> table< String: string, { Width: integer, Height: integer } >
---@type table<string, table< string, { Width: integer, Height: integer } > >
local perFontSizeCache = {}

---Determines the width, in pixels, of a given character
---@param str string
---@return integer
function LIB.GetCharWidth( str )
    local font = SURFACE_FONT

    local fontCache = perFontSizeCache[ font ]
    if not fontCache then
        fontCache = {}
        perFontSizeCache[ font ] = fontCache
    end

    local charCache = fontCache[ str ]
    if not charCache then
        local width, height = surface.GetTextSize( str )
        charCache = {
            Width = width,
            Height = height
        }
        fontCache[ str ] = charCache
    end

    return charCache.Width
end

---Determines the width, in pixels, of a given character
---@param char string
function LIB.GetCharSpacing( char )
    local width = LIB.GetCharWidth( char )

    -- Non-zero width characters get an extra pixel of width for some reason
    -- Presumably someone on the Renegade development team thought the letters looked too close together
    return width == 0 and 0 or width + 1
end

---Draws a piece of text using Renegade's abnormal text rendering
---@param x number
---@param y number
---@param text string
---@param color Color
function LIB.DrawText( x, y, text, color )
    surface.SetTextColor( color )

    local currentX = x + 0
    local currentY = y + 0.5

    local chars = string.Explode( "", text )

    for _, char in ipairs( chars ) do

        surface.SetTextPos( currentX, currentY )
        surface.DrawText( char )

        currentX = currentX + LIB.GetCharSpacing( char )
    end
end

---Determines the width, in pixels, of a string of text that uses Renegade's abonrmal text rendering
---@param text string
---@return number Width
function LIB.GetTextWidth( text )
    local currentWidth = -0.5

    local chars = string.Explode( "", text )

    for _, char in ipairs( chars ) do
        currentWidth = currentWidth + LIB.GetCharSpacing( char )
    end

    return currentWidth
end