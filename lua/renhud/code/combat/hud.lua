-- Based on Code/Combat/hud.cpp

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of Hud
    --- @class Hud
    STATIC = CNC.CreateExport()
end


--#region Imports

    --- @type GlobalSettings
    local globalSettings = CNC.Import( "renhud/code/combat/global-settings.lua" )

    --- @type CombatManager
    local combatManager = CNC.Import( "renhud/code/combat/combat-manager.lua" )

    --- @type Rect
    local rect = CNC.Import( "renhud/code/wwmath/rect.lua" )

    --- @type StyleManager
    local styleManager = CNC.Import( "renhud/code/wwui/style-manager.lua" )

    --- @type Render2d
    local render2d = CNC.Import( "renhud/code/ww3d2/render-2d.lua" )

    --- @type Render2dText
    local render2dText = CNC.Import( "renhud/code/ww3d2/render-2d-text.lua" )

    --- @type Font3d
    local font3d = CNC.Import( "renhud/code/ww3d2/font-3d.lua" )

    --- @type TranslateDb
    local translateDb = CNC.Import( "renhud/code/wwtranslatedb/translatedb.lua" )

    --- @type ObjectiveManager
    local objectiveManager = CNC.Import( "renhud/code/combat/objective-manager.lua" )

    --- @type HudInfo
    local hudInfo = CNC.Import( "renhud/code/combat/hud-info.lua" )

    --- @type PhysicalGameObjectsBridge
    local physicalGameObjectsBridge = CNC.Import( "renhud/bridges/physical-game-objects.lua" )

    --- @type BuildingsBridge
    local buildingsBridge = CNC.Import( "renhud/bridges/buildings.lua" )

    --- @type Matrix3d
    local matrix3d = CNC.Import( "renhud/code/wwmath/matrix3d.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "Hud"

    local RETICLE_WIDTH, RETICLE_HEIGHT  = 64, 64

    local ACT_RELOADING = 183

    -- Manually reformat common weapon names that don't have good print names
    -- Format is [string: weapon class] -> [string: name to display]
    local preformattedWeaponNames = {
        ["weapon_crowbar"]      = "Crowbar",
        ["weapon_physcannon"]   = "Gravity Gun",
        ["weapon_physgun"]      = "Physics Gun",
        ["weapon_stunstick"]    = "Stunstick",
        ["weapon_pistol"]       = "9mm Pistol",
        ["weapon_357"]          = ".357 Magnum",
        ["weapon_smg1"]         = "Submachine Gun",
        ["weapon_ar2"]          = "Pulse-Rifle",
        ["weapon_shotgun"]      = "Shotgun",
        ["weapon_crossbow"]     = "Crossbow",
        ["weapon_frag"]         = "Grenade",
        ["weapon_rpg"]          = "RPG",
        ["weapon_slam"]         = "S.L.A.M",
        ["weapon_bugbait"]      = "Bugbait"
    }

    --[[ Load Materials ]] do

        local function LoadMaterial( fileName )
            local filepath = "renhud/" .. fileName .. ".png"

            local loadedMaterial = Material( filepath, "" )
            loadedMaterial:SetInt( "$gammacolorread", 1 )   -- Disables SRGB conversion of color texture read.  Credit: Noaccess
            loadedMaterial:SetInt( "$linearwrite", 1 )      -- Disables SRGB conversion of shader results.      Credit: Noaccess

            return loadedMaterial
        end

        STATIC.Materials = {}

        -- Fonts
        STATIC.Materials.Fonts = {}
        STATIC.Materials.Fonts.Large    = LoadMaterial( "font12x16" )
        STATIC.Materials.Fonts.Medium   = LoadMaterial( "font12x16" )
        STATIC.Materials.Fonts.Small    = LoadMaterial( "font6x8" )

        -- HUD Base
        STATIC.Materials.Hud = {}
        STATIC.Materials.Hud.Main       = LoadMaterial( "hud_main" )
        STATIC.Materials.Hud.ChatPBox   = LoadMaterial( "hud_chatpbox" )
        STATIC.Materials.Hud.Reticle    = LoadMaterial( "hd_reticle" )
        STATIC.Materials.Hud.ReticleHit = LoadMaterial( "hd_reticle_hit" )

        -- Objective Pickups
        STATIC.Materials.Pickups = {}
        STATIC.Materials.Pickups.Eva1   = LoadMaterial( "p_eva1" )
        STATIC.Materials.Pickups.Eva2   = LoadMaterial( "p_eva2" )
        STATIC.Materials.Pickups.CdRom  = LoadMaterial( "hud_cd_rom" )

        -- Keycard Pickups
        STATIC.Materials.Pickups.GreenKeycard  = LoadMaterial( "hud_keycard_green" )
        STATIC.Materials.Pickups.RedKeycard    = LoadMaterial( "hud_keycard_red" )
        STATIC.Materials.Pickups.YellowKeycard = LoadMaterial( "hud_keycard_yellow" )

        -- Armor Pickups
        STATIC.Materials.Pickups.Armor1 = LoadMaterial( "hud_armor1" )
        STATIC.Materials.Pickups.Armor2 = LoadMaterial( "hud_armor2" )
        STATIC.Materials.Pickups.Armor3 = LoadMaterial( "hud_armor3" )

        -- Health Pickups
        STATIC.Materials.Pickups.Health1 = LoadMaterial( "hud_health1" )
        STATIC.Materials.Pickups.Health2 = LoadMaterial( "hud_health2" )
        STATIC.Materials.Pickups.Health3 = LoadMaterial( "hud_health3" )

        -- Health and Armor Upgrades
        STATIC.Materials.Pickups.HealthUpgrade = LoadMaterial( "hud_hemedal" )
        STATIC.Materials.Pickups.ArmorUpgrade  = LoadMaterial( "hud_armedal" )
    end

    --[[ Load Font3d Instances ]] do
        -- These fonts are provided by `WW3DAssetManager::Get_Instance()->Get_Font3DInstance( tgaFileName )` in the original code
        STATIC.Font3dInstances = {}

        STATIC.Font3dInstances.Large  = font3d.New( STATIC.Materials.Fonts.Large  )
        STATIC.Font3dInstances.Medium = font3d.New( STATIC.Materials.Fonts.Medium )
        STATIC.Font3dInstances.Small  = font3d.New( STATIC.Materials.Fonts.Small  )
    end

    --- @param renderAvailable boolean
    function STATIC.Init( renderAvailable )
        STATIC.StatusBarInit()
        STATIC.ReticleInit()

        if renderAvailable then
            -- SniperHudClass.Init()
            STATIC.PowerupInit()
            STATIC.WeaponInit()
            -- STATIC.WeaponChartInit()
            STATIC.InfoInit()
            -- STATIC.DamageInit()
            STATIC.TargetInit()
            -- STATIC.ObjectiveInit()

            -- STATIC.HudHelpTextInit()
        end

        STATIC.HasInit = true
    end

    function STATIC.Think()
        if not STATIC.HasInit then return end

        STATIC.InfoUpdate()
        STATIC.PowerupUpdate()
        STATIC.WeaponUpdate()
        -- STATIC.WeaponChartUpdate()
        -- STATIC.DamageUpdate()
        STATIC.TargetUpdate()
        -- STATIC.ObjectiveUpdate()

        local combatStar = combatManager.GetTheStar()

        --[[ Reticle ]] do

            local reticleColor = globalSettings.Colors.NoRelation

            -- Check for friendly or enemy targets to change the reticle color
            local targetEntity = hudInfo:GetWeaponTargetEntity()
            if IsValid( targetEntity ) then
                reticleColor = globalSettings.Colors.Friendly
                if physicalGameObjectsBridge.IsPhysicalGameObject( targetEntity ) then
                    if physicalGameObjectsBridge.IsEnemy( targetEntity, combatStar ) then
                        reticleColor = globalSettings.Colors.Enemy
                    end
                end
            end

            local weapon = LocalPlayer():GetActiveWeapon()
            if IsValid( weapon ) then
                local isWeaponBusy = (
                    not weapon:HasAmmo()
                    or ( -- Can have ammo in the magazine, but currently does not
                        weapon:Clip1() <= 0
                        and weapon:GetMaxClip1() > 0
                    )
                    or weapon:GetInternalVariable( "m_bInReload" )
                    or weapon:GetInternalVariable( "m_Activity" ) == ACT_RELOADING
                )

                if isWeaponBusy then
                    reticleColor = globalSettings.Colors.ReticleBusy
                end
            end

            local reticleOffset = Vector( ScrW()/2, ScrH()/2 ) -- TODO: Implement COMBAT_CAMERA->Get_Camera_Target_2D_Offset();

            STATIC.ReticleRenderer:Reset()
            STATIC.ReticleRenderer:AddQuad(
                rect.New(
                    reticleOffset.x - RETICLE_WIDTH / 2,
                    reticleOffset.y - RETICLE_HEIGHT / 2,
                    reticleOffset.x + RETICLE_WIDTH / 2,
                    reticleOffset.y + RETICLE_HEIGHT / 2
                ),
                reticleColor
            )

            if combatManager.IsGameplayPermitted() then
                STATIC.ReticleRenderer:SetHidden( false )
            else
                STATIC.ReticleRenderer:SetHidden( true )
            end

            -- TODO: Implement the hit reticle

        end
    end

    function STATIC.Render()
        if not STATIC.HasInit then return end

        render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD )

        render.PushFilterMin( TEXFILTER.POINT )
        render.PushFilterMag( TEXFILTER.POINT )

        STATIC.PowerupRender()
        STATIC.WeaponRender()
        -- STATIC.WeaponChartRender()
        STATIC.InfoRender()
        -- STATIC.DamageRender()
        STATIC.TargetRender()
        -- STATIC.HudHelpTextRender()
        -- STATIC.ObjectiveRender()
        -- radarManager:Render()

        STATIC.ReticleRenderer:Render()
        STATIC.ReticleHitRenderer:Render()

        render.OverrideBlend( false )

        render.PopFilterMag()
        render.PopFilterMin()
    end
    hook.Add( "HUDPaint", "A1_Renegade_RenderHUD", STATIC.Render )

    function STATIC.Reset()
        typecheck.NotImplementedError( CLASS, "Reset" )
    end

    --- @return boolean
    function STATIC.Save()
        typecheck.NotImplementedError( CLASS, "Save" )
    end

    --- @return boolean
    function STATIC.Load()
        typecheck.NotImplementedError( CLASS, "Load" )
    end

    --- @param points number
    function STATIC.DisplayPoints( points )
        typecheck.NotImplementedError( CLASS, "DisplayPoints" )
    end

    function STATIC.ToggleHidePoints()
        typecheck.NotImplementedError( CLASS, "ToggleHidePoints" )
    end

    --- @return boolean
    function STATIC.IsEnabled()
        typecheck.NotImplementedError( CLASS, "IsEnabled" )
    end

    function STATIC.Enable()
        typecheck.NotImplementedError( CLASS, "Enable" )
    end

    function STATIC.ForceWeaponChartUpdate()
        typecheck.NotImplementedError( CLASS, "ForceWeaponChartUpdate" )
    end

    function STATIC.ForceWeaponChartDisplay()
        typecheck.NotImplementedError( CLASS, "ForceWeaponChartDisplay" )
    end

    --[[ Powerups ]] do

        --- @class PowerupIcon
        --- @field Name string
        --- @field Number integer
        --- @field Renderer Render2dInstance
        --- @field UV RectInstance
        --- @field IconBox RectInstance
        --- @field Timer number

        local POWERUP_PIXEL_UV_64X64 = rect.New( 0, 0, 64, 65 )
        local POWERUP_OFFSET_10X40 = Vector( 10, 40 )

        STATIC.MaxPowerupIcons = 5
        STATIC.PowerupTime = 6
        STATIC.PowerupBoxWidth = 80
        STATIC.PowerupBoxHeight = 55
        STATIC.PowerupPickupAnimationDuration = 1

        STATIC.PowerupBoxUvUpperLeft    = Vector( 50, 1 );
        STATIC.PowerupBoxUvLowerRight   = Vector( 127, 52 );

        STATIC.PowerupBoxBase = Vector( STATIC.PowerupBoxWidth + 6, 112 )
        STATIC.PowerupBoxSpacing = STATIC.PowerupBoxHeight + 10

        --- For weapons, health, and armor pickup notifications
        --- @type table<PowerupIcon>
        STATIC.RightPowerupIconList = STATIC.RightPowerupIconList or {}

        -- For keys
        --- @type table<PowerupIcon>
        STATIC.LeftPowerupIconList = STATIC.LeftPowerupIconList or {}

        function STATIC.PowerupInit()
            local font = styleManager.PeekFont( styleManager.FONT_STYLE.FONT_INGAME_TXT )
            STATIC.PowerupTextRenderer = render2dText.New( font )
            STATIC.PowerupTextRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
        end

        --- Adds a new powerup to either the left or right powerup list
        --- @param name string
        --- @param number integer
        --- @param material IMaterial
        --- @param pixelUvs RectInstance
        --- @param offset Vector
        --- @param addToRightList boolean
        function STATIC.PowerupAdd( name, number, material, pixelUvs, offset, addToRightList )
            -- Convert pixel UVs to normalized UVs
            local textureSize = material:Width()
            local uvs
            if textureSize > 0 then
                uvs = pixelUvs / textureSize
            end

            --- @type PowerupIcon
            local data = {
                Name = name,
                Number = number,
                Renderer = render2d.New(),
                IconBox = rect.New( pixelUvs ),
                UV = uvs or pixelUvs,
                Timer = STATIC.PowerupTime
            }

            data.Renderer:SetMaterial( material )
            data.Renderer:SetCoordinateRange( render2d.GetScreenResolution() )

            data.IconBox = data.IconBox + offset + Vector( 0, -40.0 ) - data.IconBox:UpperLeft()

            if addToRightList then
                STATIC.RightPowerupIconList[ #STATIC.RightPowerupIconList + 1 ] = data
            else
                STATIC.LeftPowerupIconList[ #STATIC.LeftPowerupIconList + 1 ] = data
            end
        end

        --- Removes all active Powerups from the HUD
        function STATIC.PowerupReset()
            STATIC.LeftPowerupIconList = {}
            STATIC.RightPowerupIconList = {}
        end

        --- Draws either the left or right powerup list
        --- @param frameTime number
        --- @param animationTimer number
        --- @param isRightList boolean
        --- @return number animationTimer
        local function RenderPowerupList( powerupList, frameTime, animationTimer, isRightList )
            -- Remove the bottom of the list after a polite wait
            local listHasPowerups = #powerupList > 0
            if listHasPowerups then
                local isDoneAnimatingListBottom = powerupList[1].Timer < 0
                if  isDoneAnimatingListBottom then
                    animationTimer = animationTimer + frameTime
                    if animationTimer > STATIC.PowerupPickupAnimationDuration then
                        animationTimer = 0
                        table.remove( powerupList, 1 )
                    end
                end
            else
                animationTimer = 0
            end

            local box = rect.New( STATIC.PowerupBoxUvUpperLeft, STATIC.PowerupBoxUvLowerRight )
            local start = Vector( ScrW(),  ScrH() ) - STATIC.PowerupBoxBase
            box = box + start - box:LowerLeft()

            if not isRightList then
                box = box - Vector( box.Left - 6, 75 )
            end
            --- @cast box RectInstance

            for index, powerup in ipairs( powerupList ) do
                if index > STATIC.MaxPowerupIcons then break end
                --- @cast powerup PowerupIcon

                powerup.Timer = powerup.Timer - frameTime

                local drawBox = rect.New( box )

                --- @type Color, Color
                local green, white

                local isBottomIcon = index == 1
                local isAnimating = animationTimer > 0
                if isBottomIcon and isAnimating then
                    local alpha = math.Clamp( 1 - ( animationTimer / STATIC.PowerupPickupAnimationDuration ), 0, 1 ) * 255
                    green = Color( 0, 255, 0, alpha )
                    white = Color( 255, 255, 255, alpha )
                else
                    green = Color( 0, 255, 0, 255 )
                    white = Color( 255, 255, 255, 255 )
                end

                local iconBox = powerup.IconBox
                iconBox = iconBox + drawBox:UpperLeft()
                --- @cast iconBox RectInstance

                -- Draw the powerup icon
                do
                    local drawColor = isRightList and green or white

                    powerup.Renderer:Reset()
                    powerup.Renderer:AddQuad( iconBox, powerup.UV, drawColor )
                end

                -- Draw powerup name
                do
                    STATIC.PowerupTextRenderer:SetLocation( Vector( drawBox.Left + 1, drawBox.Top + STATIC.PowerupBoxHeight - 15 ) )
                    STATIC.PowerupTextRenderer:DrawText( powerup.Name, white )
                end

                -- Draw powerup count
                if isRightList and powerup.Number ~= 0 then
                    STATIC.PowerupTextRenderer:SetLocation( Vector( drawBox.Right - 12, drawBox.Top + 1 ) )
                    STATIC.PowerupTextRenderer:DrawText( tostring( powerup.Number ) )
                end

                -- Drop remaining icons down
                local isTimeToAnimate = animationTimer > STATIC.PowerupPickupAnimationDuration * 0.5
                if isBottomIcon and isTimeToAnimate then
                    box = box + Vector( 0, ( ( 2 * animationTimer / STATIC.PowerupPickupAnimationDuration ) - 1 ) * STATIC.PowerupBoxSpacing )
                end

                box = box - Vector( 0, STATIC.PowerupBoxSpacing )
            end

            return animationTimer
        end

        function STATIC.PowerupUpdate()
            STATIC.PowerupTextRenderer:Reset()

            -- Mimicking the behavior of C++ static variables declared within functions
            STATIC.LeftAnimateTimer = STATIC.LeftAnimateTimer or 0
            STATIC.RightAnimateTimer = STATIC.RightAnimateTimer or 0

            local frameTime = RealFrameTime()

            STATIC.LeftAnimateTimer = RenderPowerupList( STATIC.LeftPowerupIconList, frameTime, STATIC.LeftAnimateTimer, false )
            STATIC.RightAnimateTimer = RenderPowerupList( STATIC.RightPowerupIconList, frameTime, STATIC.RightAnimateTimer, true )
        end

        function STATIC.PowerupRender()

            -- Left powerup list
            for i = 1, #STATIC.LeftPowerupIconList do
                local iconRenderer = STATIC.LeftPowerupIconList[ i ]
                iconRenderer.Renderer:Render()
            end

            -- Right powerup list
            for i = 1, #STATIC.RightPowerupIconList do
                local iconRenderer = STATIC.RightPowerupIconList[ i ]
                iconRenderer.Renderer:Render()
            end

            STATIC.PowerupTextRenderer:Render()
        end

        --- @param id integer
        ---@param rounds integer
        function STATIC.AddPowerupWeapon( id, rounds )
            typecheck.NotImplementedError( CLASS, "AddPowerupWeapon" )
        end

        --- @param id integer
        ---@param rounds integer
        function STATIC.AddPowerupAmmo( id, rounds )
            typecheck.NotImplementedError( CLASS, "AddPowerupAmmo" )
        end

        --- Adds an armor powerup notification
        --- @param strength number The amount of armor gained
        function STATIC.AddShieldGrant( strength )
            local materialName = STATIC.Materials.Pickups.Armor3
            if strength > 75 then
                materialName = STATIC.Materials.Pickups.Armor1
            elseif strength > 30 then
                materialName = STATIC.Materials.Pickups.Armor2
            end

            local powerupName = translateDb.GetString( "IDS_Power_up_Armor_00" )

            STATIC.PowerupAdd( powerupName, math.floor( strength ), materialName, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, true )
        end

        --- Adds a health powerup notification
        --- @param amount number
        function STATIC.AddHealthGrant( amount )
            local materialName = STATIC.Materials.Pickups.Health1
            if amount > 75 then
                materialName = STATIC.Materials.Pickups.Health3
            elseif amount > 30 then
                materialName = STATIC.Materials.Pickups.Health2
            end

            local powerupName = translateDb.GetString( "IDS_Power_up_Health_00" )

            STATIC.PowerupAdd( powerupName, math.floor( amount ), materialName, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, true )
        end

        --- Adds an armor upgrade powerup notification
        --- @param strength number
        function STATIC.AddShieldUpgradeGrant( strength )
            local powerupName = translateDb.GetString( "IDS_Power_up_Armor_Upgrade" )
            STATIC.PowerupAdd( powerupName, math.floor( strength ), STATIC.Materials.Pickups.ArmorUpgrade, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
        end

        --- Adds a health upgrade powerup notification
        --- @param amount number
        function STATIC.AddHealthUpgradeGrant( amount )
            local powerupName = translateDb.GetString( "IDS_Power_up_Health_Upgrade" )
            STATIC.PowerupAdd( powerupName, math.floor( amount ), STATIC.Materials.Pickups.HealthUpgrade, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
        end

        --- Adds a security keycard powerup notification
        --- @param key integer
        function STATIC.AddKeyGrant( key )
            local powerupMaterial = STATIC.Materials.Pickups.GreenKeycard
            if key == 3 then
                powerupMaterial = STATIC.Materials.Pickups.RedKeycard
            elseif key == 2 then
                powerupMaterial = STATIC.Materials.Pickups.YellowKeycard
            end

            local powerupName = translateDb.GetString( "IDS_Power_up_SecurityCard" )

            STATIC.PowerupAdd( powerupName, 0, powerupMaterial, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
        end

        --- Adds a primary or secondary powerup notification
        --- @param type ObjectiveType
        function STATIC.AddObjective( type )
            if type == objectiveManager.OBJECTIVE_TYPE.PRIMARY then
                local powerupName = translateDb.GetString( "IDS_Enc_Obj_Priority_0_Primary" )
                STATIC.PowerupAdd( powerupName, 0, STATIC.Materials.Pickups.Eva1, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
            elseif type == objectiveManager.OBJECTIVE_TYPE.SECONDARY then
                local powerupName = translateDb.GetString( "IDS_Enc_Obj_Priority_0_Secondary" )
                STATIC.PowerupAdd( powerupName, 0, STATIC.Materials.Pickups.Eva2, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
            end
        end

        --- Adds a data disc powerup notification
        function STATIC.AddDataLink()
            local powerupName = translateDb.GetString( "IDS_Power_up_DataDisc_01" )
            STATIC.PowerupAdd( powerupName, 0, STATIC.Materials.Pickups.CdRom, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
        end

        --- Adds a data disc powerup notification
        function STATIC.AddMapReveal()
            STATIC.AddDataLink()
        end
    end

    --[[ Status Bar ]] do

        --- @class Hud
        --- @field StatusBarRenderer Render2dInstance

        function STATIC.StatusBarInit()
            STATIC.StatusBarRenderer = render2d.New()
            STATIC.StatusBarRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
        end

    end

    --[[ Reticles ]] do

        --- @class Hud
        --- @field ReticleRenderer Render2dInstance
        --- @field ReticleHitRenderer Render2dInstance

        function STATIC.ReticleInit()
            STATIC.ReticleRenderer = render2d.New()
            STATIC.ReticleRenderer:SetMaterial( STATIC.Materials.Hud.Reticle )
            STATIC.ReticleRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
            STATIC.ReticleRenderer:SetHidden( true )

            STATIC.ReticleHitRenderer = render2d.New()
            STATIC.ReticleHitRenderer:SetMaterial( STATIC.Materials.Hud.ReticleHit )
            STATIC.ReticleHitRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
            STATIC.ReticleHitRenderer:SetHidden( true )
        end
    end

    --[[ Weapon Display ]] do
        --- @class Hud
        --- @field WeaponBoxRenderer Render2dInstance
        --- @field WeaponImageRenderer Render2dInstance
        --- @field WeaponClipCountRenderer Render2dTextInstance
        --- @field WeaponBase Vector
        --- @field WeaponBoxUvUpperLeft Vector
        --- @field WeaponBoxUvLowerRight Vector

        STATIC.WeaponBoxUvUpperLeft    = Vector( 0, 0 );
        STATIC.WeaponBoxUvLowerRight   = Vector( 95, 95 );

        local WEAPON_OFFSET = Vector( 100, 110 )
        local CLIP_ROUNDS_OFFSET  = Vector( 15, 27 )
        local TOTAL_ROUNDS_OFFSET = Vector( 65, 34 )

        function STATIC.WeaponInit()

            --[[ Weapon Name ]] do
                local font = styleManager.PeekFont( styleManager.FONT_STYLE.FONT_INGAME_TXT )

                STATIC.WeaponNameRenderer = render2dText.New( font )
                STATIC.WeaponNameRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
            end

            --[[ Weapon Background ]] do
                STATIC.WeaponBoxRenderer = render2d.New()
                STATIC.WeaponBoxRenderer:SetMaterial( STATIC.Materials.Hud.Main )
                STATIC.WeaponBoxRenderer:SetCoordinateRange( render2d.GetScreenResolution() )

                local boxUv = rect.New( STATIC.WeaponBoxUvUpperLeft, STATIC.WeaponBoxUvLowerRight )
                local drawBox = rect.New( boxUv )
                boxUv = boxUv / 256
                drawBox = drawBox + Vector( ScrW(), ScrH() ) - WEAPON_OFFSET - drawBox:UpperLeft()
                --- @cast drawBox RectInstance

                STATIC.WeaponBoxRenderer:AddQuad( drawBox, boxUv )
                STATIC.WeaponBase = drawBox:UpperLeft()
            end

            --[[ Weapon Clip Count ]] do
                STATIC.WeaponClipCountRenderer = render2dText.New( STATIC.Font3dInstances.Large )
                STATIC.WeaponClipCountRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
            end

            --[[ Reserve Ammo ]] do
                STATIC.WeaponTotalCountRenderer = render2dText.New( STATIC.Font3dInstances.Small )
                STATIC.WeaponTotalCountRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
            end
        end

        function STATIC.WeaponUpdate()

            --[[ Weapon Name ]] do

                local name = "Unknown"

                local wep = LocalPlayer():GetActiveWeapon()
                if IsValid( wep ) then

                    local preformattedName = preformattedWeaponNames[ wep:GetClass() ]

                    if preformattedName then
                        name = preformattedName
                    else
                        -- Localize the name, if possible
                        name = language.GetPhrase( wep:GetPrintName() )
                    end

                end

                STATIC.WeaponNameRenderer:Reset()

                local textSize = STATIC.WeaponNameRenderer:GetTextExtents( name ) + Vector( 1, 0 )
                STATIC.WeaponNameRenderer:SetLocation( render2d.GetScreenResolution():LowerRight() - textSize )
                STATIC.WeaponNameRenderer:DrawText( name )
            end

            --[[ Weapon Clip Count ]] do
                STATIC.WeaponClipCountRenderer:Reset()
                STATIC.WeaponClipCountRenderer:SetLocation( STATIC.WeaponBase + CLIP_ROUNDS_OFFSET )

                local ammoText = "999"

                if IsValid( LocalPlayer() ) then
                    local wep = LocalPlayer():GetActiveWeapon()

                    if IsValid( wep ) then
                        local clip1Ammo = math.floor( wep:Clip1() + 0.5 )

                        if clip1Ammo < 0 then
                            clip1Ammo = 999
                        end

                        ammoText = string.format( "%03d", clip1Ammo )
                    end
                end

                STATIC.WeaponClipCountRenderer:DrawText( ammoText )
            end

            --[[ Reserve Ammo Count ]] do
                STATIC.WeaponTotalCountRenderer:Reset()
                STATIC.WeaponTotalCountRenderer:SetLocation( STATIC.WeaponBase + TOTAL_ROUNDS_OFFSET )

                local ammoText = "999"

                if IsValid( LocalPlayer() ) then
                    local wep = LocalPlayer():GetActiveWeapon()

                    if IsValid( wep ) then
                        local clip1Ammo = math.floor( LocalPlayer():GetAmmoCount( wep:GetPrimaryAmmoType() ) + 0.5 )

                        if clip1Ammo < 0 then
                            clip1Ammo = 999
                        end

                        ammoText = string.format( "%03d", clip1Ammo )
                    end
                end

                STATIC.WeaponTotalCountRenderer:DrawText( ammoText )
            end
        end

        function STATIC.WeaponRender()
            STATIC.WeaponBoxRenderer:Render()
            --STATIC.WeaponImageRenderer:Render()
            STATIC.WeaponNameRenderer:Render()
            STATIC.WeaponClipCountRenderer:Render()
            STATIC.WeaponTotalCountRenderer:Render()
        end
    end

    --[[ Target Display ]] do

        --- @class Hud
        --- @field TargetRenderer Render2dInstance
        --- @field TargetBoxRenderer Render2dInstance
        --- @field TargetNameRenderer Render2dTextInstance
        --- @field TargetName string
        --- @field TargetNameLocation Vector

        function STATIC.TargetInit()
            STATIC.TargetRenderer = render2d.New()
            STATIC.TargetRenderer:SetMaterial( STATIC.Materials.Hud.Main )
            STATIC.TargetRenderer:SetCoordinateRange( render2d.GetScreenResolution() )

            STATIC.TargetBoxRenderer = render2d.New()
            STATIC.TargetBoxRenderer:EnableMaterial( false )
            STATIC.TargetBoxRenderer:SetCoordinateRange( render2d.GetScreenResolution() )

            local font = styleManager.PeekFont( styleManager.FONT_STYLE.FONT_INGAME_TXT )
            STATIC.TargetNameRenderer = render2dText.New( font )
            STATIC.TargetNameRenderer:SetCoordinateRange( render2d.GetScreenResolution() )
        end

        function STATIC.TargetUpdate()
            STATIC.TargetRenderer:Reset()
            STATIC.TargetBoxRenderer:Reset()
            STATIC.TargetNameRenderer:Reset()

            hudInfo.UpdateInfoEntity()
        end

        function STATIC.TargetRender()
            STATIC.TargetRenderer:Render()
            STATIC.TargetBoxRenderer:Render()
            STATIC.TargetNameRenderer:Render()
        end

        ---@param ent Entity
        ---@return RectInstance
        function STATIC.GetTargetBox( ent )
            typecheck.NotImplementedError( CLASS )
        end
    end

    --[[ Health/Armor Info ]] do

        --- @class Hud
        --- @field InfoRenderer Render2dInstance
        --- @field InfoHealthCountRenderer Render2dTextInstance
        --- @field InfoShieldCountRenderer Render2dTextInstance
        --- @field InfoBase Vector
        --- @field LastHealth number
        --- @field CenterHealthTimer number

        STATIC.InfoBase = STATIC.InfoBase or Vector( 0, 0 )
        STATIC.LastHealth = STATIC.LastHealth or 0
        STATIC.CenterHealthTimer = STATIC.CenterHealthTimer or 0

        -- #region Info Variables

        local INFO_UV_SCALE         = Vector( 1 / 256, 1 / 256 )

        -- The time, in seconds, that health changes should be drawn on-screen
        local CENTER_HEALTH_TIME    = 2

        -- The offset, in pixels, from the bottom-left corner of the screen where the info display is positioned
        local INFO_OFFSET           = Vector( 7, -179 )

        -- The frame UV and offset values for the static parts of the info display frame
        local infoFrameData = {
            { -- Frame 1 (Radar)
                UpperLeftUv  = Vector( 96, 105 ),
                LowerRightUv = Vector( 214, 255 ),
                Offset       = Vector( -3, -1 )
            },
            { -- Frame 2 (EVA + Top Edge)
                UpperLeftUv  = Vector( 215, 125 ),
                LowerRightUv = Vector( 255, 192 ),
                Offset       = Vector( 114, 57 )
            },
            { -- Frame 3 (Top Edge)
                UpperLeftUv  = Vector( 218, 192 ),
                LowerRightUv = Vector( 255, 201 ),
                Offset       = Vector( 154, 115 ),
            },
            { -- Frame 4 (Top-Right Corner)
                UpperLeftUv  = Vector( 216, 200 ),
                LowerRightUv = Vector( 255, 255 ),
                Offset       = Vector( 191, 115 ),
            },
            { -- Frame 5 (Right Cap)
                UpperLeftUv  = Vector( 80, 203 ),
                LowerRightUv = Vector( 100, 258 ),
                Offset       = Vector( 230, 116 ),
            },
            { -- Frame 6 (Bottom-Left Rounded Corner)
                UpperLeftUv  = Vector( 216, 101 ),
                LowerRightUv = Vector( 240, 125 ),
                Offset       = Vector( 74, 149 ),
            }
        }

        local HEALTH_BACK_UV_UL     = Vector( 183, 241 )
        local HEALTH_BACK_UV_LR     = Vector( 186, 248 )
        local HEALTH_BACK_UL        = Vector( 98, 122 )
        local HEALTH_BACK_LR        = Vector( 224, 168 )

        local GRADIENT_BLACK_UV_UL  = Vector( 3, 135 )
        local GRADIENT_BLACK_UV_LR  = Vector( 44, 144 )

        local HEALTH_TEXT_BACK_UL   = Vector( 77, 124 )
        local HEALTH_TEXT_BACK_LR   = Vector( 163, 150 )

        local HEALTH_UV_UL          = Vector( 94, 52 )
        local HEALTH_UV_LR          = Vector( 249, 100 )
        local HEALTH_OFFSET         = Vector( 73, 121 )

        local SHIELD_UV_UL          = Vector( 66, 97 )
        local SHIELD_UV_LR          = Vector( 96, 132 )
        local SHIELD_OFFSET         = Vector( 211, 140 )

        local KEY_1_UV_UL           = Vector( 30, 180 )
        local KEY_1_UV_LR           = Vector( 57, 197 )
        local KEY_1_OFFSET          = Vector( 32, 134 )

        local KEY_2_UV_UL           = Vector( 0, 181 )
        local KEY_2_UV_LR           = Vector( 30, 197 )
        local KEY_2_OFFSET          = Vector( 41, 140 )

        local KEY_3_UV_UL           = Vector( 69, 133 )
        local KEY_3_UV_LR           = Vector( 97, 149 )
        local KEY_3_OFFSET          = Vector( 50, 148 )

        local HEALTH_CROSS_1_UV_UL  = Vector( 33, 199 )
        local HEALTH_CROSS_1_UV_LR  = Vector( 63, 226 )
        local HEALTH_CROSS_1_OFFSET = Vector( 77, 124 )

        local HEALTH_CROSS_2_UV_UL  = Vector( 33, 228 )
        local HEALTH_CROSS_2_UV_LR  = Vector( 63, 258 )
        local HEALTH_CROSS_2_OFFSET = Vector( 77, 124 )

        local TOTAL_SHIELD_MOVEMENT = 80
        -- #endregion

        --- @param healthPercent number
        --- @return Color
        function STATIC.GetHealthColor( healthPercent )
            local color = globalSettings.Colors.HealthHigh

            if healthPercent <= 0.5 then
                color = globalSettings.Colors.HealthMed
            end

            if healthPercent <= 0.25 then
                color = globalSettings.Colors.HealthLow
            end

            return color
        end

        function STATIC.InfoInit()
            local resolution = render2d.GetScreenResolution()

            STATIC.InfoRenderer = render2d.New( STATIC.Materials.Hud.Main )
            STATIC.InfoRenderer:SetCoordinateRange( resolution )

            STATIC.InfoHealthCountRenderer = render2dText.New( STATIC.Font3dInstances.Large )
            STATIC.InfoHealthCountRenderer:SetCoordinateRange( resolution )

            STATIC.InfoShieldCountRenderer = render2dText.New( STATIC.Font3dInstances.Small )
            STATIC.InfoShieldCountRenderer:SetCoordinateRange( resolution )

            STATIC.InfoBase = resolution:LowerLeft() + INFO_OFFSET
        end

        function STATIC.InfoUpdateHealthShield()
            local infoRenderer = STATIC.InfoRenderer

            local health = 0
            local healthPercent = 0
            local shield = 0
            local shieldPercent = 0

            local combatStar = LocalPlayer()

            -- TODO: Vehicle health

            -- Get the player's current health or the health of their vehicle
            if IsValid( combatStar ) then

                health = math.max( combatStar:Health(), 0 )
                healthPercent = math.Clamp( health / combatStar:GetMaxHealth(), 0, 1 )

                shield = math.max( combatStar:Armor(), 0 )
                shieldPercent = math.Clamp( shield / combatStar:GetMaxArmor(), 0, 1 )

                -- Using the Drive system
                if combatStar:IsDrivingEntity() then
                    typecheck.NotImplementedError( CLASS, "InfoUpdateHealthShield", "Driving system" )
                end

                -- Vehicle health
                if combatStar:InVehicle() then
                    typecheck.NotImplementedError( CLASS, "InfoUpdateHealthShield", "Vehicle Health" )
                end
            end

            --- @type RectInstance, RectInstance, RectInstance, number
            local uv, uv2, draw, intensity

            local frameTime = FrameTime()

            STATIC.LastHealthPercent = STATIC.LastHealthPercent or 0
            STATIC.LastShieldPercent = STATIC.LastShieldPercent or 0

            -- Get the health color
            local colorPercent = math.max( STATIC.LastHealthPercent, healthPercent )
            local healthColor = STATIC.GetHealthColor( colorPercent )

            local healthString = string.format( "%03d", math.floor( health ) )
            local shieldString = string.format( "%03d", math.floor( shield ) )

            --[[ Health Bar ]] do

                uv = rect.New( HEALTH_UV_UL, HEALTH_UV_LR )
                draw = rect.New( uv )
                uv:ScaleVector( INFO_UV_SCALE )

                --- @type RectInstance
                draw = draw + ( STATIC.InfoBase + HEALTH_OFFSET - draw:UpperLeft() )

                -- Scale bars
                local diff = healthPercent - STATIC.LastHealthPercent
                local maxChange = frameTime
                STATIC.LastHealthPercent = STATIC.LastHealthPercent + math.Clamp( diff, -maxChange, maxChange )
                uv.Right = uv.Left + uv:Width() * STATIC.LastHealthPercent
                draw.Right = draw.Left + draw:Width() * STATIC.LastHealthPercent

                -- Draw the colored health bar
                infoRenderer:AddQuad( draw, uv, healthColor )
            end

            --[[ Health Cross ]] do

                -- Background gradient
                uv = rect.New( GRADIENT_BLACK_UV_UL, GRADIENT_BLACK_UV_LR )
                uv:ScaleVector( INFO_UV_SCALE )
                draw = rect.New( HEALTH_TEXT_BACK_UL, HEALTH_TEXT_BACK_LR )
                draw = draw + STATIC.InfoBase
                infoRenderer:AddQuad( draw, uv )

                -- Cross icon
                STATIC.HealthCrossFlash = STATIC.HealthCrossFlash or 0
                STATIC.HealthCrossFlash = STATIC.HealthCrossFlash + frameTime * 4

                if STATIC.HealthCrossFlash > 2 then
                    STATIC.HealthCrossFlash = STATIC.HealthCrossFlash - 2
                end

                if healthPercent > 0.25 then
                    STATIC.HealthCrossFlash = 0
                end

                intensity = STATIC.HealthCrossFlash
                if STATIC.HealthCrossFlash > 1 then
                    intensity = 2 - STATIC.HealthCrossFlash
                end

                -- Cross icon fill
                uv = rect.New( HEALTH_CROSS_1_UV_UL, HEALTH_CROSS_1_UV_LR )
                draw = rect.New( uv )
                uv:ScaleVector( INFO_UV_SCALE )
                draw = draw + ( STATIC.InfoBase + HEALTH_CROSS_1_OFFSET - draw:UpperLeft() )
                infoRenderer:AddQuad( draw, uv, ColorAlpha( healthColor, intensity * 255 ) )

                -- Cross icon outline
                uv2 = rect.New( HEALTH_CROSS_2_UV_UL, HEALTH_CROSS_2_UV_LR )
                uv2:ScaleVector( INFO_UV_SCALE )
                infoRenderer:AddQuad( draw, uv2, ColorAlpha( healthColor, ( 1 - intensity ) * 255 ) )
            end

            --[[ Health Number ]] do
                STATIC.InfoHealthCountRenderer:Reset()

                if health < 1 and health > 0 then
                    health = 1
                end

                STATIC.InfoHealthCountRenderer:SetLocation( draw:UpperRight() + Vector( 4, 4 ) )
                STATIC.InfoHealthCountRenderer:DrawText( healthString, healthColor )
            end

            --[[ Center Health Number ]] do

                -- Show the center health number if we took damage recently or are low on health
                if health ~= STATIC.LastHealth or healthPercent < 0.25 then
                    STATIC.LastHealth = health
                    STATIC.CenterHealthTimer = CENTER_HEALTH_TIME
                end

                if STATIC.CenterHealthTimer > 0 then

                    local healthCenterOffset = render2d.GetScreenResolution():Center()
                    healthCenterOffset.x = healthCenterOffset.x * 0.5
                    healthCenterOffset.y = healthCenterOffset.y - draw:Height() / 2

                    healthCenterOffset = healthCenterOffset - HEALTH_CROSS_1_OFFSET

                    local fade = math.Clamp( STATIC.CenterHealthTimer, 0, 1 )

                    -- Background gradient
                    uv = rect.New( GRADIENT_BLACK_UV_UL, GRADIENT_BLACK_UV_LR )
                    uv:ScaleVector( INFO_UV_SCALE )
                    draw = rect.New( HEALTH_TEXT_BACK_UL, HEALTH_TEXT_BACK_LR )
                    draw = draw + healthCenterOffset
                    infoRenderer:AddQuad( draw, uv, Color( 255, 255, 255, fade * 255 ) )

                    -- The center cross
                    uv = rect.New( HEALTH_CROSS_1_UV_UL, HEALTH_CROSS_1_UV_LR  )
                    draw = rect.New( uv )
                    uv:ScaleVector( INFO_UV_SCALE )
                    draw = draw + healthCenterOffset + HEALTH_CROSS_1_OFFSET - draw:UpperLeft()

                    -- Cross fill
                    infoRenderer:AddQuad( draw, uv, ColorAlpha( healthColor, fade * intensity * 255 ) )

                    -- Cross outline
                    infoRenderer:AddQuad( draw, uv2, ColorAlpha( healthColor, fade * ( 1 - intensity ) * 255 ) )

                    -- Health text
                    STATIC.InfoHealthCountRenderer:SetLocation( draw:UpperRight() + Vector( 4, 4 ) )
                    STATIC.InfoHealthCountRenderer:DrawText( healthString, ColorAlpha( healthColor, fade * 255 ) )

                    STATIC.CenterHealthTimer = STATIC.CenterHealthTimer - frameTime
                end
            end

            --[[ Shield / Armor ]] do
                local diff = shieldPercent - STATIC.LastShieldPercent
                local maxChange = frameTime
                STATIC.LastShieldPercent = STATIC.LastShieldPercent + math.Clamp( diff, -maxChange, maxChange )
                shieldPercent = STATIC.LastShieldPercent
                uv.Right = uv.Left + uv:Width() * shieldPercent
                draw.Right = draw.Left + draw:Width() * shieldPercent

                if shieldPercent > 0 then

                    -- Background shields
                    local percent = 0
                    while percent < shieldPercent do
                        uv = rect.New( SHIELD_UV_UL, SHIELD_UV_LR )
                        draw = rect.New( uv )

                        uv:ScaleVector( INFO_UV_SCALE )
                        draw = draw + ( STATIC.InfoBase + SHIELD_OFFSET - draw:UpperLeft() )
                        draw = draw + Vector( math.floor(-percent * TOTAL_SHIELD_MOVEMENT ), 0 )
                        infoRenderer:AddQuad( draw, uv )

                        percent = percent + 0.1
                    end

                    -- Foreground shield
                    uv = rect.New( SHIELD_UV_UL, SHIELD_UV_LR )
                    draw = rect.New( uv )
                    uv:ScaleVector( INFO_UV_SCALE )
                    draw = draw + ( STATIC.InfoBase + SHIELD_OFFSET - draw:UpperLeft() )
                    draw = draw + Vector( math.floor( -shieldPercent * TOTAL_SHIELD_MOVEMENT ), 0 )
                    infoRenderer:AddQuad( draw, uv )

                    STATIC.InfoShieldCountRenderer:Reset()
                    
                    STATIC.InfoShieldCountRenderer:SetLocation( draw:UpperLeft() + Vector( 4, 4 ) )
                    STATIC.InfoShieldCountRenderer:DrawText( shieldString )

                else
                    STATIC.InfoShieldCountRenderer:Reset()
                end
            end

        end

        function STATIC.InfoUpdate()
            local infoRenderer = STATIC.InfoRenderer

            infoRenderer:Reset()

            --[[ Background Frame ]] do
                local uv, draw

                -- Add each frame part
                for index, frameData in ipairs( infoFrameData ) do
                    uv = rect.New( frameData.UpperLeftUv, frameData.LowerRightUv )
                    draw = rect.New( uv )

                    draw = draw + STATIC.InfoBase + frameData.Offset - draw:UpperLeft()

                    uv:ScaleVector( INFO_UV_SCALE )

                    infoRenderer:AddQuad( draw, uv )
                end

                -- Add health background
                uv = rect.New( HEALTH_BACK_UV_UL, HEALTH_BACK_UV_LR )
                uv:ScaleVector( INFO_UV_SCALE )
                draw = rect.New( HEALTH_BACK_UL, HEALTH_BACK_LR )
                draw = draw + STATIC.InfoBase

                infoRenderer:AddQuad( draw, uv )
            end

            STATIC.InfoUpdateHealthShield()

            -- TODO: Keys
        end

        function STATIC.InfoRender()
            STATIC.InfoRenderer:Render()
            STATIC.InfoHealthCountRenderer:Render()
            STATIC.InfoShieldCountRenderer:Render()
        end
    end
end