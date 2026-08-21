-- Based on TriClass within Code/WWMath/tri.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class TriangleClass
--- @field Instance TriangleInstance The metatable used by TriangleInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "TriangleClass"

--- @class TriangleInstance
--- @field Static TriangleClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Triangle" )
INSTANCE.Class = "TriangleInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsTriangle = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class TriangleClass

    --- Creates a new TriangleInstance
    --- @return TriangleInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Triangle" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) TriangleInstance, `false` otherwise
    function STATIC.IsTriangle( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsTriangle and true or false
    end

    typecheck.RegisterType( "TriangleInstance", STATIC.IsTriangle )
end


--- @class TriangleInstance
--- @field N Vector
--- @field V Vector

function INSTANCE:ComputeNormal()
	typecheck.NotImplementedError()
end

function INSTANCE:ContainsPoint()
	typecheck.NotImplementedError()
end

function INSTANCE:FindDominantPlane()
	typecheck.NotImplementedError()
end
