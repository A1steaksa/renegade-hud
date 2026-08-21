-- Based on RayCollisionTestClass within Code/ww3d2/coltest.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type CollisionTestClass
local collisionTestClass = CNC.Import( "code/ww3d2/collision-test.lua" )

--- @class RayCollisionTestClass : CollisionTestClass
--- @field Instance RayCollisionTestInstance The metatable used by RayCollisionTestInstance
local STATIC = CNC.CreateExport( collisionTestClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "RayCollisionTestClass"

--- @class RayCollisionTestInstance : CollisionTestInstance
--- @field Static RayCollisionTestClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_RayCollisionTest : Renegade_CollisionTest" )
INSTANCE.Class = "RayCollisionTestInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsRayCollisionTest = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class RayCollisionTestClass

    --- Creates a new RayCollisionTestInstance
    --- @return RayCollisionTestInstance
    function STATIC.New()
        return robustclass.New( "Renegade_RayCollisionTest" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) RayCollisionTestInstance, `false` otherwise
    function STATIC.IsRayCollisionTest( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsRayCollisionTest and true or false
    end

    typecheck.RegisterType( "RayCollisionTestInstance", STATIC.IsRayCollisionTest )
end


--- @class RayCollisionTestInstance
--- @field Ray LineSegmentInstance
--- @field IgnoreTranslucentMeshes boolean

--- @param ray LineSegmentInstance
--- @param result CastResultStruct
--- @param collisionType 
function INSTANCE:Renegade_RayCollisionTest( ray, result, collisionType, ignoreTranslucentMeshes )
	typecheck.NotImplementedError()
end

function INSTANCE:Cull()
	typecheck.NotImplementedError()
end

function INSTANCE:CastToTriangle()
	typecheck.NotImplementedError()
end
