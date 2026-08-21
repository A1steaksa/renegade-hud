-- Based on HCompressedAnimClass within Code/ww3d2/hcanim.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type HAnimationClass
local hAnimationClass = CNC.Import( "code/ww3d2/h-animation.lua" )

--- @class HCompressedAnimationClass : HAnimationClass
--- @field Instance HCompressedAnimationInstance The metatable used by HCompressedAnimationInstance
local STATIC = CNC.CreateExport( hAnimationClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HCompressedAnimationClass"

--- @class HCompressedAnimationInstance : HAnimationInstance
--- @field Static HCompressedAnimationClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HCompressedAnimation : Renegade_HAnimation" )
INSTANCE.Class = "HCompressedAnimationInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHCompressedAnimation = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type ClassUtils
	local classUtils = CNC.Import( "sh_class-utils.lua" )

	--- @type TimeCodedMotionChannelClass
	local timeCodedMotionChannelClass = CNC.Import( "code/ww3d2/time-coded-motion-channel.lua" )

	--- @type AdaptiveDeltaMotionChannelClass
	local adaptiveDeltaMotionChannelClass = CNC.Import( "code/ww3d2/adaptive-delta-motion-channel.lua" )

	--- @type TimeCodedBitChannelClass
	local timeCodedBitChannelClass = CNC.Import( "code/ww3d2/time-coded-bit-channel.lua" )
--#endregion

--#region Imported Enums

	local w3dChunkTypeEnum = w3dFileIds.W3D_CHUNK_TYPE
	local animationFlavorEnum = w3dFileIds.ANIMATION_FLAVOR
	local animationChannelEnum = w3dFileIds.ANIMATION_CHANNEL
	local bitChannelEnum = w3dFileIds.BIT_CHANNEL
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HCompressedAnimationClass

	STATIC.OK = 0
	STATIC.LOAD_ERROR = 1

    --- Creates a new HCompressedAnimationInstance
    --- @return HCompressedAnimationInstance
    function STATIC.New()
        return robustclass.New( "Renegade_HCompressedAnimation" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HCompressedAnimationInstance, `false` otherwise
    function STATIC.IsHCompressedAnimation( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHCompressedAnimation and true or false
    end

    typecheck.RegisterType( "HCompressedAnimationInstance", STATIC.IsHCompressedAnimation )
end


--- @class HCompressedAnimationInstance
--- @field Name string
--- @field HierarchyName string
--- @field NumFrames integer
--- @field NumNodes integer
--- @field Flavor integer
--- @field FrameRate number
--- @field NodeMotion NodeCompressedMotionInstance[]

function INSTANCE:Renegade_HCompressedAnimation()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_HCompressedAnimation()
	typecheck.NotImplementedError()
end

--- "Loads hierarchy animation from a file"
--- @param cload ChunkLoadInstance
function INSTANCE:LoadW3d( cload )
	-- "First make sure we release any memory in use"
	INSTANCE.Free( self )

	-- "Open the first chunk, it should be the animation header"
	if not cload:OpenChunk() then
		return STATIC.LOAD_ERROR
	end

	if cload:CurChunkId() ~= w3dChunkTypeEnum.W3D_CHUNK_COMPRESSED_ANIMATION_HEADER then
		-- "Error: Expected Animation Header!"
		section.Warn( INSTANCE.Class, " - LoadW3d - Expected Animation Header!" )
		return STATIC.LOAD_ERROR
	end

	-- I don't know if it was a typo or intentional, but the original code defines the header as being
	-- a W3dCompressedAnimHeaderStruct but then loads a W3dAnimHeaderStruct into it
	local header = cload:ReadStruct( "W3dAnimHeaderStruct" ) --[[@as W3dCompressedAnimHeaderStruct?]]
	if header == nil then
		return STATIC.LOAD_ERROR
	end

	cload:CloseChunk()

	self.Name = header.HierarchyName .. "." .. header.Name

	-- "TSS chasing crash bug 05/26/99"
	assert( self.HierarchyName ~= nil )
	assert( header.HierarchyName ~= nil )
	self.HierarchyName = header.HierarchyName:sub( 0, w3dFileIds.W3D_NAME_LEN )

	local basePose = ww3dAssetManagerClass.GetInstance():GetHTree( self.HierarchyName )
	if basePose == nil then
		INSTANCE.Free( self )
		return STATIC.LOAD_ERROR
	end
	self.NumNodes = basePose:NumPivots()

	self.NumFrames = header.NumFrames
	self.FrameRate = header.FrameRate
	self.Flavor    = header.Flavor

	-- "Just for now"
	-- (A classic lie)
	assert( self.Flavor == animationFlavorEnum.ANIM_FLAVOR_TIMECODED or self.Flavor == animationFlavorEnum.ANIM_FLAVOR_ADAPTIVE_DELTA )

	self.NodeMotion = classUtils.InitializeTypeArray( "NodeCompressedMotionStruct", self.NumNodes )

	-- "Initialize Flavor"
	for i = 1, self.NumNodes do
		self.NodeMotion[i]:SetFlavor( self.Flavor )
	end

	-- "Now, read in all of the other chunks (motion channels)."
	local timeCodedChannel 	   --- @type TimeCodedMotionChannelInstance
	local adaptiveDeltaChannel --- @type AdaptiveDeltaMotionChannelInstance
	local newBitChannel 	   --- @type TimeCodedBitChannelInstance

	while cload:OpenChunk() do
		local id = cload:CurChunkId()

		if id == w3dChunkTypeEnum.W3D_CHUNK_COMPRESSED_ANIMATION_CHANNEL then
			if self.Flavor == animationFlavorEnum.ANIM_FLAVOR_TIMECODED then
				local didSucceed, readChannel = INSTANCE.ReadTimeCodedChannel( self, cload )
				if not didSucceed or readChannel == nil then
					INSTANCE.Free( self )
					return STATIC.LOAD_ERROR
				end
				timeCodedChannel = readChannel --[[@as TimeCodedMotionChannelInstance]]

				if timeCodedChannel:GetPivot() < self.NumNodes then
					INSTANCE.AddChannel( self, timeCodedChannel )
				else
					-- "
					-- PWG 12-14-98: we have only allocated space for NumNode pivots.  
					-- If we have an index thats equal or higher than NumNode we are
					-- gonna trash memory.  Boy will we trash memory.
					-- GTH 09-25-2000: print a warning and survive this error
					-- "  
					section.Warn( "Animation '", self.Name, "' indexes a bone (", newBitChannel:GetPivot(), ") not present in the model.  Please re-export!" )
				end
			elseif self.Flavor == animationFlavorEnum.ANIM_FLAVOR_ADAPTIVE_DELTA then
				local didSucceed, readChannel = INSTANCE.ReadAdaptiveDeltaChannel( self, cload )
				if not didSucceed or readChannel == nil then
					INSTANCE.Free( self )
					return STATIC.LOAD_ERROR
				end
				adaptiveDeltaChannel = readChannel --[[@as AdaptiveDeltaMotionChannelInstance]]

				if adaptiveDeltaChannel:GetPivot() < self.NumNodes then
					INSTANCE.AddChannel( self, adaptiveDeltaChannel )
				else
					-- "
					-- PWG 12-14-98: we have only allocated space for NumNode pivots.  
					-- If we have an index thats equal or higher than NumNode we are
					-- gonna trash memory.  Boy will we trash memory.
					-- GTH 09-25-2000: print a warning and survive this error
					-- "  
					section.Warn( "Animation '", self.Name, "' indexes a bone (", newBitChannel:GetPivot(), ") not present in the model.  Please re-export!" )
				end
			end
		elseif id == w3dChunkTypeEnum.W3D_CHUNK_COMPRESSED_BIT_CHANNEL then
			local didSucceed, readChannel = INSTANCE.ReadBitChannel( self, cload )
			if not didSucceed or readChannel == nil then
				INSTANCE.Free( self )
				return STATIC.LOAD_ERROR
			end
			newBitChannel = readChannel --[[@as TimeCodedBitChannelInstance]]

			if newBitChannel:GetPivot() < self.NumNodes then
				INSTANCE.AddBitChannel( self, newBitChannel )
			else
				-- "  
				-- PWG 12-14-98: we have only allocated space for NumNode pivots.  
				-- If we have an index thats equal or higher than NumNode we are
				-- gonna trash memory.  Boy will we trash memory.
				-- GTH 09-25-2000: print a warning and survive this error
				-- "  
				section.Warn( "Animation '", self.Name, "' indexes a bone (", newBitChannel:GetPivot(), ") not present in the model.  Please re-export!" )
			end
		end
		cload:CloseChunk()
	end

	return STATIC.OK
end

--- @return string
function INSTANCE:GetName()
	return self.Name
end

--- @return string
function INSTANCE:GetHName()
	return self.HierarchyName
end

--- @return integer
function INSTANCE:GetNumFrames()
	return self.NumFrames
end

--- @return number
function INSTANCE:GetFrameRate()
	return self.FrameRate
end

--- @return number
function INSTANCE:GetTotalTime()
	return self.NumFrames / self.FrameRate
end

--- @return integer
function INSTANCE:GetFlavor()
	return self.Flavor
end

--- @param pivotIndex integer
--- @param frame number
--- @return Vector
function INSTANCE:GetTranslation( pivotIndex, frame )
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @param frame number
--- @return QuaternionInstance
function INSTANCE:GetOrientation( pivotIndex, frame )
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @param frame number
--- @return Matrix3dInstance
function INSTANCE:GetTransform( pivotIndex, frame )
	typecheck.NotImplementedError()
end

--- @return boolean
function INSTANCE:GetVisibility( pivotIndex, frame )
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @return boolean
function INSTANCE:IsNodeMotionPresent( pivotIndex )
	typecheck.NotImplementedError()
end

--- @return integer
function INSTANCE:GetNumPivots()
	return self.NumNodes
end

--- @param pivotIndex integer
--- @return boolean
function INSTANCE:HasXTranslation( pivotIndex )
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @return boolean
function INSTANCE:HasYTranslation( pivotIndex )
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @return boolean
function INSTANCE:HasZTranslation( pivotIndex )
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @return boolean
function INSTANCE:HasRotation( pivotIndex )
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @return boolean
function INSTANCE:HasVisibility( pivotIndex )
	typecheck.NotImplementedError()
end

function INSTANCE:Free()
	typecheck.NotImplementedError()
end

--- "Reads in a single channel of motion"
--- @param cload ChunkLoadInstance
--- @return boolean, TimeCodedMotionChannelInstance?
function INSTANCE:ReadTimeCodedChannel( cload )
	local newChannel = timeCodedMotionChannelClass.New()
	local result = newChannel:LoadW3d( cload )
	return result, newChannel
end

--- "Reads in a single channel of motion"
--- @param cload ChunkLoadInstance
--- @return boolean, AdaptiveDeltaMotionChannelInstance?
function INSTANCE:ReadAdaptiveDeltaChannel( cload )
	local newChannel = adaptiveDeltaMotionChannelClass.New()
	local result = newChannel:LoadW3d( cload )
	return result, newChannel
end

--- "Adds a motion channel to the animation"
--- @param newChannel TimeCodedMotionChannelInstance|AdaptiveDeltaMotionChannelInstance
function INSTANCE:AddChannel( newChannel )
	typecheck.AssertArgType( INSTANCE.Class, 1, newChannel, { "TimeCodedMotionChannelInstance", "AdaptiveDeltaMotionChannelInstance" } )

	local index = newChannel:GetPivot()
	local type = newChannel:GetType()

	if typecheck.IsOfType( newChannel, "TimeCodedMotionChannelInstance" ) then
		--- @cast newChannel TimeCodedMotionChannelInstance

		if type == animationChannelEnum.ANIM_CHANNEL_X then
			self.NodeMotion[index].TimeCoded.X = newChannel
		elseif type == animationChannelEnum.ANIM_CHANNEL_Y then
			self.NodeMotion[index].TimeCoded.Y = newChannel
		elseif type == animationChannelEnum.ANIM_CHANNEL_Z then
			self.NodeMotion[index].TimeCoded.Z = newChannel
		elseif type == animationChannelEnum.ANIM_CHANNEL_Q then
			self.NodeMotion[index].TimeCoded.Q = newChannel
		end
	else
		--- @cast newChannel AdaptiveDeltaMotionChannelInstance

		if type == animationChannelEnum.ANIM_CHANNEL_X then
			self.NodeMotion[index].AdaptiveDelta.X = newChannel
		elseif type == animationChannelEnum.ANIM_CHANNEL_Y then
			self.NodeMotion[index].AdaptiveDelta.Y = newChannel
		elseif type == animationChannelEnum.ANIM_CHANNEL_Z then
			self.NodeMotion[index].AdaptiveDelta.Z = newChannel
		elseif type == animationChannelEnum.ANIM_CHANNEL_Q then
			self.NodeMotion[index].AdaptiveDelta.Q = newChannel
		end
	end
end

--- "Read a bit channel from the file"
--- @param cload ChunkLoadInstance
--- @return boolean, TimeCodedBitChannelInstance
function INSTANCE:ReadBitChannel( cload )
	local newChannel = timeCodedBitChannelClass.New()
	local result = newChannel:LoadW3d( cload )
	return result, newChannel
end

--- "Install a bit channel into the animation"
--- @param newChannel TimeCodedBitChannelInstance
function INSTANCE:AddBitChannel( newChannel )
	local index = newChannel:GetPivot()
	local type = newChannel:GetType()

	if type == bitChannelEnum.BIT_CHANNEL_VIS then
		self.NodeMotion[index].Visibility = newChannel
	end
end
