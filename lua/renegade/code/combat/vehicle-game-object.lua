-- Based on VehicleGameObj within Code/Combat/vehicle.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type SmartGameObjectClass
local smartGameObjectClass = CNC.Import( "code/combat/smart-game-object.lua" )

--- @class VehicleGameObjectClass : SmartGameObjectClass
--- @field Instance VehicleGameObjectInstance The metatable used by VehicleGameObjectInstance
local STATIC = CNC.CreateExport( smartGameObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "VehicleGameObjectClass"

--- @class VehicleGameObjectInstance : SmartGameObjectInstance
--- @field Static VehicleGameObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_VehicleGameObject : Renegade_SmartGameObject" )
INSTANCE.Class = "VehicleGameObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsVehicleGameObject = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class VehicleGameObjectClass
	--- @field DefaultDriverIsGunner boolean
	--- @field CameraLockedToTurret boolean

    --- Creates a new VehicleGameObjectInstance
    --- @return VehicleGameObjectInstance
    function STATIC.New()
        return robustclass.New( "Renegade_VehicleGameObject" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) VehicleGameObjectInstance, `false` otherwise
    function STATIC.IsVehicleGameObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsVehicleGameObject and true or false
    end

    typecheck.RegisterType( "VehicleGameObjectInstance", STATIC.IsVehicleGameObject )

	function STATIC.SetPrecision()
		typecheck.NotImplementedError()
	end

	function STATIC.ToggleTargetSteering()
		typecheck.NotImplementedError()
	end

	function STATIC.SetTargetSteering()
		typecheck.NotImplementedError()
	end

	function STATIC.IsTargetSteering()
		typecheck.NotImplementedError()
	end

	function STATIC.SetDefaultDriverIsGunner()
		typecheck.NotImplementedError()
	end

	function STATIC.SetCameraLockedToTurret()
		typecheck.NotImplementedError()
	end

	function STATIC.GetCameraLockedToTurret()
		typecheck.NotImplementedError()
	end
end


--- @class VehicleGameObjectInstance
--- @field Sound Sound3dInstance
--- @field EngineSoundState integer
--- @field CachedEngineSound AudibleSoundInstance
--- @field TurretBone integer
--- @field BarrelBone integer
--- @field TurretTurn number
--- @field BarrelTilt number
--- @field BarrelOffset number
--- @field TransitionsEnabled boolean
--- @field HasEnterTransitions boolean
--- @field HasExitTransitions boolean
--- @field VehicleDelivered boolean
--- @field DriverIsGunner boolean
--- @field WheelSurfaceEmitters VectorClassPersistantSurfaceEmitterInstance
--- @field WheelSurfaceSound PersistantSurfaceSoundInstance
--- @field SeatOccupants SoldierGameObjectInstance[]
--- @field OccupiedSeats integer
--- @field TransitionInstances TransitionInstanceInstance[]
--- @field LockOwner ScriptableGameObjectInstance
--- @field LockTimer number

function INSTANCE:Renegade_VehicleGameObject()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_VehicleGameObject()
	typecheck.NotImplementedError()
end

function INSTANCE:Init()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDefinition()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:OnPostLoad()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFactory()
	typecheck.NotImplementedError()
end

function INSTANCE:Startup()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekVehiclePhysics()
	typecheck.NotImplementedError()
end

function INSTANCE:Think()
	typecheck.NotImplementedError()
end

function INSTANCE:PostThink()
	typecheck.NotImplementedError()
end

function INSTANCE:ApplyControl()
	typecheck.NotImplementedError()
end

function INSTANCE:GetWeaponControlOwner()
	typecheck.NotImplementedError()
end

function INSTANCE:SetTargeting()
	typecheck.NotImplementedError()
end

function INSTANCE:Use2dAiming()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLookTransform()
	typecheck.NotImplementedError()
end

function INSTANCE:HasTurret()
	typecheck.NotImplementedError()
end

function INSTANCE:AsVehicleGameObject()
	typecheck.NotImplementedError()
end

function INSTANCE:IsAircraft()
	typecheck.NotImplementedError()
end

function INSTANCE:IsTurret()
	typecheck.NotImplementedError()
end

function INSTANCE:GetPlayerType()
	typecheck.NotImplementedError()
end

function INSTANCE:AddOccupant()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveOccupant()
	typecheck.NotImplementedError()
end

function INSTANCE:ContainsOccupant()
	typecheck.NotImplementedError()
end

function INSTANCE:GetOccupantCount()
	typecheck.NotImplementedError()
end

function INSTANCE:FindSeat()
	typecheck.NotImplementedError()
end

--- @return SoldierGameObjectInstance?
function INSTANCE:GetDriver()
	typecheck.NotImplementedError()
end

function INSTANCE:GetGunner()
	typecheck.NotImplementedError()
end

function INSTANCE:GetActualGunner()
	typecheck.NotImplementedError()
end

function INSTANCE:IsEntryPermitted()
	typecheck.NotImplementedError()
end

function INSTANCE:PassengerEntering()
	typecheck.NotImplementedError()
end

function INSTANCE:PassengerExiting()
	typecheck.NotImplementedError()
end

function INSTANCE:SetVehicleDelivered()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportCreation()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportCreation()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportRare()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportRare()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportFrequent()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportFrequent()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportStateCs()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportStateCs()
	typecheck.NotImplementedError()
end

function INSTANCE:GetProfile()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVelocity()
	typecheck.NotImplementedError()
end

function INSTANCE:SetVelocity()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDescription()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTurnRadius()
	typecheck.NotImplementedError()
end

function INSTANCE:IsEngineEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableEngine()
	typecheck.NotImplementedError()
end

function INSTANCE:InitWheelEffects()
	typecheck.NotImplementedError()
end

function INSTANCE:ShutdownWheelEffects()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateWheelEffects()
	typecheck.NotImplementedError()
end

function INSTANCE:ApplyDamage()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateDamageMeshes()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSquishVelocity()
	typecheck.NotImplementedError()
end

function INSTANCE:ScriptEnableTransitions()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVehicleName()
	typecheck.NotImplementedError()
end

function INSTANCE:ObjectExpired()
	typecheck.NotImplementedError()
end

function INSTANCE:LockVehicle()
	typecheck.NotImplementedError()
end

function INSTANCE:IsLocked()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLockOwner()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDriverIsGunner()
	typecheck.NotImplementedError()
end

function INSTANCE:ToggleDriverIsGunner()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStealthFadeDistance()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFilterDistance()
	typecheck.NotImplementedError()
end

function INSTANCE:IgnoreOccupants()
	typecheck.NotImplementedError()
end

function INSTANCE:UnignoreOccupants()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveTransitions()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateNewTransitions()
	typecheck.NotImplementedError()
end

function INSTANCE:DestroyTransitions()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateTransitions()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateAndDestroyTransitions()
	typecheck.NotImplementedError()
end

function INSTANCE:AquireTurretBones()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseTurretBones()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateTurret()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateSoundEffects()
	typecheck.NotImplementedError()
end

function INSTANCE:ChangeEngineSoundState()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateEngineSoundPitch()
	typecheck.NotImplementedError()
end
