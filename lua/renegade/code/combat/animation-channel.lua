-- Based on AnimChannelClass within Code/Combat/animcontrol.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class AnimationChannelClass
--- @field Instance AnimationChannelInstance The metatable used by AnimationChannelInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "AnimationChannelClass"

--- @class AnimationChannelInstance
--- @field Static AnimationChannelClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_AnimationChannel" )
INSTANCE.Class = "AnimationChannelInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAnimationChannel = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type HumanAnimationControlClass
	local humanAnimationControlClass = CNC.Import( "code/combat/human-animation-control.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	--- @type ChunkIOClass
	local chunkIOClass = CNC.Import( "code/wwlib/chunk-io.lua" )

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )
--#endregion

--#region Imported Enums

	local animationControlAnimationModeEnum = humanAnimationControlClass.ANIMATION_CONTROL_ANIMATION_MODE
	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
--#endregion

--[[ Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
        XXXCHUNKID_LEGS		= enumBuilder:Set( 910991512 ),
        XXXCHUNKID_TORSO	= enumBuilder:Next(),
		CHUNKID_CHANNEL		= enumBuilder:Next(),
		CHUNKID_VARIABLES	= enumBuilder:Next(),
		CHUNKID_OLD			= enumBuilder:Next(),
		CHUNKID_NEW			= enumBuilder:Next(),
		CHUNKID_PARENT		= enumBuilder:Next(),
		CHUNKID_CHANNEL1	= enumBuilder:Next(),
		CHUNKID_CHANNEL2	= enumBuilder:Next(),

		MICROCHUNKID_BLEND_TIMER	= enumBuilder:Set( 1 ),
		MICROCHUNKID_BLEND_TOTAL	= enumBuilder:Next(),
		MICROCHUNKID_FRAME			= enumBuilder:Next(),
		XXXMICROCHUNKID_WEIGHT		= enumBuilder:Next(),
		MICROCHUNKID_MODE			= enumBuilder:Next(),
		MICROCHUNKID_ANIMATION_NAME	= enumBuilder:Next(),
		MICROCHUNKID_MODEL_PTR		= enumBuilder:Next(),
		MICROCHUNKID_CHANNEL2_RATIO	= enumBuilder:Next(),
		MICROCHUNKID_TARGET_FRAME	= enumBuilder:Next(),
		MICROCHUNKID_SKELETON		= enumBuilder:Next(),
    }
end

--[[ Static Functions and Variables ]] do

    --- @class AnimationChannelClass

    --- Creates a new AnimationChannelInstance
    --- @return AnimationChannelInstance
    function STATIC.New()
        return robustclass.New( "Renegade_AnimationChannel" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) AnimationChannelInstance, `false` otherwise
    function STATIC.IsAnimationChannel( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAnimationChannel and true or false
    end

    typecheck.RegisterType( "AnimationChannelInstance", STATIC.IsAnimationChannel )
end

--- @class AnimationDataRecordStruct
--- @field Animation HAnimationInstance
--- @field Frame number
--- @field Weight number

--- @class AnimationChannelInstance
--- @field Animation HAnimationInstance?
--- @field Frame number
--- @field NumFrames number
--- @field TargetFrame number
--- @field Mode AnimationControlAnimationMode

function INSTANCE:Renegade_AnimationChannel()
	self.Animation = nil
	self.Frame = 0.0
	self.NumFrames = 1
	self.TargetFrame = 0.0
	self.Mode = animationControlAnimationModeEnum.ANIM_MODE_ONCE
end

function INSTANCE:_Renegade_AnimationChannel()
	if self.Animation then
		self.Animation = nil
	end
end

--- @param csave ChunkSaveInstance
function INSTANCE:Save( csave )
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @return boolean
function INSTANCE:Load( cload )
	local ids = STATIC.ChunkIds
	while cload:OpenChunk() do
		local id = cload:CurChunkId()
		if id == ids.CHUNKID_VARIABLES then
			while cload:OpenMicroChunk() do
				local microChunkId = cload:CurMicroChunkId()

				local didRead = false

				if microChunkId == ids.MICROCHUNKID_ANIMATION_NAME then
					local _, readBytes = cload:Read( cload:CurMicroChunkLength() )
					assert( readBytes ~= nil )
					local animationName = readBytes:TrimRight( "\0" )
					self:SetAnimation( animationName )
					didRead = true
				end

				didRead = didRead or (
					   chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_FRAME,  	   fundamentalDataTypeEnum.Float, self, "Frame" )
					or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_MODE, 		   fundamentalDataTypeEnum.Int,   self, "Mode" )
					or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_TARGET_FRAME,  fundamentalDataTypeEnum.Float, self, "TargetFrame" )
				)

				if not didRead then
					section.Warn( INSTANCE.Class, " - Load - Unhandled Micro Chunk ID: ", microChunkId )
				end

				cload:CloseMicroChunk()
			end
		else
			section.Warn( INSTANCE.Class, " - Load - Unhandled Chunk ID: ", id )
		end
		cload:CloseChunk()
	end

	return true
end

--- @param animation HAnimationInstance?
--- @overload fun( self, name: string )
function INSTANCE:SetAnimation( animation )
	typecheck.AssertArgType( INSTANCE.Class, 1, animation, { "string", "HAnimationInstance" } )

	-- ( animation: HAnimationInstance )
	if typecheck.IsOfType( animation, "HAnimationInstance" ) then
		-- "If this is our current anim, bail"
		if self.Animation == animation then
			return
		end

		-- "Release the old anim"
		if self.Animation then
			self.Animation = nil
		end

		-- "We need to switch anims"
		self.Animation = animation

		if self.Animation then
			self.NumFrames = self.Animation:GetNumFrames()
			self.Mode = animationControlAnimationModeEnum.ANIM_MODE_ONCE
			self.Frame = 0
			self.TargetFrame = 0
		end

	-- ( name: string )
	else
		local name = animation --[[@as string]]

		-- "If this is our current anim, bail"
		if self.Animation ~= nil and name ~= nil then
			if self.Animation:GetName() == name then
				return
			end
		end

		if self.Animation == nil and name == nil then
			return
		end

		-- "Release the old anim"
		if self.Animation then
			self.Animation = nil
		end

		-- "We need to switch anims"
		if name ~= nil and name:len() ~= 0 then
			self.Animation = ww3dAssetManagerClass.GetInstance():GetHAnimation( name )
		end

		if self.Animation then
			self.NumFrames = self.Animation:GetNumFrames()
			self.Mode = animationControlAnimationModeEnum.ANIM_MODE_ONCE
			self.Frame = 0
			self.TargetFrame = 0
		end
	end
end

--- @return HAnimationInstance
function INSTANCE:PeekAnimation()
	return self.Animation
end


--- @param mode AnimationControlAnimationMode
--- @param frame number? [Default: -1]
function INSTANCE:SetMode( mode, frame )
	if frame == nil then frame = -1 end

	self.Mode = mode
	if frame >= 1 then
		self.Frame = frame
	end
end

--- @return AnimationControlAnimationMode
function INSTANCE:GetMode()
	return self.Mode
end

--- @return boolean
function INSTANCE:IsComplete()
	return ( self.Animation == nil ) or ( ( self.Mode == animationControlAnimationModeEnum.ANIM_MODE_ONCE ) and ( self.Frame == self.NumFrames ) ) or ( ( self.Mode == animationControlAnimationModeEnum.ANIM_MODE_TARGET ) and ( self.Frame == self.TargetFrame ) )
end

--- @return string
function INSTANCE:GetAnimationName()
	return self.Animation and self.Animation:GetName() or ""
end

--- @param frame number
function INSTANCE:SetFrame( frame )
	self.Frame = frame
end

--- @return number
function INSTANCE:GetFrame()
	return self.Frame
end

function INSTANCE:GetProgress()
	return ( self.NumFrames and ( self.Frame / self.NumFrames ) or 0 )
end

--- @param frame number
function INSTANCE:SetTargetFrame( frame )
	self.TargetFrame = frame
end

--- @return number
function INSTANCE:GetTargetFrame()
	return self.TargetFrame
end

--- @param deltaTime number
function INSTANCE:Update( deltaTime )
	if self.Mode == animationControlAnimationModeEnum.ANIM_MODE_STOP then
		return
	end

	if self.Animation ~= nil then
		if self.Mode == animationControlAnimationModeEnum.ANIM_MODE_LOOP then
			-- "Increment the frame based on the current timeslice"
			self.Frame = self.Frame + deltaTime * self.Animation:GetFrameRate()

			-- "Handle wrapping"
			if self.Frame >= self.NumFrames then
				self.Frame = self.Frame - self.NumFrames
			end

			if self.Frame >= self.NumFrames then
				self.Frame = 1
			end

		elseif self.Mode == animationControlAnimationModeEnum.ANIM_MODE_TARGET then
			-- "Which direction are we animating?"
			if self.Frame < self.TargetFrame then
				self.Frame = self.Frame + deltaTime * self.Animation:GetFrameRate()

				-- "If we overshoot targetframe, snap to targetframe"
				if self.Frame >= self.TargetFrame then
					self.Frame = self.TargetFrame
				end
			elseif self.Frame > self.TargetFrame then
				self.Frame = self.Frame - deltaTime * self.Animation:GetFrameRate()

				-- "If we overshoot targetframe, snap to targetframe"
				if self.Frame <= self.TargetFrame then
					self.Frame = self.TargetFrame
				end
			end

		elseif self.Mode == animationControlAnimationModeEnum.ANIM_MODE_ONCE then
			-- "Increment the frame based on the current timeslice"
			self.Frame = self.Frame + deltaTime * self.Animation:GetFrameRate()

			-- "Make sure we don't go past the end"
			if self.Frame > self.NumFrames then
				self.Frame = self.NumFrames
			end
		end
	end
end

--- @param weight number? [Default: 1.0]
--- @return AnimationDataRecordStruct[]
function INSTANCE:GetAnimationData( weight )
	if weight == nil then weight = 1.0 end

	local list = {} --[[@as AnimationDataRecordStruct[] ]]

	if self.Animation ~= nil and weight > 0 then
		--- @type AnimationDataRecordStruct
		list[#list+1] = {
			Animation = self.Animation,
			Frame = self.Frame,
			Weight = weight
		}
	end

	return list
end

--- @param animationModel RenderObjectInstance
function INSTANCE:UpdateModel( animationModel )
	if self.Animation then
		animationModel:SetAnimation( self.Animation, self.Frame )
	else
		animationModel:SetAnimation()
	end
end
