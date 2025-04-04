-- Replaces the default values in code/combat/global-settings.lua
-- This is emulating the behavior of .ddb files
-- Values were manually copied out of LevelEdit via `Presets>Global Settings>HUD>HUD`

if not CNC_RENEGADE or not CNC_RENEGADE.GlobalSettings then
    error( "Cannot update global settings before global settings have loaded" )
end

local settings = CNC_RENEGADE.GlobalSettings

--#region Colors
settings.Colors = {}
settings.Colors.Nod                = Color( 200,   0, 0   )
settings.Colors.GDI                = Color( 225, 175, 65  )
settings.Colors.Neutral            = Color( 225, 225, 240 )
settings.Colors.Mutant             = Color(   0, 100, 0   )
settings.Colors.Renegade           = Color(   0,   0, 255 )
settings.Colors.PrimaryObjective   = Color(  50, 225, 50  )
settings.Colors.SecondaryObjective = Color(  50, 150, 250 )
settings.Colors.TertiaryObjective  = Color( 150,  50, 150 )
settings.Colors.HealthHigh         = Color(   0, 240, 0   )
settings.Colors.HealthMed          = Color( 240, 240, 0   )
settings.Colors.HealthLow          = Color( 240,   0, 0   )
settings.Colors.Enemy              = Color( 200,   0, 0   )
settings.Colors.Friendly           = Color(   0, 225, 0   )
settings.Colors.NoRelation         = Color( 125, 150, 150 )