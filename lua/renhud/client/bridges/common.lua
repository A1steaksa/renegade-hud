-- This file contains code common to all bridge scripts

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class CommonBridge
local LIB = CNC.CreateExport()


--#region Imports

    --- @type Matrix3d
    local matrix3d = CNC.Import( "renhud/client/code/wwmath/matrix3d.lua" )

    --- @type PlayerType
    local playerType = CNC.Import( "renhud/client/code/combat/player-type.lua" )

    --- @type HudInfoUtilsClient
    local hudInfoUtils = CNC.Import( "renhud/client/cl_hud-info-utils.lua" )

    --- @type SharedCommon
    local sharedCommon = CNC.Import( "renhud/sh_common.lua" )
--#endregion


--#region Enums

    local dispositionEnum = sharedCommon.DISPOSITION
    local playerTypeEnum = playerType.PLAYER_TYPE_ENUM
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "CommonBridge"

    --- [[ Public ]]

    -- Localized for potential performance reasons
    local isServerEnabled = CNC.IsServerEnabled

    --- @param ent Entity
    --- @return boolean
    function LIB.IsGdi( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        return LIB.GetPlayerType( ent ) == playerType.PLAYER_TYPE_ENUM.GDI
    end

    --- @param ent Entity
    --- @return boolean
    function LIB.IsNod( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        return LIB.GetPlayerType( ent ) == playerType.PLAYER_TYPE_ENUM.Nod
    end

    --- Determines if a given Entity considers another given Entity to be its teammate.
    --- Note: This relationship may not be symmetrical.
    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsTeammate( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, sharedCommon.EntTypes )

        local info = hudInfoUtils.GetEntityInfo( otherEnt )
        return info.Disposition == dispositionEnum.Like

        -- local entType = LIB.GetPlayerType( ent )
        -- local otherEntType = LIB.GetPlayerType( otherEnt )

        -- -- Neutral entities can't be enemies
        -- if entType == playerTypeEnum.Neutral then
        --     return false
        -- end
        -- if otherEntType == playerTypeEnum.Neutral then
        --     return false
        -- end

        -- -- Consider Renegade to be GDI
        -- if entType == playerTypeEnum.Renegade then
        --     return otherEntType == playerTypeEnum.GDI
        -- end
        -- if otherEntType == playerTypeEnum.Renegade then
        --     return entType == playerTypeEnum.GDI
        -- end

        -- return LIB.GetPlayerType( ent ) == LIB.GetPlayerType( otherEnt )
    end

    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsEnemy( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, sharedCommon.EntTypes )

        local info = hudInfoUtils.GetEntityInfo( otherEnt )
        local disposition = info.Disposition
        return ( disposition == dispositionEnum.Hate ) or ( disposition == dispositionEnum.Fear )

        -- local entType = LIB.GetPlayerType( ent )
        -- local otherEntType = LIB.GetPlayerType( otherEnt )

        -- -- Neutral entities can't be enemies
        -- if entType == playerTypeEnum.Neutral then
        --     return false
        -- end
        -- if otherEntType == playerTypeEnum.Neutral then
        --     return false
        -- end

        -- -- Consider Renegade to be GDI
        -- if entType == playerTypeEnum.Renegade then
        --     return otherEntType == playerTypeEnum.Nod
        -- end
        -- if otherEntType == playerTypeEnum.Renegade then
        --     return entType == playerTypeEnum.Nod
        -- end


        -- return entType ~= otherEntType
    end

    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsNeutral( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, sharedCommon.EntTypes )

        local info = hudInfoUtils.GetEntityInfo( ent )
        return info.Disposition == dispositionEnum.Neutral

        -- local entType = LIB.GetPlayerType( ent )
        -- local otherEntType = LIB.GetPlayerType( otherEnt )

        -- return entType == playerTypeEnum.Neutral or otherEntType == playerTypeEnum.Neutral
    end

    --- Gets a transformation matrix that represents a given Entity
    --- @param ent Entity
    --- @return Matrix3dInstance
    function LIB.GetTransform( ent )
        local matrix = matrix3d.New( false )
        local row = matrix.Row
        local row1, row2, row3 = row[1], row[2], row[3]

        row1.x, row1.x, row1.z =  0,  0, -1
        row2.x, row2.y, row2.z = -1,  0,  0
        row3.x, row3.y, row3.z =  0,  1,  0

        local pos = ent:GetPos()
        row1.w = pos.x
        row2.w = pos.y
        row3.w = pos.z

        local ang = ent:GetAngles()

        -- "Coordinates in Source are (X,Y,Z), where X is forward/East, Y is left/North, and Z is up"
        -- https://developer.valvesoftware.com/wiki/Coordinates

        -- Apply Source rotations to the matrix
        matrix:RotateY( math.rad( ang.yaw    ) )
        matrix:RotateX( math.rad( -ang.pitch ) )
        matrix:RotateZ( math.rad( -ang.roll  ) )

        -- Correct Source rotations into Renegade's coordinate space
        matrix:RotateY( math.rad( 180 ) )
        matrix:RotateX( math.rad( -90 ) )
        matrix:RotateZ( math.rad( 90  ) )

        return matrix
    end

    --- [[ Private ]]

    --- This function is what all others rely on to determine the faction of a given Entity  
    --- Note: This can be used with all types of Entity
    --- @param ent Entity
    --- @return PlayerTypeEnum
    function LIB.GetPlayerType( ent )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )

        local class = ent:GetClass()

        -- TODO: Implement something better here

        if ent:IsPlayer() then
            --- @cast ent Player
            return playerType.PLAYER_TYPE_ENUM.Renegade
        end

        if IsEnemyEntityName( class ) then
            return playerType.PLAYER_TYPE_ENUM.Nod
        end

        if IsFriendEntityName( class ) then
            return playerType.PLAYER_TYPE_ENUM.GDI
        end

        return playerType.PLAYER_TYPE_ENUM.Neutral
    end

    --- @param ent Entity
    --- @return boolean
    --- @private
    function LIB.CanHaveRelationships( ent )
        if not typecheck.IsOfType( ent, sharedCommon.EntTypes ) then
            return false
        end

        if not ent.GetRelationship then
            return false
        end

        return true
    end
end