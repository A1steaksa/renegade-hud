-- This file contains code common to all bridge scripts

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class CommonBridge
local LIB = CNC.CreateExport()


--#region Imports

    --- @type Matrix3d
    local matrix3d = CNC.Import( "renhud/code/wwmath/matrix3d.lua" )
--#endregion


--#region Enums

    --- @enum Disposition
    LIB.DISPOSITION = {
        Error   = D_ER,
        Hate    = D_HT,
        Fear    = D_FR,
        Like    = D_LI,
        Neutral = D_NU
    }
    local disposition = LIB.DISPOSITION
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "CommonBridge"

    LIB.EntTypes = { "Entity", "NPC", "Player", "Weapon" }

    --- [[ Public ]]

    --- Determines if a given Entity considers another given Entity to be its teammate.
    --- Note: This relationship may not be symmetrical.
    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsTeammate( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, LIB.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, LIB.EntTypes )

        if not LIB.CanHaveRelationships( ent ) then
            return false
        end

        local relationship = ent:GetRelationship( otherEnt )

        return relationship == disposition.Like
    end

    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsEnemy( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, LIB.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, LIB.EntTypes )

        if not LIB.CanHaveRelationships( ent ) then
            return false
        end

        local relationship = ent:GetRelationship( otherEnt )

        return ( relationship == disposition.Hate or relationship == disposition.Fear )
    end

    --- @param ent Entity
    --- @param otherEnt Entity  
    --- @return boolean
    function LIB.IsNeutral( ent, otherEnt )
        typecheck.AssertArgType( CLASS, 1, ent, LIB.EntTypes )
        typecheck.AssertArgType( CLASS, 2, otherEnt, LIB.EntTypes )

        if not LIB.CanHaveRelationships( ent ) then
            return true
        end

        local relationship = ent:GetRelationship( otherEnt )

        return relationship == disposition.Neutral
    end

    --- Gets a transformation matrix that represents a given Entity
    --- @param ent Entity
    --- @return Matrix3dInstance
    function LIB.GetTransform( ent )
        local matrix = matrix3d.New( false )
        local row = matrix.Row
        local row1, row2, row3 = row[1], row[2], row[3]

        local right = ent:GetRight():GetNormalized()
        local forward = ent:GetForward():GetNormalized()
        local up = ent:GetUp():GetNormalized()

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

    --- @param ent Entity
    --- @return boolean
    --- @private
    function LIB.CanHaveRelationships( ent )
        if not typecheck.IsOfType( ent, LIB.EntTypes ) then
            return false
        end

        if not ent.GetRelationship then
            return false
        end

        return true
    end
end