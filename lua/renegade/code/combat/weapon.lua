-- Based on WeaponClass within Code/Combat/weapons.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class WeaponClass
--- @field Instance WeaponInstance The metatable used by WeaponInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "WeaponClass"

--- @class WeaponInstance
--- @field Static WeaponClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Weapon" )
INSTANCE.Class = "WeaponInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsWeapon = true

--#region Exported Enums
	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	local enumBuilder = enumBuilderClass.New()

	--- @enum WeaponHoldStyleType
    STATIC.WEAPON_HOLD_STYLE_TYPE = {
        WEAPON_HOLD_STYLE_C4      	  = enumBuilder:Set( 0 ),
		WEAPON_HOLD_STYLE_NOT_USED    = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_AT_SHOULDER = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_AT_HIP	  = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_LAUNCHER	  = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_HANDGUN	  = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_BEACON	  = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_EMPTY_HANDS = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_AT_CHEST	  = enumBuilder:Next(),
		WEAPON_HOLD_STYLE_HANDS_DOWN  = enumBuilder:Next(),
		NUM_WEAPON_HOLD_STYLES		  = enumBuilder:Next(),
    }
    local weaponHoldStyleType = STATIC.WEAPON_HOLD_STYLE_TYPE

	--- @enum WeaponModelUpdateState
    STATIC.WEAPON_MODEL_UPDATE_STATE = {
        WEAPON_MODEL_UPDATE_WILL_BE_NEEDED = enumBuilder:Set( 0 ),
		WEAPON_MODEL_UPDATE_IS_NEEDED      = enumBuilder:Next(),
		WEAPON_MODEL_UPDATE_NOT_NEEDED     = enumBuilder:Next(),
    }
    local weaponModelUpdateState = STATIC.WEAPON_MODEL_UPDATE_STATE

	--- @enum WeaponAnimationState
    STATIC.WEAPON_ANIMATION_STATE = {
        WEAPON_ANIM_NOT_FIRING = enumBuilder:Set( 0 ),
		WEAPON_ANIM_FIRING_0   = enumBuilder:Next(),
		WEAPON_ANIM_FIRING_1   = enumBuilder:Next(),
    }
    local weaponAnimationState = STATIC.WEAPON_ANIMATION_STATE

--#endregion

--#region Imports

--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class WeaponClass

    --- Creates a new WeaponInstance
    --- @return WeaponInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Weapon" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) WeaponInstance, `false` otherwise
    function STATIC.IsWeapon( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsWeapon and true or false
    end

    typecheck.RegisterType( "WeaponInstance", STATIC.IsWeapon )
end


--- @class WeaponInstance
--- @field Definition any
--- @field Owner any
--- @field Model any
--- @field C4dEtonationMode integer
--- @field PrimaryAmmoDefinition any
--- @field SecondaryAmmoDefinition any
--- @field ClipRounds any
--- @field InventoryRounds any
--- @field BurstDelayTimer any
--- @field BurstCount any
--- @field BulletBumpTime number
--- @field WeaponExists boolean
--- @field State any
--- @field StateTimer number
--- @field DidFire boolean
--- @field LastFrameIsPrimaryTriggered boolean
--- @field LastFrameIsSecondaryTriggered boolean
--- @field IsPrimaryTriggered boolean
--- @field IsSecondaryTriggered boolean
--- @field TotalRoundsFired integer
--- @field SafetySet boolean
--- @field LockTriggers boolean
--- @field EmptySoundTimer number
--- @field NextAnimationState any
--- @field CurrentAnimationState any
--- @field UpdateModel any
--- @field Target any
--- @field TargetObject any
--- @field ContinuousEmitters any
--- @field ContinuousSound any
--- @field FiringSound any
--- @field FiringSoundDefinitionID integer
--- @field MuzzleFlash any

function INSTANCE:Renegade_Weapon()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_Weapon()
	typecheck.NotImplementedError()
end

function INSTANCE:Init()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:SetModel()
	typecheck.NotImplementedError()
end

function INSTANCE:SetOwner()
	typecheck.NotImplementedError()
end

function INSTANCE:GetOwner()
	typecheck.NotImplementedError()
end

function INSTANCE:Select()
	typecheck.NotImplementedError()
end

function INSTANCE:Deselect()
	typecheck.NotImplementedError()
end

function INSTANCE:Update()
	typecheck.NotImplementedError()
end

function INSTANCE:IsMuzzleClear()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputeBulletStartPoint()
	typecheck.NotImplementedError()
end

function INSTANCE:NextC4DetonationMode()
	typecheck.NotImplementedError()
end

--- @return WeaponDefinitionInstance
function INSTANCE:GetDefinition()
	typecheck.NotImplementedError()
end

function INSTANCE:GetName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetId()
	typecheck.NotImplementedError()
end

function INSTANCE:GetHudIconTextureName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetModelName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetBackModelName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAnimationName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStyle()
	typecheck.NotImplementedError()
end

function INSTANCE:GetKeyNumber()
	typecheck.NotImplementedError()
end

function INSTANCE:GetCanSnipe()
	typecheck.NotImplementedError()
end

function INSTANCE:GetRating()
	typecheck.NotImplementedError()
end

function INSTANCE:GetEffectiveRange()
	typecheck.NotImplementedError()
end

function INSTANCE:GetPrimaryFireRate()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFirstPersonModelName()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFirstPersonModelOffset()
	typecheck.NotImplementedError()
end

function INSTANCE:GetRecoilTime()
	typecheck.NotImplementedError()
end

function INSTANCE:GetRecoilScale()
	typecheck.NotImplementedError()
end

function INSTANCE:SetTotalRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTotalRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:AddRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:SetClipRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:GetClipRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:SetInventoryRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:GetInventoryRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:DoReload()
	typecheck.NotImplementedError()
end

function INSTANCE:DecrementRounds()
	typecheck.NotImplementedError()
end

function INSTANCE:IsAmmoMaxed()
	typecheck.NotImplementedError()
end

function INSTANCE:IsLoaded()
	typecheck.NotImplementedError()
end

function INSTANCE:IsReloadOk()
	typecheck.NotImplementedError()
end

function INSTANCE:IsReloadNeeded()
	typecheck.NotImplementedError()
end

function INSTANCE:GetRange()
	typecheck.NotImplementedError()
end

--- @return boolean
function INSTANCE:IsModelUpdateNeeded()
	typecheck.NotImplementedError()
end

function INSTANCE:ResetModelUpdate()
	typecheck.NotImplementedError()
end

function INSTANCE:IsAnimationUpdateNeeded()
	typecheck.NotImplementedError()
end

function INSTANCE:ResetAnimationUpdate()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAnimationState()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTotalRoundsFired()
	typecheck.NotImplementedError()
end

function INSTANCE:DisplayTargeting()
	typecheck.NotImplementedError()
end

function INSTANCE:SetTarget()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTarget()
	typecheck.NotImplementedError()
end

function INSTANCE:SetTargetObject()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTargetObject()
	typecheck.NotImplementedError()
end

function INSTANCE:GetState()
	typecheck.NotImplementedError()
end

function INSTANCE:IsFiring()
	typecheck.NotImplementedError()
end

function INSTANCE:IsReloading()
	typecheck.NotImplementedError()
end

function INSTANCE:IsSwitching()
	typecheck.NotImplementedError()
end

function INSTANCE:ForceReload()
	typecheck.NotImplementedError()
end

function INSTANCE:SetSafety()
	typecheck.NotImplementedError()
end

function INSTANCE:IsSafetySet()
	typecheck.NotImplementedError()
end

function INSTANCE:SetPrimaryTriggered()
	typecheck.NotImplementedError()
end

function INSTANCE:SetSecondaryTriggered()
	typecheck.NotImplementedError()
end

function INSTANCE:IsTriggered()
	typecheck.NotImplementedError()
end

function INSTANCE:InitMuzzleFlash()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateMuzzleFlash()
	typecheck.NotImplementedError()
end

function INSTANCE:DoesWeaponExist()
	typecheck.NotImplementedError()
end

function INSTANCE:SetWeaponExists()
	typecheck.NotImplementedError()
end

function INSTANCE:CastWeapon()
	typecheck.NotImplementedError()
end

function INSTANCE:CastWeaponDownMuzzle()
	typecheck.NotImplementedError()
end

function INSTANCE:MakeShellEject()
	typecheck.NotImplementedError()
end

function INSTANCE:StopFiringSound()
	typecheck.NotImplementedError()
end

function INSTANCE:FireC4()
	typecheck.NotImplementedError()
end

function INSTANCE:FireBeacon()
	typecheck.NotImplementedError()
end

function INSTANCE:FireBullet()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMuzzle()
	typecheck.NotImplementedError()
end

function INSTANCE:DoFire()
	typecheck.NotImplementedError()
end

function INSTANCE:SetState()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateState()
	typecheck.NotImplementedError()
end

function INSTANCE:DoFiringEffects()
	typecheck.NotImplementedError()
end

function INSTANCE:DoContinuousEffects()
	typecheck.NotImplementedError()
end

function INSTANCE:IgnoreOwner()
	typecheck.NotImplementedError()
end

function INSTANCE:UnignoreOwner()
	typecheck.NotImplementedError()
end
