-- Based on CombatManager within Code/Combat/combat.cpp/h

local STATIC
--[[ Class Setup ]] do

    --- The static components of CombatManager
    --- @class CombatManager
    STATIC = CNC_RENEGADE.CombatManager or {}
    CNC_RENEGADE.CombatManager = STATIC
end

--[[ Static Functions and Variables ]] do

    --- [[ Public ]]

    --- @class CombatManager
    --- @field GameScene unknown

    --- @enum CombatMode
    CNC_RENEGADE.CombatMode = {
        None        = 0,
        FirstPerson = 1,
        ThirdPerson = 2,
        Sniping     = 3,
        InVehicle   = 4,
        OnLadder    = 5,
        Dying       = 6,
        Corpse      = 7,
        SnapShot    = 8
    }

    --[[ Default Values ]] do
        STATIC.MainCamera = nil
        STATIC.BackgroundScene = nil
        STATIC.SoundEnvironment = nil
        STATIC.DazzleLayer = nil

        STATIC._IsStarDeterminingTarget = true
        STATIC._IAmServer = false
        STATIC._IAmClient = false
        STATIC.MyId = 0
        STATIC.SyncTime = 0

        STATIC.NetworkHandler = nil
        STATIC.MiscHandler = nil
        STATIC.MessageWindow = nil

        STATIC.DifficultyLevel = 1
        STATIC.AutoTransitions = true
        STATIC.StarDamageDirection = 0
        STATIC._AreObserversActive = true
        STATIC.FirstPerson = true
        STATIC.FirstPersonDefault = true
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

        STATIC.CombatMode = CNC_RENEGADE.CombatMode.None
        STATIC.ReloadCount = 0
        STATIC.LastLsdName = nil
        STATIC.LoadProgress = 0
        STATIC.MultiplayRenderingAllowed = true

        STATIC.GameScene = nil
    end

    --- @param renderAvailable boolean
    function STATIC.Init( renderAvailable )
        STATIC._IsGameplayPermitted = false

        -- CNC_RENEGADE.ConversationManager.Init()
        -- STATIC.MessageWindow = messageWindow.New()
        -- STATIC.MessageWindow:Init()
        -- CNC_RENEGADE.ScriptManager.Init()
        -- CNC_RENEGADE.BonesManager.Init()
        -- CNC_RENEGADE.CameraClass.Init()
        -- CNC_RENEGADE.SurfaceEffectsManager.Init()
        -- CNC_RENEGADE.ObjectiveManager.Init()
        -- CNC_RENEGADE.CombatSoundManager.Init()

        -- Create the game camera
        -- STATIC.MainCamera = camera.New()

        -- Create the Dazzle Layer
        if renderAvailable then
            -- STATIC.DazzleLayer = dazzleLayer.New()
            -- dazzleLayer.SetCurrentDazzleLayer( STATIC.DazzleLayer )
        else
            -- dazzleLayer.SetCurrentDazzleLayer( nil )
        end

        CNC_RENEGADE.StyleManager.Initialize()

        CNC_RENEGADE.Hud.Init( renderAvailable )
        -- CNC_RENEGADE.ScreenFadeManager.Init()

        STATIC.FirstPerson = STATIC.FirstPersonDefault
    end

    function STATIC.Shutdown()
        error( "Function not yet implemented" )
    end

    function STATIC.SceneInit()
        error( "Function not yet implemented" )
    end

    --[[ Level Loading ]] do

        --- @param renderAvailable boolean? [Default: true]
        function STATIC.PreLoadLevel( renderAvailable )
            if not renderAvailable then
                renderAvailable = true
            end

            error( "Function not yet implemented" )
        end

        --- @param mapName string
        ---@param preloadAssets boolean
        function STATIC.LoadLevelThreaded( mapName, preloadAssets )
            error( "Function not yet implemented" )
        end

        --- @return boolean
        function STATIC.IsLoadLevelComplete()
            error( "Function not yet implemented" )
        end

        --- @return boolean
        function STATIC.IsLoadingLevel()
            error( "Function not yet implemented" )
        end

        function STATIC.PostLoadLevel()
            error( "Function not yet implemented" )
        end

        function STATIC.UnloadLevel()
            error( "Function not yet implemented" )
        end
    end

    --[[ Main Loop ]] do
      
        function STATIC.GenerateControl()
            error( "Function not yet implemented" )
        end

        function STATIC.Think()

            -- Skipping over the vast majority of this funciton for now

            CNC_RENEGADE.Hud.Think()

        end
        hook.Add( "Think", "A1_Renegade_CombatManager_Think", STATIC.Think )

        function STATIC.Render()
            error( "Function not yet implemented" )
        end

        function STATIC.HandleInput()
            error( "Function not yet implemented" )
        end
    end

    --[[ Save/Load ]] do

        --- @param save unknown
        function STATIC.Save( save )
            error( "Function not yet implemented" )
        end

        --- @param load unknown
        function STATIC.Load( load )
            error( "Function not yet implemented" )
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
            error( "Function not yet implemented" )
        end

        ---@param damager Entity
        ---@param victim Entity
        function STATIC.CanDamage( damager, victim )
            error( "Function not yet implemented" )
        end

        ---@param damager Entity
        ---@param victim Entity
        function STATIC.GetDamageFactor( damager, victim)
            error( "Function not yet implemented" )
        end

        ---@param soldier Entity
        ---@param victim Entity
        function STATIC.OnSoldierKill( soldier, victim )
            error( "Function not yet implemented" )
        end

        ---@param soldier Entity
        function STATIC.OnSoldierDeath( soldier )
            error( "Function not yet implemented" )
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
            error( "Function not yet implemented" )
        end

        function STATIC.StarKilled()
            error( "Function not yet implemented" )
        end
    end

    --[[ The Star ]] do

        --- @param target Entity
        --- @param isStarDeterminingTarget boolean? [Default: true] 
        function STATIC.SetTheStar( target, isStarDeterminingTarget )
            if not isStarDeterminingTarget then
                isStarDeterminingTarget = true
            end

            error( "Function not yet implemented" )
        end

        --- @return Entity
        function STATIC.GetTheStar()
            return STATIC.TheStar
        end

        function STATIC.UpdateStar()
            error( "Function not yet implemented" )
        end

        function STATIC.UpdateStarTargeting()
            error( "Function not yet implemented" )
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

        function STATIC.GetScene()
            error( "Function not yet implemented" )
        end

        --- @return unknown
        function STATIC.GetBackgroundScene()
            return STATIC.BackgroundScene
        end

        --- @return unknown
        function STATIC.GetCamera()
            return STATIC.MainCamera
        end

        ---@return unknown
        function STATIC.GetSoundEnvironment()
            return STATIC.SoundEnvironment
        end

        --- @param profileName string
        function STATIC.SetCameraProfile( profileName )
            error( "Function not yet implemented" )
        end

        ---@param vehicle Entity
        ---@param seat integer? [Default: 0]
        function STATIC.SetCameraVehicle( vehicle, seat )
            if not seat then
                seat = 0
            end

            error( "Function not yet implemented" )
        end

        --- @param pos Vector
        --- @return boolean
        function STATIC.IsInCameraFrustum( pos )
            error( "Function not yet implemented" )
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

        --- @param isFirstPerson boolean
        function STATIC.SetFirstPerson( isFirstPerson )
            STATIC.FirstPerson = isFirstPerson
        end

        --- @return boolean
        function STATIC.IsFirstPerson()
            return STATIC.FirstPerson
        end

        --- @param isFirstPersonDefault boolean
        function STATIC.SetFirstPersonDefault( isFirstPersonDefault )
            STATIC.FirstPersonDefault = isFirstPersonDefault
        end

        --- @return boolean
        function STATIC.GetFirstPersonDefault()
            return STATIC.FirstPersonDefault
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

        --- @return unknown
        function STATIC.GetMessageWindow()
            return STATIC.MessageWindow
        end
    end

    --[[ Damage Direction ]] do
        
        --- @param direction integer
        function STATIC.ShowStarDamageDirection( direction )
            error( "Function not yet implemented" )
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
            error( "Function not yet implemented" )
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

    --- [[ Private ]]

    --- @class CombatManager
    --- @field private _IAmServer boolean
    --- @field private _IAmClient boolean
    --- @field private MyId integer
    --- @field private SyncTime integer
    --- @field private _IsGamePaused boolean
    --- @field private IsLevelInitialized boolean
    --- @field private _IsFriendlyFirePermitted boolean
    --- @field private BeaconPlacementEndsGame boolean
    --- @field private FirstPerson boolean
    --- @field private FirstPersonDefault boolean
    --- @field private MainCamera unknown
    --- @field private BackgroundScene unknown
    --- @field private SoundEnvironment unknown
    --- @field private DazzleLayer unknown
    --- @field private MessageWindow unknown
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

    --- @param mode CombatMode
    function STATIC.SetCombatMode( mode )
        error( "Function not yet implemented" )
    end

    function STATIC.UpdateCombatMode()
        error( "Function not yet implemented" )
    end
end