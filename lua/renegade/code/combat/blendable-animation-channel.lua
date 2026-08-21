-- Based on BlendableAnimChannelClass within Code/Combat/animcontrol.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class BlendableAnimationChannelClass
--- @field Instance BlendableAnimationChannelInstance The metatable used by BlendableAnimationChannelInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "BlendableAnimationChannelClass"

--- @class BlendableAnimationChannelInstance
--- @field Static BlendableAnimationChannelClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_BlendableAnimationChannel" )
INSTANCE.Class = "BlendableAnimationChannelInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsBlendableAnimationChannel = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type AnimationChannelClass
	local animationChannelClass = CNC.Import( "code/combat/animation-channel.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class BlendableAnimationChannelClass

    --- Creates a new BlendableAnimationChannelInstance
    --- @return BlendableAnimationChannelInstance
    function STATIC.New()
        return robustclass.New( "Renegade_BlendableAnimationChannel" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) BlendableAnimationChannelInstance, `false` otherwise
    function STATIC.IsBlendableAnimationChannel( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsBlendableAnimationChannel and true or false
    end

    typecheck.RegisterType( "BlendableAnimationChannelInstance", STATIC.IsBlendableAnimationChannel )
end


--- @class BlendableAnimationChannelInstance
--- @field NewChannel AnimationChannelInstance
--- @field OldChannel AnimationChannelInstance
--- @field BlendTimer number
--- @field BlendTotal number

function INSTANCE:Renegade_BlendableAnimationChannel()
	self.BlendTimer = 0
	self.BlendTotal = 0

	self.NewChannel = animationChannelClass.New()
	self.OldChannel = animationChannelClass.New()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

--- @param animation string|HAnimationInstance
--- @param blendTime number
--- @param startFrame number
function INSTANCE:SetAnimation( animation, blendTime, startFrame )
	-- "If setting to our current anim, bail"
	if self.NewChannel:PeekAnimation() == nil and animation == nil then
		return
	end

	if self.NewChannel:PeekAnimation() ~= nil and animation ~= nil then

		--- @type string|HAnimationInstance
		local comparison = self.NewChannel:PeekAnimation()

		-- If the animation is provided as a string, compare it with the name of the new channel animation
		if typecheck.IsOfType( animation, "string" ) then
			--- @cast comparison HAnimationInstance

			section.Warn( comparison )

			comparison = comparison:GetName()
		end

		if comparison == animation then
			return
		end
	end

	-- "If no current channel, or no blend, or no new name, don't blend"
	if self.NewChannel:PeekAnimation() == nil or blendTime == 0 or animation == nil then
		self.BlendTotal = 0.0
		self.BlendTimer = 0.0
	elseif self.BlendTotal == 0.0 then -- "If not currently blending"
		self.OldChannel = self.NewChannel
		self.BlendTimer = 0.0
		self.BlendTotal = blendTime
	elseif ( self.BlendTimer / self.BlendTotal ) > 0.5 then -- "If more than halfway through the old blend"
		self.OldChannel = self.NewChannel
		self.BlendTimer = ( 1.0 - ( self.BlendTimer / self.BlendTotal ) ) * blendTime
		self.BlendTotal = blendTime
	else
		self.BlendTimer = ( self.BlendTimer / self.BlendTotal ) * blendTime
		self.BlendTotal = blendTime
	end
	self.NewChannel:SetAnimation( animation )
	if self.NewChannel:PeekAnimation() ~= nil then
		self.NewChannel:SetFrame( startFrame )
	end
	if animation == nil then
		self.OldChannel:SetAnimation( nil )
	end
end

--- @param mode AnimationControlAnimationMode
--- @param frame number? [Default: -1]
function INSTANCE:SetMode( mode, frame )
	if frame == nil then frame = -1 end

	self.NewChannel:SetMode( mode, frame )
end

--- @return AnimationControlAnimationMode
function INSTANCE:GetMode()
	return self.NewChannel:GetMode()
end

--- @return boolean
function INSTANCE:IsComplete()
	return self.NewChannel:IsComplete()
end

--- @return string
function INSTANCE:GetAnimationName()
	return self.NewChannel:GetAnimationName()
end

function INSTANCE:SetTargetFrame()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTargetFrame()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekAnimation()
	typecheck.NotImplementedError()
end

--- @param deltaTime number
function INSTANCE:Update( deltaTime )
	-- "If blending between two animations"
	if self.BlendTotal ~= 0.0 then
		-- "Bump blend timer forward"
		self.BlendTimer = self.BlendTimer + deltaTime
		-- "Blend complete, remove oldanim"
		if self.BlendTimer >= self.BlendTotal then
			self.BlendTotal = 0.0
			self.BlendTimer = 0.0
			self.OldChannel:SetAnimation( nil )
		end
	end

	-- "Calculate which frame we are on in each of the animations"
	self.NewChannel:Update( deltaTime )
	self.OldChannel:Update( deltaTime )
end

--- @param weight number? [Default: `1.0`]
--- @return AnimationDataRecordStruct[]
function INSTANCE:GetAnimationData( weight )
	if weight == nil then weight = 1.0 end

	local blendRatio = 1.0 --"Assume no blending"
	if self.BlendTotal ~= 0.0 then -- "If blending between two animations"
		-- "Calculate the blend percentage between the two animations."
		-- "This starts at 0,0 (all OldAnimation) and proceeds to 1.0o (all Animation)"
		blendRatio = math.Clamp( self.BlendTimer / self.BlendTotal, 0, 1 )
	end

	local list = {} --[[@as AnimationDataRecordStruct[] ]]
	table.Add( list, self.NewChannel:GetAnimationData( weight * blendRatio ) )
	table.Add( list, self.OldChannel:GetAnimationData( weight * ( 1 - blendRatio ) ) )
	return list
end

--- @param animationModel RenderObjectInstance
function INSTANCE:UpdateModel( animationModel )
	-- "Assume no blending"
	local blendRatio = 1.0

	-- "If blending between two animations"
	if self.BlendTotal ~= 0.0 then
		-- "Calculate the blend percentage between the two animations."
		-- "This starts at 0.0 (all OldAnimation) and proceeds to 1.0 (all Animation)"
		blendRatio = math.Clamp( self.BlendTimer / self.BlendTotal, 0, 1 )
	end

	if self.OldChannel:PeekAnimation() then
		animationModel:SetAnimation(
			self.OldChannel:PeekAnimation(),
			self.OldChannel:GetFrame(),
			self.NewChannel:PeekAnimation(),
			self.NewChannel:GetFrame(),
			blendRatio
		)
	elseif self.NewChannel:PeekAnimation() then
		animationModel:SetAnimation( self.NewChannel:PeekAnimation(), self.NewChannel:GetFrame() )
	else
		animationModel:SetAnimation()
	end
end

function INSTANCE:GetFrame()
	typecheck.NotImplementedError()
end

function INSTANCE:GetProgress()
	typecheck.NotImplementedError()
end
