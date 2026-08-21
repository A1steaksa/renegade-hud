local hudElements = {
    [ "CHudAmmo" ]                   = false,
    [ "CHudBattery" ]                = false,
    [ "CHudChat" ]                   = true,
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

local hudActiveConVar = GetConVar( "ren_hud_enabled" )
local isHudActive = hudActiveConVar:GetBool()
cvars.AddChangeCallback( "ren_hud_enabled", function( _, _, newValue )
    isHudActive = hudActiveConVar:GetBool()
end )

hook.Add( "HUDShouldDraw", "A1_Renegade_HideHud", function( name )
    if not isHudActive then return end
    if LocalPlayer().GetActiveWeapon and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera" then return end
    return hudElements[ name ]
end )

hook.Add( "HUDDrawTargetID", "A1_Renegade_HidePlayerId", function()
    if not isHudActive then return end
    return false
end )