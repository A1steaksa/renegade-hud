-- Based on Code/Combat/hud.cpp

local STATIC

--[[ Class Setup ]] do
    --- @class Renegade
    --- @field Hud Hud

    --- The static components of Hud
    --- @class Hud
    STATIC = CNC_RENEGADE.Hud or {}
    CNC_RENEGADE.Hud = STATIC
end

--#region Localization

local styleManager      = CNC_RENEGADE.StyleManager
local render2d          = CNC_RENEGADE.Render2d
local render2dSentence  = CNC_RENEGADE.Render2DSentence
local translateDb       = CNC_RENEGADE.TranslateDB
local objectiveManager  = CNC_RENEGADE.ObjectiveManager
--#endregion

--[[ Hide Original HUD ]] do
    local hudElements = {
        [ "CHudAmmo" ]                   = false,
        [ "CHudBattery" ]                = false,
        [ "CHudChat" ]                   = false,
        [ "CHudCrosshair" ]              = false,
        [ "CHudCloseCaption" ]           = false,
        [ "CHudDamageIndicator" ]        = false,
        [ "CHudHistoryResource" ]        = false,
        [ "CHudDeathNotice" ]            = false,
        [ "CHudGeiger" ]                 = false,
        [ "CHudGMod" ]                   = true,
        [ "CHudHealth" ]                 = false,
        [ "CHudHintDisplay" ]            = false,
        [ "CHudMenu" ]                   = false,
        [ "CHudMessage" ]                = false,
        [ "CHudPoisonDamageIndicator" ]  = false,
        [ "CHudSecondaryAmmo" ]          = false,
        [ "CHudSquadStatus" ]            = false,
        [ "CHudTrain" ]                  = false,
        [ "CHudVehicle" ]                = false,
        [ "CHudWeapon" ]                 = false,
        [ "CHudWeaponSelection" ]        = true,
        [ "CHudZoom" ]                   = false,
        [ "NetGraph" ]                   = true,
        [ "CHUDQuickInfo" ]              = false,
        [ "CHudSuitPower" ]              = false,
    }

    hook.Add( "HUDShouldDraw", "A1_Renegade_HideHUD", function( name )
        return hudElements[ name ]
    end )
end

--[[ Static Functions and Variables ]] do

    --[[ Load Materials ]] do

        local function LoadMaterial( fileName )
            local filepath = "renhud/" .. fileName .. ".png"
            return Material( filepath, "" )
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
        STATIC.Materials.Pickups.ArmorUpgrade = LoadMaterial( "hud_armedal" )
    end

    --- @param renderAvailable boolean
    function STATIC.Init( renderAvailable )
        
        if renderAvailable then
            -- SniperHudClass.Init()
            STATIC.PowerupInit()
            STATIC.WeaponInit()
            -- STATIC.WeaponChartInit()
            -- STATIC.InfoInit()
            -- STATIC.DamageInit()
            -- STATIC.TargetInit()
            -- STATIC.ObjectiveInit()

            -- STATIC.HudHelpTextInit()


        end

    end

    function STATIC.Think()
        error( "Function not yet implemented" )
    end

    function STATIC.Render()
        -- render.PushFilterMin( TEXFILTER.POINT )
        -- render.PushFilterMag( TEXFILTER.POINT )

        -- STATIC.InfoRender()
        STATIC.PowerupRender()
        STATIC.WeaponRender()
        -- STATIC.WeaponChartRender()
        -- STATIC.DamageRender()
        -- STATIC.TargetRender()
        -- STATIC.ObjectiveRender()

        -- render.PopFilterMag()
        -- render.PopFilterMin()
    end
    hook.Add( "HUDPaint", "A1_Renegade_RenderHUD", STATIC.Render )

    function STATIC.Reset()
        error( "Function not yet implemented" )
    end

    --- @return boolean
    function STATIC.Save()
        error( "Function not yet implemented" )
    end

    --- @return boolean
    function STATIC.Load()
        error( "Function not yet implemented" )
    end

    --- @param points number
    function STATIC.DisplayPoints( points )
        error( "Function not yet implemented" )
    end

    function STATIC.ToggleHidePoints()
        error( "Function not yet implemented" )
    end

    --- @return boolean
    function STATIC.IsEnabled()
        error( "Function not yet implemented" )
    end

    function STATIC.Enable()
        error( "Function not yet implemented" )
    end

    function STATIC.ForceWeaponChartUpdate()
        error( "Function not yet implemented" )
    end

    function STATIC.ForceWeaponChartDisplay()
        error( "Function not yet implemented" )
    end

    --[[ Powerups ]] do

        --- @class PowerupIcon
        --- @field Name string
        --- @field Number integer
        --- @field UV RectInstance
        --- @field IconBox RectInstance
        --- @field Timer number
        --- @field Material IMaterial

        local POWERUP_PIXEL_UV_64X64 = robustclass.New( "Renegade_Rect", 0, 0, 64, 65 )
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
        end

        --- Adds a new powerup to either the left or right powerup list
        --- @param name string
        --- @param number integer
        --- @param material IMaterial
        --- @param pixelUvs RectInstance
        --- @param offset Vector
        --- @param addToRightList boolean
        function STATIC.PowerupAdd( name, number, material, pixelUvs, offset, addToRightList )
            --- @class PowerupIcon
            local data = {}
            data.Material = material

            local textureSize = material:Width()
            local uvs
            if textureSize > 0 then
                uvs = pixelUvs / textureSize
            end
            data.UV = uvs or pixelUvs

            data.IconBox = robustclass.New( "Renegade_Rect", pixelUvs )
            data.IconBox = data.IconBox + offset + Vector( 0, -40.0 ) - data.IconBox:UpperLeft()

            data.Name = name
            data.Number = number
            data.Timer = STATIC.PowerupTime

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
                local isDoneAnimatingListBottom = powerupList[ 1 ].Timer < 0
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

            local box = robustclass.New( "Renegade_Rect", STATIC.PowerupBoxUvUpperLeft, STATIC.PowerupBoxUvLowerRight )
            local start = Vector( ScrW(),  ScrH() ) - STATIC.PowerupBoxBase
            box = box + start - box:LowerLeft()

            if not isRightList then
                box = box - Vector( box.Left - 6, 75 )
            end
            --- @cast box RectInstance

            surface.SetFont( styleManager.Fonts.IngameText )

            for index, powerup in ipairs( powerupList ) do
                if index > STATIC.MaxPowerupIcons then break end
                --- @cast powerup PowerupIcon

                powerup.Timer = powerup.Timer - frameTime

                -- Feels unnecessary
                local drawBox = box

                local green
                local white

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
                    surface.SetDrawColor( drawColor )

                    surface.SetMaterial( powerup.Material )
                    local uv = powerup.UV

                    surface.DrawTexturedRectUV(
                        iconBox.Left, iconBox.Top,
                        iconBox:Width(), iconBox:Height(),
                        uv.Left, uv.Top, uv.Bottom, uv.Right
                    )
                end

                -- Draw powerup name
                do
                    local text = powerup.Name
                    local textX = drawBox.Left + 1
                    local textY = drawBox.Top + STATIC.PowerupBoxHeight - 15
                    local textWidth = render2dSentence.GetTextWidth( text )

                    -- Adjust text X position to keep text from going off the right side of the screen
                    local textEndX = textX + textWidth + 1
                    if textEndX > ScrW() then
                        textX = ScrW() - ( textWidth + 1 )
                    end

                    render2dSentence.DrawText( textX, textY, text, white )
                end

                -- Draw powerup count
                if isRightList and powerup.Number ~= 0 then
                    local text = powerup.Number
                    local textX = drawBox.Right - 12
                    local textY = drawBox.Top + 1

                    render2dSentence.DrawText( textX, textY, tostring( text ), white )
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

        function STATIC.PowerupRender()
            local frameTime = RealFrameTime()

            -- Mimicking the behavior of C++ static variables declared within functions
            STATIC.LeftAnimateTimer = STATIC.LeftAnimateTimer or 0
            STATIC.RightAnimateTimer = STATIC.RightAnimateTimer or 0

            STATIC.LeftAnimateTimer = RenderPowerupList( STATIC.LeftPowerupIconList, frameTime, STATIC.LeftAnimateTimer, false )
            STATIC.RightAnimateTimer = RenderPowerupList( STATIC.RightPowerupIconList, frameTime, STATIC.RightAnimateTimer, true )
        end

        --- @param id integer
        ---@param rounds integer
        function STATIC.AddPowerupWeapon( id, rounds )
            error( "Function not yet implemented" )
        end

        --- @param id integer
        ---@param rounds integer
        function STATIC.AddPowerupAmmo( id, rounds )
            error( "Function not yet implemented" )
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
            if type == objectiveManager.ObjectiveType.TYPE_PRIMARY then
                local powerupName = translateDb.GetString( "IDS_Enc_Obj_Priority_0_Primary" )
                STATIC.PowerupAdd( powerupName, 0, STATIC.Materials.Pickups.Eva1, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
            elseif type == objectiveManager.ObjectiveType.TYPE_SECONDARY then
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

        local WEAPON_DISPLAY_WEAPON_OFFSET = Vector( 100, 110 )

        function STATIC.WeaponInit()
            STATIC.WeaponBoxRenderer = robustclass.New( "Renegade_Render2d" )
            STATIC.WeaponBoxRenderer:SetMaterial( STATIC.Materials.Hud.Main )
            STATIC.WeaponBoxRenderer:SetCoordinateRange( render2d.GetScreenResolution() )

            local boxUv = robustclass.New( "Renegade_Rect", STATIC.WeaponBoxUvUpperLeft, STATIC.WeaponBoxUvLowerRight )
            local drawBox = robustclass.New( "Renegade_Rect", boxUv )
            boxUv = boxUv / 256
            drawBox = drawBox + Vector( ScrW(), ScrH() ) - WEAPON_DISPLAY_WEAPON_OFFSET - drawBox:UpperLeft()
            --- @cast drawBox RectInstance

            STATIC.WeaponBoxRenderer:AddQuad( drawBox, boxUv )
            STATIC.WeaponBase = drawBox:UpperLeft()
        end

        function STATIC.WeaponRender()
            STATIC.WeaponBoxRenderer:Render()
            --WeaponImageRender()
            --WeaponNameRender()
            --WeaponClipCountRender()
            --WeaponTotalCountRender()
        end
    end

    function STATIC.DamageRender()
        error( "Function not yet implemented" )
    end

end

STATIC.Init( true )