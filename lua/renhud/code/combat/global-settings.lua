-- Based mostly on Code/Combat/globalsettings.h and Code/Combat/globalsettings.cpp

---@class Renegade
---@field GlobalSettings GlobalSettings

CNC_RENEGADE.GlobalSettings = CNC_RENEGADE.GlobalSettings or {}

---@class GlobalSettings
local LIB = CNC_RENEGADE.GlobalSettings

--#region Colors
LIB.Colors = {}
LIB.Colors.Nod                = Color( 255,   0, 0   )
LIB.Colors.GDI                = Color( 255, 255, 0   )
LIB.Colors.Neutral            = Color( 255, 255, 255 )
LIB.Colors.Mutant             = Color(   0, 255, 0   )
LIB.Colors.Renegade           = Color(   0,   0, 255 )
LIB.Colors.PrimaryObjective   = Color(   0, 255, 0   )
LIB.Colors.SecondaryObjective = Color(   0,   0, 255 )
LIB.Colors.TertiaryObjective  = Color( 255,   0, 255 )
LIB.Colors.HealthHigh         = Color(   0, 255, 0   )
LIB.Colors.HealthMed          = Color( 255, 255, 0   )
LIB.Colors.HealthLow          = Color( 255,   0, 0   )
LIB.Colors.Enemy              = Color( 255,   0, 0   )
LIB.Colors.Friendly           = Color(   0, 255, 0   )
LIB.Colors.NoRelation         = Color( 255, 255, 255 )
--#endregion