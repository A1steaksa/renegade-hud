-- Based on Phys3Class within Code/wwphys/phys3.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type MoveablePhysicsClass
local moveablePhysicsClass = CNC.Import( "code/wwphys/moveable-physics.lua" )

--- @class Physics3Class : MoveablePhysicsClass
--- @field Instance Physics3Instance The metatable used by Physics3Instance
local STATIC = CNC.CreateExport( moveablePhysicsClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "Physics3Class"

--- @class Physics3Instance : MoveablePhysicsInstance
--- @field Static Physics3Class The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Physics3 : Renegade_MoveablePhysics" )
INSTANCE.Class = "Physics3Instance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysics3 = true

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	local enumBuilder = enumBuilderClass.New()

	--- @enum MoveModeType
	STATIC.MOVE_MODE_TYPE = {
		USER_OVERRIDE  = enumBuilder:Set( 0 ),
		BALLISTIC_MOVE = enumBuilder:Next(),
		SLIDE_MOVE	   = enumBuilder:Next(),
		NORMAL_MOVE	   = enumBuilder:Next(),
		COLLIDE_MOVE   = enumBuilder:Next(),
	}
	local moveModeTypeEnum = STATIC.MOVE_MODE_TYPE

--#endregion

--#region Imports

	--- @type AABoxClass
	local aABoxClass = CNC.Import( "code/wwmath/aabox.lua" )

	--- @type GroundStateStructClass
	local groundStateStructClass = CNC.Import( "code/wwphys/ground-state-struct.lua" )

	--- @type RenderObjectClass
	local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

	--- @type Matrix3dClass
	local matrix3dClass = CNC.Import( "code/wwmath/matrix3d.lua" )

	--- @type InfoEntityLib
	local infoEntityLib = CNC.Import( "sh_info-entity.lua" )

	--- @type WWMathClass
	local wWMathClass = CNC.Import( "code/wwmath/wwmath.lua" )

	--- @type CollisionMathClass
	local collisionMathClass = CNC.Import( "code/wwmath/collision-math.lua" )
--#endregion

--#region Imported Enums

	local renderObjectClassIdEnum = renderObjectClass.RENDER_OBJECT_CLASS_ID
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class Physics3Class
	--- @field CorrectionTime number "Network correction handling constants"
	--- @field AllowableError number
	--- @field PopError number

	--- "The distance an object will "step up" over an obstacle"
    STATIC.DEFAULT_STEP_HEIGHT = 0.25

    -- "The distance an object will "step up" over an obstacle"
    STATIC.DEFAULT_STEP_HEIGHT = 0.25

    -- "Steepest angle the character can walk up"
    STATIC.DEFAULT_SLIDE_ANGLE = math.rad( 45.0 )

    STATIC.DEFAULT_NORMALIZED_SPEED = 10.0

    -- "On ground if within this distance"
    STATIC.GROUND_DISTANCE = 0.1

    -- "Stop at this distance from ground"
    STATIC.GROUND_EPSILON = STATIC.GROUND_DISTANCE / 5.0

    -- "Stop at this distance from walls/slides"
    STATIC.WALL_EPSILON = 0.5

    -- "Only try to step if we could move this distance"
    STATIC.MIN_STEP_MOVE = 0.25

    -- "Only step if moving at an angle close to the x-y plane"
    STATIC.MAX_STEP_MOVE_ANGLE_TAN = 1.0

    --[[ Debug Vector colors ]] do

        -- "Color for the velocity debug vector"
        STATIC.VELOCITY_COLOR = Color( 255, 0, 0 )

        -- "Color for contact vectors"
        STATIC.CONTACT_COLOR  = Color( 0.25 * 255, 0.7 * 255, 0.2 * 255 )

        STATIC.GROUND_COLOR   = Color( 0, 255, 255 )
    end

    --- Creates a new Physics3Instance
    --- @return Physics3Instance
    function STATIC.New()
        return robustclass.New( "Renegade_Physics3" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Physics3Instance, `false` otherwise
    function STATIC.IsPhysics3( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysics3 and true or false
    end

    typecheck.RegisterType( "Physics3Instance", STATIC.IsPhysics3 )

	--- @param time number
	function STATIC.SetCorrectionTime( time )
		STATIC.CorrectionTime = time
	end

	--- @param err number
	function STATIC.SetAllowableError( err )
		STATIC.AllowableError = err
	end

	--- @param err number
	function STATIC.SetPopError( err )
		STATIC.PopError = err
	end

	--- @return number
	function STATIC.GetCorrectionTime()
		return STATIC.CorrectionTime
	end

	--- @return number
	function STATIC.GetAllowableError()
		return STATIC.AllowableError
	end

	--- @return number
	function STATIC.GetPopError()
		return STATIC.PopError
	end
end

--- @class StateStruct
--- @field Position Vector
--- @field Velocity Vector

--- @class Physics3Instance
--- @field CollisionBox AABoxInstance "Object space collision box"
--- @field OnGround boolean "Flag indicates whether object is resting on something"
--- @field InCollision boolean "This object is already participating in a collision"
--- @field HeadingChanged boolean "If the heading changes, transform will be updated on next timestep"
--- @field GroundSurface integer "Surface type id of the ground we're standing on."
--- @field State StateStruct "State vector"
--- @field Heading number "Heading, a move of 1,0,0 will move in this direction."
--- @field NormalizedSpeed number "Speed to move when controller is 1.0"
--- @field SlideAngle number "Slope angle at which this object slides off"
--- @field SlideNormalZ number "cos(SlideAngle)"
--- @field SlideAngleTan number "tan(SlideAngle)"
--- @field StepHeight number Step [size] that this object will hop over
--- @field MoveMode MoveModeType "Current movement mode"
--- @field GroundObject PhysicsInstance "Object that we are standing on"
--- @field GroundState GroundStateStructInstance? "Info on the surface we're standing on (if any)"
--- @field AnimationMove Vector "How far this object moved for animation purposes"
--- @field History Physics3HistoryInstance "History of our state for smarter network updating"
--- @field LatencyError Vector "Remaining latency error"
--- @field LastKnownPosition Vector "Last position received from server"
--- @field LastKnownVelocity Vector "Last velocity received from server"

function INSTANCE:Renegade_Physics3()
	moveablePhysicsClass.Instance.Renegade_MoveablePhysics( self )

	self.State = {
		Position = Vector( 0, 0, 0 ),
		Velocity = Vector( 0, 0, 0 )
	}

	self.GroundState = groundStateStructClass.New()

	self.CollisionBox = aABoxClass.New()
	self.CollisionBox.Center:SetUnpacked( 0, 0, 1 )
	self.CollisionBox.Extent:SetUnpacked( 1, 1, 1 )
	self.OnGround = false
	self.InCollision = false
	self.HeadingChanged = false
	self.GroundSurface = 0
	self.Heading = 0.0
	self.NormalizedSpeed = STATIC.DEFAULT_NORMALIZED_SPEED
	self.SlideAngle = STATIC.DEFAULT_SLIDE_ANGLE
	self.SlideNormalZ = math.cos( self.SlideAngle )
	self.SlideAngleTan = math.tan( self.SlideAngle )
	self.StepHeight = STATIC.DEFAULT_STEP_HEIGHT
	self.MoveMode = moveModeTypeEnum.NORMAL_MOVE
    self.GroundObject = nil
    self.AnimationMove = Vector( 0, 0, 0 )
    self.History = nil
    self.LatencyError = Vector( 0, 0, 0 )
    self.LastKnownPosition = Vector( 0, 0, 0 )
    self.LastKnownVelocity = Vector( 0, 0, 0 )
    self:InvalidateGroundState()
end

function INSTANCE:_Renegade_Physics3()
	if self.History ~= nil then
		self.History = nil
	end
end

--- @return Physics3Instance?
function INSTANCE:AsPhysics3class()
	return self
end

--- @param definition Physics3DefinitionInstance
--- @param connectedEntity Entity
function INSTANCE:Init( definition, connectedEntity )
	moveablePhysicsClass.Instance.Init( self, definition, connectedEntity )

	self.CollisionBox.Center:SetUnpacked( 0, 0, 1 )
	self.CollisionBox.Extent:SetUnpacked( 1, 1, 1 )
	self.OnGround = false
	self.InCollision = false
	self.GroundSurface = 0
	self.Heading = 0.0
	self.NormalizedSpeed = definition.NormalizedSpeed
	self.SlideAngle = definition.SlideAngle
	self.SlideNormalZ = math.cos( self.SlideAngle )
	self.SlideAngleTan = math.tan( self.SlideAngle )
	self.StepHeight = definition.StepHeight
	self.MoveMode = moveModeTypeEnum.NORMAL_MOVE
    self.GroundObject = nil
    self.AnimationMove = Vector( 0, 0, 0 )
    self.LatencyError = Vector( 0, 0, 0 )
    self.LastKnownPosition = Vector( 0, 0, 0 )
    self.LastKnownVelocity = Vector( 0, 0, 0 )

	self:UpdateCachedModelParameters()
	self:InvalidateGroundState()
end

--- "Returns bounding box of the model"
--- @return AABoxInstance
function INSTANCE:GetBoundingBox()
	return self.Model:GetBoundingBox()
end

--- "Returns the current transform"
--- @return Matrix3dInstance
function INSTANCE:GetTransform()
	assert( self.Model )
	return ( self.Model:GetTransform() ) -- Only need the first result
end

--- "  
--- Sets the current transform  
--- Note that this 'warps' the object to the specified position.  The user is responsible
--- for providing a valid position.  
--- "  
--- @param matrix Matrix3dInstance
function INSTANCE:SetTransform( matrix )
	-- "Copy the translation portion of the transform into our state"
	self.State.Position = matrix:GetTranslation()

	-- "Copy the Z rotation portion of the transform into our heading variable (ugh...)"
	self.Heading = matrix:GetZRotation()
	self:UpdateTransform()
	self:UpdateCullBox()

	-- "Wake the object up whenever it moves"
	self:SetFlag( STATIC.ASLEEP, false )
	self:InvalidateGroundState()

	self:AssertStateValid()
end

--- @return AABoxInstance
function INSTANCE:GetCollisionBox()
	return self.CollisionBox
end

--- "Check a ray for intersection with this object"
--- @param rayTest PhysicsRayCollisionTestInstance
--- @return boolean, PhysicsRayCollisionTestInstance?
function INSTANCE:CastRay( rayTest )
	if self.Model:CastRay( rayTest ) then
		rayTest.CollidedPhysicsObject = self
		return true, rayTest
	end
	return false, rayTest
end

--- "Check a swept AABox for intersection with this obj"
--- @param boxTest PhysicsAABoxCollisionTestInstance
--- @return boolean, PhysicsAABoxCollisionTestInstance
function INSTANCE:CastAaBox( boxTest )
	local worldBox = aABoxClass.New(
		self.State.Position + self.CollisionBox.Center,
		self.CollisionBox.Extent
	)

	if collisionMathClass.Collide( boxTest.Box, boxTest.Move, worldBox, boxTest.Result ) then
		boxTest.CollidedPhysicsObject = self
		return true, boxTest
	end

	return false, boxTest
end

function INSTANCE:CastObBox()
	typecheck.NotImplementedError()
end

function INSTANCE:IntersectionTest()
	typecheck.NotImplementedError()
end

function INSTANCE:IntersectionTest()
	typecheck.NotImplementedError()
end

--- "Set the model being used"
--- @param model RenderObjectInstance
function INSTANCE:SetModel( model )
	-- "Let the base class have the model"
	moveablePhysicsClass.Instance.SetModel( self, model )

	-- "Update any member that depend on the model"
	self:UpdateCachedModelParameters()

	-- "Update our culling box"
	self:UpdateCullBox()
end

--- @return Vector
function INSTANCE:GetVelocity()
	return self.State.Velocity
end

--- @param newVelocity Vector
function INSTANCE:SetVelocity( newVelocity )
	self.State.Velocity = newVelocity
end

--- "  
--- Apply an impulse to this object  
--- 
--- As the code comment says... since we changed [Physics3] to essentially have infinite friction,
--- this function will only work if the object is in the air currently.  
--- "  
--- @param impulse Vector
function INSTANCE:ApplyImpulse( impulse )
	--- "
	--- Impulse applied to center of mass simply adds to the linear momentum  
	--- NOTE: The current algorithm does not maintain velocity [unless] undergoing
	--- ballistic movement... this routine will often have no effect...
	--- "
	self.State.Velocity = self.State.Velocity + impulse * self.MassInverted
end

--- @param deltaTime number
function INSTANCE:Timestep( deltaTime )
	typecheck.NotImplementedError()
end

--- @return boolean
function INSTANCE:IsInContact()
	return self.OnGround
end

--- "[SetInContact] needed for network state updates so we don't have to wait for [CheckGround]"
--- @param onOff boolean
function INSTANCE:SetInContact( onOff )
	self.OnGround = onOff
end

--- @return integer
function INSTANCE:GetContactSurfaceType()
	return self.GroundSurface
end

--- "Marks the ground state as dirty"
function INSTANCE:InvalidateGroundState()
    self.GroundState.IsDirty = true
end

--- @return PhysicsInstance
function INSTANCE:PeekGroundObject()
	return self.GroundState.GroundObject
end

function INSTANCE:AssertStateValid()
	-- Omitted function contents temporarily because I don't feel like dealing with the validation right now
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

--- "Sets the position"
--- "This blindly warps the object to the given position.  The user is responsible for providing a valid position."
function INSTANCE:SetPosition( position )
	self.State.Position = position
	self:UpdateTransform( true )
	self:UpdateCullBox()
	self:SetFlag( STATIC.ASLEEP, false )
	self:InvalidateGroundState()
end

--- "Returns the current position"
--- @return Vector
function INSTANCE:GetPosition()
	-- Omitted original function contents
	return self:GetConnectedEntity():GetPos()
end

--- "Set the heading of this object"
--- @param heading number
function INSTANCE:SetHeading( heading )
	if heading ~= self.Heading then
		self.Heading = heading
		self.HeadingChanged = true
	end
	self:UpdateTransform()
end

--- "Returns the heading of this object"
--- @return number
function INSTANCE:GetHeading()
	return self.Heading
end

--- "Sets the maximum angle this object can climb"
--- "If a [Physics3] object is resting on a slope greater than this angle, it will slide down the slope."
--- @param angle number
function INSTANCE:SetSlideAngle( angle )
	self.SlideAngle = angle
	self.SlideNormalZ = math.cos( angle )
	self.SlideAngleTan = math.tan( angle )
end

--- "Returns the slide angle"
--- @return number
function INSTANCE:GetSlideAngle()
	return self.SlideAngle
end

--- @param val number
function INSTANCE:SetNormalizedSpeed( val )
	self.NormalizedSpeed = val
end

--- @return number
function INSTANCE:GetNormalizedSpeed()
	return self.NormalizedSpeed
end

--- @param move Vector
function INSTANCE:AddAnimationMove( move )
	self.AnimationMove = self.AnimationMove + move
end

--- @return Vector
function INSTANCE:GetAnimationMove()
	return self.AnimationMove
end

function INSTANCE:ResetAnimationMove()
	self.AnimationMove:SetUnpacked( 0, 0, 0 )
end

--- "Returns the bounding box to use for blob shadows"
--- @return AABoxInstance
function INSTANCE:GetShadowBlobBox()
	return self.CollisionBox
end

function INSTANCE:Push()
	typecheck.NotImplementedError()
end

function INSTANCE:Collide()
	typecheck.NotImplementedError()
end

--- @param pos Vector
--- @param velocity Vector
function INSTANCE:NetworkStateUpdate( pos, velocity )
	local delta = pos - self.State.Position
	self:SetPosition( pos )
	self:SetVelocity( velocity )
	self:SnapToGround( delta, false )
	self:UpdateTransform( true )
end

function INSTANCE:NetworkLatencyStateUpdate()
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

function INSTANCE:OnPostLoad()
	typecheck.NotImplementedError()
end

function INSTANCE:GetGroundState()
	typecheck.NotImplementedError()
end

function INSTANCE:CheckGround()
	typecheck.NotImplementedError()
end

function INSTANCE:UserMove()
	typecheck.NotImplementedError()
end

function INSTANCE:BallisticMove()
	typecheck.NotImplementedError()
end

function INSTANCE:SlideMove()
	typecheck.NotImplementedError()
end

function INSTANCE:NormalMove()
	typecheck.NotImplementedError()
end

function INSTANCE:CollideMove()
	typecheck.NotImplementedError()
end

function INSTANCE:ApplyMove()
	typecheck.NotImplementedError()
end

--- "Following a move, snap back down to the ground"
--- @param actualMove Vector
--- @param wasStepping boolean
function INSTANCE:SnapToGround( actualMove, wasStepping )
	if self:GetFlag( STATIC.ASLEEP ) then
		return
	end

	typecheck.NotImplementedError()
end

--- "Clip a move vector by all of the active contact normals"
--- @param contacts Vector[]
--- @param move Vector
--- @return Vector
function INSTANCE:ClipMove( contacts, move )
	-- "  
	-- Loop over all of the contacts.  
	-- On each one we modify our move vector to parallel that plane.
	-- Immediately after each modification, we check if the other planes are a problem.
	-- At the first time all planes are satisfied, we're done
	-- "  
	for i = 1, #contacts do
		if not ( math.abs( contacts[i]:Length() - 1.0 ) < wWMathClass.EPSILON ) then
			move = Vector( 0, 0, 0 )
			return move
		end

		-- "Push the velocity a little bit away from the plane"
		local dot = move:Dot( contacts[i] )
		if dot < 0.0 then
			local adjustment = 1.01 * dot * contacts[i]
			move = move - adjustment
		end

		local outerJ = 0
		for j = 1, #contacts do
			outerJ = j
			local check = move:Dot( contacts[j] )
			if check < 0.0 then
				break -- "This contact isn't happy yet... keep choppin"
			end
		end

		if outerJ == #contacts then
			break -- "All contacts are happy!"
		end
	end

	return move
end

function INSTANCE:AttachToGroundObject()
	typecheck.NotImplementedError()
end

--- "Caches some data related to the model"
function INSTANCE:UpdateCachedModelParameters()
	--- "If we don't have a model yet, just return"
	if self.Model == nil then
		return
	else
		-- Omitted using the "WORLDBOX" sub object as a bounding box
		local boundingBox = infoEntityLib.GetEntityLocalBoundingBox( self:GetConnectedEntity() )

		if boundingBox then
			local oldTransform = self.Model:GetTransform()
			self.Model:SetTransform( matrix3dClass.New( true ) )

			self.CollisionBox = boundingBox
			self.Model:SetTransform( oldTransform )
		end
	end
end

--- "Recalculate the transform"
--- @param positionOnly boolean? [Default:L false]
function INSTANCE:UpdateTransform( positionOnly )
	if positionOnly == nil then positionOnly = false end

	local positionDifference = self.Model:GetPosition()
	positionDifference = positionDifference - self.State.Position

	if positionOnly and not self.HeadingChanged then
		self.Model:SetPosition( self.State.Position )
	else
		local transformationMatrix = matrix3dClass.New( true )
		transformationMatrix:SetTranslation( self.State.Position )
		transformationMatrix:RotateZ( self.Heading )
		self.Model:SetTransform( transformationMatrix )
	end

	if positionDifference:LengthSqr() > wWMathClass.EPSILON2 then
		self:UpdateVisibilityStatus()
	end

	self.HeadingChanged = false
end

--- @param state StateStruct
--- @return AABoxInstance
function INSTANCE:ComputeWsCollisionBox( state )
	return aABoxClass.New(
		self.CollisionBox.Center + state.Position,
		self.CollisionBox.Extent
	)
end

function INSTANCE:DebugVerifyPosition()
	typecheck.NotImplementedError()
end

function INSTANCE:NetworkTeleportCorrection()
	typecheck.NotImplementedError()
end
