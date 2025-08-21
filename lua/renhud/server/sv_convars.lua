--- Server-side Console Variables
MsgC( "[REN] Loading Server ConVars\n" )

local standardFlags     = { FCVAR_ARCHIVE }
local replicatedFlags   = { FCVAR_ARCHIVE, FCVAR_REPLICATED }

--[[ Info Entity / Entity Targeting ]] do
    CreateConVar( "ren_entityinfo_max_length",   "500",   replicatedFlags,  "The maximum distance, in Source units, that an Entity can be from the camera and still be targeted", 1 )
    CreateConVar( "ren_entityinfo_update_delay", "0.250", standardFlags,    "How frequently, in seconds between updates, should the server send updated InfoEntity data to clients?" )
end

--[[ Directional Damage Indicators ]] do
    -- CreateConVar( "ren_damageindicator_update_delay", "0.250", standardFlags,  "How frequently, in seconds between updates, should the server send updated InfoEntity data to clients?" )
end
