-- Based on SoldierObserverClass within Code/Combat/soldierobserver.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type PersistentGameObjectObserverClass
local persistentGameObjectObserverClass = CNC.Import( "code/combat/persistent-game-object-observer.lua" )

--- @class SoldierObserverClass : PersistentGameObjectObserverClass
--- @field Instance SoldierObserverInstance The metatable used by SoldierObserverInstance
local STATIC = CNC.CreateExport( persistentGameObjectObserverClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "SoldierObserverClass"

--- @class SoldierObserverInstance : PersistentGameObjectObserverInstance
--- @field Static SoldierObserverClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_SoldierObserver : Renegade_PersistentGameObjectObserver" )
INSTANCE.Class = "SoldierObserverInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsSoldierObserver = true

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

	--- @enum SoldierAiStates
	STATIC.SOLDIER_AI_STATES = {
		SOLDIER_AI_RELAXED_IDLE     = enumBuilder:Set( 0 ),
		SOLDIER_AI_ALERT_IDLE       = enumBuilder:Next(),
		SOLDIER_AI_FOOTSTEPS_HEARD  = enumBuilder:Next(),
		SOLDIER_AI_BULLET_HEARD     = enumBuilder:Next(),
		SOLDIER_AI_GUNSHOT_HEARD    = enumBuilder:Next(),
		SOLDIER_AI_ENEMY_SEEN       = enumBuilder:Next(),
		NUM_SOLDIER_AI_STATES       = enumBuilder:Next(),
		SOLDIER_AI_CONDITIONAL_IDLE = enumBuilder:Set( 100 )
	}
	local soldierAiStates = STATIC.SOLDIER_AI_STATES
--#endregion

--#region Imports

	--- @type SimplePersistFactoryClass
	local simplePersistFactoryClass = CNC.Import( "code/wwsaveload/simple-persist-factory.lua" )

	--- @type CombatChunkIdClass
	local combatChunkIdClass = CNC.Import( "code/combat/combat-chunk-id.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class SoldierObserverClass
	--- @field SoldierObserverPersistFactory SimplePersistFactoryInstance

    --- Creates a new SoldierObserverInstance
    --- @return SoldierObserverInstance
    function STATIC.New()
        return robustclass.New( "Renegade_SoldierObserver" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) SoldierObserverInstance, `false` otherwise
    function STATIC.IsSoldierObserver( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsSoldierObserver and true or false
    end

    typecheck.RegisterType( "SoldierObserverInstance", STATIC.IsSoldierObserver )

	function STATIC.StaticConstructor()
		STATIC.SoldierObserverPersistFactory = simplePersistFactoryClass.New( STATIC, combatChunkIdClass.CHUNKID_SOLDIER_OBSERVER )
	end
end


--- @class SoldierObserverInstance
--- @field State SoldierAiStates "Current State"
--- @field StateTimer number "Time spent in this state"
--- @field HomeLocation Vector "Location to stay centered around"
--- @field HomeRadius number "Radius to stay within"
--- @field AlertPosition Vector
--- @field ActionTimer number "Used to make us change actions periodically"
--- @field EnemyObject ScriptableGameObjectInstance
--- @field CoveredAttack boolean
--- @field CoverPosition CoverEntryInstance
--- @field ConversationTimer number
--- @field IsAlerted boolean
--- @field Aggressiveness number
--- @field TakeCoverProbability number
--- @field IsStationary boolean
--- @field SubStateString string
--- @field LastEvent SoldierAiStates
--- @field LastWeaponIndex integer

function INSTANCE:Renegade_SoldierObserver()
	persistentGameObjectObserverClass.Instance.Renegade_PersistentGameObjectObserver( self )

	self.State = soldierAiStates.SOLDIER_AI_RELAXED_IDLE
	self.StateTimer = 0
	self.HomeRadius = 9999999
	self.ActionTimer = 0
	self.CoverPosition = nil
	self.CoveredAttack = false
	self.LastEvent = soldierAiStates.SOLDIER_AI_RELAXED_IDLE
	self.ConversationTimer = math.Rand( 1.0, 10.0 )
	self.IsAlerted = false
	self.Aggressiveness = 0.5
	self.TakeCoverProbability = 0.5
	self.IsStationary = false
	self.LastWeaponIndex = 1
end

function INSTANCE:_Renegade_SoldierObserver()
	typecheck.NotImplementedError()
end

function INSTANCE:GetName()
	typecheck.NotImplementedError()
end

--- @return PersistFactoryInstance
function INSTANCE:GetFactory()
	return STATIC.SoldierObserverPersistFactory
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

--- @param object GameObjectInstance
function INSTANCE:Attach( object )
	-- "Warning, Attach may not be called on loaded scripts"
end

function INSTANCE:Detach()
	typecheck.NotImplementedError()
end

function INSTANCE:Created()
	typecheck.NotImplementedError()
end

function INSTANCE:Destroyed()
	typecheck.NotImplementedError()
end

function INSTANCE:Killed()
	typecheck.NotImplementedError()
end

function INSTANCE:Damaged()
	typecheck.NotImplementedError()
end

function INSTANCE:Custom()
	typecheck.NotImplementedError()
end

function INSTANCE:SoundHeard()
	typecheck.NotImplementedError()
end

function INSTANCE:EnemySeen()
	typecheck.NotImplementedError()
end

function INSTANCE:ActionComplete()
	typecheck.NotImplementedError()
end

function INSTANCE:TimerExpired()
	typecheck.NotImplementedError()
end

function INSTANCE:AnimationComplete()
	typecheck.NotImplementedError()
end

function INSTANCE:Poked()
	typecheck.NotImplementedError()
end

function INSTANCE:Entered()
	typecheck.NotImplementedError()
end

function INSTANCE:Exited()
	typecheck.NotImplementedError()
end

function INSTANCE:ResetConversationTimer()
	typecheck.NotImplementedError()
end

function INSTANCE:SetHomeLocation()
	typecheck.NotImplementedError()
end

function INSTANCE:SetAggressiveness()
	typecheck.NotImplementedError()
end

function INSTANCE:SetTakeCoverProbability()
	typecheck.NotImplementedError()
end

function INSTANCE:SetIsStationary()
	typecheck.NotImplementedError()
end

function INSTANCE:GetInformation()
	typecheck.NotImplementedError()
end

function INSTANCE:SetState()
	typecheck.NotImplementedError()
end

function INSTANCE:StateChanged()
	typecheck.NotImplementedError()
end

function INSTANCE:NotifyNeighborsSound()
	typecheck.NotImplementedError()
end

function INSTANCE:NotifyNeighborsEnemy()
	typecheck.NotImplementedError()
end

function INSTANCE:Think()
	typecheck.NotImplementedError()
end

function INSTANCE:StateAct()
	typecheck.NotImplementedError()
end

function INSTANCE:StateActIdle()
	typecheck.NotImplementedError()
end

function INSTANCE:StateActFootstepsHeard()
	typecheck.NotImplementedError()
end

function INSTANCE:StateActBulletHeard()
	typecheck.NotImplementedError()
end

function INSTANCE:StateActGunshotHeard()
	typecheck.NotImplementedError()
end

function INSTANCE:StateActAttack()
	typecheck.NotImplementedError()
end

function INSTANCE:ActionReset()
	typecheck.NotImplementedError()
end

function INSTANCE:ActionFaceLocation()
	typecheck.NotImplementedError()
end

function INSTANCE:ActionGotoLocation()
	typecheck.NotImplementedError()
end

function INSTANCE:ActionGotoLocationFacing()
	typecheck.NotImplementedError()
end

function INSTANCE:ActionAttackObject()
	typecheck.NotImplementedError()
end

function INSTANCE:ActionDive()
	typecheck.NotImplementedError()
end

function INSTANCE:StayWithinHome()
	typecheck.NotImplementedError()
end

function INSTANCE:TakeCover()
	typecheck.NotImplementedError()
end

function INSTANCE:LookRandom()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseCoverPosition()
	typecheck.NotImplementedError()
end
