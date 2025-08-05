-- This file contains code to bridge the gap between Garry's Mod Entities/map elements and C&C Renegade's concept of OffenseObjects 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )

--- @class OffenseObjectsBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )


--[[ Static Functions and Variables ]] do

    local CLASS = "OffenseObjectsBridge"

    --- [[ Public ]]

    --- @param ent Entity
    --- @return boolean
    function LIB.IsOffenseObject( ent )
        -- TODO: Implement something here
        return true
    end
end