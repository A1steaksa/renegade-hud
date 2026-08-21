-- Based on HTreeClass within Code/ww3d2/htree.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class HTreeClass
--- @field Instance HTreeInstance The metatable used by HTreeInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HTreeClass"

--- @class HTreeInstance
--- @field Static HTreeClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HTree" )
INSTANCE.Class = "HTreeInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHTree = true

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

    --- @enum HTreeLoadResult
    STATIC.H_TREE_LOAD_RESULT = {
        OK		   = enumBuilder:Set( 0 ),
        LOAD_ERROR = enumBuilder:Next(),
    }
    local hTreeLoadResultEnum = STATIC.H_TREE_LOAD_RESULT
--#endregion

--#region Imports

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )

	--- @type PivotClass
	local pivotClass = CNC.Import( "code/ww3d2/pivot.lua" )

	--- @type QuaternionClass
	local quaternionClass = CNC.Import( "code/wwmath/quaternion.lua" )

	--- @type Matrix3dClass
	local matrix3dClass = CNC.Import( "code/wwmath/matrix3d.lua" )

	--- @type HTreeClass
	local hTreeClass = CNC.Import( "code/ww3d2/h-tree.lua" )

	--- @type ClassUtils
	local classUtils = CNC.Import( "sh_class-utils.lua" )
--#endregion

--#region Imported Enums

	local w3dChunkTypeEnum = w3dFileIds.W3D_CHUNK_TYPE
	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HTreeClass

    --- Creates a new HTreeInstance
	--- @param src HTreeInstance?
    --- @return HTreeInstance
    function STATIC.New( src )
        return robustclass.New( "Renegade_HTree", src )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HTreeInstance, `false` otherwise
    function STATIC.IsHTree( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHTree and true or false
    end

    typecheck.RegisterType( "HTreeInstance", STATIC.IsHTree )

	function STATIC.CreateMorphed()
		typecheck.NotImplementedError()
	end

	--- @param treeBase HTreeInstance
	--- @param treeA HTreeInstance
	--- @param treeB HTreeInstance
	--- @param aScale number
	--- @param bScale number
	function STATIC.CreateInterpolated( treeBase, treeA, treeB, aScale, bScale )
		-- "Clone the first one,"
		local newTree = hTreeClass.New( treeBase )

		local aScaleAbs = math.abs( aScale )
		local bScaleAbs = math.abs( bScale )

		if aScaleAbs + bScaleAbs > 0 then
			-- Then interpolate all the pivots intranslations
			for pivotIndex = 1, newTree._NumPivots do
				local posA = LerpVector(
					aScale,
					treeBase.Pivot[pivotIndex].BaseTransform:GetTranslation(),
					treeA.Pivot[pivotIndex].BaseTransform:GetTranslation()
				)

				local posB = LerpVector(
					bScale,
					treeBase.Pivot[pivotIndex].BaseTransform:GetTranslation(),
					treeB.Pivot[pivotIndex].BaseTransform:GetTranslation()
				)

				local pos = ( posA * aScaleAbs + posB * bScaleAbs ) / ( aScaleAbs + bScaleAbs )

				newTree.Pivot[pivotIndex].BaseTransform:SetTranslation( pos )
			end
		end

		return newTree
	end
end


--- @class HTreeInstance
--- @field Name string
--- @field _NumPivots integer
--- @field Pivot PivotInstance[]
--- @field ScaleFactor number

--- @param src HTreeInstance?
function INSTANCE:Renegade_HTree( src )
	self._NumPivots = 0
	self.Pivot = nil
	self.ScaleFactor = 1.0

	self.Name = ""

	-- ( src: HTreeInstance )
	if src ~= nil then
		typecheck.AssertArgType( self.Class, 1, src, "HTreeInstance" )
		--- @cast src HTreeInstance

		self.Name = src.Name

		self._NumPivots = src._NumPivots
		if self._NumPivots > 0 then
			self.Pivot = classUtils.InitializeArray( "Renegade_Pivot", self._NumPivots )
		end

		for pivotIndex = 1, self._NumPivots do
			self.Pivot[pivotIndex] = src.Pivot[pivotIndex]

			if src.Pivot[pivotIndex].Parent ~= nil then
				self.Pivot[pivotIndex].Parent = self.Pivot[src.Pivot[pivotIndex].Parent.Index]
			else
				self.Pivot[pivotIndex].Parent = nil
			end
		end

		self.ScaleFactor = src.ScaleFactor
	end
end

function INSTANCE:_Renegade_HTree()
	self:Free()
end

--- "Loads a hierarchy tree from a file"
--- @param cload ChunkLoadInstance
--- @return HTreeLoadResult
function INSTANCE:LoadW3d( cload )
	self:Free()

	-- "Read the first chunk, it should be the hierarchy header"
	if not cload:OpenChunk() then
		return hTreeLoadResultEnum.LOAD_ERROR
	end

	if cload:CurChunkId() ~= w3dChunkTypeEnum.W3D_CHUNK_HIERARCHY_HEADER then
		section.Warn( "ERROR: Expected Hierarchy Header" )
		return hTreeLoadResultEnum.LOAD_ERROR
	end

	local header = cload:ReadStruct( "W3dHierarchyStruct" )
	if header == nil then
		return hTreeLoadResultEnum.LOAD_ERROR
	end

	cload:CloseChunk()

	-- "
	-- Check the version, if < 3.0 add a root node for everything to attach to.
	-- The [LoadPivots] function will also have to be notified of this.
	-- "
	local pre30 = false
	if header.Version < w3dFileIds.W3D_MAKE_VERSION( 3, 0 ) then
		header.NumPivots = header.NumPivots + 1
		pre30 = true
	end

	-- "Allocate the array of pivots"
	self.Name = header.Name
	self._NumPivots = header.NumPivots
	if self._NumPivots > 0 then
		self.Pivot = classUtils.InitializeArray( "Renegade_Pivot", self._NumPivots )
	end

	-- "Now, read in all of the other chunks for this hierarchy."
	while cload:OpenChunk() do
		local chunkId = cload:CurChunkId()

		if chunkId == w3dChunkTypeEnum.W3D_CHUNK_PIVOTS then
			if not self:ReadPivots( cload, pre30 ) then
				self:Free()
				return hTreeLoadResultEnum.LOAD_ERROR
			end
		else
			section.Warn( "Expected W3D_CHUNK_PIVOTS ('", w3dChunkTypeEnum.W3D_CHUNK_PIVOTS, "') but got '", chunkId, "'" )
		end
		cload:CloseChunk()
	end

	return hTreeLoadResultEnum.OK
end

function INSTANCE:InitDefault()
	self:Free()

	self._NumPivots = 1

	self.Pivot = classUtils.InitializeArray( "Renegade_Pivot", self._NumPivots )

	local rootPivot = self.Pivot[1]
	rootPivot.Index = 1
	rootPivot.Parent = nil
	rootPivot.BaseTransform:MakeIdentity()
	rootPivot.Transform:MakeIdentity()
	rootPivot.IsVisible = true
	rootPivot.Name = "RootTransform"

	self.Name = ""
end

--- @return string
function INSTANCE:GetName()
	return self.Name
end

--- @return integer
function INSTANCE:NumPivots()
	return self._NumPivots
end

--- "Find a bone by name"
--- @param name string
--- @return integer
function INSTANCE:GetBoneIndex( name )
	for i = 1, self._NumPivots do
		if self.Pivot[i].Name == name then
			return i
		end
	end
	return 0
end

--- "Get the name of a bone from its index"
--- @param boneIndex integer
--- @return string
function INSTANCE:GetBoneName( boneIndex )
	return self.Pivot[boneIndex].Name
end

--- "Returns index of the parent of the given bone"
--- @param boneIndex integer "The bone you are interested in"
--- @return integer "The index of that bone's parent"
function INSTANCE:GetParentIndex( boneIndex )
	if self.Pivot[boneIndex].Parent ~= nil then
		return self.Pivot[boneIndex].Parent.Index
	else
		return 1
	end
end

--- "Computes the base pose transform for each pivot"
--- @param root Matrix3dInstance
function INSTANCE:BaseUpdate( root )
	local pivot

	self.Pivot[1].Transform = root
	self.Pivot[1].IsVisible = true

	for pivotIndex = 2, self._NumPivots do
		pivot = self.Pivot[pivotIndex]

		assert( pivot.Parent ~= nil )
		pivot.Transform = pivot.Parent.Transform * pivot.BaseTransform
		pivot.IsVisible = true

		if pivot.IsCaptured then
			pivot:CaptureUpdate()
		end
	end
end

function INSTANCE:AnimationUpdate()
	typecheck.NotImplementedError()
end

function INSTANCE:BlendUpdate()
	typecheck.NotImplementedError()
end

function INSTANCE:ComboUpdate()
	typecheck.NotImplementedError()
end

--- "Returns the transformation for the desired pivot"
--- @param pivot integer
--- @return Matrix3dInstance
function INSTANCE:GetTransform( pivot )
	assert( pivot >= 1 )
	assert( pivot <= self._NumPivots )

	return self.Pivot[pivot].Transform
end

--- @param pivot integer
--- @return boolean
function INSTANCE:GetVisibility( pivot )
	assert( pivot >= 1 )
	assert( pivot <= self._NumPivots )
	return self.Pivot[pivot].IsVisible
end

--- @return Matrix3dInstance
function INSTANCE:GetRootTransform()
	return self.Pivot[1].Transform
end

function INSTANCE:CaptureBone()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseBone()
	typecheck.NotImplementedError()
end

function INSTANCE:IsBoneCaptured()
	typecheck.NotImplementedError()
end

function INSTANCE:ControlBone()
	typecheck.NotImplementedError()
end

function INSTANCE:GetBoneControl()
	typecheck.NotImplementedError()
end

--- "Returns the transform of a pivot at the given frame."
--- @overload fun( self: HTreeInstance, motion: HAnimationInstance, pivotIndex: integer, frame: number, objectTransformationMatrix: Matrix3dInstance ):boolean, Matrix3dInstance
--- @overload fun( self: HTreeInstance, pivotIndex: integer, objectTransformationMatrix: Matrix3dInstance ): boolean, Matrix3dInstance
function INSTANCE:SimpleEvaluatePivot( ... )
	local args = { ... }
	local argCount = #args
	typecheck.AssertArgCount( self.Class, argCount, { 2, 4 } )

	local returnValue = false

	--- @type Matrix3dInstance
	local endTransformationMatrix = matrix3dClass.New()
	endTransformationMatrix:MakeIdentity()

	-- ( pivotIndex: integer, objectTransformationMatrix: Matrix3dInstance ): boolean, Matrix3dInstance
	if argCount == 2 then
		local pivotIndex				 = args[1] --[[@as integer]]
		local objectTransformationMatrix = args[2] --[[@as Matrix3dInstance]]

		if endTransformationMatrix ~= nil and pivotIndex >= 1 and pivotIndex < self._NumPivots then
			-- "Loop over the hierarchy of pivots that this pivot is attached to and transform each."
			local pivot = self.Pivot[pivotIndex]
			while pivot ~= nil and pivot.Parent ~= nil do
				-- "Build a matrix that represents the animatino for this pivot"
				local animationTransformationMatrix = matrix3dClass.New( true )

				-- "Transform the animation transform by the 'relative-to-parent' transform."
				local currentTransformationMatrix = pivot.BaseTransform * animationTransformationMatrix

				-- "Transform the return value by this transform"
				endTransformationMatrix = currentTransformationMatrix * endTransformationMatrix

				pivot = pivot.Parent
			end

			-- "Transform the return value by the object's transform"
			endTransformationMatrix = objectTransformationMatrix * endTransformationMatrix
			returnValue = true
		end

	-- ( motion: HAnimationInstance, pivotIndex: integer, frame: number, objectTransformationMatrix: Matrix3dInstance ): boolean, Matrix3dInstance
	else
		local motion 	 				 = args[1] --[[@as HAnimationInstance]]
		local pivotIndex 				 = args[2] --[[@as integer]]
		local frame 	 				 = args[3] --[[@as number]]
		local objectTransformationMatrix = args[4] --[[@as Matrix3dInstance]]

		if motion ~= nil and endTransformationMatrix ~= nil and pivotIndex >= 1 and pivotIndex < self._NumPivots then
			-- "Loop over the hierarchy of pivots that this pivot is attached to and transform each."
			local pivot = self.Pivot[pivotIndex]
			while pivot ~= nil and pivot.Parent ~= nil do
				-- "Build a matrix that represents the animatino for this pivot"
				local animationTransformationMatrix = motion:GetTransform( pivot.Index, frame )

				local transform = animationTransformationMatrix:GetTranslation()
				animationTransformationMatrix:SetTranslation( transform * self.ScaleFactor )

				-- "Transform the animation transform by the 'relative-to-parent' transform."
				local currentTransformationMatrix = pivot.BaseTransform * animationTransformationMatrix

				-- "Transform the return value by this transform"
				endTransformationMatrix = currentTransformationMatrix * endTransformationMatrix

				pivot = pivot.Parent
			end

			-- "Transform the return value by the object's transform"
			endTransformationMatrix = objectTransformationMatrix * endTransformationMatrix

			-- "Success!"
			returnValue = true
		end
	end

	return returnValue, endTransformationMatrix
end

function INSTANCE:Scale()
	typecheck.NotImplementedError()
end

--- "De-allocate all memory in use"
function INSTANCE:Free()
	if self.Pivot ~= nil then
		self.Pivot = nil
	end
	self._NumPivots = 0

	-- "Also clean up other members:"
	self.ScaleFactor = 1.0
end

--- "Reads the pivots out of a file"
--- @param cload ChunkLoadInstance
--- @param pre30 boolean
--- @return boolean
function INSTANCE:ReadPivots( cload, pre30 )
	local firstPivot = 1

	-- "At (w3d file format) version 3.0, I added a node for the root.  Pre-3.0 htrees didn't have this so we just put one in"
	if pre30 then
		local pivot = pivotClass.New()
		pivot.Index = 0
		pivot.Parent = nil
		pivot.BaseTransform:MakeIdentity()
		pivot.Transform:MakeIdentity()
		pivot.IsVisible = true
		pivot.Name = "RootTransform"
		self.Pivot[1] = pivot
		firstPivot = firstPivot + 1
	end

	--- @type W3dPivotStruct?
	local readPivot
	--- @type PivotInstance
	local newPivot

	for pivotIndex = firstPivot, self._NumPivots do

		readPivot = cload:ReadStruct( "W3dPivotStruct" )
		if readPivot == nil then
			return false
		end

		-- Adjust the parent index to account for Lua's arrays starting at 1 instead of 0
		readPivot.ParentIdx = readPivot.ParentIdx + 1

		newPivot = pivotClass.New()
		self.Pivot[pivotIndex] = newPivot
		newPivot.Name = readPivot.Name
		newPivot.Index = pivotIndex

		newPivot.BaseTransform:MakeIdentity()
		newPivot.BaseTransform:Translate( Vector( readPivot.Translation.X, readPivot.Translation.Y, readPivot.Translation.Z ) )

		newPivot.BaseTransform =
			newPivot.BaseTransform *
			quaternionClass.BuildMatrix3d(
				quaternionClass.New(
					readPivot.Rotation.Q[1],
					readPivot.Rotation.Q[2],
					readPivot.Rotation.Q[3],
					readPivot.Rotation.Q[4]
				)
			)

		-- "At version 3.0 a root node was added, this "fixes up" pre-3.0 files to have that root node"
		if pre30 then
			readPivot.ParentIdx = readPivot.ParentIdx + 1
		end

		-- "  
		-- Set the parent pointer.
		-- The first pivot will have a parent index of -1 (in post-3.0 files) so set its parent to [nil].
		-- "  
		if readPivot.ParentIdx == -1 then
			self.Pivot[pivotIndex].Parent = nil
			assert( pivotIndex == 1 )
		else
			self.Pivot[pivotIndex].Parent = self.Pivot[readPivot.ParentIdx]
		end
	end

	self.Pivot[1].Transform:MakeIdentity()
	self.Pivot[1].IsVisible = true

	return true
end
