-- Based on DynamicPhysClass within Code/wwphys/dynamicphys.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type PhysicsClass
local physicsClass = CNC.Import( "code/wwphys/physics.lua" )

--- @class DynamicPhysicsClass : PhysicsClass
--- @field Instance DynamicPhysicsInstance The metatable used by DynamicPhysicsInstance
local STATIC = CNC.CreateExport( physicsClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "DynamicPhysicsClass"

--- @class DynamicPhysicsInstance : PhysicsInstance
--- @field Static DynamicPhysicsClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_DynamicPhysics : Renegade_Physics" )
INSTANCE.Class = "DynamicPhysicsInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsDynamicPhysics = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class DynamicPhysicsClass
	--- @field DisableDynamicPhysicsSimulation any
	--- @field DisableDynamicPhysicsRendering any

    --- Creates a new DynamicPhysicsInstance
    --- @return DynamicPhysicsInstance
    function STATIC.New()
        return robustclass.New( "Renegade_DynamicPhysics" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) DynamicPhysicsInstance, `false` otherwise
    function STATIC.IsDynamicPhysics( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsDynamicPhysics and true or false
    end

    typecheck.RegisterType( "DynamicPhysicsInstance", STATIC.IsDynamicPhysics )

	function STATIC.DisableAllSimulation()
		typecheck.NotImplementedError()
	end

	function STATIC.DisableAllRendering()
		typecheck.NotImplementedError()
	end

	function STATIC.IsAllSimulationDisabled()
		typecheck.NotImplementedError()
	end

	function STATIC.IsAllRenderingDisabled()
		typecheck.NotImplementedError()
	end
end


--- @class DynamicPhysicsInstance
--- @field DirtyVisibilityObjectId any
--- @field VisNodeId any
--- @field VisStatusLastUpdated any

function INSTANCE:Renegade_DynamicPhysics()
	physicsClass.Instance.Renegade_Physics( self )

	self.DirtyVisibilityObjectId = true
	self.VisNodeId = 0
	self.VisStatusLastUpdated = 0
end

function INSTANCE:_Renegade_DynamicPhysics()
	-- Empty in the original code
end

function INSTANCE:AsDynamicPhysicsClass()
	typecheck.NotImplementedError()
end

--- @param definition DynamicPhysicsDefinitionInstance
--- @param connectedEntity Entity
function INSTANCE:Init( definition, connectedEntity )
	physicsClass.Instance.Init( self, definition, connectedEntity )
end

--- @param model RenderObjectInstance
function INSTANCE:SetModel( model )
	physicsClass.Instance.SetModel( self, model )
end

function INSTANCE:UpdateVisibilityStatus()
	-- "Invalidate our cached vis object ID"
	self.DirtyVisibilityObjectId = true

	-- "Invalidate the lighting cache.  Next time this object is rendered the cache will be updated."
	self:InvalidateStaticLightingCache()
end

--- @return integer
function INSTANCE:GetVisibilityObjectId()
	if self.DirtyVisibilityObjectId then
		self:InternalUpdateVisibilityStatus()
	end
	return self.VisObjectId
end

function INSTANCE:IsSimulationDisabled()
	typecheck.NotImplementedError()
end

function INSTANCE:IsRenderingDisabled()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:OnPostLoad()
	typecheck.NotImplementedError()
end

function INSTANCE:InternalUpdateVisibilityStatus()
	typecheck.NotImplementedError()
end
