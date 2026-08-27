-- Based on ScriptableGameObj within Code/Combat/scriptablegameobj.cpp

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type BaseGameObjectClass
local baseGameObjectClass = CNC.Import( "code/combat/base-game-object.lua" )

-- Omitted AudioCallbackClass parent 

--- @class ScriptableGameObjectClass : BaseGameObjectClass
--- @field Instance ScriptableGameObjectInstance The metatable used by ScriptableGameObjectInstance
local STATIC = CNC.CreateExport( baseGameObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "ScriptableGameObjectClass"

--- @class ScriptableGameObjectInstance : BaseGameObjectInstance
--- @field Static ScriptableGameObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_ScriptableGameObject : Renegade_BaseGameObject" )
INSTANCE.Class = "ScriptableGameObjectInstance"
INSTANCE.IsScriptableGameObject = true
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC


--#region Imports

    --- @type GameObjectCustomTimerClass
    local gameObjectCustomTimerClass = CNC.Import( "code/combat/game-object-custom-timer.lua" )

    --- @type GameObjectObserverTimerClass
    local gameObjectObserverTimerClass = CNC.Import( "code/combat/game-object-observer-timer.lua" )

    --- @type NetworkObjectClass
    local networkObjectClass = CNC.Import( "code/wwnet/network-object.lua" )

    --- @type ScriptManagerClass
    local scriptManagerClass = CNC.Import( "code/combat/script-manager.lua" )

    --- @type CombatManagerClass
    local combatManagerClass = CNC.Import( "code/combat/combat-manager.lua" )

    --- @type EnumBuilderClass
    local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )
--#endregion


--#region Imported Enums
--#endregion


--[[ Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
        CHUNKID_PARENT         = enumBuilder:Set( 627001122 ),
        CHUNKID_VARIABLES      = enumBuilder:Next(),
        CHUNKID_REFERENCEABLE  = enumBuilder:Next(),
        CHUNKID_CUSTOM_TIMER   = enumBuilder:Next(),
        CHUNKID_OBSERVER_TIMER = enumBuilder:Next(),

        MICROCHUNKID_REFERENCEABLE_PTR        = enumBuilder:Set( 1 ),
        MICROCHUNKID_GAME_OBJ_OBSERVER_PTR    = enumBuilder:Next(),
        MICROCHUNKID_OBSERVER_CREATED_PENDING = enumBuilder:Next(),
    }
end


--[[ Static Functions and Variables ]] do

    --- @class ScriptableGameObjectClass

    --- Creates a new ScriptableGameObjectInstance
    --- @return ScriptableGameObjectInstance
    function STATIC.New()
        return robustclass.New( "Renegade_ScriptableGameObject" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) ScriptableGameObjectInstance, `false` otherwise
    function STATIC.IsScriptableGameObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsScriptableGameObject and true or false
    end

    typecheck.RegisterType( "ScriptableGameObjectInstance", STATIC.IsScriptableGameObject )
end


--- @class ScriptableGameObjectInstance
--- @field ObserverCreatedPending boolean
--- @field Observers GameObjectObserverInstance[]
--- @field ObserverTimerList GameObjectObserverTimerInstance[]
--- @field CustomTimerList GameObjectCustomTimerInstance[]


--[[ Constructor and Destructor ]] do

    --- Constructs a new ScriptableGameObjectInstance
    function INSTANCE:Renegade_ScriptableGameObject()
        baseGameObjectClass.Instance.Renegade_BaseGameObject( self )

        self.Observers = {}
        self.ObserverTimerList = {}
        self.CustomTimerList = {}

        -- Omitted ReferenceableGameObjectInstance constructor
        self.ObserverCreatedPending = false
    end

    function INSTANCE:_Renegade_ScriptableGameObject()
        INSTANCE.RemoveAllObservers( self )

        -- "Delete the ObservertimerLIst"
        self.ObserverTimerList = {}

        -- "Delete the CustomTimerList"
        self.CustomTimerList = {}
    end
end


--[[ Definitions ]] do

    --- @param definition ScriptableGameObjectDefinitionInstance
    --- @param connectedEntity Entity
    function INSTANCE:Init( definition, connectedEntity )
        baseGameObjectClass.Instance.Init( self, definition, connectedEntity )

        INSTANCE.CopySettings( self, definition )
    end

    --- @param definition ScriptableGameObjectDefinitionInstance
    function INSTANCE:CopySettings( definition )
        -- "Only assign scripts on the server"
        if combatManagerClass.IAmServer() then
            -- "Attach the scripts"
            for index, scriptName in ipairs( definition.ScriptNameList ) do
                local script  = scriptManagerClass.CreateScript( scriptName )
                if script then
                    script:SetParametersString( definition.ScriptParameterList[index] )

                    -- "Don't call Add observer, because we don't want Created called yet."
                    -- "StartObservers should be called later, which will call Created"
                    INSTANCE.InsertObserver( self, script )
                end
            end
        end
    end

    --- @param definition ScriptableGameObjectDefinitionInstance
    function INSTANCE:ReInit( definition )
        -- "Remove all currently running scripts"
        INSTANCE.RemoveAllObservers( self )

        -- "Copy any internal settings from the definition"
        INSTANCE.CopySettings( self, definition )

        -- "Reset our definition pointer"
        baseGameObjectClass.Instance.Init( self, definition, INSTANCE.GetConnectedEntity( self ) )
    end

    function INSTANCE:PostReInit()
        -- "Start the new scripts executing"
        INSTANCE.StartObservers( self )
    end

    --- @return ScriptableGameObjectDefinitionInstance
    function INSTANCE:GetDefinition()
        return baseGameObjectClass.Instance.GetDefinition( self ) --[[@as ScriptableGameObjectDefinitionInstance]]
    end

    function INSTANCE:SetDeletePending()
        if not INSTANCE.IsDeletePending( self ) then
            if combatManagerClass.AreObserversActive() then
                local observerList = INSTANCE.GetObservers( self )
                for _, observer in ipairs( observerList ) do
                    observer:Destroyed( self )
                end
            end

            if self == combatManagerClass.GetTheStar() then
                combatManagerClass.StarKilled()
            end

            baseGameObjectClass.Instance.SetDeletePending( self )
        end
    end
end


--[[ Save / Load ]] do

    --- @param csave ChunkSaveInstance
    --- @return boolean
    function INSTANCE:Save( csave )
        typecheck.NotImplementedError()
    end

    --- @param cload ChunkLoadInstance
    --- @return boolean
    function INSTANCE:Load( cload )
        typecheck.NotImplementedError()
    end

    function INSTANCE:OnPostLoad()
        baseGameObjectClass.Instance.OnPostLoad( self )

        -- "Delete any NULL pointers"
        local observerList = INSTANCE.GetObservers( self )
        for index = 1, observerList do
            if observerList[index] == nil then
                table.remove( observerList, index )
                index = index - 1
            end
        end
        self.Observers = observerList

        if combatManagerClass.IsFirstLoad() then
            self.ObserverCreatedPending = true
        end
    end
end


--[[ Thinking ]] do

    function INSTANCE:Think()
        if INSTANCE.IsAlwaysDirty( self ) then
            INSTANCE.SetObjectDirtyBit( self, networkObjectClass.DIRTY_BIT.BIT_FREQUENT, true )
        end

        if self.ObserverCreatedPending then
            INSTANCE.StartObservers( self )
            self.ObserverCreatedPending = false
        end

        baseGameObjectClass.Instance.Think( self )
    end

    function INSTANCE:PostThink()
        baseGameObjectClass.Instance.PostThink( self )

        -- "  
        -- Note: The cinematic script comes later in the obj list then the things it creates.  
        -- This means that objects the script creates when it thinks (via timers) don't think  
        -- (bump animation forward) until the next frame.  Be wary of changing this order.  
        -- "

        -- "Check Timers"
        for observerTimerIndex = #self.ObserverTimerList, 1, -1 do
            local observerTimer = self.ObserverTimerList[observerTimerIndex]

            -- When the timer expires
            if observerTimer:Update() then
                -- Let observers know 
                local observerList = INSTANCE.GetObservers( self )
                for observerIndex, observer in ipairs( observerList ) do
                    local observerTimer = self.ObserverTimerList[observerIndex]
                    if observer:getId() == observerTimer.ObserverId then
                        observer:TimerExpired( self, observerTimer.TimerId )
                    end
                end

                -- Omitted debug logging

                table.remove( self.ObserverTimerList, observerTimerIndex )
            end
        end

        for customTimerIndex = #self.CustomTimerList, 1, -1 do
            local customTimer = self.CustomTimerList[customTimerIndex]

            -- When the timer expires
            if customTimer:Update() then
                local sender = customTimer.Sender

                -- Fire the custom timer's event
                local observerList = INSTANCE.GetObservers( self )
                for _, observer in ipairs( observerList ) do
                    observer:Custom( self, customTimer.Type, customTimer.Param, sender )
                end

                table.remove( self.CustomTimerList, customTimerIndex )
            end
        end
    end
end


--- @return Vector
function INSTANCE:GetPosition()
    typecheck.NotImplementedError()
end


--[[ Observers ]] do

    --- @param observer GameObjectObserverInstance
    function INSTANCE:AddObserver( observer )
        INSTANCE.InsertObserver( self, observer )

        -- "Don't call created if in the editor"
        if combatManagerClass.AreObserversActive() then
            observer:Created( self )
        end
    end

    --- @param observer GameObjectObserverInstance
    function INSTANCE:RemoveObserver( observer )
        table.RemoveByValue( self.Observers, observer )
        observer:Detach( self )
        -- "If observer is a script, [it] will be deleted soon after this"
    end

    function INSTANCE:RemoveAllObservers()
        while #self.Observers ~= 0 do
            INSTANCE.RemoveObserver( self, self.Observers[1] )
        end
    end

    --- "
    --- [StartObservers] will call created on all observers.  
    --- Should be used in [OnPostLoad] (if first load), and after spawning / creating.  
    --- Observers added in other cases will already have Created called
    --- "
    function INSTANCE:StartObservers()
        -- "If we just came from the editor, call created on all [our] observers"
        local observerList = INSTANCE.GetObservers( self )
        for index, observer in ipairs( observerList ) do
            observer:Created( self )
        end
    end

    --- @return GameObjectObserverInstance[]
    function INSTANCE:GetObservers()
        return self.Observers
    end

    --- "This just adds to the list and calls attached, does not call Created"
    --- @param observer GameObjectObserverInstance
    function INSTANCE:InsertObserver( observer )
        observer:Attach( self )
        self.Observers[#self.Observers + 1] = observer
    end
end


--[[ Timers ]] do

    --- @param observerId integer
    --- @param duration number
    --- @param timerId integer
    function INSTANCE:StartObserverTimer( observerId, duration, timerId )
        self.ObserverTimerList[#self.ObserverTimerList + 1] = gameObjectObserverTimerClass.New(
            observerId,
            duration,
            timerId
        )
    end

    --- @param from ScriptableGameObjectInstance
    --- @param delay number
    --- @param type integer
    --- @param param integer
    function INSTANCE:StartCustomTimer( from, delay, type, param )
        self.CustomTimerList[#self.CustomTimerList+1] = gameObjectCustomTimerClass.New(
            from, delay, type, param
        )
    end
end


--[[ Type Identification ]] do

    --- @return ScriptableGameObjectInstance?
    function INSTANCE:AsScriptableGameObject()
        return self
    end

    --- @return DamageableGameObjectInstance?
    function INSTANCE:AsDamageableGameObject()
        return nil
    end

    --- @return BuildingGameObjectInstance?
    function INSTANCE:AsBuildingGameObject()
        return nil
    end

    --- @return SoldierGameObjectInstance?
    function INSTANCE:AsSoldierGameObject()
        return nil
    end

    --- @return ScriptZoneGameObjectInstance?
    function INSTANCE:AsScriptZoneGameObject()
        return nil
    end

    -- Omitted ReferenceableGameObject
end


--- @param string string
function INSTANCE:GetInformation( string )
    typecheck.NotImplementedError()
end

--- "From [AudioCallbackInstance]"
--- @param soundObject SoundSceneObjectInstance
function INSTANCE:OnSoundEnded( soundObject )
    typecheck.NotImplementedError()
end


--[[ Network Support ]] do

    --- @return boolean
    function INSTANCE:IsAlwaysDirty()
        return true
    end


    --- @param packet string
    function INSTANCE:ExportCreation( packet )
        baseGameObjectClass.Instance.ExportCreation( self, packet )
    end

    --- @param packet string
    function INSTANCE:ImportCreation( packet )
        baseGameObjectClass.Instance.ImportCreation( self, packet )

        -- "Ensure we don't have any scripts running"
        INSTANCE.RemoveAllObservers( self )
    end
end
