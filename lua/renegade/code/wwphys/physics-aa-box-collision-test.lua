-- Based on PhysAABoxCollisionTestClass within Code/wwphys/physcoltest.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type AABoxCollisionTestClass
local aABoxCollisionTestClass = CNC.Import( "code/ww3d2/aa-box-collision-test.lua" )

--- @class PhysicsAABoxCollisionTestClass : AABoxCollisionTestClass
--- @field Instance PhysicsAABoxCollisionTestInstance The metatable used by PhysicsAABoxCollisionTestInstance
local STATIC = CNC.CreateExport( aABoxCollisionTestClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "PhysicsAABoxCollisionTestClass"

--- @class PhysicsAABoxCollisionTestInstance : AABoxCollisionTestInstance
--- @field Static PhysicsAABoxCollisionTestClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_PhysicsAABoxCollisionTest : Renegade_AABoxCollisionTest" )
INSTANCE.Class = "PhysicsAABoxCollisionTestInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysicsAABoxCollisionTest = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class PhysicsAABoxCollisionTestClass

    --- Creates a new PhysicsAABoxCollisionTestInstance
    --- @return PhysicsAABoxCollisionTestInstance
    function STATIC.New()
        return robustclass.New( "Renegade_PhysicsAABoxCollisionTest" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) PhysicsAABoxCollisionTestInstance, `false` otherwise
    function STATIC.IsPhysicsAABoxCollisionTest( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysicsAABoxCollisionTest and true or false
    end

    typecheck.RegisterType( "PhysicsAABoxCollisionTestInstance", STATIC.IsPhysicsAABoxCollisionTest )
end


--- @class PhysicsAABoxCollisionTestInstance
--- @field CollidedPhysicsObject PhysicsInstance
--- @field CollisionGroup integer
--- @field CheckStaticObjects boolean
--- @field CheckDynamicObjects boolean

function INSTANCE:Renegade_PhysicsAABoxCollisionTest()
	typecheck.NotImplementedError()
end
