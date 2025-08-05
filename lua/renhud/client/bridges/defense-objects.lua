-- This file contains code to bridge the gap between Garry's Mod Entities/map elements and C&C Renegade's concept of DefenseObjects 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )

--- @class DefenseObjectsBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )

--#region Imports

--- @type SharedCommon
local sharedCommon = CNC.Import( "renhud/sh_common.lua" )
--#endregion

--[[ Static Functions and Variables ]] do

    local CLASS = "DefenseObjectsBridge"

    --- [[ Public ]]

    --- @param ent Entity
    --- @return boolean
    function LIB.IsDefenseObject( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        -- TODO: Implement something here
        return true
    end

    --- @param ent Entity
    --- @return number
    function LIB.GetHealthMax( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        return ent:GetMaxHealth()
    end

    --- @param ent Entity
    --- @return number
    function LIB.GetShieldStrengthMax( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )

        if typecheck.IsOfType( ent, "Player" ) then
            --- @cast ent Player
            return ent:GetMaxArmor()
        end

        return 0
    end

    --- @param ent Entity
    --- @return number
    function LIB.GetHealth( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        return ent:Health()
    end

    --- @param ent Entity
    --- @return number
    function LIB.GetShieldStrength( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        if typecheck.IsOfType( ent, "Player" ) then
            --- @cast ent Player
            return ent:Armor()
        end

        return 0
    end
end