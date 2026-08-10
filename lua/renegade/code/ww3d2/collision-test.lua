-- Based on CollisionTestClass within Code/ww3d2/coltest.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class CollisionTestClass
--- @field Instance CollisionTestInstance The metatable used by CollisionTestInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "CollisionTestClass"

--- @class CollisionTestInstance
--- @field Static CollisionTestClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_CollisionTest" )
INSTANCE.Class = "CollisionTestInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsCollisionTest = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class CollisionTestClass

    --- Creates a new CollisionTestInstance
    --- @return CollisionTestInstance
    function STATIC.New()
        return robustclass.New( "Renegade_CollisionTest" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) CollisionTestInstance, `false` otherwise
    function STATIC.IsCollisionTest( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCollisionTest and true or false
    end

    typecheck.RegisterType( "CollisionTestInstance", STATIC.IsCollisionTest )
end


--- @class CollisionTestInstance
--- @field Result CastResultStructInstance
--- @field CollisionType integer
--- @field CollidedRenderObject RenderObjectInstance

function INSTANCE:Renegade_CollisionTest()
	typecheck.NotImplementedError()
end
