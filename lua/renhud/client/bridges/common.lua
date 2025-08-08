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

    --- @type InfoEntityLib
    local infoEntityLib = CNC.Import( "renhud/sh_info-entity.lua" )

    --- @type SharedCommon
    local sharedCommon = CNC.Import( "renhud/sh_common.lua" )
--#endregion


--#region Enums

    local dispositionEnum = infoEntityLib.DISPOSITION
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "CommonBridge"

    --- [[ Public ]]

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

        if infoEntityLib.HasEntityInfo( otherEnt ) then
            local info = infoEntityLib.GetEntityInfo( otherEnt ) --[[@as InfoEntityData]]
            return info.FeelingTowardPlayer == dispositionEnum.Friendly
        end

        return false
    end

    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsEnemy( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, sharedCommon.EntTypes )

        if infoEntityLib.HasEntityInfo( otherEnt ) then
            local info = infoEntityLib.GetEntityInfo( otherEnt ) --[[@as InfoEntityData]]
            local disposition = info.FeelingTowardPlayer
            return disposition == dispositionEnum.Enemy
        end

        return false
    end

    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsNeutral( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, sharedCommon.EntTypes )

        if infoEntityLib.HasEntityInfo( ent ) then
            local info = infoEntityLib.GetEntityInfo( ent ) --[[@as InfoEntityData]]
            return info.FeelingTowardPlayer == dispositionEnum.Neutral
        end

        return true
    end

    --- Create a transformation matrix to represent a given position and angle
    --- @param pos Vector
    --- @param ang Angle
    --- @return Matrix3dInstance
    function LIB.CreateTransform( pos, ang )
        local matrix = matrix3d.New( false )
        local row = matrix.Row
        local row1, row2, row3 = row[1], row[2], row[3]

        row1.x, row1.x, row1.z =  0,  0, -1
        row2.x, row2.y, row2.z = -1,  0,  0
        row3.x, row3.y, row3.z =  0,  1,  0

        row1.w = pos.x
        row2.w = pos.y
        row3.w = pos.z

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

    --- Gets a transformation matrix that represents a given Entity
    --- @param ent Entity
    --- @return Matrix3dInstance
    function LIB.GetTransform( ent )
        return LIB.CreateTransform( ent:GetPos(), ent:GetAngles() )
    end

    --- Gets a transformation matrix that represents a given Player's eyes
    --- @param ply Player
    --- @return Matrix3dInstance
    function LIB.GetEyeTransform( ply )
        return LIB.CreateTransform( ply:EyePos(), Angle( 0, ply:EyeAngles().yaw, 0 ) )
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