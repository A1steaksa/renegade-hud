-- Based on CastResultStruct within Code/WWMath/castres.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class CastResultStruct
--- @field Instance CastResultStructInstance The metatable used by CastResultStructInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "CastResultStruct"

--- @class CastResultStructInstance
--- @field Static CastResultStruct The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_CastResultStruct" )
INSTANCE.Class = "CastResultStructInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsCastResultStruct = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class CastResultStruct

    --- Creates a new CastResultStructInstance
    --- @return CastResultStructInstance
    function STATIC.New()
        return robustclass.New( "Renegade_CastResultStruct" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) CastResultStructInstance, `false` otherwise
    function STATIC.IsCastResultStruct( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCastResultStruct and true or false
    end

    typecheck.RegisterType( "CastResultStructInstance", STATIC.IsCastResultStruct )
end


--- @class CastResultStructInstance
--- @field StartBad boolean
--- @field Fraction number
--- @field Normal Vector
--- @field SurfaceType integer
--- @field ComputeContactPoint boolean
--- @field ContactPoint Vector

function INSTANCE:Renegade_CastResultStruct()
	typecheck.NotImplementedError()
end

function INSTANCE:Reset()
	typecheck.NotImplementedError()
end
