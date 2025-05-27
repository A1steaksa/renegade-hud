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

    --- @type AABox
    local aABox = CNC.Import( "renhud/code/wwmath/aabox.lua" )

    --- @type CombatManager
    local combatManager = CNC.Import( "renhud/code/combat/combat-manager.lua" )

    --- @type GameType
    local gameType = CNC.Import( "renhud/code/combat/game-type.lua" )
--#endregion


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


        --- @param obj Entity
        function STATIC.SetWeaponTargetEntity( obj )
            STATIC.WeaponTargetEntity = obj
        end

        --- @return Entity
        function STATIC.GetWeaponTargetEntity()
            return STATIC.WeaponTargetEntity
        end
    end


    --[[ What entity and building should we be displaying information for? ]] do

        --- @param ent Entity
        --- @param isMct boolean?
        function STATIC.SetInfoEntity( ent , isMct )
            if not isMct then
                isMct = false
            end

            STATIC.LastInfoEntity = STATIC.LastInfoEntity or NULL
            STATIC.LastInfoHealth = STATIC.LastInfoHealth or 0

            STATIC.IsMct = isMct

            if IsValid( ent ) then

                local health = ent:Health()

                local isSameEntity = STATIC.LastInfoEntity == ent
                local isSameHealth = STATIC.LastInfoHealth == health
                if ent:IsBuilding() then
                    if isSameEntity and isSameHealth then
                        if not isMct and gameType.IsMission() then
                            return
                        end
                    end
                end

                STATIC.LastInfoEntity = ent
                STATIC.LastInfoHealth = health
            end

            STATIC.InfoEntity = ent
            STATIC.InfoEntityTimer = 0
        end

        --- @return Entity
        function STATIC.GetInfoEntity()
            return STATIC.InfoEntity
        end


        --- @return boolean
        function STATIC.GetInfoEntityIsMct()
            return STATIC.IsMct
        end

        function STATIC.ClearInfoEntity()
            STATIC.InfoEntity = NULL;
        end

        function STATIC.UpdateInfoEntity()

            local info = STATIC.GetInfoEntity()

            if not IsValid( info ) then return end

            -- Forget buildings as soon as we aren't looking at them in multiplayer
            if not gameType.IsMission() and info:IsBuilding() then
                if STATIC.InfoEntityTimer > 0 then
                    STATIC.InfoEntity = NULL
                    info = NULL
                end
            end

            -- Forget dead entities
            if info:Health() <= 0 then
                STATIC.InfoEntity = NULL
                info = NULL
            end

            STATIC.InfoEntityTimer = STATIC.InfoEntityTimer + FrameTime()

            if STATIC.InfoEntityTimer > 5 then
                STATIC.InfoEntity = NULL
                info = NULL
            else
                if not IsValid( info ) then return end

                local minBounds, maxBounds = info:GetCollisionBounds()

                local extents = maxBounds - minBounds
                local center = extents / 2

                local bounds = aABox.New( center, extents )

                local shouldCullTarget = combatManager:GetCamera():CullBox( bounds )

                if shouldCullTarget then
                    STATIC.InfoEntity = NULL
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
    --- @field private WeaponTargetEntity Entity
    --- @field private WeaponTargetPosition Vector
    --- @field private InfoEntity Entity
    --- @field private InfoEntityTimer number
    --- @field private DisplayActionBar boolean
    --- @field private ActionStatusValue number
    --- @field private HudHelpText string
    --- @field private _IsHudHelpTextDirty boolean
    --- @field private HudHelpTextColor Color
    --- @field private IsMct boolean
end