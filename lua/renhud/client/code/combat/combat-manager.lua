-- Based on CombatManager within Code/Combat/combat.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- The static components of CombatManager
--- @class CombatManager
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )


-- #region Imports

    --- @type Hud
    local hud = CNC.Import( "renhud/client/code/combat/hud.lua" )

    --- @type StyleManager
    local styleManager = CNC.Import( "renhud/client/code/wwui/style-manager.lua" )

    --- @type CommandoCamera
    local commandoCamera = CNC.Import( "renhud/client/code/combat/commando-camera.lua" )

    --- @type DamageLib
    local damageLib = CNC.Import( "renhud/sh_damage.lua" )
-- #endregion


--#region Enums

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
    local combatMode = STATIC.COMBAT_MODE

    local damageDirectionEnum = damageLib.DAMAGE_DIRECTION
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "CombatManager"

    --- [[ Public ]]

    --- @class CombatManager
    --- @field GameScene unknown

    --[[ Default Values ]] do

        if not isHotload then
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

            STATIC.CombatMode = combatMode.NONE
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
        STATIC.MainCamera = commandoCamera.New()

        -- TODO: Check if this is a good way to set up the star
        STATIC.TheStar = LocalPlayer()

        -- Create the Dazzle Layer
        if renderAvailable then
            -- STATIC.DazzleLayer = dazzleLayer.New()
            -- dazzleLayer.SetCurrentDazzleLayer( STATIC.DazzleLayer )
        else
            -- dazzleLayer.SetCurrentDazzleLayer( nil )
        end

        hud.Init( renderAvailable )
        -- CNC_RENEGADE.ScreenFadeManager.Init()

        hook.Add( "Think", "A1_Renegade_CombatManager_Think", STATIC.Think )
    end

    function STATIC.Shutdown()
        typecheck.NotImplementedError( CLASS, "Shutdown" )
    end

    function STATIC.SceneInit()
        typecheck.NotImplementedError( CLASS, "SceneInit" )
    end

    --[[ Level Loading ]] do

        --- @param renderAvailable boolean? [Default: true]
        function STATIC.PreLoadLevel( renderAvailable )
            if not renderAvailable then
                renderAvailable = true
            end

            typecheck.NotImplementedError( CLASS, "PreLoadLevel" )
        end

        --- @param mapName string
        ---@param preloadAssets boolean
        function STATIC.LoadLevelThreaded( mapName, preloadAssets )
            typecheck.NotImplementedError( CLASS, "LoadLevelThreaded" )
        end

        --- @return boolean
        function STATIC.IsLoadLevelComplete()
            typecheck.NotImplementedError( CLASS, "IsLoadLevelComplete" )
        end

        --- @return boolean
        function STATIC.IsLoadingLevel()
            typecheck.NotImplementedError( CLASS, "IsLoadingLevel" )
        end

        function STATIC.PostLoadLevel()
            typecheck.NotImplementedError( CLASS, "PostLoadLevel" )
        end

        function STATIC.UnloadLevel()
            typecheck.NotImplementedError( CLASS, "UnloadLevel" )
        end
    end

    --[[ Main Loop ]] do
      
        function STATIC.GenerateControl()
            typecheck.NotImplementedError( CLASS, "GenerateControl" )
        end

        function STATIC.Think()

            -- Omitting over the vast majority of this function for now

            STATIC.MainCamera:Update()

            hud.Think()
        end

        function STATIC.Render()
            typecheck.NotImplementedError( CLASS, "Render" )
        end

        function STATIC.HandleInput()
            typecheck.NotImplementedError( CLASS, "HandleInput" )
        end
    end

    --[[ Save/Load ]] do

        --- @param save unknown
        function STATIC.Save( save )
            typecheck.NotImplementedError( CLASS, "Save" )
        end

        --- @param load unknown
        function STATIC.Load( load )
            typecheck.NotImplementedError( CLASS, "Load" )
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
            typecheck.NotImplementedError( CLASS, "SetCombatNetworkHandler" )
        end

        ---@param damager Entity
        ---@param victim Entity
        function STATIC.CanDamage( damager, victim )
            typecheck.NotImplementedError( CLASS, "CanDamage" )
        end

        ---@param damager Entity
        ---@param victim Entity
        function STATIC.GetDamageFactor( damager, victim)
            typecheck.NotImplementedError( CLASS, "GetDamageFactor" )
        end

        ---@param soldier Entity
        ---@param victim Entity
        function STATIC.OnSoldierKill( soldier, victim )
            typecheck.NotImplementedError( CLASS, "OnSoldierKill" )
        end

        ---@param soldier Entity
        function STATIC.OnSoldierDeath( soldier )
            typecheck.NotImplementedError( CLASS, "OnSoldierDeath" )
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
            typecheck.NotImplementedError( CLASS, "MissionComplete" )
        end

        function STATIC.StarKilled()
            typecheck.NotImplementedError( CLASS, "StarKilled" )
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
                hud.Reset()
            end

            STATIC.TheStar = target
            STATIC._IsStarDeterminingTarget = isStarDeterminingTarget
            -- if IsValid( target ) then
            --     -- TODO: Point the camera toward the new star's direction
            -- end

            hud.ForceWeaponChartUpdate()
            -- Omitted weapon view class resetting

            if not STATIC.IsLevelInitialized then
                STATIC.IsLevelInitialized = true

                -- Omitted re-enabling sound and music
            end
        end

        --- @return Entity
        function STATIC.GetTheStar()

            if LocalPlayer() and not IsValid( STATIC.TheStar ) then
                STATIC.TheStar = LocalPlayer()
            end

            return STATIC.TheStar
        end

        function STATIC.UpdateStar()
            local star = STATIC.GetTheStar()

            if not IsValid( star ) then
                return
            end

            typecheck.NotImplementedError( CLASS, "UpdateStar" )
        end

        function STATIC.UpdateStarTargeting()
            typecheck.NotImplementedError( CLASS, "UpdateStarTargeting" )
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
            typecheck.NotImplementedError( CLASS, "GetScene" )
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
            typecheck.NotImplementedError( CLASS, "SetCameraProfile" )
        end

        ---@param vehicle Entity
        ---@param seat integer? [Default: 0]
        function STATIC.SetCameraVehicle( vehicle, seat )
            if not seat then
                seat = 0
            end

            typecheck.NotImplementedError( CLASS, "SetCameraVehicle" )
        end

        --- @param pos Vector
        --- @return boolean
        function STATIC.IsInCameraFrustum( pos )
            typecheck.NotImplementedError( CLASS, "IsInCameraFrustum" )
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

        --- @return unknown
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
            typecheck.NotImplementedError( CLASS, "RegisterStarKiller" )
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
    --- @field private MainCamera CommandoCameraInstance
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
        typecheck.NotImplementedError( CLASS, "SetCombatMode" )
    end

    function STATIC.UpdateCombatMode()
        typecheck.NotImplementedError( CLASS, "UpdateCombatMode" )
    end
end