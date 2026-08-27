-- Based on MotionChannelClass within var/home/JSchneider/Projects/LuaRenegadePort/C&amp;C Renegade/Code/ww3d2/motchan.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class MotionChannelClass
--- @field Instance MotionChannelInstance The metatable used by MotionChannelInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "MotionChannelClass"

--- @class MotionChannelInstance
--- @field Static MotionChannelClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_MotionChannel" )
INSTANCE.Class = "MotionChannelInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMotionChannel = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )
--#endregion

--#region Imported Enums

	local animationChannelEnum = w3dFileIds.ANIMATION_CHANNEL
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class MotionChannelClass

    --- Creates a new MotionChannelInstance
    --- @return MotionChannelInstance
    function STATIC.New()
        return robustclass.New( "Renegade_MotionChannel" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) MotionChannelInstance, `false` otherwise
    function STATIC.IsMotionChannel( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMotionChannel and true or false
    end

    typecheck.RegisterType( "MotionChannelInstance", STATIC.IsMotionChannel )
end


--- @class MotionChannelInstance
--- @field PivotIndex integer "What pivot is this channel applied to"
--- @field Type integer "What type of channel is this"
--- @field VectorLength integer "Size of each individual vector"
--- @field ValueOffset number
--- @field ValueScale number
--- @field CompressedData integer
--- @field Data number[] "Pointer to the raw floating point data"
--- @field FirstFrame integer "First frame which was non-identity"
--- @field LastFrame integer "Last frame which was non-identity"

--- @param dataSize integer
function INSTANCE:DoDataCompression( dataSize )
	return
    -- Omitted this function's body as it seems to be disabled via a return on the first line
end

--- @param frame integer
--- @param setVector number[] The vector table that values will be set into
function INSTANCE:GetVector( frame, setVector )
    if frame < self.FirstFrame or frame > self.LastFrame then
        self:SetIdentity( setVector )
    else

    end
end

function INSTANCE:Renegade_MotionChannel()
    self.PivotIndex = 1
    self.Type = 0
    self.VectorLength = 0
    self.Data = nil
    self.FirstFrame = -1
    self.LastFrame  = -1
    self.CompressedData = nil
    self.ValueScale  = 0.0
    self.ValueOffset = 0.0
end

function INSTANCE:_Renegade_MotionChannel()
    self:Free()
end

--- @param cload ChunkLoadInstance
--- @return boolean
function INSTANCE:LoadW3d( cload )
    local size = cload:CurChunkLength()
    -- "There was a bug in the exporter which saved too much data, so let's try and not load everything."
    local savedDataSize = size - deserializeLib.GetComplexDataTypeSize( "W3dAnimChannelStruct" )

    local channel = cload:ReadStruct( "W3dAnimChannelStruct" )
    if channel == nil then
        return false
    end

    self.FirstFrame   = channel.FirstFrame
    self.LastFrame    = channel.LastFrame
    self.VectorLength = channel.VectorLength or 0
    self.Type         = channel.Flags
    self.PivotIndex   = channel.Pivot

    local numFloats = math.floor( self.LastFrame - self.FirstFrame + 1 )
    numFloats = math.floor( numFloats * self.VectorLength )
    local dataSize = numFloats - 1 * 4 -- 4 is sizeof(float)

    self.Data = {}
    self.Data[1] = channel.Data[1]
    local readByteCount, readBytes = cload:Read( dataSize )
    if readByteCount ~= dataSize then
        self:Free()
        return false
    end
    self.Data[2] = deserializeLib.DeserializeFloat( readBytes --[[@as string]] )

    -- "Skip over the extra data at the end of the chunk (saved by an error in the exporter)"
    if savedDataSize - dataSize > 0 then
        cload:Seek( savedDataSize - dataSize )
    end

    self:DoDataCompression( dataSize )
    return true
end

--- @return integer
function INSTANCE:GetType()
	return self.Type
end

--- @return integer
function INSTANCE:GetPivot()
    return self.PivotIndex
end

--- @param index integer
function INSTANCE:SetPivot( index )
	self.PivotIndex = index
end

function INSTANCE:Free()
    if self.CompressedData then
        self.CompressedData = nil
    end
    if self.Data then
        self.Data = nil
    end
end

--- @param setVector number[] The vector table that values will be set into
function INSTANCE:SetIdentity( setVector )
    if self.Type == animationChannelEnum.ANIM_CHANNEL_Q then
        setVector[1] = 0.0
        setVector[2] = 0.0
        setVector[3] = 0.0
        setVector[4] = 1.0
    else
        setVector[1] = 0.0
    end
end
