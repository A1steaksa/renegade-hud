-- Based on CombatManager within Code/Combat/combat.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- The static components of CombatManager
--- @class CombatManagerClass
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "CombatManagerClass"

--#region Exported Enums

    --- @enum CombatMode
    STATIC.COMBAT_MODE = {
        NONE            = 0,
        FIRST_PERSON    = 1,
        THIRD_PERSON    = 2,
        SNIPING         = 3,
        IN_VEHICLE      = 4,
        ON_LADDER       = 5,
        DYING           = 6,
        CORPSE          = 7,
        SNAPSHOT        = 8
    }
    local combatModeEnum = STATIC.COMBAT_MODE
--#endregion

-- #region Imports

	--- @type CombatManagerClass
	local combatManagerClass = CNC.Import( "code/combat/combat-manager.lua" )

	--- @type ObjectiveManagerClass
	local objectiveManagerClass = CNC.Import( "code/combat/objective-manager.lua" )

	--- @type SaveGameManagerClass
	local saveGameManagerClass = CNC.Import( "code/combat/save-game.lua" )

	--- @type DefinitionManagerClass
	local definitionManagerClass = CNC.Import( "code/wwsaveload/definition-manager.lua" )

	--- @type HudClass
	local hudClass = CNC.Import( "code/combat/hud.lua" )

	--- @type CommandoCameraClass
	local commandoCameraClass = CNC.Import( "code/combat/commando-camera.lua" )

	--- @type DamageLib
	local damageLib = CNC.Import( "sh_damage.lua" )

	--- @type GameObjectManagerClass
	local gameObjectManagerClass = CNC.Import( "code/combat/game-object-manager.lua" )

	--- @type GameTypeClass
	local gameTypeClass = CNC.Import( "code/combat/game-type.lua" )

	--- @type GameObjectObserverManagerClass
	local gameObjectObserverManagerClass = CNC.Import( "code/combat/game-object-observer-manager.lua" )

	--- @type SmartGameObjectClass
	local smartGameObjectClass = CNC.Import( "code/combat/smart-game-object.lua" )

	--- @type HudInfoClass
	local hudInfoClass = CNC.Import( "code/combat/hud-info.lua" )

	--- @type AssetDependencyManagerClass
	local assetDependencyManagerClass = CNC.Import( "code/combat/asset-dependency-manager.lua" )

	--- @type UnitCoordinationZoneManagerClass
	local unitCoordinationZoneManagerClass = CNC.Import( "code/combat/unit-coordination-zone-manager.lua" )
-- #endregion


--#region Imported Enums

	local damageDirectionEnum = damageLib.DAMAGE_DIRECTION
--#endregion


--[[ Static Functions and Variables ]] do

    --- [[ Public ]]

    --- @class CombatManagerClass
    --- @field GameScene GameSceneInstance
    --- @field private _IAmServer boolean
    --- @field private _IAmClient boolean
    --- @field private MyId integer
    --- @field private SyncTime integer
    --- @field private _IsGamePaused boolean
    --- @field private IsLevelInitialized boolean
    --- @field private _IsFriendlyFirePermitted boolean
    --- @field private BeaconPlacementEndsGame boolean
    --- @field private MainCamera CommandoCameraInstance
    --- @field private BackgroundScene unknown
    --- @field private SoundEnvironment unknown
    --- @field private DazzleLayer unknown
    --- @field private MessageWindow MessageWindowInstance
    --- @field private TheStar Entity
    --- @field private _IsStarDeterminingTarget boolean
    --- @field private _IsFirstLoad boolean
    --- @field private _AreObserversActive boolean
    --- @field private DifficultyLevel integer
    --- @field private AutoTransitions boolean
    --- @field private StarDamageDirection integer
    --- @field private StarKillerId integer
    --- @field private NetworkHandler unknown
    --- @field private MiscHandler unknown
    --- @field private StartScript string
    --- @field private RespawnScript string
    --- @field private ReloadCount integer
    --- @field private _IsHitReticleEnabled boolean
    --- @field private _IsGameplayPermitted boolean
    --- @field private CombatMode CombatMode
    --- @field private _IsAutosaveRequested boolean
    --- @field private LastRoundTripPingMs number
    --- @field private AvgRoundTripPingMs number
    --- @field private LastLsdName string
    --- @field private LoadProgress integer
    --- @field private MultiplayRenderingAllowed boolean

    --[[ Default Values ]] do

        if not isHotload then
            STATIC.MainCamera = nil
            STATIC.BackgroundScene = nil
            STATIC.SoundEnvironment = nil
            STATIC.DazzleLayer = nil

            STATIC._IsStarDeterminingTarget = true
            STATIC._IAmServer = SERVER --false
            STATIC._IAmClient = CLIENT --false
            STATIC.MyId = 0
            STATIC.SyncTime = 0

            STATIC.NetworkHandler = nil
            STATIC.MiscHandler = nil
            STATIC.MessageWindow = nil

            STATIC.DifficultyLevel = 1
            STATIC.AutoTransitions = true
            STATIC.StarDamageDirection = 0
            STATIC._AreObserversActive = true
            STATIC._IsFirstLoad = false
            STATIC.StarKillerId = 0
            STATIC._IsGamePaused = false
            STATIC.IsLevelInitialized = false

            STATIC.StartScript = nil
            STATIC.RespawnScript = nil

            STATIC._IsAutosaveRequested = false
            STATIC.LastRoundTripPingMs = 0
            STATIC.AvgRoundTripPingMs = 0
            STATIC._IsFriendlyFirePermitted = false
            STATIC.BeaconPlacementEndsGame = false
            STATIC._IsHitReticleEnabled = true
            STATIC._IsGameplayPermitted = false

            STATIC.CombatMode = combatModeEnum.NONE
            STATIC.ReloadCount = 0
            STATIC.LastLsdName = nil
            STATIC.LoadProgress = 0
            STATIC.MultiplayRenderingAllowed = true

            STATIC.GameScene = nil
        end
    end


    --- @param renderAvailable boolean
    function STATIC.Init( renderAvailable )
        STATIC._IsGameplayPermitted = false

        -- conversationManagerClass.Initialize()

        -- STATIC.MessageWindow = messageWindowClass.New()
        -- STATIC.MessageWindow:Initialize()

        -- scriptManagerClass.Init()

        -- bonesManagerClass.Init()

        commandoCameraClass.Init()

        -- surfaceEffectsManagerClass.Init()

        -- objectiveManagerClass.Init()

        -- combatSoundManagerClass.Init()

        -- "Create THE camera"
        STATIC.MainCamera = commandoCameraClass.New()

        -- "Create the Dazzle Layer"
        if renderAvailable then
            -- STATIC.DazzleLayer = dazzleLayerClass.New()
            -- dazzleLayerClass.SetCurrentDazzleLayer( STATIC.DazzleLayer )
        else
            -- dazzleLayerClass.SetCurrentDazzleLayer( nil )
        end

        -- "Pass the main camera onto the 3D audio library as the listener's position"
        -- local soundScene = wWAudioClass.GetInstance():GetSoundScene()
        -- if soundScene then
        --     soundScene:AttachListenerToEntity( STATIC.MainCamera )
        -- end

        hudClass.Init( renderAvailable )
        -- screenFadeManagerClass.Init()

        hook.Add( "Think", "A1_Renegade_CombatManager_Think", STATIC.Think )
    end

    function STATIC.Shutdown()
        typecheck.NotImplementedError( "Shutdown" )
    end

    function STATIC.SceneInit()
        typecheck.NotImplementedError()
    end

    --[[ Level Loading ]] do

        --- @param renderAvailable boolean? [Default: true]
        function STATIC.PreLoadLevel( renderAvailable )
            renderAvailable = ( ( renderAvailable ~= nil ) and renderAvailable or true )
            STATIC.MultiplayRenderingAllowed = true
            if not gameTypeClass.IsMission() and not STATIC.IAmServer() then
                STATIC.MultiplayRenderingAllowed = false
            end

            hudClass.Enable( true )
            hudClass.Reset()

            STATIC.IsGamePaused = false

            gameObjectObserverManagerClass.Reset()

            -- coverManagerClass.Init()

            gameObjectManagerClass.Init()

            -- bulletManagerClass.Init()

            -- encoderListClass.ClearEntries()

            -- packetClass.InitEncoder()

            -- STATIC.BackgroundScene = simpleSceneClass.New()

            -- STATIC.SoundEnvironment = soundEnvironmentclass.New()

            -- backgroundManagerClass.Init( STATIC.BackgroundScene, STATIC.SoundEnvironment, renderAvailable )

            -- weatherManagerClass.Init( STATIC.SoundEnvironment )

            -- weaponViewClass.Init()

            -- smartGameObjectClass.SetGlobalSightRangeScale( 1.0 )

            -- screenFadeManagerClass.EnableLetterbox( 0, 0)
            -- screenFadeManagerclass.SetScreenOverlayOpacity( 0, 0 )

            -- "Clear text"
            hudInfoClass.SetHudHelpText( "" )
        end

        --- AKA "ThreadFunction" or "Thread_Function" from Code/Combat/combat.cpp
        --- @param mapName string
        --- @param preloadAssets boolean
        function STATIC.LoadLevelThreaded( mapName, preloadAssets )
            STATIC.IsLevelInitialized = false
            -- wWAudioClass:GetInstance():EnableNewSounds( false )

            -- Because we don't have threads, I'm directly placing the contents of `LoadThreadClass:Thread_Function()` below

            STATIC.SetLoadProgress( 0 )

            -- Omitted setting the Data Safe's thread preference

            STATIC.IncrementLoadProgress()

            -- "Reload the definition databases (to support level-specific temp ddb's)"
            section.Start( "Free definition databases" )
            definitionManagerClass.FreeDefinitions()
            section.End()

            section.Start( "Load definition databases" )
            saveGameManagerClass.LoadDefinitions()
            section.End()

            STATIC.IncrementLoadProgress()
            -- "
            -- Make sure the animated-sound system is setup.  This needs
            -- to be done after the definition databases are loaded...
            -- "
            -- animatedSoundManagerClass.Initialize()

            -- "Prep the level loading"
            section.Start( "Pre Load level" )
            -- playerInfoLogClass.SetCurrentMapName( mapName )
            local fileNameToLoad, lsdFileName = saveGameManagerClass.PreLoadGame( mapName )
            STATIC.SetLastLsdName( lsdFileName )
            section.End()

            STATIC.IncrementLoadProgress()

            -- "Preload the assets"
            if preloadAssets then
                section.Start( "Preload assets" )
                section.Start( "Always assets" )
                assetDependencyManagerClass.LoadAlwaysAssets()
                section.End()

                STATIC.IncrementLoadProgress()

                section.Start( "Level assets" )
                assetDependencyManagerClass.LoadLevelAssets( lsdFileName )
                section.End()
                section.End()
            else
                STATIC.IncrementLoadProgress()
            end

            STATIC.IncrementLoadProgress()

            -- "Now load the level"
            saveGameManagerClass.LoadGame( fileNameToLoad )

            STATIC.IncrementLoadProgress()
        end

        --- @return boolean
        function STATIC.IsLoadLevelComplete()
            typecheck.NotImplementedError( "IsLoadLevelComplete" )
        end

        --- @return boolean
        function STATIC.IsLoadingLevel()
            typecheck.NotImplementedError()
        end

        function STATIC.PostLoadLevel()
            STATIC.CombatMode = combatModeEnum.NONE
            -- Omitted flushing input
            STATIC._IsHitReticleEnabled = true -- "Default for on when you start each level"

            STATIC.ClearStarDamageDirection()

            -- "Build network wrappers for every static anim object in the level"
            -- staticNetworkObjectClass.GenerateStaticNetworkObjects()

            if STATIC.IsLevelInitialized == false and STATIC.TheStar ~= nil then
                STATIC.IsLevelInitialized = true

                -- "Turn music and sound effects back on"
                -- wWAudioClass.GetInstance():EnableNewSounds( true )
            end

            -- "Generate the unit coordination zones"
            -- unitCoordinationZoneManagerClass.BuildZones()
        end

        function STATIC.UnloadLevel()
            typecheck.NotImplementedError( "UnloadLevel" )
        end
    end

    --[[ Main Loop ]] do

        function STATIC.GenerateControl()
            typecheck.NotImplementedError( "GenerateControl" )
        end

        function STATIC.Think()
            local frameTime = FrameTime()
            STATIC.SyncTime = STATIC.SyncTime + math.floor( frameTime * 1000 + 0.5 )

            -- This should be a call to the network handler, but I don't think there's ever
            -- a time in the lifecycle for a Garry's Mod Addon where "gameplay" isn't permitted.
            -- I may be wrong in that.
            STATIC._IsGameplayPermitted = true

            -- STATIC.HandleInput()

            -- bulletManagerClass.Update()

            objectiveManagerClass.Update( frameTime )

            -- "Now, process all objects logically"
            -- conversationManagerClass.Think()

            gameObjectManagerClass.Think()

            -- "Now, process all objects physically"
            -- combatManagerClass.GetScene():Update( frameTime, 0 )

            -- STATIC.UpdateStar()

            -- "  
            -- In normal mode, the camera must think before [PostThink], sunce the camera update
            -- calls [SetTarget] on the star, which must feed [UpdateAnimation]  
            -- "
            local mainCamera = STATIC.MainCamera
            if not mainCamera:IsUsingHostModel() then
                if CLIENT then
                     -- This if statement added because I don't yet understand what keeps the dedicated server from rendering frames
                    mainCamera:Update()
                end
            end

            -- "Now, Post Process all objects logically"
            gameObjectManagerClass.PostThink()

            -- "  
            -- In [HostModel] mode, the camera must think after [PostThink],
            -- so the host model has a chance to determine where the camera should be  
            -- "
            if mainCamera:IsUsingHostModel() then
                if CLIENT then
                     -- This if statement added because I don't yet understand what keeps the dedicated server from rendering frames
                    mainCamera:Update()
                end
            end

            -- "The targeting comes from the update weapons in the [PostThink]"
            -- STATIC.UpdateStarTargeting()

            -- STATIC.MessageWindow:OnFrameUpdate()

            -- spawnManagerClass.Update()

            if STATIC.SoundEnvironment then
                -- STATIC.SoundEnvironment:Update( combatScene, mainCamera )
            end

            -- backgroundManagerClass.Update( combatScene, mainCamera )

            -- weatherManagerClass.Update( combatScene, mainCamera )

            hudClass.Think()
            -- weaponViewClass.Think()
            -- screenFadeManagerClass.Think()
        end

        function STATIC.Render()
            if combatManagerClass.GetTheStar() then
                STATIC.MultiplayRenderingAllowed = true
            end

            if STATIC.MultiplayRenderingAllowed then
                -- Omitted system info log record frame

                -- combatManagerClass.GetScene():ApplyCameraShakes( STATIC.MainCamera )

                -- dazzleRenderObjClass.InstallDazzleVisibilityHandler( STATIC._TheCombatDazzleHandler )

                -- wW3dClass.Render( STATIC.BackgroundScene, STATIC.MainCamera )

                -- wW3dClass.Render( combatManagerClass.GetScene(), STATIC.MainCamera )

                -- local dazzleLayer = combatManagerClass.GetDazzleLayer()
                -- if dazzleLayer then
                --     dazzleLayer:Render( combatManagerClass.GetCamera() )
                -- end

                -- dazzleRenderObjClass.InstallDazzleVisibilityHandler( nil )

                hudClass.Render()

                -- screenFadeManager.Render()
            end
        end

        function STATIC.HandleInput()
            typecheck.NotImplementedError( "HandleInput" )
        end
    end

    --[[ Save/Load ]] do

        --- @param save unknown
        function STATIC.Save( save )
            typecheck.NotImplementedError( "Save" )
        end

        --- @param load unknown
        function STATIC.Load( load )
            typecheck.NotImplementedError( "Load" )
        end
    end

    --[[ Client/Server Settings ]] do

        --- @param isServer boolean
        function STATIC.SetIAmServer( isServer )
            STATIC._IAmServer = isServer
        end

        --- @param isClient boolean
        function STATIC.SetIAmClient( isClient )
            STATIC._IAmClient = isClient
        end

        --- @return boolean
        function STATIC.IAmServer()
            return STATIC._IAmServer
        end

        --- @return boolean
        function STATIC.IAmClient()
            return STATIC._IAmClient
        end

        --- @return boolean
        function STATIC.IAmOnlyClient()
            return STATIC._IAmClient and not STATIC._IAmServer
        end

        --- @return boolean
        function STATIC.IAmOnlyServer()
            return STATIC._IAmServer and not STATIC._IAmClient
        end

        --- @return boolean
        function STATIC.IAmClientServer()
            return STATIC._IAmServer and STATIC._IAmClient
        end

        function STATIC.SetFriendlyFirePermitted( isPermitted )
            STATIC._IsFriendlyFirePermitted = isPermitted
        end

        --- @return boolean
        function STATIC.IsFriendlyFirePermitted()
            return STATIC._IsFriendlyFirePermitted
        end

        --- Sets whether or not detonating a Nuclear Strike or Ion Cannon Beacon on the pedestal in the
        --- Hand of Nod or Barracks immediately ends the game.
        --- @param doesEndGame boolean
        function STATIC.SetBeaconPlacementEndsGame( doesEndGame )
            STATIC.BeaconPlacementEndsGame = doesEndGame
        end

        --- @return boolean `true` if Nuclear Strike or Ion Cannon Beacon on a pedestal will end the game, `false` otherwise
        function STATIC.DoesBeaconPlacementEndGame()
            return STATIC.BeaconPlacementEndsGame
        end

        --- @param id integer
        function STATIC.SetMyId( id )
            STATIC.MyId = id
        end

        ---@return integer
        function STATIC.GetMyId()
            return STATIC.MyId
        end
    end

    --[[ Latency Support ]] do

        ---@param ping number
        function STATIC.SetLastRoundTripPingMs( ping )
            STATIC.LastRoundTripPingMs = ping
        end

        --- @return number
        function STATIC.GetLastRoundTripPingMs()
            return STATIC.LastRoundTripPingMs
        end

        ---@param ping number
        function STATIC.SetAvgRoundTripPingMs( ping )
            STATIC.AvgRoundTripPingMs = ping
        end

        --- @return number
        function STATIC.GetAvgRoundTripPingMs()
            return STATIC.AvgRoundTripPingMs
        end
    end

    --[[ Network Handler Functions ]] do

        ---@param handler unknown
        function STATIC.SetCombatNetworkHandler( handler )
            typecheck.NotImplementedError( "SetCombatNetworkHandler" )
        end

        ---@param damager ArmedGameObjectInstance
        ---@param victim PhysicalGameObjectInstance
        function STATIC.CanDamage( damager, victim )
            typecheck.NotImplementedError( "CanDamage" )
        end

        ---@param damager ArmedGameObjectInstance
        ---@param victim PhysicalGameObjectInstance
        function STATIC.GetDamageFactor( damager, victim)
            typecheck.NotImplementedError( "GetDamageFactor" )
        end

        ---@param soldier SoldierGameObjectInstance
        ---@param victim SoldierGameObjectInstance
        function STATIC.OnSoldierKill( soldier, victim )
            typecheck.NotImplementedError( "OnSoldierKill" )
        end

        ---@param soldier SoldierGameObjectInstance
        function STATIC.OnSoldierDeath( soldier )
            typecheck.NotImplementedError( "OnSoldierDeath" )
        end

        ---@return boolean
        function STATIC.IsGameplayPermitted()
            if not STATIC.NetworkHandler then
                return true
            end

            return STATIC._IsGameplayPermitted
        end

    end

    --[[ Misc Handler ]] do

        --- @param handler unknown
        function STATIC.SetCombatMiscHandler( handler )
            STATIC.MiscHandler = handler
        end

        --- @param wasSuccess boolean
        function STATIC.MissionComplete( wasSuccess )
            typecheck.NotImplementedError( "MissionComplete" )
        end

        function STATIC.StarKilled()
            typecheck.NotImplementedError( "StarKilled" )
        end
    end

    --[[ The Star ]] do

        --- @param target Entity
        --- @param isStarDeterminingTarget boolean? [Default: true] 
        function STATIC.SetTheStar( target, isStarDeterminingTarget )
            if not isStarDeterminingTarget then
                isStarDeterminingTarget = true
            end

            -- Clear the HUD if we just changed stars
            if STATIC.TheStar ~= target then
                hudClass.Reset()
            end

            STATIC.TheStar = target
            STATIC._IsStarDeterminingTarget = isStarDeterminingTarget
            if IsValid( target ) then
                -- TODO: Point the camera toward the new star's direction
            end

            hudClass.ForceWeaponChartUpdate()
            -- Omitted weapon view class resetting

            if not STATIC.IsLevelInitialized then
                STATIC.IsLevelInitialized = true

                -- Omitted re-enabling sound and music
            end
        end

        --- @return Entity
        function STATIC.GetTheStar()
            if CLIENT then return LocalPlayer() end

            return STATIC.TheStar
        end

        function STATIC.UpdateStar()
            local star = STATIC.GetTheStar()

            if not IsValid( star ) then
                return
            end

            typecheck.NotImplementedError( "UpdateStar" )
        end

        function STATIC.UpdateStarTargeting()
            typecheck.NotImplementedError( "UpdateStarTargeting" )
        end

        --- @param isStarTargeting boolean
        function STATIC.SetIsStarDeterminingTarget( isStarTargeting )
            STATIC._IsStarDeterminingTarget = isStarTargeting
        end

        --- @return boolean
        function STATIC.IsStarDeterminingTarget()
            return STATIC._IsStarDeterminingTarget
        end
    end

    --[[ The Scene ]] do

        --- @return PhysicsSceneInstance
        function STATIC.GetScene()
            return physicsSceneClass:GetInstance()
        end

        --- @return unknown
        function STATIC.GetBackgroundScene()
            return STATIC.BackgroundScene
        end

        --- @return CommandoCameraInstance
        function STATIC.GetCamera()
            return STATIC.MainCamera
        end

        ---@return unknown
        function STATIC.GetSoundEnvironment()
            return STATIC.SoundEnvironment
        end

        --- @param profileName string
        function STATIC.SetCameraProfile( profileName )
            typecheck.NotImplementedError( "SetCameraProfile" )
        end

        ---@param vehicle Entity
        ---@param seat integer? [Default: 0]
        function STATIC.SetCameraVehicle( vehicle, seat )
            if not seat then
                seat = 0
            end

            typecheck.NotImplementedError( "SetCameraVehicle" )
        end

        --- @param pos Vector
        --- @return boolean
        function STATIC.IsInCameraFrustum( pos )
            typecheck.NotImplementedError( "IsInCameraFrustum" )
        end

        --- @param areActive boolean
        function STATIC.SetAreObserversActive( areActive )
            STATIC._AreObserversActive = areActive
        end

        --- @return boolean
        function STATIC.AreObserversActive()
            return STATIC._AreObserversActive
        end

        --- @param isFirstLoad boolean
        function STATIC.SetFirstLoad( isFirstLoad )
            STATIC._IsFirstLoad = isFirstLoad
        end

        --- @return boolean
        function STATIC.IsFirstLoad()
            return STATIC._IsFirstLoad
        end

        --- @return boolean
        function STATIC.GetDazzleLayer()
            return STATIC.DazzleLayer
        end
    end

    --[[ First Person ]] do

        --- @return boolean
        function STATIC.IsFirstPerson()
            return not LocalPlayer():ShouldDrawLocalPlayer()
        end
    end

    --[[ Difficulty ]] do
        
        --- @param level integer
        function STATIC.SetDifficultyLevel( level )
            STATIC.DifficultyLevel = level
        end

        --- @return integer
        function STATIC.GetDifficultyLevel()
            return STATIC.DifficultyLevel
        end

        --- @return boolean
        function STATIC.AreTransitionsAutomatic()
            return STATIC.AutoTransitions
        end

        --- @param isAutomatic boolean
        function STATIC.SetTransitionsAutomatic( isAutomatic )
            STATIC.AutoTransitions = isAutomatic
        end
    end

    --[[ Message Window ]] do

        --- @return MessageWindowInstance
        function STATIC.GetMessageWindow()
            return STATIC.MessageWindow
        end
    end

    --[[ Damage Direction ]] do

        --- @param direction DamageDirection
        function STATIC.ShowStarDamageDirection( direction )
            if direction == damageDirectionEnum.ALL then
                STATIC.StarDamageDirection = 255 -- Decimal 255 is binary 1111 1111
                return
            end

            STATIC.StarDamageDirection = bit.bor( STATIC.StarDamageDirection, bit.lshift( 1, bit.band( direction, 7 ) ) )
        end

        --- @return integer
        function STATIC.GetStarDamageDirection()
            return STATIC.StarDamageDirection
        end

        function STATIC.ClearStarDamageDirection()
            STATIC.StarDamageDirection = 0
        end
    end

    --[[ Scripts ]] do

        --- @return string
        function STATIC.GetStartScript()
            return STATIC.StartScript
        end

        --- @return string
        function STATIC.GetRespawnScript()
            return STATIC.RespawnScript
        end

        --- @param script string
        function STATIC.SetStartScript( script )
            STATIC.StartScript = script
        end

        --- @param script string
        function STATIC.SetRespawnScript( script )
            STATIC.RespawnScript = script
        end
    end

    --[[ Autosave ]] do

        --- @param isAutosaveRequested boolean
        function STATIC.RequestAutosave( isAutosaveRequested )
            STATIC._IsAutosaveRequested = isAutosaveRequested
        end

        --- @return boolean
        function STATIC.IsAutosaveRequested()
            return STATIC._IsAutosaveRequested
        end
    end

    --[[ Hit Reticle ]] do

        --- @return boolean
        function STATIC.IsHitReticleEnabled()
            return STATIC._IsHitReticleEnabled
        end

        --- @param isHitReticleEnabled boolean
        function STATIC.SetIsHitReticleEnabled( isHitReticleEnabled )
            STATIC._IsHitReticleEnabled = isHitReticleEnabled
        end

        function STATIC.ToggleIsHitReticleEnabled()
            STATIC._IsHitReticleEnabled = not STATIC._IsHitReticleEnabled
        end
    end

    --[[ Last LSD ]] do

        --- @param name string
        function STATIC.SetLastLsdName( name )
            STATIC.LastLsdName = name
        end

        --- @return string
        function STATIC.GetLastLsdName()
            return STATIC.LastLsdName
        end
    end

    --[[ Load Progress ]] do

        --- @return integer
        function STATIC.GetLoadProgress()
            return STATIC.LoadProgress
        end

        function STATIC.IncrementLoadProgress()
            STATIC.LoadProgress = STATIC.LoadProgress + 1
        end

        --- @param progress integer
        function STATIC.SetLoadProgress( progress )
            STATIC.LoadProgress = progress
        end
    end

    --[[ Misc ]] do

        --- @return integer
        function STATIC.GetReloadCount()
            return STATIC.ReloadCount
        end

        --- @param killer Entity
        function STATIC.RegisterStarKiller( killer )
            typecheck.NotImplementedError( "RegisterStarKiller" )
        end

        --- @return integer
        function STATIC.GetSyncTime()
            return STATIC.SyncTime
        end

        --- @return boolean
        function STATIC.IsGamePaused()
            return STATIC._IsGamePaused
        end
    end

    --- @param mode CombatMode
    function STATIC.SetCombatMode( mode )
        typecheck.NotImplementedError( "SetCombatMode" )
    end

    function STATIC.UpdateCombatMode()
        typecheck.NotImplementedError( "UpdateCombatMode" )
    end
end