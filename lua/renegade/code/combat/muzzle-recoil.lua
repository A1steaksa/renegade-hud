-- Based on MuzzleRecoilClass within Code/Combat/muzzlerecoil.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class MuzzleRecoilClass
--- @field instance MuzzleRecoilInstance The metatable used by MuzzleRecoilInstance
local STATIC = CNC.CreateExport()
STATIC.Class = "MuzzleRecoilClass"
local isHotload = not table.IsEmpty( STATIC )

--- @class MuzzleRecoilInstance
--- @field Static MuzzleRecoilClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_MuzzleRecoil" )
INSTANCE.Class = "MuzzleRecoilInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMuzzleRecoil = true


--#region Imports
    --- @type Matrix3dClass
    local matrix3dClass = CNC.Import( "code/wwmath/matrix3d.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    --- @class MuzzleRecoilClass

    --- Creates a new MuzzleRecoilInstance
    --- @vararg any
    --- @return MuzzleRecoilInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_MuzzleRecoil", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) MuzzleRecoilInstance, `false` otherwise
    function STATIC.IsMuzzleRecoil( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMuzzleRecoil and true or false
    end

    typecheck.RegisterType( "MuzzleRecoilInstance", STATIC.IsMuzzleRecoil )
end

--- >"  
--- >This class tracks the recoil state of a muzzle for an [ren_armed-entity].  
--- >To set up the object, call Init with the bone index that you want it to control.  
--- >To trigger a recoil, call [StartRecoil].  
--- >To make everything work, call Update once per frame with the [Entity] and the amount of time that has elapsed.  
--- >"  
--- @class MuzzleRecoilInstance
--- @field protected BoneIndex integer "Bone to move"
--- @field protected RecoilScale number "Size of the initial translation"
--- @field protected RecoilTimer number "Counts down to 0.0s"
--- @field protected OORecoilTime number "One-over the total time for the recoil effect"

--- Constructs a new MuzzleRecoilInstance
--- @vararg any
function INSTANCE:Renegade_MuzzleRecoil()
    self:Init( 0 )
end

--- @param boneIndex integer
function INSTANCE:Init( boneIndex )
    self.BoneIndex = boneIndex
    self.RecoilScale = 1.0
    self.RecoilTimer = 0.0
    self.OORecoilTime = 0.0
end

--- @param recoilScale number
--- @param recoilTime number
function INSTANCE:StartRecoil( recoilScale, recoilTime )
    self.RecoilScale = recoilScale
    self.RecoilTimer = recoilTime
    if self.RecoilTimer > 0 then
        self.OORecoilTime = 1 / self.RecoilTimer
    end
end

--- @param model RenderObjectInstance
function INSTANCE:Update( model )
    if self.RecoilTimer <= 0.0 or not self.BoneIndex or self.BoneIndex <= 0 then
        return
    end

    -- "Since our timer is active, go ahead and capture the bone"
    model:CaptureBone( self.BoneIndex )

    -- "Apply the recoil effect"
    local recoilScale = self.RecoilScale * self.RecoilTimer * self.OORecoilTime
    local recoilTransformationMatrix = matrix3dClass.New( 1 )
    recoilTransformationMatrix:TranslateX( -recoilScale )
    model:ControlBone( self.BoneIndex, recoilTransformationMatrix )

    -- "Decrement the recoil timer and release the bone if it expires"
    self.RecoilTimer = self.RecoilTimer - FrameTime()
    if self.RecoilTimer <= 0.0 then
        self.RecoilTimer = 0.0
        model:ReleaseBone( self.BoneIndex )
    end
end