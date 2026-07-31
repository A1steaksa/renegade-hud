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
--- @field Name any
--- @field HierarchyName any
--- @field NumFrames integer
--- @field NumNodes integer
--- @field Flavor integer
--- @field FrameRate number
--- @field NodeMotion any

function INSTANCE:Renegade_HCompressedAnimation()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_HCompressedAnimation()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadW3d()
	typecheck.NotImplementedError()
end

function INSTANCE:GetName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetHName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetNumFrames()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFrameRate()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTotalTime()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFlavor()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTranslation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetOrientation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTransform()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:IsNodeMotionPresent()
	typecheck.NotImplementedError()
end

function INSTANCE:GetNumPivots()
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

function INSTANCE:Free()
	typecheck.NotImplementedError()
end

function INSTANCE:ReadChannel()
	typecheck.NotImplementedError()
end

function INSTANCE:AddChannel()
	typecheck.NotImplementedError()
end

function INSTANCE:ReadBitChannel()
	typecheck.NotImplementedError()
end

function INSTANCE:AddBitChannel()
	typecheck.NotImplementedError()
end
