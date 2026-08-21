-- Based on PhysRayCollisionTestClass within Code/wwphys/physcoltest.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type RayCollisionTestClass
local rayCollisionTestClass = CNC.Import( "code/ww3d2/ray-collision-test.lua" )

--- @class PhysicsRayCollisionTestClass : RayCollisionTestClass
--- @field Instance PhysicsRayCollisionTestInstance The metatable used by PhysicsRayCollisionTestInstance
local STATIC = CNC.CreateExport( rayCollisionTestClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "PhysicsRayCollisionTestClass"

--- @class PhysicsRayCollisionTestInstance : RayCollisionTestInstance
--- @field Static PhysicsRayCollisionTestClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_PhysicsRayCollisionTest : Renegade_RayCollisionTest" )
INSTANCE.Class = "PhysicsRayCollisionTestInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysicsRayCollisionTest = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class PhysicsRayCollisionTestClass

    --- Creates a new PhysicsRayCollisionTestInstance
    --- @return PhysicsRayCollisionTestInstance
    function STATIC.New()
        return robustclass.New( "Renegade_PhysicsRayCollisionTest" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) PhysicsRayCollisionTestInstance, `false` otherwise
    function STATIC.IsPhysicsRayCollisionTest( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysicsRayCollisionTest and true or false
    end

    typecheck.RegisterType( "PhysicsRayCollisionTestInstance", STATIC.IsPhysicsRayCollisionTest )
end


--- @class PhysicsRayCollisionTestInstance
--- @field CollidedPhysicsObject PhysicsInstance
--- @field CollisionGroup integer
--- @field CheckStaticObjects boolean
--- @field CheckDynamicObjects boolean

function INSTANCE:Renegade_PhysicsRayCollisionTest( ray, results, group, type )
    rayCollisionTestClass.Instance.Renegade_RayCollisionTest( ray, results, type )

    self.CollidedPhysicsObject = nil
    self.CollisionGroup = group
    self.CheckStaticObjects = true
    self.CheckDynamicObjects = true
end
