-- Based on Code/Combat/hud.cpp

---@class Renegade
---@field Hud HUD

CNC_RENEGADE.Hud = CNC_RENEGADE.Hud or {}

---@class HUD
local LIB = CNC_RENEGADE.Hud

local globalSettings = CNC_RENEGADE.GlobalSettings
local rect = CNC_RENEGADE.Rect
local styleManager = CNC_RENEGADE.StyleManager
local render2DSentence = CNC_RENEGADE.Render2DSentence
local translateDB = CNC_RENEGADE.TranslateDB
local objectiveManager = CNC_RENEGADE.ObjectiveManager

--#region Hide Original HUD
do
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
        --[ "CHudGMod" ]                   = false,
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
        --[ "CHudWeaponSelection" ]        = false,
        [ "CHudZoom" ]                   = false,
        [ "NetGraph" ]                   = false,
        [ "CHUDQuickInfo" ]              = false,
        [ "CHudSuitPower" ]              = false,
    }

    hook.Add( "HUDShouldDraw", "A1_Renegade_HideHUD", function( name )
        return hudElements[ name ]
    end )
end
--#endregion

--#region Materials

local function LoadMaterial( fileName )
    local filepath = "renhud/" .. fileName .. ".png"
    return Material( filepath, "" )
end

LIB.Materials = {}

-- Fonts
LIB.Materials.Fonts = {}
LIB.Materials.Fonts.Large    = LoadMaterial( "font12x16" )
LIB.Materials.Fonts.Medium   = LoadMaterial( "font12x16" )
LIB.Materials.Fonts.Small    = LoadMaterial( "font6x8" )

-- HUD Base
LIB.Materials.Hud = {}
LIB.Materials.Hud.Main       = LoadMaterial( "hud_main" )
LIB.Materials.Hud.ChatPBox   = LoadMaterial( "hud_chatpbox" )

-- Objective Pickups
LIB.Materials.Pickups = {}
LIB.Materials.Pickups.Eva1   = LoadMaterial( "p_eva1" )
LIB.Materials.Pickups.Eva2   = LoadMaterial( "p_eva2" )
LIB.Materials.Pickups.CdRom  = LoadMaterial( "hud_cd_rom" )

-- Keycard Pickups
LIB.Materials.Pickups.GreenKeycard  = LoadMaterial( "hud_keycard_green" )
LIB.Materials.Pickups.RedKeycard    = LoadMaterial( "hud_keycard_red" )
LIB.Materials.Pickups.YellowKeycard = LoadMaterial( "hud_keycard_yellow" )

-- Armor Pickups
LIB.Materials.Pickups.Armor1 = LoadMaterial( "hud_armor1" )
LIB.Materials.Pickups.Armor2 = LoadMaterial( "hud_armor2" )
LIB.Materials.Pickups.Armor3 = LoadMaterial( "hud_armor3" )

-- Health Pickups
LIB.Materials.Pickups.Health1 = LoadMaterial( "hud_health1" )
LIB.Materials.Pickups.Health2 = LoadMaterial( "hud_health2" )
LIB.Materials.Pickups.Health3 = LoadMaterial( "hud_health3" )

-- Health and Armor Upgrades
LIB.Materials.Pickups.HealthUpgrade = LoadMaterial( "hud_hemedal" )
LIB.Materials.Pickups.ArmorUpgrade = LoadMaterial( "hud_armedal" )

--#endregion

--#region Getters/Setters

---Determines the appropriate draw color for health-related HUD elements based on the percentage of health remaining
---@param percent number The percentage of an Entity's max health it has remaining as a value in the range [0-1]
---@return Color
local function GetHealthColor( percent )
    local healthColor = globalSettings.Colors.HealthHighColor

    if percent <= 0.5 then
        healthColor = globalSettings.Colors.HealthMedColor
    end

    if percent <= 0.25 then
        healthColor = globalSettings.Colors.HealthLowColor
    end

    return healthColor
end

--#endregion

--#region Powerups

---@class PowerupIcon
---@field Name string
---@field Number integer
---@field UV Rectangle
---@field IconBox Rectangle
---@field Timer number
---@field Material IMaterial

local POWERUP_PIXEL_UV_64X64 = rect.NewRectangle( 0, 0, 64, 64 )
local POWERUP_OFFSET_10X40 = Vector( 10, 40 )

LIB.MaxIcons = 5
LIB.PowerupTime = 6
LIB.PowerupBoxWidth = 80
LIB.PowerupBoxHeight = 55
LIB.PowerupPickupAnimationDuration = 1

LIB.PowerupBoxUvUpperLeft    = Vector( 50, 1 );
LIB.PowerupBoxUvLowerRight   = Vector( 127, 52 );

LIB.PowerupBoxBase = Vector( LIB.PowerupBoxWidth + 6, 112 )
LIB.PowerupBoxSpacing = LIB.PowerupBoxHeight + 10

---For weapons, health, and armor pickup notifications
---@type table<PowerupIcon>
LIB.RightPowerupIconList = LIB.RightPowerupIconList or {}

-- For keys
---@type table<PowerupIcon>
LIB.LeftPowerupIconList = LIB.LeftPowerupIconList or {}

---Adds a new powerup to either the left or right powerup list
---@param name string
---@param number integer
---@param material IMaterial
---@param pixelUvs Rectangle
---@param offset Vector
---@param addToRightList boolean
function LIB.PowerupAdd( name, number, material, pixelUvs, offset, addToRightList )
    ---@class PowerupIcon
    local data = {}
    data.Material = material

    local textureSize = material:Width()
    local uvs
    if textureSize > 0 then
        uvs = pixelUvs / textureSize
    end
    data.UV = uvs or pixelUvs

    data.IconBox = rect.CopyRectangle( pixelUvs )
    data.IconBox = data.IconBox + offset + Vector( 0, -40.0 ) - data.IconBox:UpperLeft()

    data.Name = name
    data.Number = number
    data.Timer = LIB.PowerupTime

    if addToRightList then
        LIB.RightPowerupIconList[ #LIB.RightPowerupIconList + 1 ] = data
    else
        LIB.LeftPowerupIconList[ #LIB.LeftPowerupIconList + 1 ] = data
    end
end

concommand.Add( "AddPowerup", function()
    LIB.AddDataLink()
    LIB.AddShieldGrant( 100 )
    LIB.AddHealthGrant( 40 )
    LIB.AddObjective( objectiveManager.ObjectiveType.TYPE_PRIMARY )
    LIB.AddObjective( objectiveManager.ObjectiveType.TYPE_SECONDARY )
    LIB.AddShieldUpgradeGrant( 10 )
    LIB.AddHealthUpgradeGrant( 10 )
    LIB.AddMapReveal()
end )

---Removes all active Powerups from the HUD
local function PowerupReset()
    LIB.LeftPowerupIconList = {}
    LIB.RightPowerupIconList = {}
end

---@param frameTime number
---@param animationTimer number
---@param isRightList boolean
---@return number animationTimer
local function PowerupListRender( powerupList, frameTime, animationTimer, isRightList )
    -- Remove the bottom of the list after a polite wait
    local listHasPowerups = #powerupList > 0
    if listHasPowerups then
        local isDoneAnimatingListBottom = powerupList[ 1 ].Timer < 0
        if  isDoneAnimatingListBottom then
            animationTimer = animationTimer + frameTime
            if animationTimer > LIB.PowerupPickupAnimationDuration then
                animationTimer = 0
                table.remove( powerupList, 1 )
            end
        end
    else
        animationTimer = 0
    end

    local box = rect.VectorRectangle( LIB.PowerupBoxUvUpperLeft, LIB.PowerupBoxUvLowerRight )
    local start = Vector( ScrW(),  ScrH() ) - LIB.PowerupBoxBase
    box = box + start - box:LowerLeft()

    if not isRightList then
        box = box - Vector( box.Left - 6, 75 )
    end
    ---@cast box Rectangle

    surface.SetFont( styleManager.Fonts.IngameText )

    for index, powerup in ipairs( powerupList ) do
        if index > LIB.MaxIcons then break end
        ---@cast powerup PowerupIcon

        powerup.Timer = powerup.Timer - frameTime

        -- Feels unnecessary
        local drawBox = box

        local green
        local white

        local isBottomIcon = index == 1
        local isAnimating = animationTimer > 0
        if isBottomIcon and isAnimating then
            local alpha = math.Clamp( 1 - ( animationTimer / LIB.PowerupPickupAnimationDuration ), 0, 1 ) * 255
            green = Color( 0, 255, 0, alpha )
            white = Color( 255, 255, 255, alpha )
        else
            green = Color( 0, 255, 0, 255 )
            white = Color( 255, 255, 255, 255 )
        end

        local iconBox = powerup.IconBox
        iconBox = iconBox + drawBox:UpperLeft()
        ---@cast iconBox Rectangle

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
            local textY = drawBox.Top + LIB.PowerupBoxHeight - 15
            local textWidth = render2DSentence.GetTextWidth( text )

            -- Adjust text X position to keep text from going off the right side of the screen
            local textEndX = textX + textWidth + 1
            if textEndX > ScrW() then
                textX = ScrW() - ( textWidth + 1 )
            end

            render2DSentence.DrawText( textX, textY, text, white )
        end

        -- Draw powerup count
        if isRightList and powerup.Number ~= 0 then
            local text = powerup.Number
            local textX = drawBox.Right - 12
            local textY = drawBox.Top + 1

            render2DSentence.DrawText( textX, textY, tostring( text ), white )
        end

        -- Drop remaining icons down
        local isTimeToAnimate = animationTimer > LIB.PowerupPickupAnimationDuration * 0.5
        if isBottomIcon and isTimeToAnimate then
            box = box + Vector( 0, ( ( 2 * animationTimer / LIB.PowerupPickupAnimationDuration ) - 1 ) * LIB.PowerupBoxSpacing )
        end

        box = box - Vector( 0, LIB.PowerupBoxSpacing )
    end

    return animationTimer
end


local function PowerupRender()
    local frameTime = RealFrameTime()

    -- Mimicking the behavior of C++ static variables declared within functions
    LIB.LeftAnimateTimer = LIB.LeftAnimateTimer or 0
    LIB.RightAnimateTimer = LIB.RightAnimateTimer or 0

    LIB.LeftAnimateTimer = PowerupListRender( LIB.LeftPowerupIconList, frameTime, LIB.LeftAnimateTimer, false )
    LIB.RightAnimateTimer = PowerupListRender( LIB.RightPowerupIconList, frameTime, LIB.RightAnimateTimer, true )
end

function LIB.AddPowerupWeapon( id, rounds )
end

function LIB.AddPowerupAmmo( id, rounds )
end

---Adds an armor powerup notification
---@param strength number The amount of armor gained
function LIB.AddShieldGrant( strength )
    local materialName = LIB.Materials.Pickups.Armor3
    if strength > 75 then
        materialName = LIB.Materials.Pickups.Armor1
    elseif strength > 30 then
        materialName = LIB.Materials.Pickups.Armor2
    end

    local powerupName = translateDB.GetString( "IDS_Power_up_Armor_00" )

    LIB.PowerupAdd( powerupName, math.floor( strength ), materialName, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, true )
end

---Adds a health powerup notification
---@param amount number
function LIB.AddHealthGrant( amount )
    local materialName = LIB.Materials.Pickups.Health1
    if amount > 75 then
        materialName = LIB.Materials.Pickups.Health3
    elseif amount > 30 then
        materialName = LIB.Materials.Pickups.Health2
    end

    local powerupName = translateDB.GetString( "IDS_Power_up_Health_00" )

    LIB.PowerupAdd( powerupName, math.floor( amount ), materialName, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, true )
end

---Adds an armor upgrade powerup notification
---@param strength number
function LIB.AddShieldUpgradeGrant( strength )
    local powerupName = translateDB.GetString( "IDS_Power_up_Armor_Upgrade" )
    LIB.PowerupAdd( powerupName, math.floor( strength ), LIB.Materials.Pickups.ArmorUpgrade, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
end

---Adds a health upgrade powerup notification
---@param amount number
function LIB.AddHealthUpgradeGrant( amount )
    local powerupName = translateDB.GetString( "IDS_Power_up_Health_Upgrade" )
    LIB.PowerupAdd( powerupName, math.floor( amount ), LIB.Materials.Pickups.HealthUpgrade, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
end

---Adds a security keycard powerup notification
---@param key integer
function LIB.AddKeyGrant( key )
    local powerupMaterial = LIB.Materials.Pickups.GreenKeycard
    if key == 3 then
        powerupMaterial = LIB.Materials.Pickups.RedKeycard
    elseif key == 2 then
        powerupMaterial = LIB.Materials.Pickups.YellowKeycard
    end

    local powerupName = translateDB.GetString( "IDS_Power_up_SecurityCard" )

    LIB.PowerupAdd( powerupName, 0, powerupMaterial, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
end

---Adds a primary or secondary powerup notification
---@param type ObjectiveType
function LIB.AddObjective( type )
    if type == objectiveManager.ObjectiveType.TYPE_PRIMARY then
        local powerupName = translateDB.GetString( "IDS_Enc_Obj_Priority_0_Primary" )
        LIB.PowerupAdd( powerupName, 0, LIB.Materials.Pickups.Eva1, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
    elseif type == objectiveManager.ObjectiveType.TYPE_SECONDARY then
        local powerupName = translateDB.GetString( "IDS_Enc_Obj_Priority_0_Secondary" )
        LIB.PowerupAdd( powerupName, 0, LIB.Materials.Pickups.Eva2, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
    end
end

---Adds a data disc powerup notification
function LIB.AddDataLink()
    local powerupName = translateDB.GetString( "IDS_Power_up_DataDisc_01" )
    LIB.PowerupAdd( powerupName, 0, LIB.Materials.Pickups.CdRom, POWERUP_PIXEL_UV_64X64, POWERUP_OFFSET_10X40, false )
end

---Adds a data disc powerup notification
function LIB.AddMapReveal()
    LIB.AddDataLink()
end

--#endregion

--#region Weapon Display

LIB.WeaponBoxUvUpperLeft    = Vector( 0, 0 );
LIB.WeaponBoxUvLowerRight   = Vector( 95, 95 );

local WEAPON_DISPLAY_WEAPON_OFFSET = Vector( 100, 110 )

local function WeaponBoxRender()
    local boxUv = rect.VectorRectangle( LIB.WeaponBoxUvUpperLeft, LIB.WeaponBoxUvLowerRight )
    local drawBox = rect.CopyRectangle( boxUv )

    boxUv = boxUv / 256
    drawBox = drawBox + Vector( ScrW(), ScrH() ) - WEAPON_DISPLAY_WEAPON_OFFSET - drawBox:UpperLeft()
    ---@cast drawBox Rectangle

    surface.SetMaterial( LIB.Materials.Hud.Main )
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawTexturedRectUV( drawBox.Left, drawBox.Top, drawBox:Width(), drawBox:Height(), boxUv.Left, boxUv.Top, boxUv.Right, boxUv.Bottom )
end


local function WeaponRender()
    WeaponBoxRender()
    --WeaponImageRender()
    --WeaponNameRender()
    --WeaponClipCountRender()
    --WeaponTotalCountRender()
end

--#endregion

--#region Reticle

-- Reticle
LIB.ReticleWidth = ( 64 / 640 )
LIB.ReticleWidth = ( 64 / 480 )

--#endregion

--#region Loops

local function Render()
    render.PushFilterMin( TEXFILTER.POINT )
    render.PushFilterMag( TEXFILTER.POINT )

    -- InfoRender()
    PowerupRender()
    WeaponRender()
    -- WeaponChartRender()
    -- DamageRender()
    -- TargetRender()
    -- ObjectiveRender()

    render.PopFilterMag()
    render.PopFilterMin()
end

hook.Add( "HUDPaint", "A1_Renegade_RenderHUD", Render )

--#endregion