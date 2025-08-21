--- Client-side Console Variables
MsgC( "[REN] Loading Client ConVars\n" )

local standardFlags     = { FCVAR_ARCHIVE }
local replicatedFlags   = { FCVAR_ARCHIVE, FCVAR_REPLICATED }

--[[ Info Entity / Entity Targeting ]] do
    CreateConVar( "ren_entityinfo_enabled",    "1",   standardFlags,   "Should target info draw?", 0, 1 )
    CreateConVar( "ren_entityinfo_max_length", "500", replicatedFlags, "The maximum distance, in Source units, that an Entity can be from the camera and still be targeted", 1 )
end

--[[ Directional Damage Indicators ]] do
    CreateConVar( "ren_damageindicator_enabled",          "1", standardFlags, "Should damage direction indicators draw?", 0, 1 )
    CreateConVar( "ren_damageindicator_vehicles_enabled", "0", standardFlags, "Should damage direction indicators be shown for damage taken by the vehicle the player is in?", 0, 1 )
end

--[[ Weapon Display / Ammo Counts ]] do
    CreateConVar( "ren_weaponinfo_center_ammo_display_time", "2", standardFlags, "How long, in seconds, should the center-right ammo counter be displayed when it appears?" )
end