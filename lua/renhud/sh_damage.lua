--- @class Renegade
local CNC = CNC_RENEGADE

-- A library supporting the HUD's Damage Indicator rendering
--- @class DamageLib
local LIB = CNC.CreateExport()
local CLASS = "DamageLib"
local isHotload = not table.IsEmpty( LIB )

--#region Enums

    --- @enum DamageDirection
    LIB.DAMAGE_DIRECTION = {
        ALL             = -1,
        NONE            =  0,
        FRONT_RIGHT     =  1,
        RIGHT           =  2,
        BEHIND_RIGHT    =  3,
        BEHIND          =  4,
        BEHIND_LEFT     =  5,
        LEFT            =  6,
        FRONT_LEFT      =  7,
        FRONT           =  8
    }
    local damageDirectionEnum = LIB.DAMAGE_DIRECTION
--#endregion


--#region Imports

    --- @type CombatManager
    local combatManager = CNC.Import( "renhud/client/code/combat/combat-manager.lua" )

    --- @type CommonBridge
    local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )
--#endregion


--[[ Networking Damage ]] do

    if SERVER then
        -- Used by the server to send incoming damage info to each Player
        -- Used by clients to let the server know that they would like to receive incoming damage info
        util.AddNetworkString( "A1_Renegade_PlayerDamage" )

        --- @private
        --- Players with keys in this table should receive incoming damage info
        --- @type table<Player, boolean>
        LIB.DamageInfoSubscribers = LIB.DamageInfoSubscribers or {}

        --- @private
        --- The damage types that are considered to be coming from all directions
        LIB.OmnidirectionalDamageTypes = {
            [DMG_CRUSH] = true,
            [DMG_BURN] = true,
            [DMG_FALL] = true,
            [DMG_BLAST] = true,
            [DMG_DROWN] = true,
            [DMG_PARALYZE] = true,
            [DMG_NERVEGAS] = true,
            [DMG_RADIATION] = true,
            [DMG_SLOWBURN] = true,
            [DMG_DISSOLVE] = true
        }

        --- @private
        --- @param direction integer
        --- @param ply Player The player to send damage info to
        function LIB.SendIncomingDamageInfo( direction, ply )
            net.Start( "A1_Renegade_PlayerDamage" )
            net.WriteInt( direction, 4 )
            net.Send( ply )
        end

        --- @private
        --- Process player damage info subscription changes
        --- @param ply Player The player that is changing their subscription
        function LIB.ReceiveDamageInfoSubscriptionChange( _, ply )
            local shouldReceiveDamageInfo = net.ReadBool()

            if shouldReceiveDamageInfo then
                LIB.DamageInfoSubscribers[ply] = true
            else
                LIB.DamageInfoSubscribers[ply] = nil
            end
        end

        -- Listen for players (un)subscribing
        net.Receive( "A1_Renegade_PlayerDamage", LIB.ReceiveDamageInfoSubscriptionChange )

        --- @private
        --- Determine the direction that a player took damage from and send it to them if they have subscribed to incoming damage info
        --- @param ply Player
        --- @param dmgInfo CTakeDamageInfo
        --- @param tookDamage boolean Was damage actually applied?
        function LIB.ProcessPlayerDamage( ply, dmgInfo, tookDamage )
            if not IsValid( ply ) or not isentity( ply ) or not ply:IsPlayer() then return end

            if not LIB.DamageInfoSubscribers[ply] then return end

            local direction = damageDirectionEnum.NONE

            local inflictor = dmgInfo:GetInflictor()

            local isDamageOmnidirectional = LIB.OmnidirectionalDamageTypes[dmgInfo:GetDamageType()]
            if isDamageOmnidirectional then
                direction = damageDirectionEnum.ALL
            elseif not IsValid( inflictor ) then
                direction = damageDirectionEnum.ALL
            else
                local directionVector = ( inflictor:GetPos() - ply:GetPos() )
                local relativeDirection = commonBridge.GetEyeTransform( ply ):InverseRotateVector( directionVector )

                -- "Convert direction into 0 .. 7"
                local angle = math.atan2( relativeDirection.y, -relativeDirection.x )
                direction = math.floor( 8 * angle / math.rad( 360 ) + 8.5 )
            end

            LIB.SendIncomingDamageInfo( direction, ply )
        end

        hook.Add( "PostEntityTakeDamage", "A1_Renegade_PlayerTakesDamage", LIB.ProcessPlayerDamage )
    end

    if CLIENT then
        local damageIndicatorsEnabledConVar = CreateConVar( "ren_damage_indicators_enabled", "1", { FCVAR_ARCHIVE }, "(Renegade) Should damage direction indicators draw?", 0, 1 )

        -- Keep the server up to date with our incoming damage subscription status
        cvars.AddChangeCallback( damageIndicatorsEnabledConVar:GetName(), function( _, _, newValue )
            LIB.SendDamageInfoSubscriptionChange( damageIndicatorsEnabledConVar:GetBool() )
        end, "Default" )

        --- Called when we're informed by the server that we have received damage
        function LIB.ReceiveIncomingDamage()
            local direction = net.ReadInt( 4 )
            combatManager.ShowStarDamageDirection( direction )
        end

        -- Listen for incoming damage
        net.Receive( "A1_Renegade_PlayerDamage", LIB.ReceiveIncomingDamage )

        --- @private
        --- Informs the server about a change in our incoming damage subscription state
        --- @param isSubscribed boolean
        function LIB.SendDamageInfoSubscriptionChange( isSubscribed )
            net.Start( "A1_Renegade_PlayerDamage" )
            net.WriteBool( isSubscribed )
            net.SendToServer()
        end

        -- Send the server our initial state
        hook.Add( "InitPostEntity", "A1_Renegade_DamageIndicatorInit", function()
            LIB.SendDamageInfoSubscriptionChange( damageIndicatorsEnabledConVar:GetBool() )
        end )

        -- Send the server our state if we're hotloading
        if isHotload then
            LIB.SendDamageInfoSubscriptionChange( damageIndicatorsEnabledConVar:GetBool() )
        end
    end
end