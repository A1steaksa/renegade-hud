-- This file contains code to bridge the gap between Garry's Mod Entities and C&C Renegade's concept of Damageable Game Objects 

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class DamageableGameObjectsBridge
local LIB = CNC.CreateExport()


--#region Imports

    --- @type CommonBridge
    local commonBridge = CNC.Import( "renhud/bridges/common.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "DamageableGameObjectsBridge"

    --- [[ Public ]]

    --- @param ent Entity
    --- @return boolean
    function LIB.IsDamageableGameObject( ent )
        typecheck.AssertArgType( CLASS, 1, ent, commonBridge.EntTypes )
        -- TODO: Implement something here
        return true
    end

    function LIB.IsTargetable( ent )
        typecheck.AssertArgType( CLASS, 1, ent, commonBridge.EntTypes )
        -- TODO: Implement something here
        return true
    end
end