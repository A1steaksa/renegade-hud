-- Based on DefenseObjectClass within Code/Combat/damage.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class DefenseObjectClass
--- @field Instance DefenseObjectInstance The metatable used by DefenseObjectInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "DefenseObjectClass"

--- @class DefenseObjectInstance
--- @field Static DefenseObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_DefenseObject" )
INSTANCE.Class = "DefenseObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsDefenseObject = true


--#region Exported Enums

--#endregion


--#region Imports

    --- @type ArmorWarheadManagerClass
    local armorWarheadManagerClass = CNC.Import( "code/combat/armor-warhead-manager.lua" )

    --- @type GameTypeClass
    local gameTypeClass = CNC.Import( "code/combat/game-type.lua" )

    --- @type CombatManagerClass
    local combatManagerClass = CNC.Import( "code/combat/combat-manager.lua" )

    --- @type NetworkObjectClass
    local networkObjectClass = CNC.Import( "code/wwnet/network-object.lua" )
--#endregion


--#region Imported Enums

    local dirtyBitEnum = networkObjectClass.DIRTY_BIT
--#endregion


--- @alias ArmorType integer
--- @alias WarheadType integer


--[[ Static Functions and Variables ]] do

    --- @class DefenseObjectClass

    --- Creates a new DefenseObjectInstance
    --- @param health number? [Default: DEFAULT_HEALTH]
    --- @param skin number? [Default: 0]
    function STATIC.New( health, skin )
        return robustclass.New( "Renegade_DefenseObject", health, skin )
    end

    ---@param arg any
    ---@return boolean `true` if the passed argument is a(n) DefenseObjectInstance, `false` otherwise
    function STATIC.IsDefense( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsDefense and true or false
    end

    typecheck.RegisterType( "DefenseObjectInstance", STATIC.IsDefense )

    function STATIC.SetPrecision()
        typecheck.NotImplementedError()
    end
end


--- @class DefenseObjectInstance
--- @field Skin ArmorType
--- @field ShieldStrength number
--- @field ShieldStrengthMax number
--- @field ShieldType ArmorType
--- @field DamagePoints number
--- @field DeathPoints number
--- @field CanObjectDie boolean
--- @field Owner ScriptableGameObjectInstance

local DEFAULT_HEALTH          = 100.0
local MAX_MAX_HEALTH          = 2000
local MAX_MAX_SHIELD_STRENGTH = 2000
local PUNISH_DELAY            = 60


--[[ Constructors & Destructor ]] do

    --- Constructs a new DefenseObjectInstance
    --- @param health number? [Default: DEFAULT_HEALTH]
    --- @param skin number? [Default: 0]
    function INSTANCE:Renegade_DefenseObject( health, skin )
        health = health or DEFAULT_HEALTH
        skin = skin or 0

        self:SetHealthMax( health )
        self:SetHealth( health )

        self.Skin = skin

        self.ShieldStrength    = 0
        self.ShieldStrengthMax = 0
        self.ShieldType        = 0

        self.CanObjectDie = true
    end
end


--- "DefenseObjects now have a pointer to their corresponding Object
--- to report damage and scoring to the PlayerData"
--- @param def DefenseObjectDefinitionInstance
--- @param owner DamageableGameObjectInstance
function INSTANCE:Init( def, owner )

    if SERVER then
        self:SetHealthMax( def.HealthMax )
        self:SetHealth( def.Health )
    end

    self.Skin = def.Skin

    if SERVER then
        self:SetShieldStrengthMax( def.ShieldStrengthMax )
        self:SetShieldStrength( def.ShieldStrength )
    end

    self.ShieldType   = def.ShieldType
    self.DamagePoints = def.DamagePoints
    self.DeathPoints  = def.DeathPoints

    self:SetOwner( owner )
end


--[[ Save / Load ]] do

    --- @param csave ChunkSaveInstance
    --- @return boolean
    function INSTANCE:Save( csave )
        typecheck.NotImplementedError()
    end

    --- @param cload ChunkLoadInstance
    --- @return boolean
    function INSTANCE:Load( cload )
        typecheck.NotImplementedError()
    end
end


--[[ Owner ]] do

    --- @param owner DamageableGameObjectInstance
    function INSTANCE:SetOwner( owner )
        self.Owner = owner --[[@as ScriptableGameObjectInstance]]
    end

    --- @return DamageableGameObjectInstance
    function INSTANCE:GetOwner()
        return self.Owner --[[@as DamageableGameObjectInstance]]
    end
end


--[[ Skin ]] do

    --- @param skin ArmorType
    function INSTANCE:SetSkin( skin )
        self.Skin = skin
    end

    --- @return ArmorType
    function INSTANCE:GetSkin()
        return self.Skin
    end
end


--[[ Health ]] do

    -- Source Entities have a health system built-in, so we use that directly
    -- instead of creating our own on top of that and then syncronizing them.

    --- @param newHealth number
    function INSTANCE:SetHealth( newHealth )
        local owner = self.Owner
        if not owner then return end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return end

        local oldHealth = self:GetHealth()

        newHealth = math.Clamp( newHealth, 0, self:GetHealthMax() )
        ownerEntity:SetHealth( newHealth )

        if oldHealth ~= newHealth then
            self:MarkOwnerDirty()
        end
    end

    --- @param healthToAdd number
    function INSTANCE:AddHealth( healthToAdd )
        local owner = self.Owner
        if not owner then return end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return end

        local clampedHealth = math.Clamp( ownerEntity:Health() + healthToAdd, 0, self:GetHealthMax() )
        self:SetHealth( clampedHealth )
    end

    --- @return number
    function INSTANCE:GetHealth()
        local owner = self.Owner
        if not owner then return 0 end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return 0 end

        return ownerEntity:Health()
    end

    --- @param newHealthMax number
    function INSTANCE:SetHealthMax( newHealthMax )
        local owner = self.Owner
        if not owner then return end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return end

        local clampedHealthMax = math.Clamp( newHealthMax, 0, MAX_MAX_HEALTH )
        ownerEntity:SetMaxHealth( clampedHealthMax )

        self:MarkOwnerDirty()
    end

    --- @return number
    function INSTANCE:GetHealthMax()
        local owner = self.Owner
        if not owner then return 0 end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return 0 end

        return ownerEntity:GetMaxHealth()
    end
end


--[[ Shield ]] do

    -- Only Players have an armor system built-in that we should use when possible.
    -- For non-player Entities, we'll need to add our own armor/shield system.

    --- @param newShieldStrength number
    function INSTANCE:SetShieldStrength( newShieldStrength )
        local owner = self.Owner
        if not owner then return end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return end

        local oldShieldStrength = self:GetShieldStrength()

        local clampedShieldStrength = math.Clamp( newShieldStrength, 0, self:GetShieldStrengthMax() )

        if ownerEntity:IsPlayer() then
            --- @cast ownerEntity Player
            ownerEntity:SetArmor( clampedShieldStrength )
            return
        else
            self.ShieldStrength = clampedShieldStrength
        end

        if oldShieldStrength ~= clampedShieldStrength then
            self:MarkOwnerDirty()
        end
    end

    --- @param strengthToAdd number
    function INSTANCE:AddShieldStrength( strengthToAdd )
        self:SetShieldStrength(
            math.Clamp(
                self:GetShieldStrength() + strengthToAdd,
                0,
                self:GetShieldStrengthMax()
            )
        )
    end

    --- @return number
    function INSTANCE:GetShieldStrength()
        local owner = self.Owner
        if not owner then return 0 end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return 0 end

        if ownerEntity:IsPlayer() then
            --- @cast ownerEntity Player
            return ownerEntity:Armor()
        end

        return self.ShieldStrength
    end

    --- @param newShieldStrengthMax number
    function INSTANCE:SetShieldStrengthMax( newShieldStrengthMax )
        local owner = self.Owner
        if not owner then return 0 end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return 0 end

        local clampedShieldStrengthMax = math.Clamp( newShieldStrengthMax, 0, MAX_MAX_SHIELD_STRENGTH )

        if ownerEntity:IsPlayer() then
            --- @cast ownerEntity Player
            ownerEntity:SetMaxArmor( clampedShieldStrengthMax )
        else
            self.ShieldStrengthMax = clampedShieldStrengthMax
        end

        self:MarkOwnerDirty()
    end

    --- @return number
    function INSTANCE:GetShieldStrengthMax()
        local owner = self.Owner
        if not owner then return 0 end
        local ownerEntity = owner.ConnectedEntity
        if not IsValid( ownerEntity ) then return 0 end

        if ownerEntity:IsPlayer() then
            --- @cast ownerEntity Player
            return ownerEntity:GetMaxArmor()
        end

        return self.ShieldStrengthMax
    end

    --- @param newShieldType ArmorType
    function INSTANCE:SetShieldType( newShieldType )
        self.ShieldType = newShieldType
        self:MarkOwnerDirty()
    end

    --- @return ArmorType
    function INSTANCE:GetShieldType()
        return self.ShieldType
    end
end


--[[ Apply Damage ]] do

    --- @param offense OffenseObjectInstance
    --- @param scale number? [Default: 1.0]
    --- @param alternateSkin integer? [Default: -1]
    --- @return number
    function INSTANCE:ApplyDamage( offense, scale, alternateSkin )
        scale = scale or 1.0
        alternateSkin = alternateSkin or -1

        -- Omitted original ApplyDamage logic
        -- This logic is basically the same but without all of the client authoritative stuff
        -- because I super do not trust clients to tell the server about damage

        if SERVER then
            return self:DoDamage( offense, scale, alternateSkin )
        else
            return self:GetHealth()
        end
    end

    --- @param offense OffenseObjectInstance
    --- @param scale number? [Default: 1.0]
    --- @param alternateSkin integer? [Default: -1]
    --- @return number
    function INSTANCE:DoDamage( offense, scale, alternateSkin )
        if not scale then scale = 1.0 end
        if not alternateSkin then alternateSkin = -1 end

        --- @type SmartGameObjectInstance?
        local smart
        if offense:GetOwner() ~= nil then
            smart = offense:GetOwner():AsSmartGameObject()
        end

        -- Omitted damager and damagee IDs

        local damage = offense:GetDamage() * scale

        -- "Scale damage by difficulty if star is applying"
        if gameTypeClass.IsMission() and offense:GetOwner() == combatManagerClass:GetTheStar() then
            local difficulty = combatManagerClass:GetDifficultyLevel()
            if difficulty == 0 then damage = damage * 2.0   end
            if difficulty == 1 then damage = damage * 1.333 end
            if difficulty == 2 then damage = damage * 1.0   end
        end

        local shieldDamage = 0

        local damageScale = 1
        local shieldDamageScale = 1
        if alternateSkin ~= -1 then
            damageScale = armorWarheadManagerClass.GetDamageMultiplier( alternateSkin, offense:GetWarhead() )
            shieldDamageScale = 0
        else
            local warhead = offense:GetWarhead()
            damageScale = armorWarheadManagerClass.GetDamageMultiplier( self.Skin, warhead )
            shieldDamageScale = armorWarheadManagerClass.GetDamageMultiplier( self.ShieldType, warhead )
        end

        -- "Check for punish = no more damage"
        if smart ~= nil then
            typecheck.NotImplementedError()
        end

        local isRepair = false

        -- "Check for repair on either health [or] shield"
        -- "Note: humans don't repair health, but vehicles do."
        if ( damage * damageScale < 0 ) or ( damage * shieldDamageScale < 0 ) then
            -- "We are repairing"
            isRepair = true

            self:MarkOwnerDirty()

            -- "Apply first to health, then to shield"
            if self:GetHealth() < self:GetHealthMax() and damageScale ~= 0 then
                damage = damage * damageScale
                local minDamage = self:GetHealth() - self:GetHealthMax()
                damage = math.Clamp( damage, minDamage, 0 )
                self:SetHealth( self:GetHealth() - damage )
            else
                damage = damage * shieldDamageScale
                shieldDamage = damage
                damage = 0
                local minShieldDamage = self:GetShieldStrength() - self:GetShieldStrengthMax()
                shieldDamage = math.Clamp( shieldDamage, minShieldDamage, 0 )
                self:SetShieldStrength( self:GetShieldStrength() - shieldDamage )
            end
        else

            if (
                smart ~= nil
                and self:GetOwner() ~= nil
                and smart ~= self:GetOwner()
                and smart:IsTeammate( self:GetOwner() )
            ) then
                -- "This is friendly fire!!"
                if not combatManagerClass.IsFriendlyFirePermitted() then
                    return self:GetHealth()
                end
            end

            if damage ~= 0 then
                self:MarkOwnerDirty()
            end

            -- "If we have a shield, redirect a fraction of our damage;"
            -- "If alternate skin (MCT) ignore [shield] damage;"
            if self:GetShieldStrength() > 0 and alternateSkin == -1 then
                shieldDamage = damage * armorWarheadManagerClass.GetShieldAbsorbsion( self.ShieldType, offense:GetWarhead() )
                damage = damage - shieldDamage

                shieldDamage = shieldDamage * shieldDamageScale
                -- "How much scaled damage to apply"
                local shieldDamageToApply = shieldDamage

                if shieldDamage > self:GetShieldStrength() then
                    shieldDamage = self:GetShieldStrength()
                end
                self:SetShieldStrength( self:GetShieldStrength() - shieldDamage )
                if shieldDamageScale ~= 0 then
                    -- "How much un scaled damage did we apply"
                    shieldDamage = shieldDamage / shieldDamageScale
                    -- "How much scaled damage did we try to apply"
                    shieldDamageToApply = shieldDamageToApply / shieldDamageScale
                end

                damage = damage + shieldDamageToApply - shieldDamage

                -- "Clamp shield strength"
                self:SetShieldStrength( math.Clamp( self:GetShieldStrength(), 0, self:GetShieldStrengthMax() ) )
            end

            -- "Scale the (remaining) damage"
            -- "(gth) added [alternateSkin] feature which is used by buildings when their MCT is being damaged."
            damage = damage * damageScale

            if self:GetHealth() < damage then
                damage = self:GetHealth()
            end

            self:SetHealth( self:GetHealth() - damage )

            -- "Don't allow this object to die (if necessary)"
            if self.CanObjectDie == false then
                self:SetHealth( math.max( self:GetHealth(), 1 ) )
            end
        end

        -- "Clamp health to max"
        self:SetHealth( math.Clamp( self:GetHealth(), 0, self:GetHealthMax() ) )

        if (
            damage > 0
            and self:GetHealth() <= 0
            and smart ~= nil
            and smart:AsSoldierGameObject() ~= nil
            and self:GetOwner() ~= nil
            and self:GetOwner():AsSoldierGameObject() ~= nil
        ) then
            combatManagerClass.OnSoldierKill(
                smart:AsSoldierGameObject() --[[@as SoldierGameObjectInstance]],
                self:GetOwner():AsSoldierGameObject() --[[@as SoldierGameObjectInstance]]
            )
        end

        -- "Apply points for damage/death"
        if smart ~= nil and smart:GetPlayerData() then
            typecheck.NotImplementedError()
        end

        return self:GetHealth()
    end
end

--- @param offense OffenseObjectInstance
--- @param scale number? [Default: 1.0]
function INSTANCE:RequestDamage( offense, scale )
    scale = scale or 1.0

    -- Clients are not authoritative so this function should never be used

    typecheck.NotImplementedError()
end


--- "Will an apply damage call actually repair?"
--- @param offense OffenseObjectInstance
--- @param scale number? [Default: 1.0]
--- @return boolean
function INSTANCE:IsRepair( offense, scale )
    scale = scale or 1.0

    local damage = offense:GetDamage() * scale
    local damageScale = armorWarheadManagerClass.GetDamageMultiplier( self.Skin, offense:GetWarhead() )
    local shieldDamageScale = armorWarheadManagerClass.GetDamageMultiplier( self.ShieldType, offense:GetWarhead() )

    -- "Check for repair on either health [or] shield"
    return ( ( damage * damageScale < 0 ) or ( damage * shieldDamageScale < 0 ) )
end

--- "Would an apply damage call actually damage?"
--- @param offense OffenseObjectInstance
--- @param scale number? [Default: 1.0]
--- @return boolean
function INSTANCE:WouldDamage( offense, scale )
    scale = scale or 1.0

    local damage = offense:GetDamage() * scale
    local damageScale = armorWarheadManagerClass.GetDamageMultiplier( self.Skin, offense:GetWarhead() )
    local shieldDamageScale = armorWarheadManagerClass.GetDamageMultiplier( self.ShieldType, offense:GetWarhead() )

    --- @type SmartGameObjectInstance
    local attacker;

    if offense:GetOwner() ~= nil then
        attacker = offense:GetOwner():AsSmartGameObject() --[[@as SmartGameObjectInstance]]
    end

    local victim = self:GetOwner()

    -- Check for friendly fire
    if (
        attacker ~= nil
        and victim ~= nil
        and attacker:IsTeammate( victim )
        and attacker ~= self:GetOwner() -- Self-inflicted damage doesn't count as friendly fire
    ) then
        -- "This is friendly fire!!"
        if not combatManagerClass.IsFriendlyFirePermitted() then
            return false
        end
    end

    -- If we would take damage and we have health to lose, that's classic taking damage territory
    if damage * damageScale > 0 and self:GetHealth() > 0 then
        return true
    end

    -- Ditto but for shields
    if damage * shieldDamageScale > 0 and self:GetShieldStrength() > 0 then
        return true
    end

    return false
end

--- @return boolean
function INSTANCE:IsSoft()
    if not armorWarheadManagerClass.IsArmorSoft( self.Skin ) then
        return false
    end

    if self.ShieldStrength > 0 and not armorWarheadManagerClass.IsArmorSoft( self.ShieldType ) then
        return false
    end

    return true
end

--- @param canObjectDie boolean
function INSTANCE:SetCanObjectDie( canObjectDie )
    self.CanObjectDie = canObjectDie
end

--[[ State Import/Export ]] do

    --- @param packet string
    function INSTANCE:Import( packet )
        typecheck.NotImplementedError()
    end

    --- @param packet string
    function INSTANCE:Export( packet )
        typecheck.NotImplementedError()
    end
end

--- @return number
function INSTANCE:GetDamagePoints()
    return self.DamagePoints
end

--- @return number
function INSTANCE:GetDeathPoints()
    return self.DeathPoints
end

--- @private
function INSTANCE:MarkOwnerDirty()
    if self:GetOwner() ~= nil then
        self:GetOwner():SetObjectDirtyBit( dirtyBitEnum.BIT_OCCASIONAL, true )
    end
end
