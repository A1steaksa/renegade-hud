-- Based on PhysicalGameObj within Code/Combat/physicalgameobj.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type DamageableGameObjectClass
local damageableGameObjectClass = CNC.Import( "code/combat/damageable-game-object.lua" )

--- @type CombatPhysicsObserverClass
local combatPhysicsObserverClass = CNC.Import( "code/combat/combat-physics-observer.lua" )

--- @class PhysicalGameObjectClass : DamageableGameObjectClass, CombatPhysicsObserverClass
--- @field Instance PhysicalGameObjectInstance The metatable used by PhysicalGameObjectInstance
local STATIC = CNC.CreateExport( damageableGameObjectClass, combatPhysicsObserverClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "PhysicalGameObjectClass"

--- @class PhysicalGameObjectInstance : DamageableGameObjectInstance, CombatPhysicsObserverInstance
--- @field Static PhysicalGameObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_PhysicalGameObject : Renegade_DamageableGameObject, Renegade_CombatPhysicsObserver" )
INSTANCE.Class = "PhysicalGameObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysicalGameObject = true

--#region Exported Enums

    --- @type EnumBuilderClass
    local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local builder = enumBuilderClass.New()

    --- @enum CollisionGroupType
    STATIC.COLLISION_GROUP_TYPE = {
        DEFAULT_COLLISION_GROUP            = builder:Set( 0 ),  -- "Collides with everything"
        UNCOLLIDEABLE_GROUP                = builder:Next(),    -- "Collides with nothing"
        TERRAIN_ONLY_COLLISION_GROUP       = builder:Next(),    -- "Collides only with terrain"
        BULLET_COLLISION_GROUP             = builder:Next(),    -- "Collides with everything but itself"
        TERRAIN_AND_BULLET_COLLISION_GROUP = builder:Next(),    -- "Collides with terrain and bullets"
        BULLET_ONLY_COLLISION_GROUP        = builder:Next(),    -- "Collides only with bullets"
        SOLDIER_COLLISION_GROUP            = builder:Next(),    -- "Collides with everything (but only soldiers use it)"
        SOLDIER_GHOST_COLLISION_GROUP      = builder:Next(),    -- "Collides with everything but soldiers"
        TERRAIN_COLLISION_GROUP            = builder:Set( 15 ), -- "Terrain must be 15"
    }
    local collisionGroupTypeEnum = STATIC.COLLISION_GROUP_TYPE
--#endregion

--#region Imports

	--- @type PhysicsObserverClass
	local physicsObserverClass = CNC.Import( "code/wwphys/physics-observer.lua" )

	--- @type CombatManagerClass
	local combatManagerClass = CNC.Import( "code/combat/combat-manager.lua" )

	--- @type DefinitionManagerClass
	local definitionManagerClass = CNC.Import( "code/wwsaveload/definition-manager.lua" )

	--- @type BaseGameObjectClass
	local baseGameObjectClass = CNC.Import( "code/combat/base-game-object.lua" )

	--- @type Matrix3dClass
	local matrix3dClass = CNC.Import( "code/wwmath/matrix3d.lua" )

	--- @type PlayerTypeClass
	local playerTypeClass = CNC.Import( "code/combat/player-type.lua" )

	--- @type RadarManagerClass
	local radarManagerClass = CNC.Import( "code/combat/radar.lua" )

	--- @type NetworkObjectClass
	local networkObjectClass = CNC.Import( "code/wwnet/network-object.lua" )

	--- @type GameObjectManagerClass
	local gameObjectManagerClass = CNC.Import( "code/combat/game-object-manager.lua" )

	--- @type SimpleAnimationControlClass
	local simpleAnimationControlClass = CNC.Import( "code/combat/simple-animation-control.lua" )

	--- @type TextUtils
	local textUtils = CNC.Import( "sh_text-utils.lua" )

	--- @type AssetsClass
	local assetsClass = CNC.Import( "code/combat/assets.lua" )

	--- @type RenderObjectClass
	local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

	--- @type HumanAnimationControlClass
	local humanAnimationControlClass = CNC.Import( "code/combat/human-animation-control.lua" )

	--- @type SaveLoadSystemClass
	local saveLoadSystemClass = CNC.Import( "code/wwsaveload/save-load.lua" )

	--- @type ScriptableGameObjectClass
	local scriptableGameObjectClass = CNC.Import( "code/combat/scriptable-game-object.lua" )

	--- @type ChunkIOClass
	local chunkIOClass = CNC.Import( "code/wwlib/chunk-io.lua" )

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )
--#endregion


--#region Imported Enums

	local expirationReactionTypeEnum = physicsObserverClass.EXPIRATION_REACTION_TYPE
	local playerTypeEnum = playerTypeClass.PLAYER_TYPE_ENUM
	local blipColorTypeEnum = radarManagerClass.BLIP_COLOR_TYPE
	local dirtyBitEnum = networkObjectClass.DIRTY_BIT
	local animationModeEnum = renderObjectClass.ANIMATION_MODE
	local animationControlAnimationModeEnum = humanAnimationControlClass.ANIMATION_CONTROL_ANIMATION_MODE
	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
--#endregion


--[[ Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
	    XXXCHUNKID_PARENT_OLD_OLD = enumBuilder:Set( 910991145 ),
        CHUNKID_VARIABLES         = enumBuilder:Next(),
        XXX_CHUNKID_SCRIPTS       = enumBuilder:Next(),
        LEGACY_CHUNKID_DEFENSE    = enumBuilder:Next(),
        XXXCHUNKID_LISTENER       = enumBuilder:Next(),
        XXXCHUNKID_REFERENCEABLE  = enumBuilder:Next(),
        XXXCHUNKID_OBSER_XXX_VER  = enumBuilder:Next(),
        LEGACY_CHUNKID_PARENT_OLD = enumBuilder:Next(),
        CHUNKID_ANIM_CONTROL      = enumBuilder:Next(),
        CHUNKID_HOST_GAME_OBJ     = enumBuilder:Next(),
        CHUNKID_PARENT            = enumBuilder:Next(),


        XXXMICROCHUNKID_ID                    = enumBuilder:Set( 1 ),
        XXXMICROCHUNKID_GANG                  = enumBuilder:Next(),
        MICROCHUNKID_PHYS_OBSERVER_PTR        = enumBuilder:Next(),
        XXXMICROCHUNKID_REFERENCEABLE_PTR     = enumBuilder:Next(),
        XXXMICROCHUNKID_DISTANCE_PRIORITY     = enumBuilder:Next(),
        XXXMICROCHUNKID_TIME_PRIORITY         = enumBuilder:Next(),
        XXXMICROCHUNKID_PRIORITY              = enumBuilder:Next(),
        XXXMICROCHUNKID_GAME_OBJ_OBSERVER_PTR = enumBuilder:Next(),
        LEGACY_MICROCHUNKID_PLAYER_TYPE       = enumBuilder:Next(),
        MICROCHUNKID_PHYSICAL_OBJECT          = enumBuilder:Next(),
        MICROCHUNKID_HIBERNATION_TIMER        = enumBuilder:Next(),
        MICROCHUNKID_HIBERNATION_ENABLE       = enumBuilder:Next(),
        MICROCHUNKID_HOST_GAME_OBJ_BONE       = enumBuilder:Next(),

        MICROCHUNKID_RADAR_BLIP_SHAPE_TYPE           = enumBuilder:Next(),
        MICROCHUNKID_RADAR_BLIP_COLOR_TYPE           = enumBuilder:Next(),
        MICROCHUNKID_RADAR_BLIP_INTENSITY            = enumBuilder:Next(),
        MICROCHUNKID_ACTIVE_CONVERSATION             = enumBuilder:Next(),
        MICROCHUNKID_HUD_POKABLE_INDICATOR           = enumBuilder:Next(),
        MICROCHUNKID_IS_INNATE_CONVERSATIONS_ENABLED = enumBuilder:Next(),
    }
end


--[[ Static Functions and Variables ]] do

    --- @class PhysicalGameObjectClass

    --- Creates a new PhysicalGameObjectInstance
    --- @return PhysicalGameObjectInstance
    function STATIC.New()
        return robustclass.New( "Renegade_PhysicalGameObject" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) PhysicalGameObjectInstance, `false` otherwise
    function STATIC.IsPhysicalGameObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysicalGameObject and true or false
    end

    typecheck.RegisterType( "PhysicalGameObjectInstance", STATIC.IsPhysicalGameObject )
end


--- @class PhysicalGameObjectInstance
--- @field ActiveConversation ActiveConversationInstance
--- @field PhysicsObject PhysicsInstance
--- @field AnimationControl AnimationControlInstance
--- @field ServerUpdateSkips any
--- @field HibernationTimer any
--- @field HibernationEnable any
--- @field HostGameObject GameObjectInstance
--- @field HostGameObjectBone any
--- @field RadarBlipShapeType any
--- @field RadarBlipColorType any
--- @field RadarBlipIntensity any
--- @field PendingHostObjectId any
--- @field HudPokableIndicatorEnabled any
--- @field IsInnateConversationsEnabled any

-- "Hibernate after 30 seconds"
local HIBERNATION_DELAY = 30


--[[ Constructor and Destructor ]] do

    function INSTANCE:Renegade_PhysicalGameObject()
        damageableGameObjectClass.Instance.Renegade_DamageableGameObject( self )
        combatPhysicsObserverClass.Instance.Renegade_CombatPhysicsObserver( self )

        self.PhysicsObject = nil
        self.AnimationControl = nil
        self.HibernationTimer = 0 -- "Start asleep"
        self.HibernationEnable = true
        self.HostGameObjectBone = 0
        self.RadarBlipShapeType = 0
        self.RadarBlipColorType = 0
        self.RadarBlipIntensity = 0
        self.ActiveConversation = nil
        self.PendingHostObjectId = 0
        self.HudPokableIndicatorEnabled = false
        self.IsInnateConversationsEnabled = true
        INSTANCE.ResetServerSkips( self, 255 )
    end

    function INSTANCE:_Renegade_PhysicalGameObject()
        if self.PhysicsObject then
            -- Omitted removing physical game object from the physics scene
            -- combatManagerClass.GetScene():RemoveObject( self.PhysicsObject )
        end
    end
end


--[[ Definitions ]] do

    --- @param definition PhysicalGameObjectDefinitionInstance
    --- @param connectedEntity Entity
    function INSTANCE:Init( definition, connectedEntity )
        damageableGameObjectClass.Instance.Init( self, definition, connectedEntity )
        INSTANCE.CopySettings( self, definition )

        INSTANCE.HideMuzzleFlashes( self )

        -- "If the definition calls for it, add a material effect to the object"
        if definition.UseCreationEffect then
            local physicalObject = self:PeekPhysicalObject()
            if physicalObject then
                -- Omitted transition effect
                -- TODO: Implement transition effect
            end
        end
    end

    --- @param definition PhysicalGameObjectDefinitionInstance
    function INSTANCE:CopySettings( definition )
        -- "Release our hold on the physics object"
        if self.PhysicsObject then
            -- Omitted original logic
            INSTANCE.GetConnectedEntity( self ):PhysicsDestroy()
            self.PhysicsObject = nil
        end

        -- "Set the Physical Object"
        assert( self.PhysicsObject == nil )
        local physicsObjectDefinition = definitionManagerClass.FindDefinition( definition.PhysicsDefinitionId )
        assert( physicsObjectDefinition ~= nil, "Could not find definition for '" .. definition.PhysicsDefinitionId .. "'" )
        self.PhysicsObject = physicsObjectDefinition:Create( self:GetConnectedEntity() ) --[[@as PhysicsInstance]]
        assert( self.PhysicsObject ~= nil, "Could not create definition instance for '" .. definition.PhysicsDefinitionId .. "'" )

        self.PhysicsObject:SetConnectedEntity( INSTANCE.GetConnectedEntity( self ) )

        self.PhysicsObject:SetCollisionGroup( collisionGroupTypeEnum.DEFAULT_COLLISION_GROUP )
        self.PhysicsObject:SetObserver( self )
        -- Omitted adding the physics object to the physics scene

        --- "Do we still use this?????"
        -- Omitted setting animation from definition
        if definition.Animation:len() ~= 0 then
            INSTANCE.SetAnimation( self, definition.Animation )
        end

        INSTANCE.EnableHibernation( self, definition.DefaultHibernationEnable )

        INSTANCE.ResetRadarBlipShapeType( self )
    end

    --- @param definition PhysicalGameObjectDefinitionInstance
    function INSTANCE:ReInit( definition )
        local transformationMatrix = INSTANCE.GetTransform( self )

        -- "Re-initialize the base class"
        damageableGameObjectClass.Instance.ReInit( self, definition )

        -- "Copy any internal settings from the definition"
        INSTANCE.CopySettings( self, definition )

        -- "Restore the necessary settings"
        INSTANCE.SetTransform( self, transformationMatrix )
    end

    --- @return PhysicalGameObjectDefinitionInstance
    function INSTANCE:GetDefinition()
        return baseGameObjectClass.Instance.GetDefinition( self ) --[[@as PhysicalGameObjectDefinitionInstance]]
    end
end


--[[ Save / Load ]] do

    --- @param csave ChunkSaveInstance
    function INSTANCE:Save( csave )
        typecheck.NotImplementedError()
    end

    --- @param cload ChunkLoadInstance
    function INSTANCE:Load( cload )
        local ids = STATIC.ChunkIds

        -- Temporary holder for the PhysicsObserverId
        local readTable = {}

        while cload:OpenChunk() do
            local curChunkId = cload:CurChunkId()

            if curChunkId == ids.LEGACY_CHUNKID_PARENT_OLD then
                scriptableGameObjectClass.Instance.Load( self, cload )

            elseif curChunkId == ids.CHUNKID_PARENT then
                damageableGameObjectClass.Instance.Load( self, cload )

            elseif curChunkId == ids.CHUNKID_VARIABLES then
                while cload:OpenMicroChunk() do
                    local microChunkId = cload:CurMicroChunkId()

                    local didRead = (
                        -- Omitted reading physics observer pointer
                           chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_PHYS_OBSERVER_PTR,               fundamentalDataTypeEnum.Pointer, readTable, "PhysicsObserverPointer"            )
					    or chunkIOClass.ReadMicroChunk( cload, ids.LEGACY_MICROCHUNKID_PLAYER_TYPE,              fundamentalDataTypeEnum.Int,     self,      "PlayerType"                   )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_PHYSICAL_OBJECT,                 fundamentalDataTypeEnum.Pointer, self,      "PhysObj"                      )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_HIBERNATION_TIMER,               fundamentalDataTypeEnum.Float,   self,      "HibernationTimer"             )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_HIBERNATION_ENABLE,              fundamentalDataTypeEnum.Boolean, self,      "HibernationEnable"            )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_HOST_GAME_OBJ_BONE,              fundamentalDataTypeEnum.Int,     self,      "HostGameObjBone"              )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_RADAR_BLIP_SHAPE_TYPE,           fundamentalDataTypeEnum.Int,     self,      "RadarBlipShapeType"           )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_RADAR_BLIP_COLOR_TYPE,           fundamentalDataTypeEnum.Int,     self,      "RadarBlipColorType"           )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_RADAR_BLIP_INTENSITY,            fundamentalDataTypeEnum.Float,   self,      "RadarBlipIntensity"           )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_ACTIVE_CONVERSATION,             fundamentalDataTypeEnum.Pointer, self,      "ActiveConversation"           )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_HUD_POKABLE_INDICATOR,           fundamentalDataTypeEnum.Boolean, self,      "HUDPokableIndicatorEnabled"   )
						or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_IS_INNATE_CONVERSATIONS_ENABLED, fundamentalDataTypeEnum.Boolean, self,      "IsInnateConversationsEnabled" )
                    )

                    if not didRead then
                        section.Warn( INSTANCE.Class, " - Load - Unrecognized PhysicalGameObj Variable chunkID (", microChunkId, ")" )
                    end

                    cload:CloseMicroChunk()
                end

            elseif curChunkId == ids.LEGACY_CHUNKID_DEFENSE then
                self.DefenseObject:Load( cload )

            elseif curChunkId == ids.CHUNKID_ANIM_CONTROL then
                -- "Build AnimControl"
                INSTANCE.SetAnimation( self, nil )
                self.AnimationControl:Load( cload )

            elseif curChunkId == ids.CHUNKID_HOST_GAME_OBJ then
                section.Warn( INSTANCE.Class, " - Load - Skipping CHUNKID_HOST_GAME_OBJ" )
            else
                section.Warn( "Unrecognized PhysicalGameObj chunkID (", curChunkId, ")" )
            end

            cload:CloseChunk()
        end

        assert( self.PhysicsObject ~= nil )
        saveLoadSystemClass.RequestRefCountedPointerRemap( self.PhysicsObject )

        if self.ActiveConversation ~= nil then
            saveLoadSystemClass.RequestRefCountedPointerRemap( self.ActiveConversation )
        end

        -- "Register the multiple-inheritance versions of our this pointer"
        assert( readTable.PhysicsObserverPointer ~= nil )
        if readTable.PhysicsObserverPointer ~= nil then
            saveLoadSystemClass.RegisterPointer( readTable.PhysicsObserverPointer, self --[[@as CombatPhysicsObserverInstance]] )
        end

        saveLoadSystemClass.RegisterPostLoadCallback( self )

        return true
    end

    function INSTANCE:OnPostLoad()
        -- "Plug ourselves back into the physics object as an observer"
        self.PhysicsObject:SetObserver( self )

        INSTANCE.HideMuzzleFlashes( self )
        damageableGameObjectClass.Instance.OnPostLoad( self )
    end

    function INSTANCE:Startup()
        -- Empty in the original code
    end
end


--[[ Physics ]] do

    --- @return PhysicsInstance
    function INSTANCE:PeekPhysicalObject()
        return self.PhysicsObject
    end

    function INSTANCE:AttachToObjectBone()
        typecheck.NotImplementedError()
    end

    --- @return boolean
    function INSTANCE:IsAttachedToAnObject()
        return self.HostGameObject ~= nil
    end

    function INSTANCE:TeleportToHostBone()
        typecheck.NotImplementedError()
    end

    --- @param transformationMatrix Matrix3dInstance
    function INSTANCE:SetTransform( transformationMatrix )
        local physicalObject = self:PeekPhysicalObject()
        if physicalObject == nil then
            return
        end

        physicalObject:SetTransform( transformationMatrix )
    end

    --- @return Matrix3dInstance
    function INSTANCE:GetTransform()
        local physicalObject = self:PeekPhysicalObject()
        if physicalObject == nil then
            return matrix3dClass.Identity
        end

        return physicalObject:GetTransform()
    end

    --- @return Vector
    function INSTANCE:GetPosition()
        local physicsObject = self:PeekPhysicalObject()
        if physicsObject == nil then
            return Vector( 0, 0, 0 )
        end

        return physicsObject:GetPosition()
    end

    --- @param pos Vector
    function INSTANCE:SetPosition( pos )
        local physicalObject = self:PeekPhysicalObject()
        if physicalObject == nil then
            return
        end

        physicalObject:SetPosition( pos )
    end

    --- @return number
    function INSTANCE:GetFacing()
        local physicalObject = self:PeekPhysicalObject()
        if physicalObject == nil then
            return 0
        end

        return physicalObject:GetFacing()
    end
end


--[[ Display ]] do

    --- @return RenderObjectInstance?
    function INSTANCE:PeekModel()
        local physicalObject = self:PeekPhysicalObject()
        if physicalObject == nil then
            return
        end

        return physicalObject:PeekModel()
    end

    --- @return AnimationControlInstance
    function INSTANCE:GetAnimationControl()
        return self.AnimationControl
    end

    --- @param animationControl AnimationControlInstance
    function INSTANCE:SetAnimationControl( animationControl )
        self.AnimationControl = animationControl
    end

    --- "Note: Set_Animation calls will force an AnimControl to be created, if needed"
    --- @param animationName string?
    --- @param looping boolean? [Default: true]
    --- @param frameOffset number? [Default: 0.0]
    function INSTANCE:SetAnimation( animationName, looping, frameOffset )
        if looping == nil then looping = true end
        if frameOffset == nil then frameOffset = 0.0 end

        if self.AnimationControl == nil then
            -- "Be sure we have a anim control"
            self.AnimationControl = simpleAnimationControlClass.New()
        end

        local animName = animationName
        if animationName ~= nil and animationName:len() ~= 0 then

            -- "Make sure it lead with model name"
            if textUtils.IndexOf( animationName, "." ) == nil then
                animName = assetsClass.CreateAnimationName( animationName, INSTANCE.PeekModel( self ):GetName() )
            end

            self.AnimationControl:SetModel( INSTANCE.PeekModel( self ) )

            self.AnimationControl:SetAnimation( animName, 0, frameOffset )
            self.AnimationControl:SetMode( ( looping and animationControlAnimationModeEnum.ANIM_MODE_LOOP or animationControlAnimationModeEnum.ANIM_MODE_ONCE ) )

            -- "Force the object to start using the anim"
            self.AnimationControl:Update( 0 )

            -- "'Dirty' the object for networking"
            INSTANCE.SetObjectDirtyBit( self, dirtyBitEnum.BIT_RARE, true )
        end
    end

    --- @param animationName string
    --- @param frame integer
    function INSTANCE:SetAnimationFrame( animationName, frame )
        if self.AnimationControl == nil then
            -- "Be sure we have a anim control"
            INSTANCE.SetAnimationControl( self, simpleAnimationControlClass.New() )
        end

        local animName = animationName
        if animationName:len() ~= 0 then
            -- "Make sure it lead with model name"
            if textUtils.IndexOf( animationName, "." ) == nil then
                animName = assetsClass.CreateAnimationName( animationName, INSTANCE.PeekModel( self ):GetName() )
            end

            self.AnimationControl:SetModel( INSTANCE.PeekModel( self ) )

            self.AnimationControl:SetAnimation( animName, 0 )
            self.AnimationControl:SetMode( animationControlAnimationModeEnum.ANIM_MODE_STOP, FRAME )

            -- "'Dirty' the object for networking"
            INSTANCE.SetObjectDirtyBit( self, dirtyBitEnum.BIT_RARE, true )
        end
    end
end


--[[ Targeting ]] do

    --- @return number
    function INSTANCE:GetBullseyeOffsetZ()
        return INSTANCE.GetDefinition( self ).BullseyeOffsetZ
    end

    --- @return Vector
    function INSTANCE:GetBullseyePosition()
        return INSTANCE.GetPosition( self )
    end

    --- @param string string
    function INSTANCE:GetInformation( string )
        typecheck.NotImplementedError()
    end
end


--[[ Damage ]] do

    --- @param damager OffenseObjectInstance
    --- @param scale number? [Default: 1.0]
    --- @param alternateSkin integer? [Default: -1]
    function INSTANCE:ApplyDamage( damager, scale, alternateSkin )
        scale = scale or 1.0
        alternateSkin = alternateSkin or -1

        -- "If this damage is allowed"
        if not combatManagerClass.CanDamage( damager:GetOwner(), self ) then
            return
        end

        damageableGameObjectClass.Instance.ApplyDamage( self, damager, scale )
    end

    --- @param damager OffenseObjectInstance
    --- @param scale number
    --- @param direction Vector? [Default: Vector(0,0,0)]
    --- @param collisionBoxName string? [Default: None]
    function INSTANCE:ApplyDamageExtended( damager, scale, direction, collisionBoxName )
        -- This isn't very "extended" of them
        INSTANCE.ApplyDamage( self, damager, scale )
    end

    --- @param damager OffenseObjectInstance
    function INSTANCE:CompletelyDamaged( damager )
        if INSTANCE.GetDefinition( self ).KilledExplosion ~= 0 then
            local pos = INSTANCE.GetPosition( self )

            -- "Build a transform with the same heading as the object"
            local zRotation = INSTANCE.GetTransform( self ):GetZRotation()
            local transformationMatrix = matrix3dClass.New( pos )
            transformationMatrix:RotateZ( zRotation )

            -- "Create the explosion"
            explosionManagerClass.CreateExplosionat( INSTANCE.GetDefinition( self ).KilledExplosion, transformationMatrix, damager:GetOwner() )

            -- "Reveal this object to the player's encyclopedia"
            if damager:GetOwner() == combatManagerClass.GetTheStar() then
                encyclopediaManagerClass.RevealObject( self )
            end
        end
        INSTANCE.SetDeletePending( self )
    end

    --- @return boolean
    function INSTANCE:IsSoft()
        return self.DefenseObject:IsSoft()
    end

    --- @return boolean
    function INSTANCE:TakesExplosionDamage()
        return true
    end
end


--[[ Game Object Type ]] do

    --- @return integer
    function INSTANCE:GetType()
        return INSTANCE.GetDefinition( self ).Type
    end
end


--[[ Thinking ]] do

    function INSTANCE:PostThink()
        if self.AnimationControl then
            -- "For some reason??  Some vehicles come in with an anim control, but not model in the anim control."
            if INSTANCE.GetAnimationControl( self ) and not INSTANCE.GetAnimationControl( self ):PeekModel() then
                INSTANCE.GetAnimationControl( self ):SetModel( INSTANCE.PeekModel( self ) )
            end
        end

        -- "Handle Pending Host"
        if self.PendingHostObjectId ~= 0 then
            INSTANCE.ResetHibernating( self )
            self.HostGameObject = gameObjectManagerClass.FindPhysicalGameObject( self.PendingHostObjectId )
            INSTANCE.SetObjectDirtyBit( self, dirtyBitEnum.BIT_RARE, true )
            if self.HostGameObject then
                -- "Found em"
                self.PendingHostObjectId = 0
            end
        end

        -- "If host bone controlled"
        if self.HostGameObject then
            INSTANCE.TeleportToHostBone( self )
        end

        damageableGameObjectClass.Instance.PostThink( self )

        if self.HibernationEnable and self.HibernationTimer > 0 then
            self.HibernationTimer = self.HibernationTimer - FrameTime()

            if self.HibernationTimer <= 0 then
                INSTANCE.BeginHibernation( self )
            end
        end

        if self.AnimationControl then
            local animComplete = self.AnimationControl:IsComplete()

            -- "Update the animation control"
            self.AnimationControl:Update( FrameTime() )

            if not animComplete and self.AnimationControl:IsComplete() then
                -- "We just completed.  Return animation complete IF this is not a smart obj with animation action"
                if INSTANCE.AsSmartGameObject( self ) or not INSTANCE.AsSmartGameObject( self ):GetAction():IsAnimating() then
                    local observerList = INSTANCE.GetObservers( self )
                    for index = 1, #observerList do
                        observerList[index]:AnimationComplete( self, self.AnimationControl:GetAnimationName() )
                    end
                end
            end
        end
    end
end


--[[ Collision ]] do

    --- @param group CollisionGroupType
    function INSTANCE:SetCollisionGroup( group )
        self:PeekPhysicalObject():SetCollisionGroup( group )
    end

    --- @param observedObject PhysicsInstance
    --- @return ExpirationReactionType
    function INSTANCE:ObjectExpired( observedObject )
        INSTANCE.SetDeletePending( self )
        return expirationReactionTypeEnum.EXPIRATION_APPROVED
    end
end


--[[ Type Identification ]] do

    --- @return PhysicalGameObjectInstance?
    function INSTANCE:AsPhysicalGameObject()
        return self
    end

    --- "Re-implement for [CombatPhysicsObserverClass]"
    --- @return DamageableGameObjectInstance?
    function INSTANCE:AsDamageableGameObject()
        return self
    end

    --- @return SoldierGameObjectInstance?
    function INSTANCE:AsSoldierGameObject()
        return nil
    end

    --- @return PowerUpGameObjectInstance?
    function INSTANCE:AsPowerUpGameObject()
        return nil
    end

    --- @return VehicleGameObjectInstance?
    function INSTANCE:AsVehicleGameObject()
        return nil
    end

    --- @return C4GameObjectInstance?
    function INSTANCE:AsC4GameObject()
        return nil
    end

    --- @return BeaconGameObjectInstance?
    function INSTANCE:AsBeaconGameObject()
        return nil
    end

    --- @return ArmedGameObjectInstance?
    function INSTANCE:AsArmedGameObject()
        return nil
    end

    --- @return CinematicGameObjectInstance?
    function INSTANCE:AsCinematicGameObject()
        return nil
    end

    --- @return SimpleGameObjectInstance?
    function INSTANCE:AsSimpleGameObject()
        return nil
    end
end


--[[ Network Diagnostics ]] do

    --- @return integer
    function INSTANCE:GetServerSkips()
        return self.ServerUpdateSkips
    end

    --- @param value integer
    function INSTANCE:ResetServerSkips( value )
        self.ServerUpdateSkips = value
    end

    function INSTANCE:IncrementServerSkips()
        if self.ServerUpdateSkips < 254 then
            self.ServerUpdateSkips = self.ServerUpdateSkips + 1
        end
    end
end


--[[ Hibernation ]] do

    --- @return boolean
    function INSTANCE:IsHibernating()

        -- Turning hibernation off until I have a way to enable it correctly

        -- return self.HibernationTimer <= 0
    end

    --- @param isHibernationEnabled boolean
    function INSTANCE:EnableHibernation( isHibernationEnabled )
        self.HibernationEnable = isHibernationEnabled
        if INSTANCE.IsHibernating( self ) then
            self.HibernationTimer = 1
        end
    end

    function INSTANCE:ResetHibernating()
        -- "Notify the object that is has just finished hibernating"
        if INSTANCE.IsHibernating( self ) then
            INSTANCE.EndHibernation( self )
        end

        self.HibernationTimer = math.min( HIBERNATION_DELAY, self.HibernationTimer + FrameTime() * 2 )
    end

    function INSTANCE:DoNotHibernate()
        if self.HibernationTimer < 1 then
            self.HibernationTimer = 1
        end
    end

    function INSTANCE:BeginHibernation()
        -- Omitted debug printing
    end

    function INSTANCE:EndHibernation()
        -- Omitted debug printing
    end
end


--[[ Radar Blips ]] do

    --- @return integer
    function INSTANCE:GetRadarBlipShapeType()
        return self.RadarBlipShapeType
    end

    --- @param blipShapeType integer    
    function INSTANCE:SetRadarBlipShapeType( blipShapeType )
        self.RadarBlipShapeType = blipShapeType
    end

    function INSTANCE:ResetRadarBlipShapeType()
        self.RadarBlipShapeType = INSTANCE.GetDefinition( self ).RadarBlipType
    end

    --- @return integer
    function INSTANCE:GetRadarBlipColorType()
        return self.RadarBlipColorType
    end

    --- @param blipColorType integer
    function INSTANCE:SetRadarBlipColorType( blipColorType )
        self.RadarBlipColorType = blipColorType
    end

    STATIC.RadarBlipColorTypes = {
        [playerTypeEnum.Spectator] = blipColorTypeEnum.Neutral,
        [playerTypeEnum.Mutant   ] = blipColorTypeEnum.Mutant,
        [playerTypeEnum.Neutral  ] = blipColorTypeEnum.Neutral,
        [playerTypeEnum.Renegade ] = blipColorTypeEnum.Renegade,
        [playerTypeEnum.Nod      ] = blipColorTypeEnum.Nod,
        [playerTypeEnum.GDI      ] = blipColorTypeEnum.GDI,
        [playerTypeEnum.Combine  ] = blipColorTypeEnum.Combine,
        [playerTypeEnum.Rebels   ] = blipColorTypeEnum.Rebels,
        [playerTypeEnum.BlackMesa] = blipColorTypeEnum.BlackMesa,
        [playerTypeEnum.HECU     ] = blipColorTypeEnum.HECU,
        [playerTypeEnum.Aperture ] = blipColorTypeEnum.Aperture,
    }

    function INSTANCE:ResetRadarBlipColorType()
        local playerType = INSTANCE.GetPlayerType( self )
        self.RadarBlipColorType = (
            STATIC.RadarBlipColorTypes[playerType]
            or
            blipColorTypeEnum.Neutral
        )
    end

    --- @return number
    function INSTANCE:GetRadarBlipIntensity()
        return self.RadarBlipIntensity
    end

    --- @param newIntensity number 
    function INSTANCE:SetRadarBlipIntensity( newIntensity )
        self.RadarBlipIntensity = newIntensity
    end
end


--[[ Network Support ]] do

    function INSTANCE:ExportCreation()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ImportCreation()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ExportRare()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ImportRare()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ExportFrequent()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ImportFrequent()
        typecheck.NotImplementedError()
    end

    --- @return integer
    function INSTANCE:GetVisId()
        local physicsObject = self:PeekPhysicalObject()

        -- "Do we have a physics object we can use?"
        if physicsObject then
            return physicsObject:GetVisObjectId()
        end

        return -1
    end

    --- @return boolean, Vector 
    function INSTANCE:GetWorldPosition()
        return true, INSTANCE.GetPosition( self )
    end
end


--[[ Conversation Support ]] do

    --- @return boolean
    function INSTANCE:AreInnateConversationsEnabled()
        return INSTANCE.GetDefinition( self ).AllowInnateConversations and self.IsInnateConversationsEnabled
    end

    --- @param shouldEnableInnateConversations boolean
    function INSTANCE:EnableInnateConversations( shouldEnableInnateConversations )
        self.IsInnateConversationsEnabled = shouldEnableInnateConversations
    end

    --- @return boolean
    function INSTANCE:IsInConversation()
        return self.ActiveConversation ~= nil
    end

    --- @param conversation ActiveConversationInstance
    function INSTANCE:SetConversation( conversation )
        self.ActiveConversation = conversation
    end
end

--- @param hide boolean? [Default: `true`]
function INSTANCE:HideMuzzleFlashes( hide )
    hide = ( ( hide == nil ) and true or hide )

    -- TODO: Implement muzzle flash hide/show
end

--- @param isHudPokableIndicatorEnabled boolean
function INSTANCE:EnableHudPokableIndicator( isHudPokableIndicatorEnabled )
    self.HudPokableIndicatorEnabled = isHudPokableIndicatorEnabled
    INSTANCE.SetObjectDirtyBit( self, networkObjectClass.DIRTY_BIT.BIT_RARE, true )
end

--- @return boolean
function INSTANCE:IsHudPokableIndicatorEnabled()
    return self.HudPokableIndicatorEnabled
end

--- @param id integer
function INSTANCE:SetPlayerType( id )
    damageableGameObjectClass.Instance.SetPlayerType( self, id )

    INSTANCE.ResetRadarBlipColorType( self )
end


--[[ Physics Observer Support ]] do

    --- @param observedObject PhysicsInstance
    --- @param shatteredObject PhysicsInstance
    --- @param surfaceType integer
    function INSTANCE:ObjectShatteredSomething( observedObject, shatteredObject, surfaceType )
        local transformationMatrix = observedObject:GetTransform()

        surfaceEffectsManagerClass.ApplyEffect(
            surfaceType,
            hitterTypeBulletEnum.HITTER_TYPE_BULLET,
            transformationMatrix,
            nil,
            nil,
            false, -- "No decals"
            false  -- "No emitter"
        )
    end
end
