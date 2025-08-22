--- @class Renegade
local CNC = CNC_RENEGADE

-- A library supporting the HUD's InfoEntity rendering
--- @class InfoEntityLib
local LIB = CNC.CreateExport()
local CLASS = "InfoEntityLib"


--#region Imports

--- @type PlayerType
local playerTypeLib = CNC.Import( "renhud/client/code/combat/player-type.lua" )

--- @type AABox
local aABox = CNC.Import( "renhud/client/code/wwmath/aabox.lua" )

--- @type CameraBridge
local cameraBridge = CNC.Import( "renhud/client/bridges/camera.lua" )
--#endregion


--#region Enums

--- Describes how Entities feel about each other
--- @enum Disposition
LIB.DISPOSITION = {
    Friendly = 1,
    Enemy    = 2,
    Neutral  = 3
}
local dispositionEnum = LIB.DISPOSITION

local playerTypeEnum = playerTypeLib.PLAYER_TYPE_ENUM
--#endregion


--- Information used to target and display an Entity on the HUD
--- @class InfoEntityData
--- @field InfoEntity Entity
--- @field ShouldTarget boolean Should this Entity be targeted? This may be different from the result of LIB.IsEntityTargetable depending on the specific situation of this individual Entity.
--- @field DisplayName string How this Entity's name will be displayed on the HUD
--- @field TeamToShow PlayerTypeEnum Which icon should be drawn when this Entity is targeted? Note: Neutral will be used as a fallback for options without a unique icon.
--- @field FeelingTowardPlayer Disposition
--- @field ShowHealthBar boolean Should the Entity's health bar be drawn?
--- @field IsHealthServerAuthoritative boolean Should the client try to calculate the health themselves?
--- @field HealthPercent number How much health this Entity has, as a percentage between `0` and `1`
--- @field ShowInteractionChevrons boolean Should this Entity draw the three triangles that indicate it is interactable?

--- @class InfoEntityLib
--- @field private Enabled boolean

function LIB.Init()
    if CLIENT then
        LIB.EntityInfoCache = {}
        LIB.Enabled = true
    end
end

function LIB.Shutdown()
    if CLIENT then
        LIB.EntityInfoCache = nil
        LIB.Enabled = nil
    end
end

--[[ Networking and Storing InfoEntities ]] do

    if SERVER then
        -- Used by the server to send info to each Player about their current InfoEntity
        -- Used by clients to let the server know their InfoEntity or lack of one
        util.AddNetworkString( "A1_Renegade_InfoEntity" )

        --- @private
        --- Pairs Players with Entities they have targeted as their InfoEntity and the data we retrieved for that Entity
        --- @type table<Player, table<Entity, InfoEntityData>>
        LIB.PlayerEntityInfoCache = {}

        --- @private
        --- Keeps track of which Entity each Player currently has as their InfoEntity
        --- @type table<Player, Entity>
        LIB.PlayerInfoEntities = {}

        --- @private
        --- @param data InfoEntityData The data to send
        --- @param ply Player The player to send the data to
        function LIB.SendInfoEntityData( data, ply )
            net.Start( "A1_Renegade_InfoEntity" )
            net.WriteEntity( data.InfoEntity )
            net.WriteString( data.DisplayName )
            net.WriteInt( data.TeamToShow, 8 )
            net.WriteInt( data.FeelingTowardPlayer, 8 )
            net.WriteBool( data.ShowHealthBar )
            net.WriteBool( data.IsHealthServerAuthoritative )
            net.WriteFloat( data.HealthPercent or -1 )
            net.WriteBool( data.ShowInteractionChevrons )
            net.Send( ply )
        end

        --- @private
        --- Retrieves either an existing InfoEntityData table or a newly created empty table for a given Entity and Player pairing
        --- @param ent Entity
        --- @param ply Player
        --- @return InfoEntityData
        function LIB.GetServerInfoEntityCacheEntry( ent, ply )
            local existingPlayerTable = LIB.PlayerEntityInfoCache[ply]
            if not existingPlayerTable then
                existingPlayerTable = {}
                LIB.PlayerEntityInfoCache[ply] = existingPlayerTable
            end

            local existingValue = existingPlayerTable[ent]
            if not existingValue then
                existingValue = {}
                existingPlayerTable[ent] = existingValue
            end

            return existingValue
        end

        --- @private
        --- Stores an InfoEntityData table for a given Player and Entity pairing
        --- @param ent Entity
        --- @param ply Player
        --- @param data InfoEntityData
        function LIB.SetServerInfoEntityCacheEntry( ent, ply, data )
            local playerTable = LIB.PlayerEntityInfoCache[ply]
            if not playerTable then
                playerTable = {}
                LIB.PlayerEntityInfoCache[ply] = playerTable
            end

            playerTable[ent] = data
        end

        --- @private
        --- Receives updated InfoEntity selections from players
        --- @param _ number The length of the request in bits
        --- @param ply Player The Player that is updating their InfoEntity
        function LIB.ReceiveInfoEntityData( _, ply )
            local newInfoEntity = net.ReadEntity()

            if not IsValid( newInfoEntity ) then
                LIB.PlayerInfoEntities[ply] = nil
                return
            end

            LIB.PlayerInfoEntities[ply] = newInfoEntity
        end
        net.Receive( "A1_Renegade_InfoEntity", LIB.ReceiveInfoEntityData )

        --[[ InfoEntity Updates ]] do

            --- Gathers fresh data for all active InfoEntities and sends them to their respective Players
            function LIB.DoAllInfoEntityUpdates()
                for ply, infoEntity in pairs( LIB.PlayerInfoEntities ) do
                    if IsValid( infoEntity ) then
                        local data = LIB.GatherInfoEntityData( infoEntity, ply )
                        LIB.SendInfoEntityData( data, ply )
                    end
                end
            end

            local updateDelayConVar = GetConVar( "ren_entityinfo_update_delay" )

            -- Schedule the updates
            timer.Create( updateDelayConVar:GetName(), updateDelayConVar:GetFloat(), 0, LIB.DoAllInfoEntityUpdates )

            -- Keep the update timer's duration up-to-date with the ConVar
            cvars.AddChangeCallback( updateDelayConVar:GetName(), function( _, _, newValue )
                timer.Adjust( updateDelayConVar:GetName(), tonumber( newValue ) or 1000 )
            end, "Default" )
        end
    end

    if CLIENT then

        --- @class EntityInfoLib
        --- @field private EntityInfoCache table<Entity, InfoEntityData> Pairs Entities with the InfoEntity data we have about them

        --- @param ent Entity
        --- @return boolean
        function LIB.HasEntityInfo( ent )
            return ( LIB.EntityInfoCache ~= nil ) and ( LIB.EntityInfoCache[ent] ~= nil )
        end

        --- Retrieves data about a given Entity or `nil` if no data is available.
        --- @param ent Entity
        --- @return InfoEntityData?
        function LIB.GetEntityInfo( ent )
            local data = LIB.EntityInfoCache[ent]

            -- Update the health value
            if not data.IsHealthServerAuthoritative then
                data.HealthPercent = LIB.GetEntityHealthPercent( ent )
            end

            return LIB.EntityInfoCache[ent]
        end

        --- Alert the server that our InfoEntity has either changed, or that we are keeping it the same
        --- @param ent Entity
        function LIB.SendUpdatedInfoEntity( ent )
            net.Start( "A1_Renegade_InfoEntity" )
            net.WriteEntity( ent )
            net.SendToServer()
        end

        --- @private
        --- Retrieves either an existing InfoEntityData table or a newly created empty table for a given Entity
        --- @param ent Entity
        --- @return InfoEntityData
        function LIB.GetClientInfoEntityCacheEntry( ent )
            local existingValue = LIB.EntityInfoCache[ent]
            if existingValue then
                return existingValue
            end

            local newTable = {}
            LIB.EntityInfoCache[ent] = newTable
            return newTable
        end

        --- @private
        --- Stores an InfoEntityData table for a given Entity
        --- @param ent Entity
        --- @param data InfoEntityData
        function LIB.SetClientInfoEntityCacheEntry( ent, data )
            LIB.EntityInfoCache[ent] = data
        end

        --- @private
        --- Receives and stores an InfoEntityData table from the server
        function LIB.ReceiveInfoEntityData()
            if not LIB.Enabled then return end

            local ent = net.ReadEntity()

            if not IsValid( ent ) then return end

            local data = LIB.GetClientInfoEntityCacheEntry( ent )
            data.InfoEntity = ent

            -- The server will only provide a DisplayName if it has an override
            local displayName = net.ReadString()
            if string.len( displayName ) > 0 then
                data.DisplayName = displayName
            else
                data.DisplayName = LIB.GetEntityDisplayName( ent )
            end

            data.TeamToShow                  = net.ReadInt( 8 )
            data.FeelingTowardPlayer         = net.ReadInt( 8 )
            data.ShowHealthBar               = net.ReadBool()
            data.IsHealthServerAuthoritative = net.ReadBool()

            -- Only update the health percentage if the server has an override for it
            local healthPercent = net.ReadFloat()
            if data.IsHealthServerAuthoritative then
                data.HealthPercent = healthPercent
            end

            data.ShowInteractionChevrons = net.ReadBool()

            data.ShouldTarget = data.ShouldTarget or data.ShowHealthBar or data.ShowInteractionChevrons
        end
        net.Receive( "A1_Renegade_InfoEntity", LIB.ReceiveInfoEntityData )
    end
end

if CLIENT then
    --[[ Finding InfoEntities ]] do

        local traceLengthConVar = GetConVar( "ren_entityinfo_max_length" )

        --- @private
        --- This table provides a blacklist of classes that are never targetable regardless of other factors.  
        --- * It is used to quickly determine if an Entity might ever be a valid target before doing more expensive data gathering.  
        --- * Entries should be lowercase.
        --- @type table<string, boolean>
        LIB.UntargetableClasses = {
            ["func_wall"]             = true,
            ["func_brush"]            = true,
            ["func_lod"]              = true,
            ["func_reflective_glass"] = true, -- It looks weird to target mirrors
            ["func_breakable_surf"]   = true, -- Shatterable glass in Renegade does not get targeted
        }


        --- Performs a trace from the camera to find a valid Entity to be our new InfoEntity
        --- @return Entity?
        --- @return number traceDistance
        function LIB.TraceForInfoEntity()
            local viewSetup = cameraBridge.GetViewSetup()

            local startPos = viewSetup.origin
            local endPos = startPos + viewSetup.angles:Forward() * traceLengthConVar:GetFloat()

            local ply = LocalPlayer()
            local filter
            if ply:InVehicle() then
                filter = { ply, ply:GetVehicle() }

                -- Support for Glide vehicles
                if Glide then
                    local glideVehicle = ply:GlideGetVehicle()
                    if IsValid( glideVehicle ) then
                        filter[#filter + 1] = glideVehicle
                    end
                end
            else
                filter = ply
            end

            local trace = util.TraceLine( {
                start = startPos,
                endpos = endPos,
                filter = filter,
                hitclientonly = true
            } )

            local newInfoEntity = trace.Entity

            -- If the normal trace failed to find anything, run a backup
            -- to find secret buttons
            if not IsValid( newInfoEntity ) or newInfoEntity:IsWorld() then
                local foundEnts = ents.FindAlongRay( startPos, trace.HitPos )

                for _, ent in ipairs( foundEnts ) do
                    if  ent:GetClass() == "class C_BaseToggle" then
                        newInfoEntity = ent
                        break
                    end
                end
            end

            if IsValid( newInfoEntity ) then
                local distance = startPos:Distance( newInfoEntity:GetPos() )
                return newInfoEntity, distance
            end

            local distance = startPos:Distance( trace.HitPos )
            return nil, distance
        end

        --- Determines if a given Entity can be targeted by the HUD
        --- @param ent Entity?
        --- @return boolean
        function LIB.IsEntityTargetable( ent )
            if not IsValid( ent ) then return false end
            --- @cast ent Entity

            -- Check the class blacklist
            local class = ent:GetClass():lower()
            if LIB.UntargetableClasses[class] then return false end

            if DarkRP then
                if ent:isKeysOwnable() then
                    return true
                end
            end

            return true
        end

        --- @private
        --- Makes a given button solid so that it can be found by 
        --- `ents.FindAlongRay` as a backup for the info Entity's trace.
        --- @param buttonEnt Entity
        function LIB.MakeButtonFindable( buttonEnt )
            if not IsValid( buttonEnt ) or buttonEnt:GetClass() ~= "class C_BaseToggle" then
                return
            end
            --- Some `func_button` entities cannot be traced against or found via `ents.FindAlongRay` unless
            --- they are made solid through a handful of different flags and values being updated
            buttonEnt:RemoveSpawnFlags( 16384 ) -- 16384 is Non-Solid
            buttonEnt:SetSolid( SOLID_BSP )
            buttonEnt:RemoveSolidFlags( FSOLID_NOT_SOLID )
        end

        --- Ensure all buttons are made findable
        hook.Add( "NetworkEntityCreated", "A1_Renegade_HudInfoUtilsClient_MakeButtonsFindable", LIB.MakeButtonFindable )
    end
end

--[[ Gathering InfoEntity Data ]] do

    --- @private
    --- Gathers and stores data about an Entity relative to a given Player  
    --- **Note:** If called on the client the results will be of a worse quality due
    --- to some information being available only on the server.
    --- @param ent Entity
    --- @param ply Player
    --- @return InfoEntityData
    function LIB.GatherInfoEntityData( ent, ply )

        --- @type InfoEntityData
        local data
        if SERVER then
            data = LIB.GetServerInfoEntityCacheEntry( ent, ply )
        end
        if CLIENT then
            data = LIB.GetClientInfoEntityCacheEntry( ent )
        end

        data.InfoEntity                  = ent
        data.DisplayName                 = LIB.GetEntityDisplayName( ent )
        data.TeamToShow                  = LIB.GetEntityTeamToShow( ent )
        data.FeelingTowardPlayer         = LIB.GetEntityFeelingTowardPlayer( ent, ply )
        data.ShowHealthBar               = LIB.ShouldShowHealthBar( ent )
        data.IsHealthServerAuthoritative = LIB.IsHealthServerAuthoritative( ent )
        data.HealthPercent               = LIB.GetEntityHealthPercent( ent )
        data.ShowInteractionChevrons     = LIB.ShouldShowInteractionChevrons( ent )

        data.ShouldTarget = data.ShouldTarget or data.ShowHealthBar or data.ShowInteractionChevrons

        if SERVER then
            LIB.SetServerInfoEntityCacheEntry( ent, ply, data )
        end
        if CLIENT then
            LIB.SetClientInfoEntityCacheEntry( ent, data )
        end

        return data
    end

    --[[ Display Name ]] do

        --- Called for npc_combine_s
        --- @param ent NPC
        local function GetCombineSoldierName( ent )
            local model = ent:GetModel()

            -- Combine Elite Soldiers
            if model == "models/combine_super_soldier.mdl" then
                return "Combine Elite"
            end

            local skin = ent:GetSkin()

            -- Nova Prospekt Prison Guards
            if model == "models/combine_soldier_prisonguard.mdl" then
                if skin == 1 then -- Red eyed skin
                    return "Prison Shotgunner"
                end
                return "Prison Guard"
            end

            -- Combine Soldiers
            if model == "models/combine_soldier.mdl" then
                if skin == 1 then
                    return "Shotgunner"
                end
                return "Combine Soldier"
            end

            -- Fallback value
            return "Combine"
        end

        --- Called for npc_citizen
        --- @param ent NPC
        local function GetCitizenName( ent )
            local model = ent:GetModel() --[[@as string]]

            -- Odessa Cubbage
            if model == "models/odessa.mdl" then
                return "Cubbage"
            end

            -- Rebels
            if string.find( model, "group03", nil, true ) then
                -- Medics
                if string.find( model, "group03m", nil, true ) then
                    return "Rebel Medic"
                end

                return "Rebel"
            end

            -- Armed Resistance
            if ent:GetActiveWeapon() ~= NULL then
                return "Resistance"
            end

            -- Fallback value
            return "Citizen"
        end

        --- Called for npc_vortigaunt
        --- @param ent NPC
        local function GetVortigauntName( ent )
            local model = ent:GetModel() --[[@as string]]

            -- Doctor
            if model == "models/vortigaunt_doctor.mdl" then
                return "Doctor"
            end

            -- Slave
            if model == "models/vortigaunt_slave.mdl" then
                return "Slave"
            end

            -- Fallback value
            return "Vortigaunt"
        end

        --- Called for prop_vehicle_prisoner_pod
        --- @param ent Entity
        --- @return string
        local function GetPrisonerPodName( ent )
            local model = ent:GetModel() --[[@as string]]

            -- Prisoner Pod
            if model == "models/vehicles/prisoner_pod_inner.mdl" then
                return "Prisoner Pod"
            end

            return "Seat"
        end

        --- Called for prop_vehicle_jeep
        --- @param ent Entity
        --- @return string
        local function GetJeepName( ent )
            local model = ent:GetModel()

            if model == "models/buggy.mdl" then
                return "Buggy"
            end

            if model == "models/vehicle.mdl" then
                return "Jalopy"
            end

            return "Vehicle"
        end

        --- Called for prop_door_rotating, prop_door, func_door_rotating, and func_door
        --- @param ent Entity
        --- @return string
        local function GetDoorName( ent )
            local name = "Door"

            local mins, maxs = ent:OBBMins(), ent:OBBMaxs()

            local xSize = math.abs( mins.x ) + maxs.x
            local ySize = math.abs( mins.y ) + maxs.y
            local zSize = math.abs( mins.z ) + maxs.z

            -- Try to classify this entity based on its shape
            local depthToWidthRatio  = xSize / ySize
            local isApproximatelyHorizontallySquare = (
                depthToWidthRatio > 0.9 and
                ( 1 / depthToWidthRatio ) > 0.9
            )

            local totalSize = xSize + ySize + zSize
            local isLargeDoor = totalSize > 300

            if isApproximatelyHorizontallySquare and isLargeDoor then
                name = "Elevator"
            end

            return name
        end

        --- @param ply Player
        --- @return string
        local function GetPlayerName( ply )
            if DarkRP then
                return ply:getDarkRPVar( "rpname" )
            end

            return ply:Nick()
        end

        --- @private
        --- A lookup table to pair Entity classes with their printable class names (or a function to determine it)  
        --- <b>Note:</b> Due to early 2000s sexism, male NPCs are called by their last names and female NPCs are called by their first names unless they have a doctorate in which case they are referred to by their last name.
        --- @type table<string, string|fun( ent: Entity ): string> 
        LIB.PrettyClassNames = {

            ["player"]                    = GetPlayerName,

            -- Map Entities
            ["class c_basetoggle"]        = "Switch", -- Buttons are called switches in Renegade
            ["prop_door_rotating"]        = GetDoorName,
            ["prop_door"]                 = GetDoorName,
            ["func_door_rotating"]        = GetDoorName,
            ["func_door"]                 = GetDoorName,

            -- Vehicles
            ["prop_vehicle_prisoner_pod"] = GetPrisonerPodName,
            ["prop_vehicle_jeep"]         = GetJeepName,

            -- Misc. NPCs
            ["npc_monk"]                  = "Grigori",

            -- Rebels
            ["npc_citizen"]               = GetCitizenName,
            ["npc_alyx"]                  = "Alyx", 
            ["npc_barney"]                = "Calhoun",
            ["npc_breen"]                 = "Breen",
            ["npc_kleiner"]               = "Kleiner",
            ["npc_eli"]                   = "Vance",
            ["npc_mossman"]               = "Mossman",
            ["npc_magnusson"]             = "Magnusson",
            ["npc_vortigaunt"]            = GetVortigauntName,

            -- Combine    
            ["npc_combine_s"]             = GetCombineSoldierName,
        }

        --- Determines the name to display on the HUD for a given Entity
        --- @param ent Entity
        --- @return string
        function LIB.GetEntityDisplayName( ent )

            -- As of right now, there are no cases where the server needs to correct the client's display name
            -- Returning an empty string indicates that there is no server override
            if SERVER then return "" end

            local names = LIB.PrettyClassNames
            local class = ent:GetClass():lower() --[[@as string]]

            --- @type string
            local name

            -- Use pre-formatted names if one is available
            local preformattedValue = names[class]
            if preformattedValue then
                if isfunction( preformattedValue ) then
                    --- @cast preformattedValue fun( ent:Entity ): string
                    name = preformattedValue( ent )
                else
                    --- @cast preformattedValue string
                    name = preformattedValue
                end
            end

            -- Use a localized phrase if one is available and needed
            if not name then
                local phrase = "#" .. class
                local localizedName = language.GetPhrase( phrase )

                if localizedName ~= phrase then
                    name = localizedName
                end
            end

            -- Use the Entity's print name if one is available
            if not name then
                if ent.PrintName then
                    name = ent.PrintName
                end
            end

            -- If no other name exists, create a backup from the class name
            if not name then
                name = class

                -- Remove prefixes
                name = string.Replace( name, "npc_", ""  )
                name = string.Replace( name, "func_", "" )
                name = string.Replace( name, "prop_", "" )
                name = string.Replace( name, "sent_", "" )
                name = string.Replace( name, "item_", "" )

                -- Break the name apart by underscores
                local explodedName = string.Explode( "_", name )
                for i = 1, #explodedName do
                    local word = explodedName[i] --[[@as string]]

                    -- Capitalize each word
                    word = ( word:sub( 1,1 ):upper() .. word:sub( 2 ):lower() ):Trim()

                    explodedName[i] = word
                end

                -- Put the exploded pieces back together with spaces between them (to replace the underscores)
                name = table.concat( explodedName, " " )
            end

            if DarkRP and ent:isKeysOwnable() then
                -- Use a title directly if one has been set
                local title = ent:getKeysTitle()
                if title then
                    name = title
                else
                    local owner = ent:getDoorOwner() --[[@as Player]]
                    if IsValid( owner ) then
                        local ownerName = owner:getDarkRPVar( "rpname" )
                        name = ownerName .. "'s " .. name
                    else
                        name = "Unowned " .. name
                    end
                end
            end

            return name
        end
    end

    --[[ Team to Show ]] do

        --- @private
        --- @type table<string, PlayerTypeEnum>
        LIB.NpcTeams = {
            -- Half-Life 2
            -- Rebels
            ["npc_barney"]                  = playerTypeEnum.Rebels,
            ["npc_citizen"]                 = playerTypeEnum.Rebels,
            ["npc_magnusson"]               = playerTypeEnum.Rebels,
            ["npc_fisherman"]               = playerTypeEnum.Rebels,
            ["npc_eli"]                     = playerTypeEnum.Rebels,
            ["npc_kleiner"]                 = playerTypeEnum.Rebels,
            ["npc_mossman"]                 = playerTypeEnum.Rebels,
            ["npc_alyx"]                    = playerTypeEnum.Rebels,
            ["npc_monk"]                    = playerTypeEnum.Rebels,
            ["npc_dog"]                     = playerTypeEnum.Rebels,
            ["npc_vortigaunt"]              = playerTypeEnum.Rebels,

            -- Antlions
            ["npc_antlion"]                 = playerTypeEnum.Neutral,
            ["npc_anylionguard"]            = playerTypeEnum.Neutral,
            ["npc_antlion_spitter"]         = playerTypeEnum.Neutral,

            -- Combine
            ["npc_combine"]                 = playerTypeEnum.Combine,
            ["npc_advisor"]                 = playerTypeEnum.Combine,
            ["apc_missile"]                 = playerTypeEnum.Combine,
            ["npc_apcdriver"]               = playerTypeEnum.Combine,
            ["npc_turret_floor"]            = playerTypeEnum.Combine,
            ["npc_rollermine"]              = playerTypeEnum.Combine,
            ["npc_turret_ground"]           = playerTypeEnum.Combine,
            ["npc_turret_ceiling"]          = playerTypeEnum.Combine,
            ["npc_combine_camera"]          = playerTypeEnum.Combine,
            ["npc_spotlight"]               = playerTypeEnum.Combine,
            ["npc_strider"]                 = playerTypeEnum.Combine,
            ["npc_combinegunship"]          = playerTypeEnum.Combine,
            ["npc_combinedropship"]         = playerTypeEnum.Combine,
            ["npc_helicopter"]              = playerTypeEnum.Combine,
            ["npc_metropolice"]             = playerTypeEnum.Combine,
            ["npc_vehicledriver"]           = playerTypeEnum.Combine,
            ["npc_cscanner"]                = playerTypeEnum.Combine,
            ["npc_clawscanner"]             = playerTypeEnum.Combine,
            ["npc_manhack"]                 = playerTypeEnum.Combine,
            ["npc_stalker"]                 = playerTypeEnum.Combine,
            ["npc_hunter"]                  = playerTypeEnum.Combine,
            ["npc_sniper"]                  = playerTypeEnum.Combine,
            ["proto_sniper"]                = playerTypeEnum.Combine,
            ["npc_combine_s"]               = playerTypeEnum.Combine,

            -- Xen
            ["npc_barnacle"]                = playerTypeEnum.Mutant,
            ["npc_headcrab"]                = playerTypeEnum.Mutant,
            ["npc_zombie"]                  = playerTypeEnum.Mutant,
            ["npc_zombie_torso"]            = playerTypeEnum.Mutant,
            ["npc_poisonzombie"]            = playerTypeEnum.Mutant,
            ["npc_fastzombie"]              = playerTypeEnum.Mutant,
            ["npc_fastzombie_torso"]        = playerTypeEnum.Mutant,
            ["npc_zombine"]                 = playerTypeEnum.Mutant,

            -- Misc
            ["npc_gman"]                    = playerTypeEnum.Neutral,
            ["npc_crow"]                    = playerTypeEnum.Neutral,
            ["npc_seagull"]                 = playerTypeEnum.Neutral,
            ["npc_pigeon"]                  = playerTypeEnum.Neutral,

            -- Half-Life
            -- Black Mesa
            ["monster_scientist"]           = playerTypeEnum.BlackMesa,
            ["monster_barney"]              = playerTypeEnum.BlackMesa,

            -- HECU
            ["monster_human_grunt"]         = playerTypeEnum.HECU,
            ["monster_apache"]              = playerTypeEnum.HECU,
            ["monster_turret"]              = playerTypeEnum.HECU,
            ["monster_miniturret"]          = playerTypeEnum.HECU,
            ["monster_sentry"]              = playerTypeEnum.HECU,

            -- Xen
            ["monster_alien_controller"]    = playerTypeEnum.Mutant,
            ["monster_vortigaunt"]          = playerTypeEnum.Mutant,
            ["monster_alien_grunt"]         = playerTypeEnum.Mutant,
            ["monster_nihilanth"]           = playerTypeEnum.Mutant,
            ["monster_snark"]               = playerTypeEnum.Mutant,
            ["monster_tentacle"]            = playerTypeEnum.Mutant,
            ["monster_barnacle"]            = playerTypeEnum.Mutant,
            ["monster_zombie"]              = playerTypeEnum.Mutant,
            ["monster_gargantua"]           = playerTypeEnum.Mutant,
            ["monster_houndeye"]            = playerTypeEnum.Mutant,
            ["monster_ichthyosaur"]         = playerTypeEnum.Mutant,
            ["monster_bigmomma"]            = playerTypeEnum.Mutant,
            ["monster_headcrab"]            = playerTypeEnum.Mutant,
            ["monster_bullsquid"]           = playerTypeEnum.Mutant,
            ["xen_tree"]                    = playerTypeEnum.Mutant,
            ["hornet"]                      = playerTypeEnum.Mutant,

            -- Misc
            ["montser_roach"]               = playerTypeEnum.Neutral,
            ["monster_leech"]               = playerTypeEnum.Neutral,

            -- Portal
            -- Aperture Science
            ["npc_portal_turret_floor"]     = playerTypeEnum.Aperture,
            ["npc_rocket_turret"]           = playerTypeEnum.Aperture,
            ["npc_security_camera"]         = playerTypeEnum.Aperture,
        }

        --- @private
        --- @param ent Entity
        --- @return PlayerTypeEnum
        function LIB.GetEntityTeamToShow( ent )

            if ent:IsNPC() then
                local class = ent:GetClass()
                local playerType = LIB.NpcTeams[class]
                if playerType then return playerType end
            end

            return playerTypeEnum.Neutral
        end
    end

    --[[ Feeling Toward Player ]] do

        --- @private
        --- Attempts to determine how one Player feels about another Player
        --- @param judged Player The Player about whom we are retrieving the disposition
        --- @param judger Player The Player whose opinion we are finding
        --- @return Disposition # How `plyJudging` feels about `plyBeingJudged`
        function LIB.GetPlayerFeelingTowardPlayer( judged, judger )
            if not IsValid( judged ) or not IsValid( judger ) then
                return dispositionEnum.Neutral
            end

            local result = dispositionEnum.Neutral

            -- We like ourselves in this household
            if judged == judger then
                result = dispositionEnum.Friendly
            end

            -- Being on the same team is a good sign for friendship
            local judgedTeam = judged:Team()
            local isJudgedOnATeam = judgedTeam ~= TEAM_UNASSIGNED
            if isJudgedOnATeam then
                if judgedTeam == judger:Team() then
                    result = dispositionEnum.Friendly
                end
            end

            return result
        end

        --- @private
        --- Determines how an Entity (including players) feels about a given Player
        --- @param ent Entity
        --- @param ply Player
        --- @return Disposition
        function LIB.GetEntityFeelingTowardPlayer( ent, ply )
            local result = dispositionEnum.Neutral

            if ent:IsNPC() then
                if SERVER then
                    --- @cast ent NPC
                    local npcDisposition = ent:Disposition( ply )

                    if npcDisposition == D_HT or npcDisposition == D_FR then
                        result = dispositionEnum.Enemy
                    elseif npcDisposition == D_LI then
                        result = dispositionEnum.Friendly
                    end
                end

                if CLIENT then
                    local class = ent:GetClass()

                    if IsFriendEntityName( class ) then
                        result = dispositionEnum.Friendly
                    elseif IsEnemyEntityName( class ) then
                        result = dispositionEnum.Enemy
                    else
                        result = dispositionEnum.Neutral
                    end
                end
            end

            if ent:IsPlayer() then
                --- @cast ent Player
                result = LIB.GetPlayerFeelingTowardPlayer( ply, ent )
            end

            -- Check disposition of vehicle occupants
            if ent:IsVehicle() then
                --- @cast ent Vehicle

                local driver = ent:GetDriver() --[[@as Player]]
                result = LIB.GetPlayerFeelingTowardPlayer( ply, driver )
            end

            return result
        end
    end

    --[[ Show Health Bar ]] do

        --- @private
        --- @param ent Entity
        --- @return boolean
        function LIB.ShouldShowHealthBar( ent )
            if Glide and isfunction( ent.GetChassisHealth ) then
                return true
            end

            if CLIENT then
                local health = ent:Health()
                local maxHealth = ent:GetMaxHealth()

                return health > 0 and maxHealth > 1
            end

            if SERVER then
                return ent:GetInternalVariable( "m_takedamage" ) == 2 -- 2 is DAMAGE_YES
            end

            return true
        end
    end

    --[[ Server Authoritative Health ]] do

        --- @param ent Entity
        --- @return boolean
        function LIB.IsHealthServerAuthoritative( ent )
            --- This exists for potential future use in a situation where an 
            --- Entity's health can only be determined on the server

            return false
        end
    end

    --[[ Health Percent ]] do

        --- @private
        --- Determines a given Entity's current health as a percentage of their maximum health between `0` and `1`
        --- @param ent Entity
        --- @return number
        function LIB.GetEntityHealthPercent( ent )
            -- As of right now, there are no cases where the server needs to override the client's health calculations
            if SERVER then
                return -1
            end

            local health
            local maxHealth
            local healthPercent

            if ent:IsVehicle() then
                -- Support for Glide vehicles
                if Glide and isfunction( ent.GetChassisHealth ) then
                    health = ent.GetChassisHealth()
                    maxHealth = ent.MaxChassisHealth or 1
                end

                -- Support for other vehicle systems goes here...
            end

            -- Calculate health percentage only if some prior logic didn't set it directly
            if not healthPercent then
                -- Use the normal health getters if nothing else changed them
                if not health    then health    = ent:Health()       end
                if not maxHealth then maxHealth = ent:GetMaxHealth() end

                healthPercent = math.Clamp( health / maxHealth, 0, 1 )
            end

            return healthPercent
        end
    end

    --[[ Show Interaction Chevrons ]] do

        --- @private
        --- Determines if an Entity can be activated with +use
        --- @param ent Entity
        --- @return boolean
        function LIB.ShouldShowInteractionChevrons( ent )
            local class = ent:GetClass():lower()

            -- Hardcode some known interactions
            -- Bouncy balls
            if class == "sent_ball" then return true end

            -- Ammo Crates
            if class == "item_ammo_crate" then return true end

            if SERVER then
                -- Locked Entities aren't usable
                local isLocked = ent:GetInternalVariable( "m_bLocked" )
                local isLockable = isLocked ~= nil
                if isLockable and isLocked then return false end

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
            end

            if CLIENT then
                -- Doors
                if class == "prop_door_rotating" or class == "func_door_rotating" or class == "func_door" or class == "prop_door" then
                    return true
                end

                -- Buttons
                if class == "class c_basetoggle" then
                    return true
                end

                -- Vehicles
                if ent:IsVehicle() then
                    return true
                end
            end

            return false
        end
    end
end


-- Client-only from here down 
if not CLIENT then return end


--- Retrieves an AABox that contains a given Entity in Entity-local space
--- @param ent Entity
--- @return AABoxInstance
function LIB.GetEntityLocalBoundingBox( ent )
    local mins, maxs = ent:GetModelRenderBounds()

    local center = -( maxs + mins ) / 2
    center.z = -center.z

    local extent = ( maxs - mins ) / 2

    local boundingBox = aABox.New( center, extent )

    return boundingBox
end

--- Retrieves an AABox that contains a given Entity in world space
--- @param ent Entity
--- @return AABoxInstance
function LIB.GetEntityWorldBoundingBox( ent )
    local mins, maxs = ent:GetModelRenderBounds()

    mins = ent:LocalToWorld( mins )
    maxs = ent:LocalToWorld( maxs )

    local center = ( maxs + mins ) / 2

    local extent = ( maxs - mins ) / 2

    local boundingBox = aABox.New( center, extent )

    return boundingBox
end