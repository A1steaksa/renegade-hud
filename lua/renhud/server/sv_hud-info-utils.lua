-- This class supports the HUD's target info box

--- @class Renegade
local CNC = CNC_RENEGADE

local LIB

--[[ Class Setup ]] do

    --- The static components of HudInfoUtilsServer
    --- @class HudInfoUtilsServer
    LIB = CNC.CreateExport()
end


--#region Imports

--- @type SharedCommon
local sharedCommon = CNC.Import( "renhud/sh_common.lua" )
--#endregion


--#region enums

local dispositionEnum = sharedCommon.DISPOSITION
--#endregion


--[[ Static Functions and Variables ]] do
    local CLASS = "HudInfoUtilsServer"

    -- Used to request target info for the HUD from the server
    util.AddNetworkString( "A1_Renegade_EntityInfo" )

    --- [[ Public ]]

    --- @class HudInfoUtilsServer

    -- Let clients know that we're running the server side of this addon
    SetGlobal2Bool( "A1_Renegade_ServerRunning", true )

    --[[ Target Info ]] do

        -- Set up server-side throttling of target info requests
        local targetInfoThrottler = Throttler:build()
        targetInfoThrottler.id = "A1_Renegade_EntityInfo"

        --- Each player has their own request "budget"
        --- @diagnostic disable-next-line: duplicate-set-field
        targetInfoThrottler.context = function( ply )
            return ply
        end

        -- Each player has a budget of up to 100 info requests
        targetInfoThrottler.budget = 100

        -- Refill 1 budget per second
        targetInfoThrottler.refillRate = 1

        -- Wait 0.5 seconds between requests if a player runs out of budget
        targetInfoThrottler.delay = 0.5

        -- Store each player's budget info in this table 
        LIB.InfoRequestContext = {}
        targetInfoThrottler.context = LIB.InfoRequestContext

        --- Determines if an Entity can be damaged
        --- @param ent Entity
        --- @return boolean
        function LIB.CanEntityTakeDamage( ent )
            local result = ent:GetInternalVariable( "m_takedamage" ) == 2 -- 2 is DAMAGE_YES

            if Glide and isfunction( ent.GetChassisHealth ) then
                result = true
            end

            return result
        end

        --- Determines if an Entity can be activated with +use
        --- @param ent Entity
        --- @return boolean
        function LIB.IsEntityUsable( ent )
            local class = ent:GetClass():lower()

            -- Hardcoding some known interactions
            if class == "sent_ball" then return true end

            -- Locked Entities aren't usable
            local isLocked = ent:GetInternalVariable( "m_bLocked" )
            local isLockable = isLocked ~= nil
            if isLockable then
                if isLocked then
                    return false
                end
            end

            -- Ammo Crates
            if class == "item_ammo_crate" then
                return true
            end

            -- Health and Armor Chargers
            local juice = ent:GetInternalVariable( "m_flJuice" )
            if juice ~= nil then
                if juice > 0 then
                    return true
                end
            end

            -- Buttons
            if class == "func_button" then
                return true
            end

            -- Empty vehicles are usable
            if ent:IsVehicle() then
                --- @cast ent Vehicle

                local hasDriver = IsValid( ent:GetDriver() )
                if not hasDriver then
                    return true
                end

                if Glide and isfunction( ent.GetFreeSeat ) then
                    -- Support passenger seats
                    local hasOpenSeat = ent:GetFreeSeat() ~= nil
                    if hasOpenSeat then
                        return true
                    end
                end

            end

            -- Doors
            if class == "prop_door_rotating" or class == "func_door_rotating" or class == "func_door" then
                local useOpens  = ent:HasSpawnFlags( 256  ) -- 256 is "Use Opens"
                local useCloses = ent:HasSpawnFlags( 8192 ) -- 8192 is "Use Closes"
                return ( useOpens or useCloses )
            end

            return false
        end

        --- Attempts to determine how one Player feels about another Player
        --- @param judged Player The Player about whom we are retrieving the disposition
        --- @param judger Player The Player whose opinion we are finding
        --- @return Disposition # How `plyJudging` feels about `plyBeingJudged`
        function LIB.GetPlayerDisposition( judged, judger )
            if not IsValid( judged ) or not IsValid( judger ) then
                return dispositionEnum.Neutral
            end

            local result = dispositionEnum.Neutral

            -- We like ourselves in this household
            if judged == judger then
                result = dispositionEnum.Like
            end

            -- Being on the same team is a good sign for friendship
            local judgedTeam = judged:Team()
            local isJudgedOnATeam = judgedTeam ~= TEAM_UNASSIGNED
            if isJudgedOnATeam then
                if judgedTeam == judger:Team() then
                    result = dispositionEnum.Like
                end
            end

            return result
        end

        --- Determines how an Entity feels about a Player
        --- @param ent Entity
        --- @return Disposition
        function LIB.GetEntityDisposition( ply, ent )
            local result = dispositionEnum.Neutral

            if ent:IsNPC() then
                --- @cast ent NPC
                result = ent:Disposition( ply )
            end

            if ent:IsPlayer() then
                --- @cast ent Player
                result = LIB.GetPlayerDisposition( ply, ent )
            end

            -- Check disposition of vehicle occupants
            if ent:IsVehicle() then
                --- @cast ent Vehicle

                local driver = ent:GetDriver() --[[@as Player]]
                result = LIB.GetPlayerDisposition( ply, driver )
            end

            return result
        end

        --- Gathers server-only HUD-relevant information about an Entity and sends it to the requester
        --- @param ply Player The Player requesting the data
        local function SendEntityInfo( _, ply )
            -- The Entity the player wants information about
            local ent = net.ReadEntity()
            if not IsValid( ent ) then return end

            -- Gather information about the Entity
            local takesDamage   = LIB.CanEntityTakeDamage( ent )
            local isUsable      = LIB.IsEntityUsable( ent )
            local disposition   = LIB.GetEntityDisposition( ply, ent )

            -- Send our findings back to the requester
            net.Start( "A1_Renegade_EntityInfo" )

            -- The Entity that we're sending info back for
            net.WriteEntity( ent )

            -- Disposition AKA How does the Entity feel about the player?
            net.WriteInt( disposition, 3 )

            -- Is it damagable?
            net.WriteBool( takesDamage )

            -- Can it be +use'd?
            net.WriteBool( isUsable )

            net.Send( ply )
        end

        net.Receive( "A1_Renegade_EntityInfo", Throttler:create( SendEntityInfo, targetInfoThrottler ) )
    end
end