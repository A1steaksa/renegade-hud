-- Based on OBBoxCollisionTestClass within Code/ww3d2/coltest.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type CollisionTestClass
local collisionTestClass = CNC.Import( "code/ww3d2/collision-test.lua" )

--- @class OBBoxCollisionTestClass : CollisionTestClass
--- @field Instance OBBoxCollisionTestInstance The metatable used by OBBoxCollisionTestInstance
local STATIC = CNC.CreateExport( collisionTestClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "OBBoxCollisionTestClass"

--- @class OBBoxCollisionTestInstance : CollisionTestInstance
--- @field Static OBBoxCollisionTestClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_OBBoxCollisionTest : Renegade_CollisionTest" )
INSTANCE.Class = "OBBoxCollisionTestInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsOBBoxCollisionTest = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class OBBoxCollisionTestClass

    --- Creates a new OBBoxCollisionTestInstance
    --- @return OBBoxCollisionTestInstance
    function STATIC.New()
        return robustclass.New( "Renegade_OBBoxCollisionTest" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) OBBoxCollisionTestInstance, `false` otherwise
    function STATIC.IsOBBoxCollisionTest( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsOBBoxCollisionTest and true or false
    end

    typecheck.RegisterType( "OBBoxCollisionTestInstance", STATIC.IsOBBoxCollisionTest )
end


--- @class OBBoxCollisionTestInstance
--- @field Box ObBoxInstance
--- @field Move Vector
--- @field SweepMin Vector
--- @field SweepMax Vector

function INSTANCE:Renegade_OBBoxCollisionTest()
	typecheck.NotImplementedError()
end

function INSTANCE:Renegade_OBBoxCollisionTest()
	typecheck.NotImplementedError()
end

function INSTANCE:Cull()
	typecheck.NotImplementedError()
end

function INSTANCE:CastToTriangle()
	typecheck.NotImplementedError()
end
