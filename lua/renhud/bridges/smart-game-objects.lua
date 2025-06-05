-- This file contains code to bridge the gap between Garry's Mod Entities and C&C Renegade's concept of Smart Game Objects 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/bridges/common.lua" )

--- @class SmartGameObjectsBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )


--[[ Static Functions and Variables ]] do

    local CLASS = "SmartGameObjectsBridge"

    --- [[ Public ]]

    --- @param ent Entity
    --- @return boolean
    function LIB.IsSmartGameObject( ent )
        typecheck.AssertArgType( CLASS, 1, ent, commonBridge.EntTypes )
        -- TODO: Implement something here
        return true
    end

    --- @param ent Entity
    --- @return boolean
    function LIB.IsStealthed( ent )
        typecheck.AssertArgType( CLASS, 1, ent, commonBridge.EntTypes )
        -- TODO: Implement something here
        return false
    end
end