-- Based mostly on Code/Combat/globalsettings.h and Code/Combat/globalsettings.cpp

--- @class Renegade
--- @field GlobalSettings GlobalSettings

CNC_RENEGADE.GlobalSettings = CNC_RENEGADE.GlobalSettings or {}

--- @class GlobalSettings
local STATIC = CNC_RENEGADE.GlobalSettings

--#region Colors
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
--#endregion