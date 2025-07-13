-- This file contains code to bridge the gap between Garry's Mod Entities and C&C Renegade's concept of Physical Game Objects 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )

--- @class PhysicalGameObjectsBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )


--#region Imports

    --- @type AABox
    local aABox = CNC.Import( "renhud/client/code/wwmath/aabox.lua" )

    --- @type SharedCommon
    local sharedCommon = CNC.Import( "renhud/sh_common.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "PhysicalGameObjectsBridge"

    --- [[ Public ]]

    --- @param ent Entity
    --- @return boolean
    function LIB.IsPhysicalGameObject( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        -- TODO: Implement something here
        return true
    end

    --- @param ent Entity
    --- @return boolean
    function LIB.IsHudPokableIndicatorEnabled( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )

        --[[ Vehicles ]] do
            if ent:IsVehicle() then
                --- @cast ent Vehicle

                local hasDriver = ent:GetDriver() ~= NULL
                return not hasDriver
            end
        end

        return false
    end
end