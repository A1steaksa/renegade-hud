-- Based on MoveablePhysClass within Code/wwphys/movephys.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type DynamicPhysicsClass
local dynamicPhysicsClass = CNC.Import( "code/wwphys/dynamic-physics.lua" )

--- @class MoveablePhysicsClass : DynamicPhysicsClass
--- @field Instance MoveablePhysicsInstance The metatable used by MoveablePhysicsInstance
local STATIC = CNC.CreateExport( dynamicPhysicsClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "MoveablePhysicsClass"

--- @class MoveablePhysicsInstance : DynamicPhysicsInstance
--- @field Static MoveablePhysicsClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_MoveablePhysics : Renegade_DynamicPhysics" )
INSTANCE.Class = "MoveablePhysicsInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMoveablePhysics = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class MoveablePhysicsClass

    --- Creates a new MoveablePhysicsInstance
    --- @return MoveablePhysicsInstance
    function STATIC.New()
        return robustclass.New( "Renegade_MoveablePhysics" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) MoveablePhysicsInstance, `false` otherwise
    function STATIC.IsMoveablePhysics( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMoveablePhysics and true or false
    end

    typecheck.RegisterType( "MoveablePhysicsInstance", STATIC.IsMoveablePhysics )
end


--- @class MoveablePhysicsInstance
--- @field SourcePhysObj PhysObj The Connected Entity's PhysObj
--- @field Mass number
--- @field MassInverted number
--- @field GravityScale number
--- @field Elasticity number
--- @field Controller PhysicsControllerInstance
--- @field Carrier PhysicsInstance
--- @field CarrierSubObject RenderObjectInstance
--- @field ShadowManager DynamicShadowManagerInstance

function INSTANCE:Renegade_MoveablePhysics()
	dynamicPhysicsClass.Instance.Renegade_DynamicPhysics( self )

	self.Mass = 1.0
	self.MassInverted = 1.0
	self.GravityScale = 1.0
	self.Elasticity = 0.5
	self.Controller = nil
	self.Carrier = nil
	self.CarrierSubObject = nil
	self.ShadowManager = self
end

function INSTANCE:_Renegade_MoveablePhysics()
	self:LinkToCarrier( nil )
end

--- @param definition MoveablePhysicsDefinitionInstance
--- @param connectedEntity Entity
function INSTANCE:Init( definition, connectedEntity )
	self.Mass = definition.Mass
	self.MassInverted = 1.0 / self.Mass
	self.GravityScale = definition.GravityScale
	self.Elasticity = definition.Elasticity

	self.SourcePhysObj = connectedEntity:GetPhysicsObject()
	if self.SourcePhysObj:IsValid() then
		self.SourcePhysObj:SetMass( self.Mass )
	end

	dynamicPhysicsClass.Instance.Init( self, definition, connectedEntity )
end

function INSTANCE:AsMoveablePhysicsClass()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMoveablePhysicsDefinition()
	typecheck.NotImplementedError()
end

function INSTANCE:DefinitionChanged()
	typecheck.NotImplementedError()
end

function INSTANCE:NeedsTimestep()
	typecheck.NotImplementedError()
end

function INSTANCE:PostTimestepProcess()
	typecheck.NotImplementedError()
end

--- @param mass number
function INSTANCE:SetMass( mass )
	self.Mass = mass
	self.MassInverted = ( 1.0 / mass )

	if self.SourcePhysObj ~= nil and self.SourcePhysObj:IsValid() then
		self.SourcePhysObj:SetMass( self.Mass )
	end
end

--- @return number
function INSTANCE:GetMass()
	return self.Mass
end

--- @return number
function INSTANCE:GetMassInv()
	return self.MassInverted
end

--- @param grav number
function INSTANCE:SetGravityMultiplier( grav )
	self.GravityScale = grav
end

--- @return number
function INSTANCE:GetGravityMultiplier()
	return self.GravityScale
end

function INSTANCE:SetElasticity()
	typecheck.NotImplementedError()
end

function INSTANCE:GetElasticity()
	typecheck.NotImplementedError()
end

function INSTANCE:GetInertiaInv()
	typecheck.NotImplementedError()
end

function INSTANCE:CanTeleport()
	typecheck.NotImplementedError()
end

function INSTANCE:CanTeleportAndStand()
	typecheck.NotImplementedError()
end

function INSTANCE:FindTeleportLocation()
	typecheck.NotImplementedError()
end

function INSTANCE:CanMoveTo()
	typecheck.NotImplementedError()
end

function INSTANCE:CinematicMoveTo()
	typecheck.NotImplementedError()
end


--- @param control PhysicsControllerInstance
function INSTANCE:SetController( control )
	self.Controller = control
end

function INSTANCE:GetController()
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

function INSTANCE:GetVelocity()
	typecheck.NotImplementedError()
end

function INSTANCE:SetVelocity()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowBlobBox()
	typecheck.NotImplementedError()
end

function INSTANCE:IsCastingShadow()
	typecheck.NotImplementedError()
end

--- @param carrier PhysicsInstance
--- @param carrierSubObject RenderObjectInstance
function INSTANCE:LinkToCarrier( carrier, carrierSubObject )
	typecheck.NotImplementedError()
end

function INSTANCE:PeekCarrierObject()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekCarrierSubObject()
	typecheck.NotImplementedError()
end
