-- Provides shared resources common to both the server and the client

--- @class Renegade
local CNC = CNC_RENEGADE

local LIB

--[[ Class Setup ]] do

    --- @class SharedCommon
    LIB = CNC.CreateExport()
end

--[[ Static Functions and Variables ]] do
    local CLASS = "SharedCommon"

    --- [[ Public ]]

    --- @class SharedCommon
    --- The various `type()` results that constitute an Entity
    LIB.EntTypes = { "Entity", "NPC", "Player", "Weapon", "Vehicle", "Nextbot" }
end