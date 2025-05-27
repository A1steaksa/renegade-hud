-- Based mostly on Code/Combat/globalsettings.h and Code/Combat/globalsettings.cpp

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of GameType
    --- @class GlobalSettings
    STATIC = CNC.CreateExport()
end


--[[ Static Functions and Variables ]] do

    local CLASS = "GlobalSettings"

    --- [[ Public ]]

    --- @class GlobalSettings
    --- @field Colors table<string, Color>

    STATIC.Colors = {}
    STATIC.Colors.Nod                = Color( 255,   0, 0   )
    STATIC.Colors.GDI                = Color( 255, 255, 0   )
    STATIC.Colors.Neutral            = Color( 255, 255, 255 )
    STATIC.Colors.Mutant             = Color(   0, 255, 0   )
    STATIC.Colors.Renegade           = Color(   0,   0, 255 )
    STATIC.Colors.PrimaryObjective   = Color(   0, 255, 0   )
    STATIC.Colors.SecondaryObjective = Color(   0,   0, 255 )
    STATIC.Colors.TertiaryObjective  = Color( 255,   0, 255 )
    STATIC.Colors.HealthHigh         = Color(   0, 255, 0   )
    STATIC.Colors.HealthMed          = Color( 255, 255, 0   )
    STATIC.Colors.HealthLow          = Color( 255,   0, 0   )
    STATIC.Colors.Enemy              = Color( 255,   0, 0   )
    STATIC.Colors.Friendly           = Color(   0, 255, 0   )
    STATIC.Colors.NoRelation         = Color( 255, 255, 255 )
    STATIC.Colors.ReticleBusy        = Color( 255, 255, 0   )
end