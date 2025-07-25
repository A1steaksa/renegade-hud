-- Based on HUDInfo within Code/Combat/hudinfo.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of HudInfo
    --- @class HudInfo
    STATIC = CNC.CreateExport()
end


--#region Imports

--- @type CombatManager
local combatManager = CNC.Import( "renhud/client/code/combat/combat-manager.lua" )

--- @type GameType
local gameType = CNC.Import( "renhud/client/code/combat/game-type.lua" )

--- @type BuildingsBridge
local buildingsBridge = CNC.Import( "renhud/client/bridges/buildings.lua" )

--- @type InfoEntityLib
local infoEntityLib = CNC.Import( "renhud/sh_info-entity.lua" )
--#endregion

--[[ Console Variables ]] do
    --[[ Info Entity Timer Duration ]] do

        --- How long, in seconds, should an Entity be targeted after looking away?
        --- @type number
        STATIC.InfoEntityTimerDuration = CreateClientConVar( "ren_info_entity_timer_duration", "5", true, false, "(Renegade) How long, in seconds, should an Entity be targeted after looking away?", 0 ):GetFloat()

        --- @param newValue string
        cvars.AddChangeCallback( "ren_info_entity_timer_duration", function( _, _, newValue )
            STATIC.InfoEntityTimerDuration = ( tonumber( newValue ) or 0 )
        end )
    end
end


--[[ Static Functions and Variables ]] do

    local CLASS = "HudInfo"

    --- [[ Public ]]

    STATIC.WeaponTargetPosition = Vector( 0, 0, 0 )
    STATIC.WeaponTargetEntity = NULL
    STATIC.InfoEntity = NULL
    STATIC.DisplayActionBar = false
    STATIC.ActionStatusValue = 0
    STATIC._IsHudHelpTextDirty = true
    STATIC.HudHelpText = nil
    STATIC.HudHelpTextColor = Color( 255, 255, 255 )
    STATIC.IsMct = false

    --[[ Where is the camera looking? ]] do

        --- @param pos Vector
        function STATIC.SetCameraTargetPosition( pos )
            STATIC.CameraTargetPosition = pos
        end

        --- @return Vector
        function STATIC.GetCameraTargetPosition()
            return STATIC.CameraTargetPosition
        end
    end


    --[[ Where is the Star's weapon pointing? ]] do

        --- @param pos Vector
        function STATIC.SetWeaponTargetPosition( pos )
            STATIC.WeaponTargetPosition = pos
        end

        --- @return Vector
        function STATIC.GetWeaponTargetPosition()
            return STATIC.WeaponTargetPosition
        end

        --- Stores the Entity that is directly under the Player's reticle
        --- @param obj Entity
        function STATIC.SetWeaponTargetEntity( obj )
            STATIC.WeaponTargetEntity = obj
        end

        --- Retrieves the Entity that is directly under the Player's reticle
        --- @return Entity
        function STATIC.GetWeaponTargetEntity()
            return STATIC.WeaponTargetEntity
        end
    end


    --[[ What entity and building should we be displaying information for? ]] do

        --- @param ent Entity
        --- @param isMct boolean?
        function STATIC.SetInfoEntity( ent, isMct )
            if not isMct then
                isMct = false
            end

            STATIC.LastInfoEntity = STATIC.LastInfoEntity or NULL
            STATIC.LastInfoHealth = STATIC.LastInfoHealth or 0

            local isSameEntity = STATIC.LastInfoEntity == ent

            STATIC.IsMct = isMct

            if IsValid( ent ) then
                local health = ent:Health()
                local isSameHealth = STATIC.LastInfoHealth == health

                if buildingsBridge.IsBuilding( ent ) then
                    if isSameEntity and isSameHealth then
                        if not isMct and gameType.IsMission() then
                            return
                        end
                    end
                end

                STATIC.LastInfoHealth = health
            end

            -- Update the server if we've changed our InfoEntity
            if not isSameEntity then
                infoEntityLib.SendUpdatedInfoEntity( ent )
            end

            STATIC.LastInfoEntity = ent

            STATIC.InfoEntity = ent
            STATIC.InfoEntityTimer = 0
        end

        --- Retrieves the Entity that is currently being targeted and displaying its health, name, and size
        --- @return Entity
        function STATIC.GetInfoEntity()
            return STATIC.InfoEntity
        end

        --- Is the current InfoEntity a Master Control Terminal?
        --- @return boolean
        function STATIC.GetInfoEntityIsMct()
            return STATIC.IsMct
        end

        --- Checks whether or not the current InfoEntity should be cleared and clears it if it should be
        function STATIC.UpdateInfoEntity()
            local infoEntity = STATIC.GetInfoEntity()
            if not IsValid( infoEntity ) then return end

            -- Forget buildings as soon as we aren't looking at them in multiplayer
            if not gameType.IsMission() and buildingsBridge.IsBuilding( infoEntity ) then
                if STATIC.InfoEntityTimer > 0 then
                    STATIC.InfoEntity = NULL
                    infoEntity = NULL
                end
            end

            --[[ Forget Dead Entities ]] do

                if infoEntityLib.HasEntityInfo( infoEntity ) then
                    local targetInfo = infoEntityLib.GetEntityInfo( infoEntity ) --[[@as InfoEntityData]]

                    if targetInfo.ShowHealthBar then
                        if targetInfo.HealthPercent == 0 then
                            STATIC.InfoEntity = NULL
                            infoEntity = NULL
                        end
                    end
                end
            end

            STATIC.InfoEntityTimer = STATIC.InfoEntityTimer + FrameTime()

            if STATIC.InfoEntityTimer > STATIC.InfoEntityTimerDuration then
                STATIC.InfoEntity = NULL
                infoEntity = NULL
            else
                if not IsValid( infoEntity ) then return end

                local bounds = infoEntityLib.GetEntityBoundingBox( infoEntity )

                local shouldCullTarget = combatManager:GetCamera():CullBox( bounds )
                if shouldCullTarget then
                    -- TODO: Fix this
                    -- Omitted removing info entity while frustum culling logic is broken
                    -- STATIC.InfoEntity = NULL
                end
            end
        end
    end


    --[[ Should we display the action statusbar, and what is it currently at? ]] do

        ---@param shouldDisplay boolean
        function STATIC.SetDisplayActionStatusBar( shouldDisplay )
            STATIC.DisplayActionBar = shouldDisplay
        end

        --- @return boolean
        function STATIC.GetDisplayActionStatusBar()
            return STATIC.DisplayActionBar
        end

        --- @return number
        function STATIC.GetActionStatusValue()
            return STATIC.ActionStatusValue
        end

        --- @param value number
        function STATIC.SetActionStatusValue( value )
            STATIC.ActionStatusValue = value
        end
    end


    --[[ HUD Help Text ]] do

        ---@param str string
        ---@param color Color?
        function STATIC.SetHudHelpText( str, color )
            if not color then
                color = Color( 255, 255, 255 )
            end

            STATIC.HudHelpText = str
            STATIC.HudHelpTextColor = color
            STATIC._IsHUDHelpTextDirty = true
        end

        --- @param isDirty boolean
        function STATIC.SetIsHudHelpTextDirty( isDirty )
            STATIC._IsHUDHelpTextDirty = isDirty
        end

        --- @return boolean
        function STATIC.IsHudHelpTextDirty()
            return STATIC._IsHUDHelpTextDirty
        end

        --- @return string
        function STATIC.GetHudHelpText()
            return STATIC.HudHelpText
        end

        --- @return Color
        function STATIC.GetHudHelpTextColor()
            return STATIC.HudHelpTextColor
        end
    end


    --- [[ Private ]]

    --- @class HudInfo
    --- @field private CameraTargetPosition Vector
    --- @field private WeaponTargetEntity Entity The Entity that is directly under the Player's reticle, if any. May be NULL.
    --- @field private WeaponTargetPosition Vector The position, in world space, where the Player's weapon is pointed.
    --- @field private InfoEntity Entity The Entity whose name, health, and size is being displayed on the HUD as target info. May be NULL.
    --- @field private InfoEntityTimer number How long, in seconds, that the current Info Entity has been drawing.  Resets each time the InfoEntity is looked at.
    --- @field private DisplayActionBar boolean
    --- @field private ActionStatusValue number
    --- @field private HudHelpText string
    --- @field private _IsHudHelpTextDirty boolean
    --- @field private HudHelpTextColor Color
    --- @field private IsMct boolean
end