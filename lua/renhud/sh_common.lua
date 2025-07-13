-- Provides shared resources common to both the server and the client

--- @class Renegade
local CNC = CNC_RENEGADE

local LIB

--[[ Class Setup ]] do

    --- @class SharedCommon
    LIB = CNC.CreateExport()
end


--#region Enums

    --- @enum Disposition
    LIB.DISPOSITION = {
        -- These are integer literals so the Client has them as well
        Error   = 0, -- D_ER 
        Hate    = 1, -- D_HT
        Fear    = 2, -- D_FR
        Like    = 3, -- D_LI
        Neutral = 4  -- D_NU
    }
--#endregion


--[[ Static Functions and Variables ]] do
    local CLASS = "SharedCommon"

    --- [[ Public ]]

    --- @class SharedCommon
    --- The various `type()` results that constitute an Entity
    LIB.EntTypes = { "Entity", "NPC", "Player", "Weapon", "Vehicle", "Nextbot" }
end