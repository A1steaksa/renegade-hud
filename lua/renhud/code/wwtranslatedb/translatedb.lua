-- Based on Code/wwtranslatedb/translatedb.cpp

--- @class Renegade
--- @field TranslateDb TranslateDB

CNC_RENEGADE.TranslateDb = CNC_RENEGADE.TranslateDb or {}

--- @class TranslateDB
local STATIC = CNC_RENEGADE.TranslateDb

local strings = {
    [ "IDS_Power_up_DataDisc_01" ] = "Data Disc",

    [ "IDS_Enc_Obj_Priority_0_Primary" ] = "Primary",
    [ "IDS_Enc_Obj_Priority_0_Secondary" ] = "Secondary",

    [ "IDS_Power_up_SecurityCard" ] = "Security Card",

    [ "IDS_Power_up_Armor_00" ] = "Armor",
    [ "IDS_Power_up_Health_00" ] = "Health",
    [ "IDS_Power_up_Armor_Upgrade" ] = "Augmented Armor",
    [ "IDS_Power_up_Health_Upgrade" ] = "Augmented Health",
}

function STATIC.GetString( id )
    return strings[ id ] or "UNKNOWN STRING ID"
end