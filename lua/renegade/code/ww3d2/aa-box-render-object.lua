-- Based on AABoxRenderObjClass within Code/ww3d2/boxrobj.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type BoxRenderObjectClass
local boxRenderObjectClass = CNC.Import( "code/ww3d2/box-render-object.lua" )

--- @class AABoxRenderObjectClass : BoxRenderObjectClass
--- @field Instance AABoxRenderObjectInstance The metatable used by AABoxRenderObjectInstance
local STATIC = CNC.CreateExport( boxRenderObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "AABoxRenderObjectClass"

--- @class AABoxRenderObjectInstance : BoxRenderObjectInstance
--- @field Static AABoxRenderObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_AABoxRenderObject : Renegade_BoxRenderObject" )
INSTANCE.Class = "AABoxRenderObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAABoxRenderObject = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type AABoxClass
	local aABoxClass = CNC.Import( "code/wwmath/aabox.lua" )

	--- @type RenderObjectClass
	local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

	--- @type SphereClass
	local sphereClass = CNC.Import( "code/wwmath/sphere.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class AABoxRenderObjectClass

    --- Creates a new AABoxRenderObjectInstance
    --- @return AABoxRenderObjectInstance
    function STATIC.New()
        return robustclass.New( "Renegade_AABoxRenderObject" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) AABoxRenderObjectInstance, `false` otherwise
    function STATIC.IsAABoxRenderObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAABoxRenderObject and true or false
    end

    typecheck.RegisterType( "AABoxRenderObjectInstance", STATIC.IsAABoxRenderObject )
end


--- @class AABoxRenderObjectInstance
--- @field CachedBox AABoxInstance

--- @param src W3dBoxStruct|AABoxRenderObjectInstance|AABoxInstance?
function INSTANCE:Renegade_AABoxRenderObject( src )
	self.CachedBox = aABoxClass.New()

	-- "Constructor"
	-- ()
	if src == nil then
		--- @cast src nil

		boxRenderObjectClass.Instance.Renegade_BoxRenderObject( self )

		INSTANCE.UpdateCachedBox( self )
		return
	else
		typecheck.AssertArgType( INSTANCE.Class, 1, src, { "W3dBoxStruct", "AABoxRenderObjectInstance", "AABoxInstance" } )

		-- "Init from a definition"
		-- ( def: W3dBoxStruct )
		if typecheck.IsOfType( src, "W3dBoxStruct" ) then
			local def = src --[[@as W3dBoxStruct]]

			boxRenderObjectClass.Instance.Renegade_BoxRenderObject( self, def )

			INSTANCE.UpdateCachedBox( self )
			return

		-- "Copy constructor"
		-- ( src: AABoxRenderObjectInstance )
		elseif typecheck.IsOfType( src, "AABoxRenderObjectInstance" ) then
			--- @cast src AABoxRenderObjectInstance

			boxRenderObjectClass.Instance.Renegade_BoxRenderObject( self )

			typecheck.NotImplementedError()
			return

		-- "Constructor from a wwmath aabox"
		-- ( box: AABoxInstance )
		else
			local box = src --[[@as AABoxInstance]]

			boxRenderObjectClass.Instance.Renegade_BoxRenderObject( self )

			self.ObjectSpaceCenter = Vector( 0, 0, 0 )
			self.ObjectSpaceExtent = box.Extent
			INSTANCE.SetPosition( self, box.Center )
			INSTANCE.UpdateCachedBox( self )
			return
		end
	end
end

--[[ Render Object Interface ]] do

	function INSTANCE:Clone()
		typecheck.NotImplementedError()
	end

	function INSTANCE:ClassId()
		typecheck.NotImplementedError()
	end

	--- @param renderInfo RenderInfoInstance
	function INSTANCE:Render( renderInfo )
		typecheck.NotImplementedError()
	end

	function INSTANCE:SpecialRender()
		typecheck.NotImplementedError()
	end

	--- "Set the transform for this box"
	--- @param matrix Matrix3dInstance
	function INSTANCE:SetTransform( matrix )
		renderObjectClass.Instance.SetTransform( self, matrix )
		INSTANCE.UpdateCachedBox( self )
	end

	--- @param pos Vector
	function INSTANCE:SetPosition( pos )
		renderObjectClass.Instance.SetPosition( self, pos )
		INSTANCE.UpdateCachedBox( self )
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

	--- @return SphereInstance
	function INSTANCE:GetObjectSpaceBoundingSphere()
		local sphere = sphereClass.New()
		sphere:Init( self.ObjectSpaceCenter, self.ObjectSpaceExtent:Length() )
		return sphere
	end

	--- @return AABoxInstance
	function INSTANCE:GetObjectSpaceBoundingBox()
		local box = aABoxClass.New()
		box:Init( self.ObjectSpaceCenter, self.ObjectSpaceExtent )
		return box
	end
end

--- @return AABoxInstance
function INSTANCE:GetBox()
	INSTANCE.ValidateTransform( self )
	INSTANCE.UpdateCachedBox( self )
	return self.CachedBox
end

--- "Update the world-space version of this box"
function INSTANCE:UpdateCachedBox()
	self.CachedBox.Center = self.Transform:GetTranslation() + self.ObjectSpaceCenter
	self.CachedBox.Extent = self.ObjectSpaceExtent
end
