-- Based on HLodClass within Code/ww3d2/hlod.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type Animatable3dObjectClass
local animatable3dObjectClass = CNC.Import( "code/ww3d2/animatable-3d-object.lua" )

--- @class HLodClass : Animatable3dObjectClass
--- @field Instance HLodInstance The metatable used by HLodInstance
local STATIC = CNC.CreateExport( animatable3dObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HLodClass"

--- @class HLodInstance : Animatable3dObjectInstance
--- @field Static HLodClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HLod : Renegade_Animatable3dObject" )
INSTANCE.Class = "HLodInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHLod = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type ModelArrayClass
	local modelArrayClass = CNC.Import( "code/ww3d2/model-array.lua" )

	--- @type Matrix3dClass
	local matrix3dClass = CNC.Import( "code/wwmath/matrix3d.lua" )

	--- @type MinMaxAABoxClass
	local minMaxAABoxClass = CNC.Import( "code/wwmath/min-max-aa-box.lua" )

	--- @type RenderObjectClass
	local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

	--- @type TextUtils
	local textUtils = CNC.Import( "sh_text-utils.lua" )

	--- @type AABoxClass
	local aABoxClass = CNC.Import( "code/wwmath/aabox.lua" )

	--- @type SphereClass
	local sphereClass = CNC.Import( "code/wwmath/sphere.lua" )

	--- @type ModelNodeClass
	local modelNodeClass = CNC.Import( "code/ww3d2/model-node.lua" )

	--- @type ClassUtils
	local classUtils = CNC.Import( "sh_class-utils.lua" )

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )
--#endregion

--#region Imported Enums

	local renderObjectClassIdEnum = renderObjectClass.RENDER_OBJECT_CLASS_ID
	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HLodClass

    --- Creates a new HLodInstance
	--- @overload fun( src: HLodInstance ): HLodInstance
	--- @overload fun( name: string, lods: RenderObjectInstance, count: integer ): HLodInstance
	--- @overload fun( definition: HLodDefinitionInstance ): HLodInstance
	--- @overload fun( definition: HModelDefinitionInstance ): HLodInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_HLod", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HLodInstance, `false` otherwise
    function STATIC.IsHLod( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHLod and true or false
    end

    typecheck.RegisterType( "HLodInstance", STATIC.IsHLod )
end


--- @class HLodInstance
--- @field LodCount integer Lod Render Objects, basically one of the LOD Models will be rendered.  Typically each model in an HLodModel will be a mesh or a 'simple' HLod (one with a single LOD)
--- @field CurrentLod integer
--- @field Lod ModelArrayInstance[]
--- @field BoundingBoxIndex integer "An animating heirarchy can use a hidden CLASSID_OBBOX mesh to represent its bounding box as it animates.  This is the sub object index of that mesh (if it exists)"
--- @field Cost number[] "Cost array (recalculated every frame)"
--- @field Value number[] "Value array (recalculated every frame)"
--- @field AdditionalModels ModelArrayInstance "Additional models, these models have been linked to one of the bones in this model.  They are all always rendered.  They can be HLODs themselves in order to implement switching on sub models.  Note:  This uses [ModelArrayInstance] for convenience, but MaxScreenSize, NonPixelCost, PixelCostPerArea, BenefitFactor are not used here."
--- @field SnapPoints SnapPointsInstance[] "Possible array of snap points."
--- @field ProxyArray ProxyArrayInstance[] "Possible array of proxy objects (names and bone indexes for application defined usage)"
--- @field LodBias number "Current LOD Bias (affects recalculation of the Value array)"

--- @overload fun()
--- @overload fun( src: HLodInstance )
--- @overload fun( definition: HLodDefinitionInstance )
--- @overload fun( definition: HModelDefinitionInstance )
--- @overload fun( name: string, lods: RenderObjectInstance[], count: integer )
function INSTANCE:Renegade_HLod( ... )
	local args = { ... }
	local argCount = #args
	typecheck.AssertArgCount( INSTANCE.Class, argCount, { 1, 3 } )

	-- ()
	if argCount == 0 then
		animatable3dObjectClass.Instance.Renegade_Animatable3dObject( self, nil )

		self.LodCount = 0
		self.CurrentLod = 0
		self.Lod = nil
		self.BoundingBoxIndex = -1
		self.Cost = nil
		self.Value = nil
		self.AdditionalModels = modelArrayClass.New()
		self.SnapPoints = nil
		self.ProxyArray = nil
		self.LodBias = 1.0
		return
	end

	if argCount == 1 then
		local arg = args[1]
		typecheck.AssertArgType( INSTANCE.Class, 1, arg, { "HLodInstance", "HLodDefinitionInstance", "HModelDefinitionInstance" } )

		-- ( src: HLodInstance )
		if typecheck.IsOfType( arg, "HLodInstance" ) then
			local src = arg --[[@as HLodInstance]]

			animatable3dObjectClass.Instance.Renegade_Animatable3dObject( self, src )

			typecheck.NotImplementedError()
			return

		-- "Constructs an HLod from an [HLodDefinitionInstance]"
		-- ( definition: HLodDefinitionInstance )
		elseif typecheck.IsOfType( arg, "HLodDefinitionInstance" ) then
			local definition = arg --[[@as HLodDefinitionInstance]]

			animatable3dObjectClass.Instance.Renegade_Animatable3dObject( self, definition.HierarchyTreeName )

			self.LodCount = 0
			self.CurrentLod = 0
			self.Lod = nil
			self.BoundingBoxIndex = -1
			self.Cost = nil
			self.Value = nil
			self.AdditionalModels = modelArrayClass.New()
			self.SnapPoints = nil
			self.ProxyArray = nil
			self.LodBias = 1.0

			-- "Set the name"
			self:SetName( definition:GetName() )

			-- "Number of LODs comes from the dislod"
			self.LodCount = definition.LodCount
			assert( self.LodCount >= 1 )

			-- We need to initialize these arrays manually
			self.Lod = classUtils.InitializeArray( "Renegade_ModelArray", self.LodCount )
			self.Cost = classUtils.InitializeArray( fundamentalDataTypeEnum.Float, self.LodCount )
			-- "
			-- Value has LodCount + 1 entries so PostIncrementValue can always use
			-- Value[CurLod + 1] (the last entry will be AT_MAX_LOD).
			-- "
			self.Value = classUtils.InitializeArray( fundamentalDataTypeEnum.Float, self.LodCount + 1 )

			-- "Add Models to the ModelArrays"
			for iLod = 1, definition.LodCount do
				self.Lod[iLod] = modelArrayClass.New()

				self.Lod[iLod].MaxScreenSize = definition.Lod[iLod].MaxScreenSize
				for iModel = 1, definition.Lod[iLod].ModelCount do
					local renderObject = ww3dAssetManagerClass.GetInstance():CreateRenderObject( definition.Lod[iLod].ModelName[iModel] )
					local boneIndex = definition.Lod[iLod].BoneIndex[iModel]

					-- Convert from a 0 based to 1 based index
					boneIndex = boneIndex + 1

					if renderObject ~= nil then
						self:AddLodModel( iLod, renderObject, boneIndex )
					end
				end
			end

			self:RecalculateStaticLodFactors()

			-- "Add aggregates to this model"
			for aggregateIndex = 1, definition.Aggregates.ModelCount do
				local renderObject = ww3dAssetManagerClass.GetInstance():CreateRenderObject(
					definition.Aggregates.ModelName[aggregateIndex]
				)
				local boneIndex = definition.Aggregates.BoneIndex[aggregateIndex]

				if renderObject ~= nil then
					INSTANCE.AddSubObjectToBone( self, renderObject, boneIndex )
					renderObject = nil
				end
			end

			-- "Add a reference to the proxy array"
			self.ProxyArray = definition.ProxyArray

			-- "
			-- So that the object is ready for use after construction, we will
			-- complete its initialization by initializing its cost and value arrays
			-- according to a screen are of 1 pixel.
			-- "
			local minLod = self:CalculateCostValueArrays( 1.0, self.Value, self.Cost )

			-- "Ensure lod is no less than minimum allowed"
			if self.CurrentLod < minLod then
				self:SetLodLevel( minLod )
			end

			-- "Flag our sub-objects as having dirty transforms"
			self:SetSubObjectTransformsDirty( true )

			self:UpdateSubObjectBits()
			self:UpdateObjectSpaceBoundingVolumes()
			return

		-- ( definition: HModelDefinitionInstance )
		else
			local definition = arg --[[@as HModelDefinitionInstance]]

			animatable3dObjectClass.Instance.Renegade_Animatable3dObject( self, definition.BasePoseName )

			self.LodCount = 0
			self.CurrentLod = 0
			self.Lod = nil
			self.BoundingBoxIndex = -1
			self.Cost = nil
			self.Value = nil
			self.AdditionalModels = modelArrayClass.New()
			self.SnapPoints = nil
			self.ProxyArray = nil
			self.LodBias = 1.0

			typecheck.NotImplementedError()
			return
		end
	end

	-- ( name: string, lods: RenderObjectInstance[], count: integer )
	if argCount == 3 then
		local name  = args[1] --[[@as string]]
		local lods  = args[2] --[[@as RenderObjectInstance[] ]]
		local count = args[3] --[[@as integer]]
		typecheck.AssertArgType( INSTANCE.Class, 1, name, "string" )

		typecheck.NotImplementedError()
		return
	end
end

function INSTANCE:_Renegade_HLod()
	typecheck.NotImplementedError()
end

function INSTANCE:Clone()
	typecheck.NotImplementedError()
end

function INSTANCE:ClassId()
	typecheck.NotImplementedError()
end

function INSTANCE:GetNumPolys()
	typecheck.NotImplementedError()
end

function INSTANCE:SetMaxScreenSize()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMaxScreenSize()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLodCount()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLodModelCount()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekLodModel()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLodModel()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLodModelBone()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAdditionalModelCount()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekAdditionalModel()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAdditionalModel()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAdditionalModelBone()
	typecheck.NotImplementedError()
end

function INSTANCE:IsNullLodIncluded()
	typecheck.NotImplementedError()
end

function INSTANCE:IncludeNullLod()
	typecheck.NotImplementedError()
end

function INSTANCE:GetProxyCount()
	typecheck.NotImplementedError()
end

function INSTANCE:GetProxy()
	typecheck.NotImplementedError()
end

function INSTANCE:Render()
	typecheck.NotImplementedError()
end

function INSTANCE:SpecialRender()
	typecheck.NotImplementedError()
end

--- @param matrix Matrix3dInstance
function INSTANCE:SetTransform( matrix )
	animatable3dObjectClass.Instance.SetTransform( self, matrix )
	self:SetSubObjectTransformsDirty( true )
end

--- "Sets the position"
--- @param pos Vector
function INSTANCE:SetPosition( pos )
	animatable3dObjectClass.Instance.SetPosition( self, pos )
	self:SetSubObjectTransformsDirty( true )
end

function INSTANCE:NotifyAdded()
	typecheck.NotImplementedError()
end

function INSTANCE:NotifyRemoved()
	typecheck.NotImplementedError()
end

--- "Returns total number of sub-objects"
--- @return integer
function INSTANCE:GetNumSubObjects()
	local count = 0
	for lod = 1, self.LodCount do
		count = count + #self.Lod[lod]
	end
	count = count + #self.AdditionalModels
	return count
end

--- "Returns a pointer to specified sub-object"
--- @param index integer
--- @return RenderObjectInstance
function INSTANCE:GetSubObject( index )
	assert( index >= 1 )
	for lod = 1, self.LodCount do
		if index <= #self.Lod[lod] then
			return self.Lod[lod][index].Model
		end
		index = index - #self.Lod[lod]
	end
	assert( index <= #self.AdditionalModels )
	return self.AdditionalModels[index].Model
end

function INSTANCE:AddSubObject()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveSubObject()
	typecheck.NotImplementedError()
end

--- "Returns the number of objects on the given bone"
--- @param boneIndex integer
--- @return integer
function INSTANCE:GetNumSubObjectsOnBone( boneIndex )
	local count = 0
	for lod = 1, self.LodCount do
		for model = 1, #self.Lod[lod] do
			if self.Lod[lod][model].BoneIndex == boneIndex then
				count = count + 1
			end
		end
	end

	for model = 1, #self.AdditionalModels do
		if self.AdditionalModels[model].BoneIndex == boneIndex then
			count = count + 1
		end
	end

	return count
end

--- "Returns obj on the given bone"
--- @param index integer
--- @param boneIndex integer
--- @return RenderObjectInstance?
function INSTANCE:GetSubObjectOnBone( index, boneIndex )
	local count = 0
	for lod = 1, self.LodCount do
		for model = 1, #self.Lod[lod] do
			if self.Lod[lod][model].BoneIndex == boneIndex then
				if count == index then
					return self.Lod[lod][model].Model
				end
				count = count + 1
			end
		end
	end
	for model = 1, #self.AdditionalModels do
		if self.AdditionalModels[model].BoneIndex == boneIndex then
			if count == index then
				return self.AdditionalModels[model].Model
			end
			count = count + 1
		end
	end
	return nil
end

--- "Returns bone index of given object"
--- @param subObject RenderObjectInstance
--- @return integer
function INSTANCE:GetSubObjectBoneIndex( subObject )
	for lod = 1, self.LodCount do
		for model = 1, #self.Lod[lod] do
			if self.Lod[lod][model].Model == subObject then
				return self.Lod[lod][model].BoneIndex
			end
		end
	end
	for model = 1, #self.AdditionalModels do
		if self.AdditionalModels[model].Model == subObject then
			return self.AdditionalModels[model].BoneIndex
		end
	end
	return 0
end

--- "Adds a sub-object to a bone"
--- @param subObject RenderObjectInstance
--- @param bone integer|string
--- @return boolean wasSuccessful
function INSTANCE:AddSubObjectToBone( subObject, bone )

	-- HLod only overrides one of this function's overloads
	-- So we're passing the un-overridden call to the parent class's overload
	-- ( subObject: RenderObjectInstance, boneIndex: string )
    if typecheck.IsOfType( bone, "string" ) then
        local boneName = bone --[[@as string]]

		return animatable3dObjectClass.Instance.AddSubObjectToBone( self, subObject, boneName )
    end

	local boneIndex = bone --[[@as integer]]

	if boneIndex < 0 or boneIndex > self.HTree:NumPivots() then
		return false
	end

	subObject:SetLodBias( self.LodBias )

	local newNode = modelNodeClass.New()
	newNode.Model = subObject
	newNode.Model:SetContainer( self )
	newNode.Model:SetAnimationHidden( self.HTree:GetVisibility( boneIndex ) == false )
	newNode.BoneIndex = boneIndex

	local result = true

	self.AdditionalModels[#self.AdditionalModels] = newNode

	INSTANCE.UpdateSubObjectBits( self )
	INSTANCE.UpdateObjectSpaceBoundingVolumes( self )
	INSTANCE.SetHierarchyValid( self, false )
	INSTANCE.SetSubObjectTransformsDirty( self, true )

	if INSTANCE.IsInScene( self ) then
		subObject:NotifyAdded( self.Scene )
	end

	return result
end

--- @overload fun( self )
--- @overload fun( self, animationCombo: HAnimationComboInstance )
--- @overload fun( self, motion: HAnimationInstance, frame: number, mode: integer )
--- @overload fun( self, motion0: HAnimationInstance, fram0: number, motion1: HAnimationInstance, frame1: number, percentage: number )
function INSTANCE:SetAnimation( ... )
	animatable3dObjectClass.Instance.SetAnimation( self, ... )
	self:SetSubObjectTransformsDirty( true )
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

function INSTANCE:IntersectAaBox()
	typecheck.NotImplementedError()
end

function INSTANCE:IntersectObBox()
	typecheck.NotImplementedError()
end

function INSTANCE:PrepareLod()
	typecheck.NotImplementedError()
end

--- "Compute lod factors"
function INSTANCE:RecalculateStaticLodFactors()
	-- "  
	-- Calculate NonPixelCost, PixelCostPerArea, BenefitFactor for all LOD levels.  
	-- NOTE: for now we are using vastly simplified Cost and Benefit metrics.  
	-- (these will be improved after initial experimentation).  
	-- the Cost metric is simply the number of polygons, and the Benefit
	-- Metric is 1 - 0.5 / #polygons^2.  
	-- "  

	for i = 1, self.LodCount do
		-- "Currently there are no pixel-related costs taken into account"
		self.Lod[i].PixelCostPerArea = 0.0

		-- "Sum polycount over all non-hidden models in array"
		local modelCount = #self.Lod[i]
		local polyCount = 0
		for j = 1, modelCount do
			if self.Lod[i][j].Model:IsNotHiddenAtAll() then
				polyCount = polyCount + self.Lod[i][j].Model:GetNumPolys()
			end
		end

		-- "If polycount is zero set Cost to a small nonzero amount to avoid divisions by zero."
		self.Lod[i].NonPixelCost = ( polyCount ~= 0 and polyCount or 0.000001 )

		-- "A polycount of zero yields a benefit factor of zero: otherwise apply formula."
		self.Lod[i].BenefitFactor = ( polyCount ~= 0 and ( 1 - ( 0.5 / (polyCount / polyCount ) ) ) or 0.0 )
	end
end

function INSTANCE:IncrementLod()
	typecheck.NotImplementedError()
end

function INSTANCE:DecrementLod()
	typecheck.NotImplementedError()
end

function INSTANCE:GetCost()
	typecheck.NotImplementedError()
end

function INSTANCE:GetValue()
	typecheck.NotImplementedError()
end

function INSTANCE:GetPostIncrementValue()
	typecheck.NotImplementedError()
end

--- "Set the current lod level"
--- @param lod integer
function INSTANCE:SetLodLevel( lod )

	lod = math.max( 1, lod )
	lod = math.min( lod, self.LodCount )

	if lod == self.CurrentLod then
		return
	end

	if self:IsInScene() then
		local modelCount = #self.Lod[self.CurrentLod]
		for i = 1, modelCount do
			self.Lod[ self.CurrentLod ][i].Model:NotifyRemoved( self.Scene )
		end
	end

	self.CurrentLod = lod

	if self:IsInScene() then
		local modelCount = #self.Lod[self.CurrentLod]
		for i = 1, modelCount do
			self.Lod[ self.CurrentLod ][i].Model:NotifyAdded( self.Scene )
		end
	end
end

function INSTANCE:GetLodLevel()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLodCount()
	typecheck.NotImplementedError()
end

--- @param bias number
function INSTANCE:SetLodBias( bias )
	assert( bias > 0.0 )
	bias = math.max( bias, 0.0 )
	self.LodBias = bias

	local additionalCount = #self.AdditionalModels
	for additionalModelIndex = 1, additionalCount do
		self.AdditionalModels[additionalModelIndex].Model:SetLodBias( bias )
	end
end

--- "Computes the cost-value arrays"
--- @param screenArea number
--- @param values number[]
--- @param costs number[]
--- @return integer
function INSTANCE:CalculateCostValueArrays( screenArea, values, costs )
	section.Warn( INSTANCE.Class, " - Skipping CalculateCostValueArrays" )
	return 1
end

function INSTANCE:GetCurrentLod()
	typecheck.NotImplementedError()
end

function INSTANCE:GetBoundingSphere()
	typecheck.NotImplementedError()
end

--- "Return the bounding box mesh if we have one."
--- @return AABoxInstance
function INSTANCE:GetBoundingBox()
	if self.BoundingBoxIndex >= 1 then
		-- "Get the bounding box in local coordinates"
		local box = self:GetObjectSpaceBoundingBox()
		assert( box ~= nil, INSTANCE.Class .. " - GetBoundingBox - Failed to get ObjectSpaceBoundingBox for: " .. tostring( self ) )

		-- "Transform the bounding box to world coordinates"
		self:GetTransform():TransformCenterExtentAABox( box.Center, box.Extent )
	else
		animatable3dObjectClass.Instance.GetBoundingBox( self )
	end

	return self.CachedBoundingBox
end

--- @return SphereInstance
function INSTANCE:GetObjectSpaceBoundingSphere()
	local box = self:GetObjectSpaceBoundingBox()

	if box == nil then
		section.Error( INSTANCE.Class, " - GetObjectSpaceBoundingSphere - Could not retrieve object space bounding box" )
		error()
	end

	local sphere = sphereClass.New( box.Center, box.Extent:Length() )
	return sphere
end

--- "Return the bounding box mesh if we have one."
--- @return AABoxInstance?
function INSTANCE:GetObjectSpaceBoundingBox()

	-- "Do we have a bounding box mesh?"
	local count = #self.Lod[self.LodCount]

	if self.BoundingBoxIndex >= 1 and self.BoundingBoxIndex <= count then

		local mesh = self.Lod[self.LodCount][self.BoundingBoxIndex].Model
		if mesh ~= nil and mesh:ClassId() == renderObjectClassIdEnum.CLASSID_OBBOX then

			local oBBBoxMesh = mesh --[[@as OBBoxRenderObjectInstance]]

			-- "  
			-- Determine what the box's transform 'should' be this frame.
			-- Note:  We do this because some animation types don't update
			-- unless they are visible.
			-- "  
			local _, boxTransformationMatrix = self:SimpleEvaluateBone( self.Lod[self.LodCount][self.BoundingBoxIndex].BoneIndex )

			-- "Convert the OBBox from its coordinate system to the coordinate system of the HLOD"
			local worldToHLodTransformationMatrix = self:GetTransform():GetOrthogonalInverse()
			local boxToHLodTransformationMatrix = worldToHLodTransformationMatrix * boxTransformationMatrix

			local center, extent = boxToHLodTransformationMatrix:TransformCenterExtentAABox( oBBBoxMesh:GetLocalCenter(), oBBBoxMesh:GetLocalExtent() )
			return aABoxClass.New( center, extent )
		end
	else
		return animatable3dObjectClass.Instance.GetObjectSpaceBoundingBox( self )
	end
end

function INSTANCE:CreateDecal()
	typecheck.NotImplementedError()
end

function INSTANCE:DeleteDecal()
	typecheck.NotImplementedError()
end

function INSTANCE:Scale()
	typecheck.NotImplementedError()
end

function INSTANCE:GetNumSnapPoints()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSnapPoint()
	typecheck.NotImplementedError()
end

function INSTANCE:SetHidden()
	typecheck.NotImplementedError()
end

--- "Replace the hierarchy tree"
--- @param htree HTreeInstance
function INSTANCE:SetHTree( htree )
	animatable3dObjectClass.Instance.SetHTree( self, htree )
end

function INSTANCE:Free()
	typecheck.NotImplementedError()
end

--- "Updates transforms of all sub-objects"
function INSTANCE:UpdateSubObjectTransforms()

	-- "Update the animation transforms, recurse up to the top of the tree..."
	animatable3dObjectClass.Instance.UpdateSubObjectTransforms( self )

	-- "Put the computed transforms into our sub objects."
	for lod = 1, self.LodCount do
		for model = 1, #self.Lod[lod] do
			local renderObject = self.Lod[lod][model].Model
			local bone = self.Lod[lod][model].BoneIndex

			renderObject:SetTransform( self.HTree:GetTransform( bone ) )
			renderObject:SetAnimationHidden( not self.HTree:GetVisibility( bone ) )
			renderObject:UpdateSubObjectTransforms()
		end
	end

	for model = 1, #self.AdditionalModels do
		local renderObject = self.AdditionalModels[model].Model
		local bone = self.AdditionalModels[model].BoneIndex

		renderObject:SetTransform( self.HTree:GetTransform( bone ) )
		renderObject:SetAnimationHidden( not self.HTree:GetVisibility( bone ) )
		renderObject:UpdateSubObjectTransforms()
	end

	self:SetSubObjectTransformsDirty( false )
end

function INSTANCE:UpdateObjectSpaceBoundingVolumes()
	-- "Do we still have a valid bounding box index?"
	local highLod = self.Lod[self.LodCount]

	local count = #highLod
	if
		   self.BoundingBoxIndex < 1
		or self.BoundingBoxIndex > count
		or highLod[self.BoundingBoxIndex].Model:ClassId() ~= renderObjectClassIdEnum.CLASSID_OBBOX
	then
		self.BoundingBoxIndex = -1
	end

	-- "Attempt to find an OBBox mesh inside the hierarchy"
	local index = #highLod

	while index >= 1 and self.BoundingBoxIndex == -1 do
		local model = highLod[index].Model

		local name = model:GetName()
		local nameSegment = textUtils.IndexOf( name, "." )
		if nameSegment ~= nil then
			name = name:sub( nameSegment + 1 )
		end

		-- "Does the name match the designator we are looking for?"
		if name == "BOUNDINGBOX" then
			self.BoundingBoxIndex = index
		end

		index = index - 1
	end

	-- "If we don't have any sub objects, just set default bounds"
	if self:GetNumSubObjects() <= 0 then
		section.Warn( INSTANCE.Class, "UpdateObjectSpaceBoundingVolumes - Does not have any sub objects" )

		self.ObjectSphere:Init( Vector( 0, 0, 0 ), 0 )
		self.ObjectBox.Center:SetUnpacked( 0, 0, 0 )
		self.ObjectBox.Extent:SetUnpacked( 0, 0, 0 )
		return
	end

	-- "Loop through all sub-objects, combining their object-space bounding spheres and boxes"
	-- "Put our HTree in its base pose at the origin."
	local sphere
	local objectAABox
	local box = minMaxAABoxClass.New()

	self.HTree:BaseUpdate( matrix3dClass.New( true ) )

	local renderObject = self:GetSubObject( 1 )
	assert( renderObject ~= nil )

	local boneTransformationMatrix = self.HTree:GetTransform( self:GetSubObjectBoneIndex( renderObject ) )
	sphere = renderObject:GetObjectSpaceBoundingSphere()
	sphere:Transform( boneTransformationMatrix )
	objectAABox = renderObject:GetObjectSpaceBoundingBox()

	box:Init( objectAABox )
	box:Transform( boneTransformationMatrix )

	for i = 2, self:GetNumSubObjects() do
		renderObject = self:GetSubObject( i )
		assert( renderObject ~= nil )

		local boneTransformationMatrix = self.HTree:GetTransform( self:GetSubObjectBoneIndex( renderObject ) )

		local tempSphere = renderObject:GetObjectSpaceBoundingSphere()
		tempSphere:Transform( boneTransformationMatrix )
		sphere:AddSphere( tempSphere )

		local tempBox = renderObject:GetObjectSpaceBoundingBox()
		tempBox:Transform( boneTransformationMatrix )
		box:AddBox( tempBox )
	end

	self.ObjectSphere = sphere
	self.ObjectBox = aABoxClass.New( box )

	self:InvalidateCachedBoundingVolumes()
	self:SetHierarchyValid( false )

	-- "Now update the object space bounding volumes of this object's container:"
	local container = self:GetContainer()
	if container then
		container:UpdateObjectSpaceBoundingVolumes()
	end
end

--- "Adds a model to one of the lods"
--- @param lod integer
--- @param renderObject RenderObjectInstance
--- @param boneIndex integer
function INSTANCE:AddLodModel( lod, renderObject, boneIndex )
	local newNode = modelNodeClass.New()
	newNode.Model = renderObject
	newNode.BoneIndex = boneIndex
	newNode.Model:SetContainer( self )
	newNode.Model:SetTransform( self.HTree:GetTransform( boneIndex ) )

	if INSTANCE.IsInScene( self ) and lod == self.CurrentLod then
		newNode.Model:NotifyAdded( self.Scene )
	end
	self.Lod[lod][#self.Lod[lod] + 1] = newNode
end
