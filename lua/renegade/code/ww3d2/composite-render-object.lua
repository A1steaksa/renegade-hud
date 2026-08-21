-- Based on CompositeRenderObjClass within Code/ww3d2/composite.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type RenderObjectClass
local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

--- @class CompositeRenderObjectClass : RenderObjectClass
--- @field Instance CompositeRenderObjectInstance The metatable used by CompositeRenderObjectInstance
local STATIC = CNC.CreateExport( renderObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "CompositeRenderObjectClass"

--- @class CompositeRenderObjectInstance : RenderObjectInstance
--- @field Static CompositeRenderObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_CompositeRenderObject : Renegade_RenderObject" )
INSTANCE.Class = "CompositeRenderObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsCompositeRenderObject = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type AABoxClass
	local aABoxClass = CNC.Import( "code/wwmath/aabox.lua" )

	--- @type SphereClass
	local sphereClass = CNC.Import( "code/wwmath/sphere.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class CompositeRenderObjectClass

    --- Creates a new CompositeRenderObjectInstance
	--- @param other CompositeRenderObjectInstance?
    --- @return CompositeRenderObjectInstance
    function STATIC.New( other )
        return robustclass.New( "Renegade_CompositeRenderObject", other )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) CompositeRenderObjectInstance, `false` otherwise
    function STATIC.IsCompositeRenderObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCompositeRenderObject and true or false
    end

    typecheck.RegisterType( "CompositeRenderObjectInstance", STATIC.IsCompositeRenderObject )
end


--- @class CompositeRenderObjectInstance
--- @field Name string "Name of the render object"
--- @field BaseModelName? string "Name of the original render obj (before aggregation)"
--- @field ObjectSphere SphereInstance "Object-space bounding sphere"
--- @field ObjectBox AABoxInstance "Object-space bounding box"

--- @param other CompositeRenderObjectInstance?
function INSTANCE:Renegade_CompositeRenderObject( other )
	self.ObjectBox = aABoxClass.New()
	self.ObjectSphere = sphereClass.New()

	-- ()
	if other == nil then
		renderObjectClass.Instance.Renegade_RenderObject( self )
		return
	end

	-- ( other: CompositeRenderObjectInstance )
	typecheck.AssertArgType( self.Class, 1, other, "CompositeRenderObjectInstance" )

	renderObjectClass.Instance.Renegade_RenderObject( self )

	self:SetName( other:GetName() )
	self:SetBaseModelName( other:GetBaseModelName() )
end

function INSTANCE:_Renegade_CompositeRenderObject()
	typecheck.NotImplementedError()
end

function INSTANCE:Restart()
	typecheck.NotImplementedError()
end

--- @return string
function INSTANCE:GetName()
	return self.Name
end

--- "Sets the name of this render object"
--- @param name string
function INSTANCE:SetName( name )
	self.Name = name
end

--- @return string?
function INSTANCE:GetBaseModelName()
	return nil
end

--- @param name string?
function INSTANCE:SetBaseModelName( name )
	self.BaseModelName = name
end

function INSTANCE:GetNumPolys()
	typecheck.NotImplementedError()
end

function INSTANCE:NotifyAdded()
	typecheck.NotImplementedError()
end

function INSTANCE:NotifyRemoved()
	typecheck.NotImplementedError()
end

function INSTANCE:CastRay()
	typecheck.NotImplementedError()
end

function INSTANCE:CastAABox()
	typecheck.NotImplementedError()
end

function INSTANCE:CastOBBox()
	typecheck.NotImplementedError()
end

function INSTANCE:IntersectAABox()
	typecheck.NotImplementedError()
end

function INSTANCE:IntersectOBBox()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateDecal()
	typecheck.NotImplementedError()
end

function INSTANCE:DeleteDecal()
	typecheck.NotImplementedError()
end

--- @return SphereInstance
function INSTANCE:GetObjectSpaceBoundingSphere()
	return self.ObjectSphere
end

--- @return AABoxInstance
function INSTANCE:GetObjectSpaceBoundingBox()
	return self.ObjectBox
end

function INSTANCE:UpdateObjectSpaceBoundingVolumes()
	typecheck.NotImplementedError()
end

function INSTANCE:SetUserData()
	typecheck.NotImplementedError()
end
