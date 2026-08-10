-- Based on AABoxCollisionTestClass within Code/ww3d2/coltest.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type CollisionTestClass
local collisionTestClass = CNC.Import( "code/ww3d2/collision-test.lua" )

--- @class AABoxCollisionTestClass : CollisionTestClass
--- @field Instance AABoxCollisionTestInstance The metatable used by AABoxCollisionTestInstance
local STATIC = CNC.CreateExport( collisionTestClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "AABoxCollisionTestClass"

--- @class AABoxCollisionTestInstance : CollisionTestInstance
--- @field Static AABoxCollisionTestClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_AABoxCollisionTest : Renegade_CollisionTest" )
INSTANCE.Class = "AABoxCollisionTestInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAABoxCollisionTest = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class AABoxCollisionTestClass

    --- Creates a new AABoxCollisionTestInstance
    --- @return AABoxCollisionTestInstance
    function STATIC.New()
        return robustclass.New( "Renegade_AABoxCollisionTest" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) AABoxCollisionTestInstance, `false` otherwise
    function STATIC.IsAABoxCollisionTest( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAABoxCollisionTest and true or false
    end

    typecheck.RegisterType( "AABoxCollisionTestInstance", STATIC.IsAABoxCollisionTest )
end


--- @class AABoxCollisionTestInstance
--- @field Box AaBoxInstance
--- @field Move Vector
--- @field SweepMin Vector
--- @field SweepMax Vector

function INSTANCE:Renegade_AABoxCollisionTest()
	typecheck.NotImplementedError()
end

function INSTANCE:Cull()
	typecheck.NotImplementedError()
end

function INSTANCE:CastToTriangle()
	typecheck.NotImplementedError()
end

function INSTANCE:Translate()
	typecheck.NotImplementedError()
end

function INSTANCE:Rotate()
	typecheck.NotImplementedError()
end

function INSTANCE:Transform()
	typecheck.NotImplementedError()
end
