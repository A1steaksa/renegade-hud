-- Based on HAnimClass within Code/ww3d2/hanim.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class HAnimationClass
--- @field Instance HAnimationInstance The metatable used by HAnimationInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HAnimationClass"

--- @class HAnimationInstance
--- @field Static HAnimationClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HAnimation" )
INSTANCE.Class = "HAnimationInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHAnimation = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HAnimationClass

    --- Creates a new HAnimationInstance
    --- @return HAnimationInstance
    function STATIC.New()
        return robustclass.New( "Renegade_HAnimation" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HAnimationInstance, `false` otherwise
    function STATIC.IsHAnimation( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHAnimation and true or false
    end

    typecheck.RegisterType( "HAnimationInstance", STATIC.IsHAnimation )
end


--- "  
--- This is the base class for all animation formats used in W3D.  
--- It contains the virtual interface that all animations must support.  
--- "  
--- @class HAnimationInstance
--- @field HasEmbeddedSounds boolean

function INSTANCE:Renegade_HAnimation()
	self.HasEmbeddedSounds = false
end

function INSTANCE:_Renegade_HAnimation()
	typecheck.NotImplementedError()
end

--- @return string
function INSTANCE:GetName()
	CNC.VirtualFunction()
end

function INSTANCE:GetHName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetKey()
	typecheck.NotImplementedError()
end

--- @return integer
function INSTANCE:GetNumFrames()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFrameRate()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTotalTime()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTranslation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetOrientation()
	typecheck.NotImplementedError()
end

--- @param pivotIndex integer
--- @param frame number
--- @return Matrix3dInstance
function INSTANCE:GetTransform( pivotIndex, frame )
	CNC.VirtualFunction()
end

function INSTANCE:GetVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:GetNumPivots()
	typecheck.NotImplementedError()
end

--- @param index integer
--- @return boolean
function INSTANCE:IsNodeMotionPresent( index )
	typecheck.NotImplementedError()
end

function INSTANCE:HasXTranslation()
	typecheck.NotImplementedError()
end

function INSTANCE:HasYTranslation()
	typecheck.NotImplementedError()
end

function INSTANCE:HasZTranslation()
	typecheck.NotImplementedError()
end

function INSTANCE:HasRotation()
	typecheck.NotImplementedError()
end

function INSTANCE:HasVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:HasEmbeddedSounds()
	typecheck.NotImplementedError()
end

function INSTANCE:SetHasEmbeddedSounds()
	typecheck.NotImplementedError()
end
