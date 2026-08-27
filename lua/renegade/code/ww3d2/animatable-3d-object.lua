-- Based on Animatable3dObjectClass within Code/ww3d2/animobj.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type CompositeRenderObjectClass
local compositeRenderObjectClass = CNC.Import( "code/ww3d2/composite-render-object.lua" )

--- @class Animatable3dObjectClass : CompositeRenderObjectClass
--- @field Instance Animatable3dObjectInstance The metatable used by Animatable3dObjectInstance
local STATIC = CNC.CreateExport( compositeRenderObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "Animatable3dObjectClass"

--- @class Animatable3dObjectInstance : CompositeRenderObjectInstance
--- @field Static Animatable3dObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Animatable3dObject : Renegade_CompositeRenderObject" )
INSTANCE.Class = "Animatable3dObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAnimatable3dObject = true

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

    --- "  
    --- Animation state for the next frame.  When we add more flexible motion
    --- compositing, add a new state and its associated data to the union below
    --- "  
    --- @enum MotionMode
    STATIC.MOTION_MODE = {
        NONE			= enumBuilder:Set( 0 ),
        BASE_POSE		= enumBuilder:Next(),
        SINGLE_ANIM		= enumBuilder:Next(),
        DOUBLE_ANIM		= enumBuilder:Next(),
        MULTIPLE_ANIM	= enumBuilder:Next(),
    }
    local motionModeEnum = STATIC.MOTION_MODE

	--- "
	--- Animation state for the next frame.  When we add more flexible motion
	--- compositing, add a new state and its associated data to the union below
	--- "
	--- @enum AnimationState
	STATIC.ANIMATION_STATE = {
		NONE 		  = enumBuilder:Set( 0 ),
		BASE_POSE 	  = enumBuilder:Next(),
		SINGLE_ANIM   = enumBuilder:Next(),
		DOUBLE_ANIM   = enumBuilder:Next(),
		MULTIPLE_ANIM = enumBuilder:Next(),
	}
	local animationStateEnum = STATIC.ANIMATION_STATE
--#endregion

--#region Imports

	--- @type WW3dClass
	local wW3dClass = CNC.Import( "code/ww3d2/ww3d.lua" )

	--- @type RenderObjectClass
	local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type HTreeClass
	local hTreeClass = CNC.Import( "code/ww3d2/h-tree.lua" )
--#endregion

--#region Imported Enums

	local renderObjectAnimationModeEnum = renderObjectClass.ANIMATION_MODE
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class Animatable3dObjectClass

    --- Creates a new Animatable3dObjectInstance
    --- @return Animatable3dObjectInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Animatable3dObject" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Animatable3dObjectInstance, `false` otherwise
    function STATIC.IsAnimatable3dObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAnimatable3dObject and true or false
    end

    typecheck.RegisterType( "Animatable3dObjectInstance", STATIC.IsAnimatable3dObject )
end

--- "CurMotionMode == SINGLE_ANIM"
--- @class ModeAnimation
--- @field Motion HAnimationInstance?
--- @field Frame number
--- @field PreviousFrame number
--- @field AnimationMode RenderObjectAnimationMode
--- @field LastSyncTime number

--- "CurMotionMode == DOUBLE_ANIM"
--- @class ModeInterpolation
--- @field Motion0 HAnimationInstance?
--- @field Motion1 HAnimationInstance?
--- @field Frame0 number
--- @field Frame1 number
--- @field PreviousFrame0 number
--- @field PreviousFrame1 number
--- @field Percentage number

--- "CurMotionMode == MULTIPLE_ANIM"
--- @class ModeCombo
--- @field AnimationCombo HAnimationComboInstance?

--- @class Animatable3dObjectInstance
--- @field IsTreeValid boolean "Is the hierarchy tree currently valid"
--- @field HTree HTreeInstance "Hierarchy Tree"
--- @field CurrentMotionMode MotionMode
--- @field ModeAnimation ModeAnimation
--- @field ModeInterpolation ModeInterpolation
--- @field ModeCombo ModeCombo

--- @param src Animatable3dObjectInstance?
--- @overload fun( self:Animatable3dObjectInstance, hTreeName: string )
function INSTANCE:Renegade_Animatable3dObject( src )
	typecheck.AssertArgType( self.Class, 1, src, { "string", "Animatable3dObjectInstance" } )

	-- ( hTreeName: string )
	if isstring( src ) then
		local hTreeName = src --[[@as string]]

		compositeRenderObjectClass.Instance.Renegade_CompositeRenderObject( self )

		self.IsTreeValid = false
		self.CurrentMotionMode = motionModeEnum.BASE_POSE

		-- "Inline struct members can't be initialized in init list for some reason..."
		self.ModeAnimation = {
			Motion = nil,
			Frame = 0.0,
			PreviousFrame = 0.0,
			LastSyncTime = wW3dClass.GetSyncTime(),
			AnimationMode = renderObjectAnimationModeEnum.ANIM_MODE_MANUAL
		}
		self.ModeInterpolation = {
			Motion0 = nil,
			Motion1 = nil,
			Frame0 = 0.0,
			PreviousFrame0 = 0.0,
			PreviousFrame1 = 0.0,
			Frame1 = 0.0,
			Percentage = 0.0
		}
		self.ModeCombo = {
			AnimationCombo = nil
		}

		-- "Store a pointer to the htree"
		if hTreeName == nil then
			self.HTree = nil
		elseif hTreeName:len() == 0 then
			self.HTree = hTreeClass.New()
			self.HTree:InitDefault()
		else
			local source = ww3dAssetManagerClass.GetInstance():GetHTree( hTreeName )
			if source ~= nil then
				self.HTree = hTreeClass.New( source )
			else
				section.Warn( "Unable to find HTree: '", hTreeName, "'" )
				self.HTree = hTreeClass.New()
				self.HTree:InitDefault()
			end
		end

		return

	-- ( src: Animatable3dObjectInstance )
	else
		compositeRenderObjectClass.Instance.Renegade_CompositeRenderObject( self, src )

		self.IsTreeValid = false
		self.CurrentMotionMode = motionModeEnum.BASE_POSE
		self.HTree = nil

		typecheck.NotImplementedError()
	end
end

function INSTANCE:_Renegade_Animatable3dObject()
	typecheck.NotImplementedError()
end

--- "Update this object for rendering"
--- @param renderInfo RenderInfoInstance
function INSTANCE:Render( renderInfo )
	if self.HTree == nil then
		return
	end

	if self:IsNotHiddenAtAll() == false then
		return
	end

	if self.CurrentMotionMode == motionModeEnum.SINGLE_ANIM then
		if self.ModeAnimation.AnimationMode ~= renderObjectAnimationModeEnum.ANIM_MODE_MANUAL then
			self:SingleAnimationProgress()
		end
	end

	if not self:IsHierarchyValid() or self:AreSubObjectTransformsDirty() then
		self:UpdateSubObjectTransforms()
	end
end

--- "'Special render' function for animatables"
--- @param renderInfo SpecialRenderInfoInstance
function INSTANCE:SpecialRender( renderInfo )
	if self.HTree == nil then
		return
	end

	if self.CurrentMotionMode == motionModeEnum.SINGLE_ANIM then
		if self.ModeAnimation.AnimationMode ~= renderObjectAnimationModeEnum.ANIM_MODE_MANUAL then
			self:SingleAnimationProgress()
		end
	end

	if not self:IsHierarchyValid() then
		self:UpdateSubObjectTransforms()
	end
end

--- "Sets the transform and marks sub-objects as dirty"
--- @param matrix Matrix3dInstance
function INSTANCE:SetTransform( matrix )
	compositeRenderObjectClass.Instance.SetTransform( self, matrix )
	self:SetHierarchyValid( false )
end

--- "Sets the position and marks sub-objects as dirty"
--- @param pos Vector
function INSTANCE:SetPosition( pos )
	compositeRenderObjectClass.Instance.SetPosition( self, pos )
	self:SetHierarchyValid( false )
end

--- @overload fun( self )
--- @overload fun( self, animationCombo: HAnimationComboInstance )
--- @overload fun( self, motion: HAnimationInstance, frame: number, mode: RenderObjectAnimationMode? )
--- @overload fun( self, motion0: HAnimationInstance, frame0: number, motion1: HAnimationInstance, frame1: number, percentage: number )
function INSTANCE:SetAnimation( ... )
	local args = {...}
	local argCount = #args

	typecheck.AssertArgCount( INSTANCE.Class, argCount, { 0, 1, 2, 3, 5 } )

	-- "Set the animation state to "none" (base pose)""
	-- ()
	if argCount == 0 then
		self:Release()
		self.CurrentMotionMode = animationStateEnum.BASE_POSE
		self:SetHierarchyValid( false )
		return
	end

	-- "Set animation state with an anim combo"
	-- ( animationCombo: HAnimationComboInstance )
	if argCount == 1 then
		local animationCombo = args[1] --[[@as HAnimationComboInstance]]
		self:Release()

		self.CurrentMotionMode = motionModeEnum.MULTIPLE_ANIM
		self.ModeCombo.AnimationCombo = animationCombo
		self:SetHierarchyValid( false )
		return
	end

	-- "Set the animation state to the given anim/frame"
	-- (motion: HAnimationInstance, frame: number, mode: RenderObjectAnimationMode )
	if argCount == 2 or argCount == 3 then
		local motion = args[1] --[[@as HAnimationInstance]]
		local frame  = args[2] --[[@as number]]
		local mode 	 = args[3] and args[3] or renderObjectAnimationModeEnum.ANIM_MODE_MANUAL

		if motion then
			self:Release()
			self.CurrentMotionMode = motionModeEnum.SINGLE_ANIM
			self.ModeAnimation.Motion = motion
			self.ModeAnimation.PreviousFrame = self.ModeAnimation.Frame
			self.ModeAnimation.Frame = frame
			self.ModeAnimation.LastSyncTime = wW3dClass.GetSyncTime()
			self.ModeAnimation.AnimationMode = mode
		else
			self.CurrentMotionMode = motionModeEnum.BASE_POSE
			self:Release()
		end

		self:SetHierarchyValid( false )
		return
	end

	-- "Set the animation state to a blend of two anims"
	-- ( motion0: HAnimationInstance, frame0: number, motion1: HAnimationInstance, frame1: number, percentage: number )
	if argCount == 5 then
		local motion0    = args[1] --[[@as HAnimationInstance]]
		local frame0     = args[2] --[[@as number]]
		local motion1    = args[3] --[[@as HAnimationInstance]]
		local frame1     = args[4] --[[@as number]]
		local percentage = args[5] --[[@as number]]

        self:Release()

        self.CurrentMotionMode = motionModeEnum.DOUBLE_ANIM
        self.ModeInterpolation.Motion0 = motion0
        self.ModeInterpolation.Motion1 = motion1
        self.ModeInterpolation.PreviousFrame0 = self.ModeInterpolation.Frame0
        self.ModeInterpolation.PreviousFrame1 = self.ModeInterpolation.Frame1
        self.ModeInterpolation.Frame0 = frame0
        self.ModeInterpolation.Frame1 = frame1
        self.ModeInterpolation.Percentage = percentage
        self:SetHierarchyValid( false )
		return
	end
end

--- @return HAnimationInstance?
function INSTANCE:PeekAnimation()
	if self.CurrentMotionMode == motionModeEnum.SINGLE_ANIM then
		return self.ModeAnimation.Motion
	else
		return nil
	end
end

--- "is the current animation on the last frame?"
--- "Note: Only works for Single, ONCE anims"
--- @return boolean
function INSTANCE:IsAnimationComplete()
	if self.CurrentMotionMode == motionModeEnum.SINGLE_ANIM then
		if self.ModeAnimation.AnimationMode == renderObjectAnimationModeEnum.ANIM_MODE_ONCE then
			return self.ModeAnimation.Frame == self.ModeAnimation.Motion:GetNumFrames() -- Removed -1 to align with Lua's base 1 arrays
		end
	end

	return false
end

function INSTANCE:GetNumBones()
	if self.HTree then
		return self.HTree:NumPivots()
	else
		return 1
	end
end

--- "returns the name of the given bone"
--- @param boneIndex integer
--- @return string
function INSTANCE:GetBoneName( boneIndex )
	if self.HTree then
		return self.HTree:GetBoneName( boneIndex )
	else
		return "RootTransform"
	end
end

--- "Returns the index of the given bone"
--- @param boneName string
--- @return integer
function INSTANCE:GetBoneIndex( boneName )
	if self.HTree then
		return self.HTree:GetBoneIndex( boneName )
	else
		return 0
	end
end

--- "Return the transform for the given bone"
--- @param bone integer|string
--- @return Matrix3dInstance
function INSTANCE:GetBoneTransform( bone )
	typecheck.AssertArgType( INSTANCE.Class, 1, bone, { "string", "number" } )

	-- ( bone: string ): Matrix3dInstance
	if typecheck.IsOfType( bone, "string" ) then
		--- @cast bone string

		if self.HTree then
			assert( self.HTree ~= nil )
			assert( bone ~= nil )

			local boneIndex = self.HTree:GetBoneIndex( bone )
			return self.HTree:GetTransform( boneIndex )
		else
			return ( self:GetTransform() )
		end

	-- ( bone: integer ): Matrix3dInstance
	else
		--- @cast bone integer

		self:ValidateTransform()

		if self.HTree then
			-- "If our hierarchy isn't valid, we just need to evaluate our animation state."
			if not self:IsHierarchyValid() then
				self:UpdateSubObjectTransforms()
			end

			return self.HTree:GetTransform( bone )
		else
			return self.Transform
		end
	end
end

--- "Capture the specified bone (override animation)"
--- @param boneIndex integer
function INSTANCE:CaptureBone( boneIndex )
	if self.HTree then
		self.HTree:CaptureBone( boneIndex )
	end
end

--- "Release the specified bone (allow animation)"
--- @param boneIndex integer
function INSTANCE:ReleaseBone( boneIndex )
	if self.HTree then
		self.HTree:ReleaseBone( boneIndex )
	end
end

--- "Returns whether the specified bone is captured"
--- @param boneIndex integer
--- @return boolean
function INSTANCE:IsBoneCaptured( boneIndex )
	if self.HTree then
		return self.HTree:IsBoneCaptured( boneIndex )
	else
		return false
	end
end

--- "Sets the transform for the bone"
--- @param boneIndex integer
--- @param objectTransformationMatrix Matrix3dInstance
--- @param worldSpaceTranslation boolean
function INSTANCE:ControlBone( boneIndex, objectTransformationMatrix, worldSpaceTranslation )
	if self.HTree then
		self.HTree:ControlBone( boneIndex, objectTransformationMatrix, worldSpaceTranslation )
		self:SetHierarchyValid( false )
	end
end

--- @return HTreeInstance
function INSTANCE:GetHTree()
	return self.HTree
end

--- "If the animation is 'single', evaluate the given pivot and return its transform."
--- @param boneIndex integer
--- @param frame number?
--- @return boolean, Matrix3dInstance
function INSTANCE:SimpleEvaluateBone( boneIndex, frame )
	local returnValue = false
	local transformationMatrix

	if frame == nil then
		-- "Only do this for simple animations"
		if
			   self.CurrentMotionMode == motionModeEnum.NONE
			or self.CurrentMotionMode == motionModeEnum.BASE_POSE
			or self.CurrentMotionMode == motionModeEnum.SINGLE_ANIM
		then
			-- "Determine which frame we should be on, then use this information to determine the bone's transform."
			local currentFrame = self:ComputeCurrentFrame()
			returnValue, transformationMatrix = self:SimpleEvaluateBone( boneIndex, currentFrame )
		else
			self:UpdateSubObjectTransforms()
			transformationMatrix = self.HTree:GetTransform( boneIndex)
		end
	else
		-- "Only do this for simple animations"
		if self.HTree ~= nil then
			if self.CurrentMotionMode == motionModeEnum.SINGLE_ANIM then
				returnValue, transformationMatrix = self.HTree:SimpleEvaluatePivot( self.ModeAnimation.Motion, boneIndex, frame, self:GetTransform() )
			elseif self.CurrentMotionMode == motionModeEnum.NONE or self.CurrentMotionMode == motionModeEnum.BASE_POSE then
				returnValue, transformationMatrix = self.HTree:SimpleEvaluatePivot( boneIndex, self:GetTransform() )
			else
				transformationMatrix = self.Transform
			end
		else
			transformationMatrix = self.Transform
		end
	end

	return returnValue, transformationMatrix
end

--- @param newHTree HTreeInstance
function INSTANCE:SetHTree( newHTree )
	-- "Just assign it..."
	if self.HTree ~= nil then
		self.HTree = nil
	end
	self.HTree = hTreeClass.New( newHTree )
end

function INSTANCE:ComputeCurrentFrame()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateSubObjectTransforms()

	-- "The [RenderObject] implementation will cause our 'container' to update if we are not valid yet"
	compositeRenderObjectClass.Instance.UpdateSubObjectTransforms( self )

	-- "Update the transforms"
	if self.CurrentMotionMode == motionModeEnum.BASE_POSE then
		self:BaseUpdate( self.Transform )

	elseif self.CurrentMotionMode == motionModeEnum.SINGLE_ANIM then
		if self.ModeAnimation.AnimationMode ~= renderObjectAnimationModeEnum.ANIM_MODE_MANUAL then
			self:SingleAnimationProgress()
		end
		self:AnimationUpdate( self.Transform, self.ModeAnimation.Motion, self.ModeAnimation.Frame )

		-- "Play any sounds that are triggered by this frame of animation"
		-- if self.ModeAnimation.Motion:SetHasEmbeddedSounds() then
			-- Omitted embedded sounds
		-- end

	elseif self.CurrentMotionMode == motionModeEnum.DOUBLE_ANIM then
		self:BlendUpdate(
			self.Transform,
			self.ModeInterpolation.Motion0,
			self.ModeInterpolation.Frame0,
			self.ModeInterpolation.Motion1,
			self.ModeInterpolation.Frame1,
			self.ModeInterpolation.Percentage
		)
		-- "Play any sounds that are triggered by this frame of animation"
		-- Omitted embedded sounds

	elseif self.CurrentMotionMode == motionModeEnum.MULTIPLE_ANIM then
		self:ComboUpdate( self.Transform, self.ModeCombo.AnimationCombo )

		-- "Play any sounds that are triggered by this frame of animation"
		-- Omitted embedded sounds
	end

	self:SetHierarchyValid( true )

end

--- "Animation update function for the base pose"
--- @param root Matrix3dInstance
function INSTANCE:BaseUpdate( root )
	-- "This method simply puts the meshes in the base pose's configuration"
	if self.HTree then
		self.HTree:BaseUpdate( root )
	end
	self:SetHierarchyValid( true )
end

function INSTANCE:AnimationUpdate()
	typecheck.NotImplementedError()
end

function INSTANCE:BlendUpdate()
	typecheck.NotImplementedError()
end

function INSTANCE:ComboUpdate()
	typecheck.NotImplementedError()
end

--- @return boolean
function INSTANCE:IsHierarchyValid()
	return self.IsTreeValid
end

--- @param onOff boolean
function INSTANCE:SetHierarchyValid( onOff )
	self.IsTreeValid = onOff
end

function INSTANCE:SingleAnimationProgress()
	typecheck.NotImplementedError()
end

--- "Releases any anims being held by this object"
function INSTANCE:Release()
    local mode = self.CurrentMotionMode
    if mode == motionModeEnum.BASE_POSE then
        return
    elseif mode == motionModeEnum.SINGLE_ANIM then
        if self.ModeAnimation.Motion ~= nil then
            self.ModeAnimation.Motion = nil
        end
        return
    elseif mode == motionModeEnum.DOUBLE_ANIM then
        if self.ModeInterpolation.Motion0 ~= nil then
            self.ModeInterpolation.Motion0 = nil
        end

        if self.ModeInterpolation.Motion1 ~= nil then
            self.ModeInterpolation.Motion1 = nil
        end
        return
    elseif mode == motionModeEnum.MULTIPLE_ANIM then
        return
    end
end
