-- Based on PhysOBBoxCollisionTestClass within Code/wwphys/physcoltest.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type OBBoxCollisionTestClass
local oBBoxCollisionTestClass = CNC.Import( "code/ww3d2/ob-box-collision-test.lua" )

--- @class PhysicsOBBoxCollisionTestClass : OBBoxCollisionTestClass
--- @field Instance PhysicsOBBoxCollisionTestInstance The metatable used by PhysicsOBBoxCollisionTestInstance
local STATIC = CNC.CreateExport( oBBoxCollisionTestClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "PhysicsOBBoxCollisionTestClass"

--- @class PhysicsOBBoxCollisionTestInstance : OBBoxCollisionTestInstance
--- @field Static PhysicsOBBoxCollisionTestClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_PhysicsOBBoxCollisionTest : Renegade_OBBoxCollisionTest" )
INSTANCE.Class = "PhysicsOBBoxCollisionTestInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysicsOBBoxCollisionTest = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class PhysicsOBBoxCollisionTestClass

    --- Creates a new PhysicsOBBoxCollisionTestInstance
    --- @return PhysicsOBBoxCollisionTestInstance
    function STATIC.New()
        return robustclass.New( "Renegade_PhysicsOBBoxCollisionTest" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) PhysicsOBBoxCollisionTestInstance, `false` otherwise
    function STATIC.IsPhysicsOBBoxCollisionTest( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysicsOBBoxCollisionTest and true or false
    end

    typecheck.RegisterType( "PhysicsOBBoxCollisionTestInstance", STATIC.IsPhysicsOBBoxCollisionTest )
end


--- @class PhysicsOBBoxCollisionTestInstance
--- @field CollidedPhysicsObject PhysicsInstance
--- @field CollisionGroup integer
--- @field CheckStaticObjects boolean
--- @field CheckDynamicObjects boolean

function INSTANCE:Renegade_PhysicsOBBoxCollisionTest()
	typecheck.NotImplementedError()
end
