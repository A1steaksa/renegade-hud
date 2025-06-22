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

    --- Gets are transformation matrix that represents a given Entity
    --- @param ent Entity
    --- @return Matrix3dInstance
    function LIB.GetTransform( ent )
        local matrix = matrix3d.New( ent:GetPos() )

        local ang = ent:GetAngles()

        -- "Coordinates in Source are (X,Y,Z), where X is forward/East, Y is left/North, and Z is up"
        -- https://developer.valvesoftware.com/wiki/Coordinates
        matrix:RotateY( math.rad( ang.pitch ) )
        matrix:RotateZ( math.rad( ang.yaw ) )
        matrix:RotateX( math.rad( ang.roll ) )

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