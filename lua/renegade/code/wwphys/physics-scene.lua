-- Based on PhysicsSceneClass within Code/wwphys/pscene.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type SceneClass
local sceneClass = CNC.Import( "code/ww3d2/scene.lua" )

--- @class PhysicsSceneClass : SceneClass
--- @field Instance PhysicsSceneInstance The metatable used by PhysicsSceneInstance
local STATIC = CNC.CreateExport( sceneClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "PhysicsSceneClass"

--- @class PhysicsSceneInstance : SceneInstance
--- @field Static PhysicsSceneClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_PhysicsScene : Renegade_Scene" )
INSTANCE.Class = "PhysicsSceneInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysicsScene = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class PhysicsSceneClass
	--- @field AllowCollisionFlags boolean
	--- @field TheScene PhysicsSceneInstance

    --- Creates a new PhysicsSceneInstance
    --- @return PhysicsSceneInstance
    function STATIC.New()
        return robustclass.New( "Renegade_PhysicsScene" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) PhysicsSceneInstance, `false` otherwise
    function STATIC.IsPhysicsScene( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysicsScene and true or false
    end

    typecheck.RegisterType( "PhysicsSceneInstance", STATIC.IsPhysicsScene )

	function STATIC.GetInstance()
		typecheck.NotImplementedError()
	end
end


--- @class PhysicsSceneInstance
--- @field VisibleStaticObjectList RefPhysicsListInstance
--- @field VisibleWsMeshList RefPhysicsListInstance
--- @field VisibleDynamicObjectList RefPhysicsListInstance
--- @field ActiveTextureProjectors TexProjListInstance
--- @field FrameNum integer
--- @field LastCameraPosition Vector
--- @field LastValidVisibilityId integer
--- @field DebugDisplayEnabled boolean
--- @field ProjectorDebugDisplayEnabled boolean
--- @field DirtyCullDebugDisplayEnabled boolean
--- @field LightingDebugDisplayEnabled boolean
--- @field LastValidStats StatsStructInstance
--- @field CurrentStats StatsStructInstance
--- @field StaticProjectorsDirty boolean
--- @field VisibilityEnabled boolean
--- @field VisibilityInverted boolean
--- @field VisibilityQuickAndDirty boolean
--- @field VisibilityResetNeeded boolean
--- @field VisibilitySectorDisplayEnabled boolean
--- @field VisibilitySectorHistoryEnabled boolean
--- @field VisibilityGridDisplayMode integer
--- @field VisibilitySectorMissing boolean
--- @field VisibilitySectorFallbackEnabled boolean
--- @field BackfaceDebugEnabled boolean
--- @field VisibilitySamplePointLocked boolean
--- @field LockedVisibilitySamplePoint Vector
--- @field VisibilityCamera CameraInstance
--- @field CurrentVisibilityTable VisibilityTableInstance
--- @field StaticProjectorsEnabled boolean
--- @field DynamicProjectorsEnabled boolean
--- @field ShadowMode ShadowEnumInstance
--- @field ShadowAttenStart number
--- @field ShadowAttenEnd number
--- @field ShadowNormalIntensity number
--- @field ShadowBlobTexture TextureInstance
--- @field ShadowRenderContext SpecialRenderInfoInstance
--- @field ShadowCamera CameraInstance
--- @field ShadowMaterialPass MaterialPassInstance
--- @field ShadowResWidth integer
--- @field ShadowResHeight integer
--- @field DecalSystem PhysicsDecalSystemInstance
--- @field Pathfinder PathfindInstance
--- @field CameraShakeSystem CameraShakeSystemInstance
--- @field UpdateList RefRenderObjectListInstance
--- @field VertexProcList RefRenderObjectListInstance
--- @field ReleaseList RefPhysicsListInstance
--- @field HighlightMaterialPass MaterialPassInstance
--- @field StaticCullingSystem StaticAabTreeCullInstance
--- @field StaticLightingSystem StaticLightCullInstance
--- @field DynamicCullingSystem PhysicsGridCullInstance
--- @field DynamicObjectVisibilitySystem DynamicAabTreeCullInstance
--- @field StaticProjectorCullingSystem TypedAabTreeCullSystemClassTexProjectInstance
--- @field DynamicProjectorCullingSystem TypedGridCullSystemClassTexProjectInstance
--- @field VisibilityTableManager VisibilityTableManagerInstance
--- @field LightingMode integer
--- @field SceneAmbientLight Vector
--- @field UseSun boolean
--- @field SunPitch number
--- @field SunYaw number
--- @field SunLight LightInstance
--- @field DynamicPolyBudget integer
--- @field StaticPolyBudget integer
--- @field ObjectList RefPhysicsListInstance
--- @field StaticObjectList RefPhysicsListInstance
--- @field StaticLightList RefPhysicsListInstance
--- @field StaticProjectorList TexProjListInstance
--- @field DynamicProjectorList TexProjListInstance
--- @field DirtyCullList RefPhysicsListInstance
--- @field TimestepList RefPhysicsListInstance
--- @field StaticAnimationList RefPhysicsListInstance
--- @field CollisionRegionList NonRefPhysicsListInstance
--- @field UpdateOnlyVisibleObjects boolean
--- @field CurrentFrameNumber UnsignedInstance

function INSTANCE:Renegade_PhysicsScene()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_PhysicsScene()
	typecheck.NotImplementedError()
end

function INSTANCE:Update()
	typecheck.NotImplementedError()
end

function INSTANCE:PreRenderProcessing()
	typecheck.NotImplementedError()
end

function INSTANCE:PostRenderProcessing()
	typecheck.NotImplementedError()
end

function INSTANCE:AddDynamicObject()
	typecheck.NotImplementedError()
end

function INSTANCE:AddStaticObject()
	typecheck.NotImplementedError()
end

function INSTANCE:AddDynamicLight()
	typecheck.NotImplementedError()
end

function INSTANCE:AddStaticLight()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveObject()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveAll()
	typecheck.NotImplementedError()
end

function INSTANCE:DelayedRemoveObject()
	typecheck.NotImplementedError()
end

function INSTANCE:ProcessReleaseList()
	typecheck.NotImplementedError()
end

function INSTANCE:Contains()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDynamicObjectIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStaticObjectIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStaticAnimationObjectIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStaticLightIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStaticProjectorIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDynamicProjectorIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStaticObjectById()
	typecheck.NotImplementedError()
end

function INSTANCE:AddToDirtyCullList()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveFromDirtyCullList()
	typecheck.NotImplementedError()
end

function INSTANCE:IsInDirtyCullList()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLightingMode()
	typecheck.NotImplementedError()
end

function INSTANCE:SetLightingMode()
	typecheck.NotImplementedError()
end

function INSTANCE:SetAmbientLight()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAmbientLight()
	typecheck.NotImplementedError()
end

function INSTANCE:SetLightingLodCutoff()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLightingLodCutoff()
	typecheck.NotImplementedError()
end

function INSTANCE:IsSunLightEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableSunLight()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSunLight()
	typecheck.NotImplementedError()
end

function INSTANCE:SetSunLightOrientation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSunLightOrientation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSunLightVector()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputeStaticLighting()
	typecheck.NotImplementedError()
end

function INSTANCE:InvalidateLightingCaches()
	typecheck.NotImplementedError()
end

function INSTANCE:SetCollisionRegion()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseCollisionRegion()
	typecheck.NotImplementedError()
end

function INSTANCE:CastRay()
	typecheck.NotImplementedError()
end

function INSTANCE:CastAaBox()
	typecheck.NotImplementedError()
end

function INSTANCE:CastObBox()
	typecheck.NotImplementedError()
end

function INSTANCE:IntersectionTest()
	typecheck.NotImplementedError()
end

function INSTANCE:IntersectionTest()
	typecheck.NotImplementedError()
end

function INSTANCE:ForceDynamicObjectsAwake()
	typecheck.NotImplementedError()
end

function INSTANCE:CollectObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:CollectObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:CollectCollideableObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:CollectLights()
	typecheck.NotImplementedError()
end

function INSTANCE:FindStaticObject()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableCollisionDetection()
	typecheck.NotImplementedError()
end

function INSTANCE:DisableCollisionDetection()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableAllCollisionDetections()
	typecheck.NotImplementedError()
end

function INSTANCE:DisableAllCollisionDetections()
	typecheck.NotImplementedError()
end

function INSTANCE:DoGroupsCollide()
	typecheck.NotImplementedError()
end

function INSTANCE:RePartitionStaticObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:RePartitionStaticLights()
	typecheck.NotImplementedError()
end

function INSTANCE:RePartitionStaticProjectors()
	typecheck.NotImplementedError()
end

function INSTANCE:RePartitionDynamicCullingSystem()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateCullingSystemBoundingBoxes()
	typecheck.NotImplementedError()
end

function INSTANCE:VerifyCullingSystems()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:InvertVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:SetVisibilityQuickAndDirty()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableVisibilitySectorDisplay()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableVisibilitySectorHistoryDisplay()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableVisibilitySectorFallback()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableBackfaceOccluderDebug()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilityEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilityInverted()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilityQuickAndDirty()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilitySectorDisplayEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilitySectorHistoryDisplayEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilitySectorMissing()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilitySectorFallbackEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:IsBackfaceOccluderDebugEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:LockVisibilitySamplePoint()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilitySamplePointLocked()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputeVisibilitySamplePoint()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibilityTable()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibilityTable()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibilityTableForRendering()
	typecheck.NotImplementedError()
end

function INSTANCE:OnVisibilityOccludersRendered()
	typecheck.NotImplementedError()
end

function INSTANCE:SetVisibilityGridDisplayMode()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibilityGridDisplayMode()
	typecheck.NotImplementedError()
end

function INSTANCE:VisibilityGridDebugResetNode()
	typecheck.NotImplementedError()
end

function INSTANCE:VisibilityGridDebugEnterParent()
	typecheck.NotImplementedError()
end

function INSTANCE:VisibilityGridDebugEnterSibling()
	typecheck.NotImplementedError()
end

function INSTANCE:VisibilityGridDebugEnterFrontChild()
	typecheck.NotImplementedError()
end

function INSTANCE:VisibilityGridDebugEnterBackChild()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDynamicObjectVisibilityId()
	typecheck.NotImplementedError()
end

function INSTANCE:DebugDisplayDynamicVisibilityNode()
	typecheck.NotImplementedError()
end

function INSTANCE:ResetVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:ValidateVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:AllocateVisibilityObjectId()
	typecheck.NotImplementedError()
end

function INSTANCE:AllocateVisibilitySectorId()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibilityTableSize()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibilityTableCount()
	typecheck.NotImplementedError()
end

function INSTANCE:UpdateVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStaticLightCount()
	typecheck.NotImplementedError()
end

function INSTANCE:GenerateVisibilityForLight()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportVisibilityData()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportVisibilityData()
	typecheck.NotImplementedError()
end

function INSTANCE:ShowVisibilityWindow()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilityWindowVisible()
	typecheck.NotImplementedError()
end

function INSTANCE:GenerateVisibilityStatisticsReport()
	typecheck.NotImplementedError()
end

function INSTANCE:OptimizeVisibilityData()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableStaticProjectors()
	typecheck.NotImplementedError()
end

function INSTANCE:AreStaticProjectorsEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableDynamicProjectors()
	typecheck.NotImplementedError()
end

function INSTANCE:AreDynamicProjectorsEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:AddStaticTextureProjector()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveStaticTextureProjector()
	typecheck.NotImplementedError()
end

function INSTANCE:AddDynamicTextureProjector()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveDynamicTextureProjector()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveTextureProjector()
	typecheck.NotImplementedError()
end

function INSTANCE:SetShadowMode()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowMode()
	typecheck.NotImplementedError()
end

function INSTANCE:SetShadowAttenuation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowAttenuation()
	typecheck.NotImplementedError()
end

function INSTANCE:SetShadowNormalIntensity()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowNormalIntensity()
	typecheck.NotImplementedError()
end

function INSTANCE:SetShadowResolution()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowResolution()
	typecheck.NotImplementedError()
end

function INSTANCE:SetMaxSimultaneousShadows()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMaxSimultaneousShadows()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowCamera()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowRenderContext()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShadowMaterialPass()
	typecheck.NotImplementedError()
end

function INSTANCE:InvalidateStaticShadowProjectors()
	typecheck.NotImplementedError()
end

function INSTANCE:GenerateStaticShadowProjectors()
	typecheck.NotImplementedError()
end

function INSTANCE:SetupStaticDirectionalShadow()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateDecal()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveDecal()
	typecheck.NotImplementedError()
end

function INSTANCE:ShatterMesh()
	typecheck.NotImplementedError()
end

function INSTANCE:AddCameraShake()
	typecheck.NotImplementedError()
end

function INSTANCE:ApplyCameraShakes()
	typecheck.NotImplementedError()
end

function INSTANCE:IsVisibilityResetNeeded()
	typecheck.NotImplementedError()
end

function INSTANCE:VisibilityResetNeeded()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveLevelStaticData()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadLevelStaticData()
	typecheck.NotImplementedError()
end

function INSTANCE:PostLoadLevelStaticData()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveLevelStaticObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadLevelStaticObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:PostLoadLevelStaticObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveLevelDynamicData()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadLevelDynamicData()
	typecheck.NotImplementedError()
end

function INSTANCE:PostLoadLevelDynamicData()
	typecheck.NotImplementedError()
end

function INSTANCE:SetPolygonBudgets()
	typecheck.NotImplementedError()
end

function INSTANCE:GetPolygonBudgets()
	typecheck.NotImplementedError()
end

function INSTANCE:SetUpdateOnlyVisibleObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:GetUpdateOnlyVisibleObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:AddRenderObject()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveRenderObject()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:DestroyIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:Register()
	typecheck.NotImplementedError()
end

function INSTANCE:Unregister()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLevelExtents()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableDebugDisplay()
	typecheck.NotImplementedError()
end

function INSTANCE:IsDebugDisplayEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableProjectorDebugDisplay()
	typecheck.NotImplementedError()
end

function INSTANCE:IsProjectorDebugDisplayEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableDirtyCullDebugDisplay()
	typecheck.NotImplementedError()
end

function INSTANCE:IsDirtyCullDebugDisplayEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableLightingDebugDisplay()
	typecheck.NotImplementedError()
end

function INSTANCE:IsLightingDebugDisplayEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLastCameraPosition()
	typecheck.NotImplementedError()
end

function INSTANCE:PerFrameStatisticsUpdate()
	typecheck.NotImplementedError()
end

function INSTANCE:GetStatistics()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputeVisibilityMeshRam()
	typecheck.NotImplementedError()
end

function INSTANCE:CustomizedRender()
	typecheck.NotImplementedError()
end

function INSTANCE:RenderObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:RenderObject()
	typecheck.NotImplementedError()
end

function INSTANCE:RenderBackfaceOccluders()
	typecheck.NotImplementedError()
end

function INSTANCE:OptimizeLoDs()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseVisibilityResources()
	typecheck.NotImplementedError()
end

function INSTANCE:InternalVisibilityReset()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVisibilityCamera()
	typecheck.NotImplementedError()
end

function INSTANCE:VisibilityRenderAndScan()
	typecheck.NotImplementedError()
end

function INSTANCE:MergeVisibilitySectorIDs()
	typecheck.NotImplementedError()
end

function INSTANCE:MergeVisibilityObjectIDs()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseProjectorResources()
	typecheck.NotImplementedError()
end

function INSTANCE:ApplyProjectors()
	typecheck.NotImplementedError()
end

function INSTANCE:ApplyProjectorToObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputeProjectorAttenuation()
	typecheck.NotImplementedError()
end

function INSTANCE:AllocateDecalResources()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseDecalResources()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveLddVariables()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveStaticObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveDynamicObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveStaticLights()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveStaticObjectStates()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadLddVariables()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadStaticObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadDynamicObjects()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadStaticLights()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadStaticObjectStates()
	typecheck.NotImplementedError()
end

function INSTANCE:InternalAddDynamicObject()
	typecheck.NotImplementedError()
end

function INSTANCE:InternalAddStaticObject()
	typecheck.NotImplementedError()
end

function INSTANCE:InternalAddStaticLight()
	typecheck.NotImplementedError()
end

function INSTANCE:ResetSunLight()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadSunLight()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveSunLight()
	typecheck.NotImplementedError()
end

function INSTANCE:AddCollectedObjectsToList()
	typecheck.NotImplementedError()
end

function INSTANCE:AddCollectedCollideableObjectsToList()
	typecheck.NotImplementedError()
end

function INSTANCE:AddCollectedLightsToList()
	typecheck.NotImplementedError()
end
