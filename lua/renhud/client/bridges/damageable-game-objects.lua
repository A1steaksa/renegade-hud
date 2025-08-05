-- This file contains code to bridge the gap between Garry's Mod Entities and C&C Renegade's concept of Damageable Game Objects 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )

--- @class DamageableGameObjectsBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )

--#region Imports

--- @type SharedCommon
local sharedCommon = CNC.Import( "renhud/sh_common.lua" )
--#endregion

--[[ Static Functions and Variables ]] do

    local CLASS = "DamageableGameObjectsBridge"

    --- [[ Public ]]

    --- @param ent Entity
    --- @return boolean
    function LIB.IsDamageableGameObject( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        -- TODO: Implement something here

        return ent:GetMaxHealth() ~= 0
    end
end