-- This class supports the HUD's target info box

--- @class Renegade
local CNC = CNC_RENEGADE

local LIB

--[[ Class Setup ]] do

    --- The static components of HudInfoUtilsClient
    --- @class HudInfoUtilsClient
    LIB = CNC.CreateExport()
end


--#region Imports

--- @type SharedCommon
local sharedCommon = CNC.Import( "renhud/sh_common.lua" )

--- @type AABox
local aABox = CNC.Import( "renhud/client/code/wwmath/aabox.lua" )

--- @type Matrix3d
local matrix3d = CNC.Import( "renhud/client/code/wwmath/matrix3d.lua" )
--#endregion


--#region Enums

local dispositionEnum = sharedCommon.DISPOSITION
--#endregion


--[[ Static Functions and Variables ]] do
    local CLASS = "HudInfoUtilsClient"

    --- [[ Public ]]

    --- @class HudInfoUtilsClient

    --[[ Target Info ]] do

        --- Info about an Entity used to target it on the HUD
        --- @class EntityInfo
        --- @field IsTargetable boolean Should this Entity be targeted?
        --- @field Disposition Disposition How this Entity feels about the Player
        --- @field TakesDamage boolean Can this Entity be harmed?
        --- @field Health number How much health does this Entity have, as a percentage between `0` and `1`?
        --- @field IsUsable boolean Can this Entity be activated with +use?

        --- Stores Entity info received from the server
        --- @private
        --- @type table<Entity, EntityInfo>
        LIB.EntityInfo = {}

        --- When, relative to CurTime, we can next ask for an Entity update
        --- @private
        LIB.NextEntityInfoRequestTime = 0

        --- How far, in Source units, should the trace to find an Info Entity be?
        LIB.InfoEntityTraceLength = 500

        --- @param ent Entity
        --- @return AABoxInstance
        function LIB.GetEntityBoundingBox( ent )
            typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )

            local mins, maxs = ent:GetModelRenderBounds()

            local center = -( maxs + mins ) / 2
            center.z = -center.z

            local extent = ( maxs - mins ) / 2

            local boundingBox = aABox.New( center, extent )

            return boundingBox
        end

        --- Performs a trace from the camera to find a valid Entity to use as the target/info Entity
        --- @return Entity?
        --- @return number traceDistance
        function LIB.TraceForInfoEntity()
            local startPos = LocalPlayer():EyePos()
            local endPos = startPos + LocalPlayer():GetAimVector() * LIB.InfoEntityTraceLength

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

        --- Makes a given button solid so that it can be found by 
        --- `ents.FindAlongRay` as a backup for the info Entity's trace.
        --- Called when new entities are networked to the client
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
        hook.Add( "NetworkEntityCreated", "A1_Renegade_HudInfoUtilsClient_MakeButtonsFindable", LIB.MakeButtonFindable )

        --- @param ent Entity
        --- @param entityInfo EntityInfo
        function LIB.IsEntityTargetable( ent, entityInfo )

            if DarkRP then
                if ent:isKeysOwnable() then
                    return true
                end
            end

            return entityInfo.IsUsable or entityInfo.TakesDamage
        end

        --- Sends a request to the server for information about a given Entity
        --- Results are delivered asyncronously and stored in the EntityInfo table
        --- @param ent Entity
        function LIB.RequestEntityInfo( ent )
            if CNC.IsServerEnabled then
                net.Start( "A1_Renegade_EntityInfo" )
                net.WriteEntity( ent )
                net.SendToServer()
            else
                LIB.EntityInfo[ent] = LIB.GetBestGuessEntityInfo( ent )
            end
        end

        function LIB.ReceiveEntityInfo()
            local ent = net.ReadEntity()

            if not IsValid( ent ) then return end

            -- Make sure we have an entry for this Entity
            local info = LIB.EntityInfo[ent]
            if not info then
                ---@diagnostic disable-next-line: missing-fields
                info = {}
                LIB.EntityInfo[ent] = info
            end

            -- Read data from the server for the entity
            info.Disposition  = net.ReadInt( 3 )
            info.TakesDamage  = net.ReadBool()
            info.IsUsable     = net.ReadBool()

            -- Make our own determinations now that we have more info from the server
            info.IsTargetable = LIB.IsEntityTargetable( ent, info )
        end
        net.Receive( "A1_Renegade_EntityInfo", LIB.ReceiveEntityInfo )

        --- Updates the EntityInfo fields that change frequently for a given Entity and returns the updated EntityInfo
        --- @param ent Entity
        --- @return EntityInfo
        function LIB.GetEntityInfo( ent )
            local info = LIB.EntityInfo[ ent ]

            --[[ Health ]] do

                info.Health = nil

                local health
                local maxHealth

                if ent:IsVehicle() then
                    -- Support for Glide vehicles
                    if Glide and isfunction( ent.GetChassisHealth ) then
                        health = ent.GetChassisHealth()
                        maxHealth = ent.MaxChassisHealth or 1
                    end

                    -- Support for other vehicle systems goes here...
                end

                -- Calculate health percentage only if some prior logic didn't set it directly
                if not info.Health then
                    -- Use the normal health getters if nothing else changed them
                    if not health    then health    = ent:Health()       end
                    if not maxHealth then maxHealth = ent:GetMaxHealth() end

                    info.Health = math.Clamp( health / maxHealth, 0, 1 )
                end
            end

            return info
        end

        --- When the HUD is operating without the benefit a server to provide target info,
        --- this function is called to provide a "best guess" approximation of the target info
        --- using only the information that is available to the client
        --- @param ent Entity
        --- @return EntityInfo
        function LIB.GetBestGuessEntityInfo( ent )

            --- @type EntityInfo
            local info = {}

            local class = ent:GetClass():lower()

            --[[ Disposition ]] do

                if IsFriendEntityName( class ) then
                    info.Disposition = dispositionEnum.Like
                elseif IsEnemyEntityName( class ) then
                    info.Disposition = dispositionEnum.Hate
                else
                    info.Disposition = dispositionEnum.Neutral
                end
            end

            --[[ Takes Damage ]] do

                local health = ent:Health()
                local maxHealth = ent:GetMaxHealth()

                -- 1 seems to be the default max health for things without health
                if health > 0 and maxHealth > 1 then
                    info.TakesDamage = true
                else
                    info.TakesDamage = false
                end
            end

            --[[ Is Usable ]] do

                -- Doors
                if class == "prop_door_rotating" or class == "func_door_rotating" or class == "func_door" or class == "prop_door" then
                    info.IsUsable = true
                end

                -- Buttons
                if class == "class c_basetoggle" then
                    info.IsUsable = true
                end

                -- Vehicles
                if ent:IsVehicle() then
                    info.IsUsable = true
                end

                -- Default
                info.IsUsable = false
            end

            info.IsTargetable = LIB.IsEntityTargetable( ent, info )

            return info
        end

        --- Determines if a given Entity has had info returned by the server
        --- @param ent Entity
        --- @return boolean
        function LIB.HasEntityInfo( ent )
            return LIB.EntityInfo[ent] ~= nil
        end
    end

    --[[ Pretty Entity Names ]] do

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

            local heightToDepthRatio = zSize / xSize
            local heightToWidthRatio = zSize / ySize
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

        --- A lookup table to pair Entity classes with their printable class names (or a function to determine it)  
        --- <b>Note:</b> Due to early 2000s sexism, male NPCs are called by their last names and female NPCs are called by their first names unless they have a doctorate in which case they are referred to by their last name.
        --- @type table<string, string|fun( ent: Entity ): string> 
        LIB.PrettyClassNames = {
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

        function LIB.GetPrettyName( ent )
            typecheck.AssertArgType( CLASS, 1, ent, sharedCommon.EntTypes )

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


    --- [[ Private ]]

    --- @class HudInfoUtilsClient

end



