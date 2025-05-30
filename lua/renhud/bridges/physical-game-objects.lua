-- This file contains code to bridge the gap between Garry's Mod Entities and C&C Renegade's concept of Physical Game Objects 

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class PhysicalGameObjectsBridge
local LIB = CNC.CreateExport()


--#region Imports

    --- @type CommonBridge
    local commonBridge = CNC.Import( "renhud/bridges/common.lua" )

    --- @type AABox
    local aABox = CNC.Import( "renhud/code/wwmath/aabox.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "PhysicalGameObjectsBridge"

    --- [[ Public ]]

    LIB.IsTeammate = commonBridge.IsTeammate
    LIB.IsEnemy = commonBridge.IsEnemy
    LIB.IsNeutral = commonBridge.IsNeutral

    --- @param ent Entity
    --- @return boolean
    function LIB.IsPhysicalGameObject( ent )
        typecheck.AssertArgType( CLASS, 1, ent, commonBridge.EntTypes )
        -- TODO: Implement something here
        return true
    end

    --- @param ent Entity
    --- @return AABoxInstance
    function LIB.GetShadowBox( ent )
        typecheck.AssertArgType( CLASS, 1, ent, commonBridge.EntTypes )

        local mins, maxs = ent:GetCollisionBounds()

        local center = ( maxs - mins ) / 2

        local shadowBox = aABox.New( center, maxs )

        return shadowBox
    end
end