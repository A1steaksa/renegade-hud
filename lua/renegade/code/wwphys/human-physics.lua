-- Based on HumanPhysClass within Code/wwphys/humanphys.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type Physics3Class
local physics3Class = CNC.Import( "code/wwphys/physics-3.lua" )

--- @class HumanPhysicsClass : Physics3Class
--- @field Instance HumanPhysicsInstance The metatable used by HumanPhysicsInstance
local STATIC = CNC.CreateExport( physics3Class )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HumanPhysicsClass"

--- @class HumanPhysicsInstance : Physics3Instance
--- @field Static HumanPhysicsClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HumanPhysics : Renegade_Physics3" )
INSTANCE.Class = "HumanPhysicsInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHumanPhysics = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HumanPhysicsClass
	--- @field DisableHumanSimulation boolean
	--- @field DisableHumanRendering boolean

    --- Creates a new HumanPhysicsInstance
    --- @return HumanPhysicsInstance
    function STATIC.New()
        return robustclass.New( "Renegade_HumanPhysics" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HumanPhysicsInstance, `false` otherwise
    function STATIC.IsHumanPhysics( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHumanPhysics and true or false
    end

    typecheck.RegisterType( "HumanPhysicsInstance", STATIC.IsHumanPhysics )

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


--- @class HumanPhysicsInstance
--- @field JustJumped boolean
--- @field IsAiControlledJump boolean

function INSTANCE:Renegade_HumanPhysics()
	physics3Class.Instance.Renegade_Physics3( self )

	self.IsAiControlledJump = false
	self.JustJumped = false
	INSTANCE.SetMass( self, 1.0 ) -- "??"

	-- "(gth) turn on shadows for all humans for now"
	INSTANCE.EnableShadowGeneration( self, true )
end

function INSTANCE:_Renegade_HumanPhysics()
	typecheck.NotImplementedError()
end

--- @return HumanPhysicsInstance?
function INSTANCE:AsHumanPhysics()
	return self
end

--- "initializes from a Definition"
--- @param definition HumanPhysicsDefinitionInstance
--- @param connectedEntity Entity
function INSTANCE:Init( definition, connectedEntity )
	physics3Class.Instance.Init( self, definition, connectedEntity )

	-- "(gth) turn on shadows for all humans for now"
	INSTANCE.EnableShadowGeneration( self, true )
end

function INSTANCE:Timestep()
	typecheck.NotImplementedError()
end

function INSTANCE:Render()
	typecheck.NotImplementedError()
end

function INSTANCE:IsSimulationDisabled()
	typecheck.NotImplementedError()
end

function INSTANCE:IsRenderingDisabled()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFactory()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:HasJustJumped()
	typecheck.NotImplementedError()
end

function INSTANCE:JumpToPoint()
	typecheck.NotImplementedError()
end

function INSTANCE:CheckGround()
	typecheck.NotImplementedError()
end

function INSTANCE:BallisticMove()
	typecheck.NotImplementedError()
end

function INSTANCE:NormalMove()
	typecheck.NotImplementedError()
end

function INSTANCE:SlideMove()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputeDesiredMoveVector()
	typecheck.NotImplementedError()
end
