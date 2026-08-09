-- Based on Null3dObjectClass within Code/ww3d2/nullrobj.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type RenderObjectClass
local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

--- @class Null3dObjectClass : RenderObjectClass
--- @field Instance Null3dObjectInstance The metatable used by Null3dObjectInstance
local STATIC = CNC.CreateExport( renderObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "Null3dObjectClass"

--- @class Null3dObjectInstance : RenderObjectInstance
--- @field Static Null3dObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Null3dObject : Renegade_RenderObject" )
INSTANCE.Class = "Null3dObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsNull3dObject = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type SphereClass
	local sphereClass = CNC.Import( "code/wwmath/sphere.lua" )

	--- @type AABoxClass
	local aABoxClass = CNC.Import( "code/wwmath/aabox.lua" )

	--- @type NullLoaderClass
	local nullLoaderClass = CNC.Import( "code/ww3d2/null-loader.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class Null3dObjectClass
    --- @field NullLoader NullLoaderInstance

    --- Creates a new Null3dObjectInstance
    --- @overload fun( name: string ): Null3dObjectInstance
    --- @overload fun( src: Null3dObjectInstance ): Null3dObjectInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Null3dObject", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Null3dObjectInstance, `false` otherwise
    function STATIC.IsNull3dObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsNull3dObject and true or false
    end

    typecheck.RegisterType( "Null3dObjectInstance", STATIC.IsNull3dObject )

    function STATIC.StaticConstructor()
        STATIC.NullLoader = nullLoaderClass.New()
    end
end


--- @class Null3dObjectInstance
--- @field Name string

--- @param name string
--- @overload fun( self: Null3dObjectInstance, src: Null3dObjectInstance )
function INSTANCE:Renegade_Null3dObject( name )
    typecheck.AssertArgType( self.Class, 1, name, { "string", "Null3dObjectInstance" } )

    -- ( connectedEntity: Entity, name: string )
    if typecheck.IsOfType( name, "string" ) then
        renderObjectClass.Instance.Renegade_RenderObject( self )

        self.Name = name

    -- ( connectedEntity: Entity, src: Null3dObjectInstance )
    else
        renderObjectClass.Instance.Renegade_RenderObject( self )

        local src = name --[[@as Null3dObjectInstance]]
        self.Name = src.Name
    end
end

--- @return integer
function INSTANCE:ClassId()
	return renderObjectClass.RENDER_OBJECT_CLASS_ID.CLASSID_NULL
end

--- @return RenderObjectInstance
function INSTANCE:Clone()
    return STATIC.New( self )
end

function INSTANCE:GetName()
	typecheck.NotImplementedError()
end

--- @param renderInfo RenderInfoInstance
function INSTANCE:Render( renderInfo )
    -- empty in the original code
end

--- @return SphereInstance
function INSTANCE:GetObjectSpaceBoundingSphere()
	return sphereClass.New(
        Vector( 0, 0, 0 ),
        0.1
    )
end

--- @return AABoxInstance
function INSTANCE:GetObjectSpaceBoundingBox()
    return aABoxClass.New(
        Vector( 0, 0, 0 ),
        Vector( 0.1, 0.1, 0.1 )
    )
end
