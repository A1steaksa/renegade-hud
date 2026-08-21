-- Based on PhysClass within Code/wwphys/phys.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type PersistClass
local persistClass = CNC.Import( "code/wwsaveload/persist.lua" )

--- @class PhysicsClass : PersistClass
--- @field Instance PhysicsInstance The metatable used by PhysicsInstance
local STATIC = CNC.CreateExport( persistClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "PhysicsClass"

--- @class PhysicsInstance : PersistInstance
--- @field Static PhysicsClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Physics" )
INSTANCE.Class = "PhysicsInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysics = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type TextUtils
	local textUtils = CNC.Import( "sh_text-utils.lua" )

	--- @type Ww3dAssetManagerClass
	local wW3DAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class PhysicsClass

    --- Creates a new PhysicsInstance
    --- @return PhysicsInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Physics" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) PhysicsInstance, `false` otherwise
    function STATIC.IsPhysics( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysics and true or false
    end

    typecheck.RegisterType( "PhysicsInstance", STATIC.IsPhysics )

    --- @param connectedEntity Entity
    --- @param filePath string
    --- @return RenderObjectInstance
    function STATIC.CreateRenderObjectFromFileName( connectedEntity, filePath )
        -- Extract the file name without extension from the path
        local lastSlashIndex = textUtils.LastIndexOf( filePath, "\\" )
        local lastDotIndex = textUtils.LastIndexOf( filePath, "." )
        local renderObjectName = filePath:sub( lastSlashIndex + 1, lastDotIndex - 1 ):lower():TrimRight( "\0" )

        local sourceModelPath = "models/cnc_renegade/" .. filePath
        sourceModelPath = sourceModelPath:Replace( "\\", "/" )
        sourceModelPath = sourceModelPath:Replace( ".w3d", ".mdl" )

        local renderObject = wW3DAssetManagerClass.GetInstance():CreateRenderObject( renderObjectName )
        if renderObject == nil then
            section.Error( "Failed to create '", renderObjectName, "' from '", filePath, "'" )
            error() -- To make LuaLS happy
        end

        renderObject:SetConnectedEntity( connectedEntity )
        renderObject:SetSourceModelPath( sourceModelPath )

        return renderObject
    end

end


--- @class PhysicsInstance
--- @field private ConnectedEntity Entity The Garry's Mod Entity that this object represents
--- @field Flags integer "Flags for things like whether this object is currently being considered immovable"
--- @field Model RenderObjectInstance "Render model"
--- @field Name string? "Optional instance name"
--- @field InstanceId integer "Optional instance identifier (unique if non-zero)"
--- "  
--- Every phys object can store a vis object id.
--- Static objects will have constant ID's assigned by the vis generation process, dynamic objects
--- will update their id based on their current location.  
--- "
--- @field VisObjectId integer
--- @field Observer PhysicsObserverInstance
--- @field Definition PhysicsDefinitionInstance "Definition object, contains constants which are shared between instances"
--- @field MaterialEffectsOnMe MaterialEffectInstance[] "List of projected textures that are being applied to this object"
--- @field StaticLightingCache LightEnvironmentInstance
--- @field SunStatusLastUpdated integer "Frame time at which the sun status was last updated. The sun status is cached and only updated few times per second."
--- @field LastVisibleFrame integer "The pscene uses this to figure out if the mesh is visible, to do some physics optimizations."

-- "Bits for the collision group"
STATIC.COLLISION_MASK = 0x0000000F

-- "This object is immovable."
STATIC.IMMOVABLE = 0x00000100

-- "Some objects can be disabled (e.g. lights)"
STATIC.DISABLED = 0x00000200

-- "Render debugging aids (forces, impacts, etc)"
STATIC.DEBUGDISPLAY = 0x00000400

-- "Ignore physics, move according to controller directly"
STATIC.USERCONTROL = 0x00000800

-- "Does this object cast a shadow?"
STATIC.CASTSHADOW = 0x00001000

-- "When the shadow mode is BLOBS_PLUS, this object still uses a "proper" shadow"
STATIC.FORCE_PROJECTION_SHADOW = 0x00002000

-- "Scene should never save this object (used for transient things like glass fragments)"
STATIC.DONT_SAVE = 0x00004000

-- "This object is not moving so its simulation was skipped"
STATIC.ASLEEP = 0x00008000

-- "Enable the static-world-space-mesh rendering optimizations."
STATIC.IS_WS_MESH = 0x00010000

-- "Is this a light-mapped object that doesn't need static lights applied."
STATIC.IS_PRE_LIT = 0x00020000

-- "Is this object illuminated by the sun?"
STATIC.IS_IN_THE_SUN = 0x00040000

-- "This object's state has changed. "
STATIC.IS_STATE_DIRTY = 0x00080000

-- "This object's static lighting cache is dirty"
STATIC.STATIC_LIGHTING_DIRTY = 0x00100000

-- "Friction is disabled for this object (vehicles disable body-friction when their wheels are in contact)"
STATIC.FRICTION_DISABLED = 0x00200000

-- "Turn on/off simulation for this object"
STATIC.SIMULATION_DISABLED = 0x00400000

-- "Mask for the 'ignore-me' counter"
STATIC.IGNORE_MASK = 0xF0000000

STATIC.DEFAULT_FLAGS = 0

function INSTANCE:Renegade_Physics()
    self.Flags = STATIC.DEFAULT_FLAGS
    self.Model = nil
    self.Observer = nil
    self.Definition = nil
    self.InstanceId = 0
    self.VisObjectId = 0
    self.LastVisibleFrame = 0 -- "JANI TEMP TEST"
    self.SunStatusLastUpdated = 0
    self.StaticLightingCache = nil
end

--- @param definition PhysicsDefinitionInstance
--- @param connectedEntity Entity
function INSTANCE:Init( definition, connectedEntity )
    self:SetConnectedEntity( connectedEntity )

    self.Definition = definition
    self.Flags = STATIC.DEFAULT_FLAGS
    if definition.ModelName:len() ~= 0 then
        --- @type RenderObjectInstance
        local model

        if definition.ModelName:find( ".", nil, true ) then
            model = STATIC.CreateRenderObjectFromFileName( connectedEntity, definition.ModelName )
        else
            typecheck.NotImplementedError()
            -- model = wW3DAssetManagerClass.GetInstance():CreateRenderObject( connectedEntity, definition.ModelName )
        end

        if model == nil then
            section.Error( "Unable to create render object model for ", definition.Class, " ", connectedEntity )
            return
        end

        self:SetModel( model )
    end
end

function INSTANCE:DefinitionChanged()
    -- Empty in the original code
end

function INSTANCE:Expire()
    typecheck.NotImplementedError()
end


--[[ Entity Connection ]] do

    --- @param entity Entity
    function INSTANCE:SetConnectedEntity( entity )
        self.ConnectedEntity = entity
    end

    --- @returns Entity
    function INSTANCE:GetConnectedEntity()
        return self.ConnectedEntity
    end
end


--[[ Timestep ]] do

    --- "System informs the object to update itself for the specified amount of time"
    function INSTANCE:NeedsTimestep()
        return false
    end

    function INSTANCE:Timestep()
        typecheck.NotImplementedError()
    end

    function INSTANCE:PostTimestepProcess()
        -- Empty in the original code
    end
end


--[[ Position & Orientation ]] do

    --- @return Matrix3dInstance
    function INSTANCE:GetTransform()
        typecheck.NotImplementedError()
    end

    --- @param transformationMatrix Matrix3dInstance
    function INSTANCE:SetTransform( transformationMatrix )
        typecheck.NotImplementedError()
    end

    --- @return Vector
    function INSTANCE:GetPosition()
        return self:GetTransform():GetTranslation()
    end

    --- @param pos Vector
    function INSTANCE:SetPosition( pos )
        local transformationMatrix = self:GetTransform()
        transformationMatrix:SetTranslation( pos )
        self:SetTransform( transformationMatrix )
    end

    --- @return number
    function INSTANCE:GetFacing()
        return self:GetTransform():GetZRotation()
    end

    function INSTANCE:SetFacing()
        typecheck.NotImplementedError()
    end
end


--[[ Collision Detection ]] do

    -- "  
    -- all collideable objects provide the following collision detection
    -- functions so that other objects do not pass through them.
    -- These functions should test the given primitive against this object's
    -- geometric representation.  
    -- "  

    --- @param test PhysicsRayCollisionTestInstance
    --- @return boolean
    function INSTANCE:CastRay( test )
        return false
    end

    --- @param test PhysicsAABoxCollisionTestInstance
    --- @return boolean
    function INSTANCE:CastAaBox( test )
        return false
    end

    --- @param test PhysicsObBoxCollisionTestInstance
    --- @return boolean
    function INSTANCE:CastObBox( test )
        return false
    end

    --- @param test PhysicsAABoxIntersectionTestInstance|PhysicsOBBoxIntersectionTestInstance|PhysicMeshIntersectionTestInstance
    --- @return boolean
    function INSTANCE:IntersectionTest( test )
        return false
    end
end


--[[ Inter-Object Geometric Dependency ]] do

    -- "
    -- These functions don't really perform any physics-based motion, only purely kinematic.  
    -- You can link a moveable physics object (the rider) to another object that it is
    -- standing on (the carrier).  This will cause the carrier to move the rider whenever
    -- it moves (by calling Push).
    -- "

    --- @param carrier PhysicsInstance
    --- @param carrierSubObject RenderObjectInstance? (Optional)
    function INSTANCE:LinkToCarrier( carrier, carrierSubObject )
        -- Empty in the original code
    end

    --- @return RenderObjectInstance?
    function INSTANCE:PeekCarrierSubObject()
        return nil
    end

    --- "Carriers push their riders around, also objects not being carried can be pushed"
    --- @param move Vector
    function INSTANCE:Push( move )
        return false
    end

    --- "An object is being attached to you, move him when you move"
    --- @param rider PhysicsInstance
    function INSTANCE:InternalLinkRider( rider )
        return false
    end

    --- "Stop moving this object when you move."
    --- @param rider PhysicsInstance
    function INSTANCE:InternalUnlinkRider( rider )
        return false
    end
end


--[[ Culling ]] do

    --- "  
    --- This function updates the culling box used by the object.
    --- The default implementation is to copy the bounding box of
    --- the current Model.
    --- "  
    function INSTANCE:UpdateCullBox()
        if self.Model then
            self:SetCullBox( self.Model:GetBoundingBox() )
        end
    end
end


--[[ Model ]] do

    --- @param model RenderObjectInstance
    function INSTANCE:SetModel( model )
        local connectedEntity = self:GetConnectedEntity()
        local sourceModel = model:GetSourceModelPath()
        section.Warn( self.Class, ": '", connectedEntity, "': Setting model '", model, "' using debug code" )
        connectedEntity:SetModel( sourceModel )

        -- Omitted the majority of the function

        -- local theScene = physicsSceneClass.GetInstance()
        -- local inScene = theScene:Contains( self )

        if self.Model then
            -- "If we had an old model, copy the transform"
            if model then
                model:SetTransform( self.Model:GetTransform() )
            end
            -- if inScene then
            --     self.Model:NotifyRemoved( theScene )
            -- end
        end

        self.Model = model

        -- if self.Model then
        --     if inScene then
        --         self.Model:NotifyAdded( theScene )
        --     end
        -- end

        if self.Definition ~= nil and self.Definition.IsPreLit then
            self:EnableIsPreLit( true )
        end

        self:InvalidateStaticLightingCache()
    end

    --- @param modelTypeName string
    function INSTANCE:SetModelByName( modelTypeName )
        typecheck.NotImplementedError()
    end

    --- @return string?
    function INSTANCE:GetModel()
        local connectedEntity = self:GetConnectedEntity()
        if not IsValid( connectedEntity ) then
            return nil
        end

        return connectedEntity:GetModel()
    end

    --- @return RenderObjectInstance?
    function INSTANCE:PeekModel()
        return self.Model
    end
end


--[[ Name ]] do

    function INSTANCE:SetName()
        typecheck.NotImplementedError()
    end

    function INSTANCE:GetName()
        typecheck.NotImplementedError()
    end
end


--[[ Instance Id ]] do

    function INSTANCE:GetId()
        typecheck.NotImplementedError()
    end

    function INSTANCE:SetId()
        typecheck.NotImplementedError()
    end
end


--[[ Vis Object Id ]] do

    function INSTANCE:SetVisObjectId()
        typecheck.NotImplementedError()
    end

    --- @return integer
    function INSTANCE:GetVisObjectId()
        return self.VisObjectId
    end
end


--[[ Lighting ]] do

    function INSTANCE:InvalidateStaticLightingCache()
        self:SetFlag( STATIC.STATIC_LIGHTING_DIRTY, true )
    end

    function INSTANCE:GetStaticLightingEnvironment()
        typecheck.NotImplementedError()
    end
end

function INSTANCE:RenderVisMeshes()
    typecheck.NotImplementedError()
end

function INSTANCE:GetShadowBlobBox()
    typecheck.NotImplementedError()
end

function INSTANCE:IsCastingShadow()
    typecheck.NotImplementedError()
end


--[[ Material Effects ]] do

    function INSTANCE:AddEffectToMe()
        typecheck.NotImplementedError()
    end

    function INSTANCE:RemoveEffectFromMe()
        typecheck.NotImplementedError()
    end

    function INSTANCE:DoAnyEffectsSuppressShadows()
        typecheck.NotImplementedError()
    end
end


--[[ Collision Groups ]] do

    --- "  
    --- Set the Collision Group for this physics object.  
    --- The collision group is an integer between 0 and 15.  
    --- Collisions between any two groups can be enabled/disabled through
    --- the physics system.  
    --- "
    --- @param group CollisionGroupType
    function INSTANCE:SetCollisionGroup( group )
        group = bit.band( group, STATIC.COLLISION_MASK )
        self.Flags = bit.band( self.Flags, bit.bnot( STATIC.COLLISION_MASK ) )
        self.Flags = bit.bor( self.Flags, group )
    end

    --- @return integer
    function INSTANCE:GetCollisionGroup()
        return bit.band( self.Flags, STATIC.COLLISION_MASK )
    end
end


--[[ Ignore Me ]] do

    function INSTANCE:IncrementIgnoreCounter()
        typecheck.NotImplementedError()
    end

    function INSTANCE:DecrementIgnoreCounter()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsIgnoreMe()
        typecheck.NotImplementedError()
    end
end


--[[ Immovable ]] do

    function INSTANCE:SetImmovable()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsImmovable()
        typecheck.NotImplementedError()
    end
end


--[[ Disabled ]] do

    function INSTANCE:SetDisabled()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsDisabled()
        typecheck.NotImplementedError()
    end
end


--[[ Debug Display ]] do

    function INSTANCE:EnableDebugDisplay()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsDebugDisplayEnabled()
        typecheck.NotImplementedError()
    end
end


--[[ User Control ]] do

    function INSTANCE:EnableUserControl()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsUserControlEnabled()
        typecheck.NotImplementedError()
    end
end


--[[ Shadow Casting ]] do

    --- @param areShadowsEnabled boolean
    function INSTANCE:EnableShadowGeneration( areShadowsEnabled )
        INSTANCE.SetFlag( self, STATIC.CASTSHADOW, areShadowsEnabled )
    end

    --- @return boolean
    function INSTANCE:IsShadowGenerationEnabled()
        return INSTANCE.GetFlag( self, STATIC.CASTSHADOW )
    end
end


--[[ Blob Shadow Override ]] do

    function INSTANCE:EnableForceProjectionShadow()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsForceProjectionShadowEnabled()
        typecheck.NotImplementedError()
    end
end


--[[ Don&#x27;t Save ]] do

    function INSTANCE:EnableDontSave()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsDontSaveEnabled()
        typecheck.NotImplementedError()
    end
end


--[[ Asleep ]] do

    function INSTANCE:IsAsleep()
        typecheck.NotImplementedError()
    end

    function INSTANCE:ForceAwake()
        typecheck.NotImplementedError()
    end
end


--[[ Static World-Space Mesh ]] do

    function INSTANCE:EnableIsWorldSpaceMesh()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsWorldSpaceMesh()
        typecheck.NotImplementedError()
    end
end


--[[ Pre-Lit ]] do

    function INSTANCE:EnableIsPreLit()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsPreLit()
        typecheck.NotImplementedError()
    end
end


--[[ Is In The Sun ]] do

    function INSTANCE:EnableIsInTheSun()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsInTheSun()
        typecheck.NotImplementedError()
    end
end


--[[ Is State Dirty ]] do

    function INSTANCE:EnableIsStateDirty()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsStateDirty()
        typecheck.NotImplementedError()
    end
end


--[[ Object&#x27;s Simulation ]] do

    function INSTANCE:EnableObjectsSimulation()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsObjectsSimulationEnabled()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsObjectSimulating()
        typecheck.NotImplementedError()
    end
end


--[[ Collision Observer ]] do

    --- "
    --- If you install a collision observer, it will be notified of any collisions which occur 
    --- involving this object.  One way to do this is to derive your game objects from 
    --- CollisionObserverClass so that they can be directly installed here.  Currently, there
    --- can only be one observer for any physics object.  You are responsible for removing
    --- the observer before this phys object is destroyed: Set_Observer(NULL)
    --- "
    --- @param observer PhysicsObserverInstance
    function INSTANCE:SetObserver( observer )
        self.Observer = observer
    end

    --- @return PhysicsObserverInstance
    function INSTANCE:GetObserver()
        return self.Observer
    end

    function INSTANCE:CollisionOccurred()
        typecheck.NotImplementedError()
    end
end


--[[ Definition ]] do

    --- "
    --- Many physics objects are created from a "definition".
    --- The definition object contains constants. 
    --- If this object has a definition, you can access it here.
    --- "
    --- @return PhysicsDefinitionInstance
    function INSTANCE:GetDefinition()
        return self.Definition
    end
end


--[[ Physics RTTI ]] do

    --- @return DynamicPhysicsInstance?
    function INSTANCE:AsDynamicPhysics()
        return nil
    end

    --- @return MoveablePhysicsInstance?
    function INSTANCE:AsMoveablePhysics()
        return nil
    end

    --- @return Physics3Instance?
    function INSTANCE:AsPhysics3()
        return nil
    end

    --- @return HumanPhysicsInstance?
    function INSTANCE:AsHumanPhysics()
        return nil
    end

    --- @return RigidBodyInstance?
    function INSTANCE:AsRigidBody()
        return nil
    end

    function INSTANCE:AsVehiclePhysics()
        return nil
    end

    function INSTANCE:AsMotorVehicle()
        return nil
    end

    function INSTANCE:AsWheeledVehicle()
        return nil
    end

    function INSTANCE:AsMotorcycle()
        return nil
    end

    function INSTANCE:AsTrackedVehicle()
        return nil
    end

    function INSTANCE:AsVtolVehicle()
        return nil
    end

    function INSTANCE:AsStaticPhyicss()
        return nil
    end

    function INSTANCE:AsStaticAnimationPhysics()
        return nil
    end

    function INSTANCE:AsElevatorPhysics()
        return nil
    end

    function INSTANCE:AsDamageableStaticPhysics()
        return nil
    end

    function INSTANCE:AsDoorPhysics()
        return nil
    end

    function INSTANCE:AsDecorationPhysics()
        return nil
    end

    function INSTANCE:AsTimedDecorationPhysics()
        return nil
    end

    function INSTANCE:AsDynamicAnimationPhysics()
        return nil
    end

    function INSTANCE:AsLightPhysics()
        return nil
    end

    function INSTANCE:AsRenderObjectPhysics()
        return nil
    end

    function INSTANCE:AsProjectile()
        return nil
    end

    function INSTANCE:AsAccessiblePhysics()
        return nil
    end
end


--[[ Persistance ]] do

    function INSTANCE:Save()
        typecheck.NotImplementedError()
    end

    function INSTANCE:Load()
        typecheck.NotImplementedError()
    end
end


--[[ Simulation and Rendering ]] do

    --- @param renderInfo RenderInfoInstance
    function INSTANCE:Render( renderInfo )
        self:PushEffects( renderInfo )

        if self.Model ~= nil then
            self.Model:Render( renderInfo )
        end

        self:PopEffects( renderInfo )
    end

    function INSTANCE:VisRender()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsSimulationDisabled()
        typecheck.NotImplementedError()
    end

    function INSTANCE:IsRenderingDisabled()
        typecheck.NotImplementedError()
    end

    function INSTANCE:GetLastVisibleFrame()
        typecheck.NotImplementedError()
    end

    function INSTANCE:SetLastVisibleFrame()
        typecheck.NotImplementedError()
    end
end

--- @param flag integer
--- @return boolean
function INSTANCE:GetFlag( flag )
    return ( ( bit.band( self.Flags, flag ) == flag ) )
end

--- @param flag integer
--- @param isOn boolean
function INSTANCE:SetFlag( flag, isOn )
    if isOn then
        self.Flags = bit.bor( self.Flags, flag )
    else
        self.Flags = bit.band( self.Flags, bit.bor( flag ) )
    end
end

--- @param renderInfo RenderInfoInstance
function INSTANCE:PushEffects( renderInfo )
    typecheck.NotImplementedError()
end

--- @param renderInfo RenderInfoInstance
function INSTANCE:PopEffects( renderInfo )
    typecheck.NotImplementedError()
end

function INSTANCE:UpdateSunStatus()
    typecheck.NotImplementedError()
end
