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

hook.Add( "HUDShouldDraw", "A1_Renegade_HideHud", function( name )
    return hudElements[ name ]
end )

hook.Add( "HUDDrawTargetID", "A1_Renegade_HidePlayerId", function()
    return false
end )