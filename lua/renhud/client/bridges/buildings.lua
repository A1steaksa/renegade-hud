-- This file contains code to bridge the gap between Garry's Mod Entities/map elements and C&C Renegade's concept of Buildings 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )

--- @class BuildingsBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )


--#region Imports

--- @type SharedCommon
local sharedCommon = CNC.Import( "renhud/sh_common.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "BuildingsBridge"

    --- [[ Public ]]

    --- Any Entity present as a key in this table is a building
    --- @type table<Entity, boolean>
    LIB.BuildingEntities = {}

    --- Marks an Entity as either being or not being a building
    --- @param ent Entity
    --- @param isBuilding boolean
    function LIB.SetIsBuilding( ent, isBuilding )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        typecheck.AssertArgType( CLASS, 2, isBuilding, "boolean" )

        -- Swap nil for false-y values to remove non-buildings from the table for speed or something
        local value = ( isBuilding ) and true or nil

        LIB.BuildingEntities[ ent ] = value
    end

    --- @param ent Entity
    --- @return boolean
    function LIB.IsBuilding( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )

        -- Explicitly test the table value to ensure we return a boolean
        return LIB.BuildingEntities[ ent ] == true
    end

    --- @param ent Entity
    --- @return boolean
    function LIB.IsMct( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        -- TODO: Implement something here
        return false
    end
end