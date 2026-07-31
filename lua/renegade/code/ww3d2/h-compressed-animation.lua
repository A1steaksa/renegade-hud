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
--#endregion

--#region Imported Enums
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
--- @field NodeMotion NodeCompressedMotionStructInstance

function INSTANCE:Renegade_HCompressedAnimation()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_HCompressedAnimation()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadW3d()
	typecheck.NotImplementedError()
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

--- @param cload ChunkLoadInstance
--- @param newChannel TimeCodedMotionChannelInstance[][]|AdaptiveDeltaMotionChannelClass[][]
--- @return boolean
function INSTANCE:ReadChannel( cload, newChannel )
	typecheck.NotImplementedError()
end

--- @param newChannel TimeCodedMotionChannelInstance[][]|AdaptiveDeltaMotionChannelClass[][]
function INSTANCE:AddChannel( newChannel )
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @param newChannel TimeCodedBitChannelInstance[][]
--- @return boolean
function INSTANCE:ReadBitChannel( cload, newChannel )
	typecheck.NotImplementedError()
end

--- @param newChannel TimeCodedBitChannelInstance[][]
function INSTANCE:AddBitChannel( newChannel )
	typecheck.NotImplementedError()
end
