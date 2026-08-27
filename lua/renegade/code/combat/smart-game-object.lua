-- Based on SmartGameObj within Code/Combat/smartgameobj.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type ArmedGameObjectClass
local armedGameObjectClass = CNC.Import( "code/combat/armed-game-object.lua" )

--- @class SmartGameObjectClass : ArmedGameObjectClass
--- @field Instance SmartGameObjectInstance The metatable used by SmartGameObjectInstance
local STATIC = CNC.CreateExport( armedGameObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "SmartGameObjectClass"

--- @class SmartGameObjectInstance : ArmedGameObjectInstance
--- @field Static SmartGameObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_SmartGameObject : Renegade_ArmedGameObject" )
INSTANCE.Class = "SmartGameObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsSmartGameObject = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	--- @type ActionClass
	local actionClass = CNC.Import( "code/combat/action.lua" )

	--- @type GameObjectManagerClass
	local gameObjectManagerClass = CNC.Import( "code/combat/game-object-manager.lua" )

	--- @type BaseGameObjectClass
	local baseGameObjectClass = CNC.Import( "code/combat/base-game-object.lua" )

	--- @type Matrix3dClass
	local matrix3dClass = CNC.Import( "code/wwmath/matrix3d.lua" )

	--- @type CombatManagerClass
	local combatManagerClass = CNC.Import( "code/combat/combat-manager.lua" )

	--- @type ControlClass
	local controlClass = CNC.Import( "code/combat/control.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
        OLD_CHUNKID_PHYSICALGAMEOBJ_PARENT = enumBuilder:Set( 910991113 ),
        CHUNKID_VARIABLES                  = enumBuilder:Next(),
        CHUNKID_CONTROL                    = enumBuilder:Next(),
        CHUNKID_CONTROLLER                 = enumBuilder:Next(),
        CHUNKID_ACTION                     = enumBuilder:Next(),
        XXXCHUNKID_WEAPONBAG               = enumBuilder:Next(),
        CHUNKID_ARMEDGAMEOBJ_PARENT        = enumBuilder:Next(),
        XXXCHUNKID_PLAYER_DATA             = enumBuilder:Next(),
        CHUNKID_STEALTH_EFFECT             = enumBuilder:Next(),

        MICROCHUNKID_CONTROL_ENABLED    = enumBuilder:Set( 1 ),

        XXXMICROCHUNKID_WEAPON_TILT     = enumBuilder:Next(),
        XXXMICROCHUNKID_WEAPON_TURN     = enumBuilder:Next(),
        MICROCHUNKID_CONTROL_OWNER      = enumBuilder:Next(),
        XXX_MICROCHUNKID_IS_GHOST       = enumBuilder:Next(),
        MICROCHUNKID_IMPORT_STATE_COUNT = enumBuilder:Next(),
        MICROCHUNKID_TINT_COLOR         = enumBuilder:Next(),

        MICROCHUNKID_CONTROLLER_PTR        = enumBuilder:Next(),
        MICROCHUNKID_IS_ENEMY_SEEN_ENABLED = enumBuilder:Next(),
        XXXMICROCHUNKID_TARGETING_POS      = enumBuilder:Next(),
        MICROCHUNKID_MOVING_SOUND_TIMER    = enumBuilder:Next(),
        MICROCHUNKID_PLAYER_DATA           = enumBuilder:Next(),

        MICROCHUNKID_STEALTH_ENABLED       = enumBuilder:Next(),
        MICROCHUNKID_STEALTH_POWERUP_TIMER = enumBuilder:Next(),
        MICROCHUNKID_STEALTH_FIRING_TIMER  = enumBuilder:Next()
    }
end


--[[ Static Functions and Variables ]] do

    --- @class SmartGameObjectClass
    --- @field GlobalSightRangeScale number

    --- "Client who controls this object"
    STATIC.SERVER_CONTROL_OWNER = -99999

    --- Creates a new SmartGameObjectInstance
    --- @return SmartGameObjectInstance
    function STATIC.New()
        return robustclass.New( "Renegade_SmartGameObject" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) SmartGameObjectInstance, `false` otherwise
    function STATIC.IsSmartGameObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsSmartGameObject and true or false
    end

    typecheck.RegisterType( "SmartGameObjectInstance", STATIC.IsSmartGameObject )

    --- @return number
	function STATIC.GetGlobalSightRangeScale()
		return STATIC.GlobalSightRangeScale
	end

    --- @param scale number
	function STATIC.SetGlobalSightRangeScale( scale )
		STATIC.GlobalSightRangeScale = scale
	end
end


--- @class SmartGameObjectInstance
--- @field Control ControlInstance
--- @field Controller PhysicsControllerInstance "Controller for the physics object"
--- @field ControlEnabled boolean
--- @field StealthEnabled boolean "Stealth enabled by script or initialization code"
--- @field StealthPowerupTimer number "Stealth power is in effect"
--- @field StealthFiringTimer number "Timer for de-cloaking during"
--- @field StealthEffect StealthEffectInstance? "Possible stealth effect"
--- @field Action ActionInstance "For actions"
--- @field ControlOwner integer "Client who controls this object"
--- @field PlayerData PlayerDataInstance
--- @field IsEnemySeenEnabled boolean
--- @field MovingSoundTimer number
--- @field Listener LogicalListenerInstance

function INSTANCE:Renegade_SmartGameObject()
    armedGameObjectClass.Instance.Renegade_ArmedGameObject( self )

    self.Control = controlClass.New()

    self.Action = actionClass.New( self )
    self.ControlOwner = STATIC.SERVER_CONTROL_OWNER
    self.ControlEnabled = true
    self.IsEnemySeenEnabled = false
    self.MovingSoundTimer = 0
    self.PlayerData = nil
    self.StealthEnabled = false
    self.StealthPowerupTimer = 0.0
    self.StealthFiringTimer = 0.0
    self.StealthEffect = nil

    gameObjectManagerClass.AddSmart( self )

    -- Omitted setting up audio listener
    -- self.Listener = wWAudioClass.GetInstance():CreateLogicalListener()
    -- self.Listener:RegisterCallback( audioCallbackEventEnum.EVENT_LOGICAL_HEARD, self )
end

function INSTANCE:_Renegade_SmartGameObject()
	typecheck.NotImplementedError()
end


--[[ Definitions ]] do

    --- @param definition SmartGameObjectDefinitionInstance
    --- @param connectedEntity Entity
    function INSTANCE:Init( definition, connectedEntity )
        armedGameObjectClass.Instance.Init( self, definition, connectedEntity )
        INSTANCE.CopySettings( self, definition )
    end

    --- @param definition SmartGameObjectDefinitionInstance
    function INSTANCE:CopySettings( definition )

        local moveable = INSTANCE.PeekPhysicalObject( self ):AsMoveablePhysics()
        if moveable ~= nil then
            INSTANCE.PeekPhysicalObject( self ):AsMoveablePhysics():SetController( self.Controller )
        end
        INSTANCE.RegisterListener( self )

        if definition.IsStealthUnit then
            INSTANCE.EnableStealth( self, true )
        end
    end

    --- @param definition SmartGameObjectDefinitionInstance
    function INSTANCE:ReInit( definition )
        armedGameObjectClass.Instance.ReInit( self, definition )

        -- "Remove the listener from the scene"
        if self.Listener ~= nil then
            -- self.Listener:RemoveFromScene()
        end

        -- "Free the stealth effect as necessary"
        if self.StealthEffect ~= nil then
            self.StealthEffect = nil
            self.StealthEnabled = false
            self.StealthPowerupTimer = 0.0
            self.StealthFiringTimer = 0.0
        end

        -- "Copy any internal settings from the definition"
        self:CopySettings( definition )
    end

    --- @return SmartGameObjectDefinitionInstance
    function INSTANCE:GetDefinition()
        return baseGameObjectClass.Instance.GetDefinition( self ) --[[@as SmartGameObjectDefinitionInstance]]
    end
end


--[[ Save / Load ]] do

    function INSTANCE:Save()
        typecheck.NotImplementedError()
    end

    function INSTANCE:Load()
        typecheck.NotImplementedError()
    end

    function INSTANCE:OnPostLoad()
        typecheck.NotImplementedError()
    end
end


--[[ Commands ]] do

    function INSTANCE:ClearControl()
        self.Control:ClearControl()
    end

    --- @param control BooleanControl
    --- @param state boolean
    function INSTANCE:SetBooleanControl( control, state )
        if state == nil then state = true end

        self.Control:SetBoolean( control, state )
    end

    --- @param control AnalogControl
    --- @param value number
    function INSTANCE:SetAnalogControl( control, value )
        self.Control:SetAnalog( control, value )
    end

    --- @param packet BitStreamInstance
    function INSTANCE:ImportControlCs( packet )
        self.Control:ImportCs( packet )
    end

    --- @param packet BitStreamInstance
    function INSTANCE:ExportControlCs( packet )
        self.Control:ExportCs( packet )
    end

    --- @param packet BitStreamInstance
    function INSTANCE:ImportControlSc( packet )
        self.Control:ImportSc( packet )
    end

    --- @param packet BitStreamInstance
    function INSTANCE:ExportControlSc( packet )
        self.Control:ExportSc( packet )
    end

    function INSTANCE:GetControl()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ControlEnable()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsControlEnabled()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ResetController()
        typecheck.NotImplementedError()
    end

    function INSTANCE:GenerateControl()
        typecheck.NotImplementedError()
    end

    --- @return integer
    function INSTANCE:GetControlOwner()
        return self.ControlOwner
    end

    --- @return integer
    function INSTANCE:GetWeaponControlOwner()
        return INSTANCE.GetControlOwner( self )
    end

    --- @param controlOwner integer
    function INSTANCE:SetControlOwner( controlOwner )
        self.ControlOwner = controlOwner
    end
end


--- @return PlayerDataInstance
function INSTANCE:GetPlayerData()
    return self.PlayerData
end

function INSTANCE:SetPlayerData()
	typecheck.NotImplementedError()
end

function INSTANCE:HasPlayer()
	typecheck.NotImplementedError()
end

function INSTANCE:IsHumanControlled()
    -- "There is a human cPlayer object for this smart object"
    return self.ControlOwner >= 0
end

function INSTANCE:IsControlledByMe()
    if not combatManagerClass.IAmClient() then
        return false
    end

    local gameObject = self

    -- "If this is a vehicle, then passthru to the driver"
    local vehicle = self:AsVehicleGameObject()
    if vehicle ~= nil then
        local driver = vehicle:GetDriver()
        if driver ~= nil then
            gameObject = driver
        end
    end

    return gameObject:IsHumanControlled() and ( gameObject.ControlOwner == combatManagerClass.GetMyId() )
end

function INSTANCE:ApplyControl()
	typecheck.NotImplementedError()
end


--[[ Thinking ]] do

    function INSTANCE:Think()

        -- For testing purposes, move to my owning source entity if one exists
        if IsValid( self.ConnectedEntity ) then
            -- local matrix = self:GetTransform()
            -- matrix:SetTranslation( Vector( 0, 0, 0 ) )
            -- self:SetTransform( matrix )

            self:SetPosition( Vector( 0, 0, 0 ) )

            -- section.Print( self:GetPosition() )
            -- self:SetPosition( Vector( 0, 0, 0 ) )
        end

        -- Omitted almost all original function contents

        --[[ Embedded Armed think in smart think ]] do
            armedGameObjectClass.Instance.Think( self )
        end
    end

    function INSTANCE:PostThink()
        armedGameObjectClass.Instance.PostThink( self )

        -- "Don't update if destroying... (so we don't create a new laser!)"
        if self:IsDeletePending() then
            return
        end

        -- "Reset the one time booleans"
        self.Control:ClearOneTimeBoolean()
    end
end


--- @param damager OffenseObjectInstance
--- @param scale number? [Default: `1.0`]
--- @param alternateSkin integer [Default: `-1`]
function INSTANCE:ApplyDamage( damager, scale, alternateSkin )
	if scale == nil then scale = 1.0 end
    if alternateSkin == nil then alternateSkin = -1 end

    typecheck.NotImplementedError()
end

--[[ Object Motion ]] do

    --- @return number
    function INSTANCE:GetMaxSpeed()
        return 10
    end

    --- @return number
    function INSTANCE:GetTurnRate()
        return math.rad( 360 )
    end
end

--- @return ActionInstance
function INSTANCE:GetAction()
    return self.Action
end

--- @return SmartGameObjectInstance
function INSTANCE:AsSmartGameObject()
	return self
end

--[[ State Import/Export ]] do

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

    function INSTANCE:ExportCreation()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ImportCreation()
        typecheck.NotImplementedError()
    end
end

function INSTANCE:IsControlDataDirty()
	typecheck.NotImplementedError()
end

function INSTANCE:IsObjectVisible()
	typecheck.NotImplementedError()
end

--- @param enabled boolean
function INSTANCE:SetEnemySeenEnabled( enabled )
	self.IsEnemySeenEnabled = enabled
end

function INSTANCE:IsEnemySeenEnabled()
    return self.IsEnemySeenEnabled
end

--- @return Matrix3dInstance
function INSTANCE:GetLookTransform()
    return INSTANCE.GetTransform( self )
end

--- @return Vector
function INSTANCE:GetVelocity()
	return Vector( 0, 0, 0 )
end

--- @return boolean
function INSTANCE:IsVisible()
    return true
end

function INSTANCE:OnLogicalHeard()
	typecheck.NotImplementedError()
end

function INSTANCE:BeginHibernation()
	typecheck.NotImplementedError()
end

function INSTANCE:EndHibernation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetInformation()
	typecheck.NotImplementedError()
end


--[[ Stealth Interface ]] do

    --- "Turn this object's cloaking device on or off"
    --- @param onOff boolean
    function INSTANCE:EnableStealth( onOff )
        typecheck.NotImplementedError()
    end

    function INSTANCE:ToggleStealth()
        typecheck.NotImplementedError()
    end

    --- "Is this object's cloaking device turned on?  (May not be cloaked yet though)"
    --- @return boolean
    function INSTANCE:IsStealthEnabled()
        typecheck.NotImplementedError()
    end

    --- "Is this object actually stealthed (takes some time to turn on and off...)"
    --- @return boolean
    function INSTANCE:IsStealthed()
        typecheck.NotImplementedError()
    end

    --- "Humans and vehicles fade in at different distances"
    --- @return number
    function INSTANCE:GetStealthFadeDistance()
        return 25.0
    end

    --- @param seconds number
    function INSTANCE:GrantStealthPowerup( seconds )
        typecheck.NotImplementedError()
    end

    --- @return number
    function INSTANCE:RemainingStealthPowerupTime()
        typecheck.NotImplementedError()
    end

    --- @return StealthEffectInstance?
    function INSTANCE:PeekStealthEffect()
        typecheck.NotImplementedError()
    end
end

function INSTANCE:AllocateStealthEffect()
	typecheck.NotImplementedError()
end

function INSTANCE:RegisterListener()
	if self.Listener ~= nil then
        local definition = INSTANCE.GetDefinition( self )

    end
end
