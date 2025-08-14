--- Server-side Console Variables

MsgC( "[REN] Loading Server ConVars\n" )

--[[ Info Entity / Entity Targeting ]] do
    CreateConVar( "ren_entityinfo_update_delay",   "0.250",    { FCVAR_ARCHIVE },  "(Renegade) How frequently, in seconds between updates, should the server send updated InfoEntity data to clients?" )
end
