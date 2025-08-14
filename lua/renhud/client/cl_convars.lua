--- Client-side Console Variables

MsgC( "[REN] Loading Client ConVars\n" )

--[[ Info Entity / Entity Targeting ]] do
    CreateConVar( "ren_entityinfo_max_length", "500",    { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "The maximum distance, in Source units, that an Entity can be from the camera and still be targeted", 1 )
end

--[[ Directional Damage Indicators ]] do
    CreateConVar( "ren_damageindicator_enabled", "1", { FCVAR_ARCHIVE }, "Should damage direction indicators draw?", 0, 1 )
end

--[[ Weapon Display / Ammo Counts ]] do
    CreateConVar( "ren_weaponinfo_center_ammo_display_time", "2", { FCVAR_ARCHIVE }, "How long, in seconds, should the center-right ammo counter be displayed when it appears?" )
end