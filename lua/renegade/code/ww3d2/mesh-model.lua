-- Based on MeshModelClass within Code/ww3d2/meshmdl.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type MeshGeometryClass
local meshGeometryClass = CNC.Import( "code/ww3d2/mesh-geometry.lua" )

--- @class MeshModelClass : MeshGeometryClass
--- @field Instance MeshModelInstance The metatable used by MeshModelInstance
local STATIC = CNC.CreateExport( meshGeometryClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "MeshModelClass"

--- @class MeshModelInstance : MeshGeometryInstance
--- @field Static MeshModelClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_MeshModel : Renegade_MeshGeometry" )
INSTANCE.Class = "MeshModelInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMeshModel = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type MeshGeometryClass
	local meshGeometryClass = CNC.Import( "code/ww3d2/mesh-geometry.lua" )

	--- @type MeshMaterialDescriptionClass
	local meshMaterialDescriptionClass = CNC.Import( "code/ww3d2/mesh-material-description.lua" )

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type WW3dErrorTypes
	local wW3dErrorTypes = CNC.Import( "code/ww3d2/w3d-errors.lua" )

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )

	--- @type ObsoleteW3dFileIds
	local obsoleteW3dFileIds = CNC.Import( "code/ww3d2/w3d-obsolete.lua" )

	--- @type MeshLoadContextClass
	local meshLoadContextClass = CNC.Import( "code/ww3d2/mesh-load-context.lua" )

	--- @type MaterialInfoClass
	local materialInfoClass = CNC.Import( "code/ww3d2/material-info.lua" )

	--- @type VertexMaterialClass
	local vertexMaterialClass = CNC.Import( "code/ww3d2/vertex-material.lua" )

	--- @type W3dUtilityClass
	local w3dUtilityClass = CNC.Import( "code/ww3d2/w3d-utility.lua" )

	--- @type TextureClass
	local textureClass = CNC.Import( "code/ww3d2/texture.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type WW3dClass
	local wW3dClass = CNC.Import( "code/ww3d2/ww3d.lua" )

	--- @type ShaderClass
	local shaderClass = CNC.Import( "code/ww3d2/shader.lua" )

	--- @type TextUtils
	local textUtils = CNC.Import( "sh_text-utils.lua" )

	--- @type ChunkIOClass
	local chunkIOClass = CNC.Import( "code/wwlib/chunk-io.lua" )
--#endregion

--#region Imported Enums

	local meshGeometryFlagsTypeEnum = meshGeometryClass.MESH_GEOMETRY_FLAGS_TYPE
	local wW3dErrorTypeEnum = wW3dErrorTypes.WW3D_ERROR_TYPE
	local colorSourceTypeEnum = vertexMaterialClass.COLOR_SOURCE_TYPE
	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
	local dstBlendFuncEnum = shaderClass.DST_BLEND_FUNC
	local alphaTestEnum = shaderClass.ALPHA_TEST
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class MeshModelClass

    --- Creates a new MeshModelInstance
    --- @return MeshModelInstance
    function STATIC.New()
        return robustclass.New( "Renegade_MeshModel" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) MeshModelInstance, `false` otherwise
    function STATIC.IsMeshModel( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMeshModel and true or false
    end

    typecheck.RegisterType( "MeshModelInstance", STATIC.IsMeshModel )
end

--- "  
--- This class is a repository for all of the geometry information that defines the mesh.  
--- Its purpose is to allow separate instances of a mesh to share as much data as possible.  
--- "  
--- @class MeshModelInstance
--- @field DefinitionMaterialDescription MeshMaterialDescriptionInstance "The default material description, allocated in constructor, always present."
--- @field AlternateMaterialDescription MeshMaterialDescriptionInstance "An optional alternate material description, allocated at load time if needed"
--- @field CurrentMaterialDescription MeshMaterialDescriptionInstance "...the currently active material description"
--- @field MaterialInfo MaterialInfoInstance "Collection of the unique materials in the mesh"
--- @field GapFiller GapFillerInstance
--- @field HasBeenInUse boolean "For debugging purposes!"

--- @param that MeshModelInstance?
function INSTANCE:Renegade_MeshModel( that )
	-- ( that: MeshModelInstance )
	if that ~= nil then

		typecheck.NotImplementedError()

	-- ()
	else
		meshGeometryClass.Instance.Renegade_MeshGeometry( self )

		self.DefinitionMaterialDescription = meshMaterialDescriptionClass.New()
		self.AlternateMaterialDescription = meshMaterialDescriptionClass.New()
		self.CurrentMaterialDescription = self.DefinitionMaterialDescription
		self.MaterialInfo = materialInfoClass.New()
		self.GapFiller = nil

		self:SetFlag( meshGeometryFlagsTypeEnum.DIRTY_BOUNDS, true )

		self.DefinitionMaterialDescription = meshMaterialDescriptionClass.New()
		self.CurrentMaterialDescription = self.DefinitionMaterialDescription

		self.MaterialInfo = materialInfoClass.New()
	end
end

function INSTANCE:_Renegade_MeshModel()
	typecheck.NotImplementedError()
end

--- @param polyCount integer
--- @param vertCount integer
--- @param passCount integer
function INSTANCE:Reset( polyCount, vertCount, passCount )
	self:ResetGeometry( polyCount, vertCount )

	-- "Release everything we have and reset to initial state"
	self.MaterialInfo:Reset()
	self.DefinitionMaterialDescription:Reset( polyCount, vertCount, passCount )
	if self.AlternateMaterialDescription ~= nil then
		self.AlternateMaterialDescription = nil
	end
	self.CurrentMaterialDescription = self.DefinitionMaterialDescription

	self.GapFiller = nil
end

function INSTANCE:RegisterForRendering()
	typecheck.NotImplementedError()
end

function INSTANCE:ShadowRender()
	typecheck.NotImplementedError()
end

--- @param passes integer
function INSTANCE:SetPassCount( passes )
	self.CurrentMaterialDescription:SetPassCount( passes )
end

--- @return integer
function INSTANCE:GetPassCount()
	return self.CurrentMaterialDescription:GetPassCount()
end

function INSTANCE:GetUvArray()
	typecheck.NotImplementedError()
end

function INSTANCE:GetUvArrayCount()
	typecheck.NotImplementedError()
end

function INSTANCE:GetUvArrayByIndex()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDcgArray()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDigArray()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDcgSource()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDigSource()
	typecheck.NotImplementedError()
end

function INSTANCE:GetColorArray()
	typecheck.NotImplementedError()
end

function INSTANCE:SetSingleMaterial()
	typecheck.NotImplementedError()
end

function INSTANCE:SetSingleTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:SetSingleShader()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSingleMaterial()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSingleTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSingleShader()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekSingleMaterial()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekSingleTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:SetMaterial()
	typecheck.NotImplementedError()
end

function INSTANCE:SetShader()
	typecheck.NotImplementedError()
end

function INSTANCE:SetTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:HasMaterialArray()
	typecheck.NotImplementedError()
end

function INSTANCE:HasShaderArray()
	typecheck.NotImplementedError()
end

function INSTANCE:HasTextureArray()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMaterial()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShader()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekMaterial()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:ReplaceTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:ReplaceVertexMaterial()
	typecheck.NotImplementedError()
end

function INSTANCE:MakeGeometryUnique()
	typecheck.NotImplementedError()
end

function INSTANCE:MakeUvArrayUnique()
	typecheck.NotImplementedError()
end

function INSTANCE:MakeColorArrayUnique()
	typecheck.NotImplementedError()
end

--- Note: This functiuon is from `Code/ww3d2/meshmdlio.cpp` but IS on the `MeshModelInstance` class  
--- @param cload ChunkLoadInstance
--- @return WW3dErrorType
function INSTANCE:LoadW3d( cload )

	-- "Open the first chunk, it should be the mesh header"
	cload:OpenChunk()

	if cload:CurChunkId() ~= w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_MESH_HEADER3 then
		section.Warn( "Old format mesh mesh, no longer supported." )
		return wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED
	end

	local context = meshLoadContextClass.New()

	-- Load the header
	local header = cload:ReadStruct( "W3dMeshHeader3Struct" )
	if header == nil then
		section.Warn( INSTANCE.Class, " - LoadW3d failed to read a header." )
		return wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED
	end
	cload:CloseChunk()

	-- "Process the header"
	context.Header = header

	self:Reset( header.NumTris, header.NumVertices, 1 )

	-- Model name
	local tempName
	if header.ContainerName ~= nil then
		tempName = header.ContainerName .. "." .. header.MeshName
	else
		tempName = header.MeshName
	end
	self:SetName( tempName )


	context.AlternateMaterialDescription:SetVertexCount( self.VertexCount )
	context.AlternateMaterialDescription:SetPolygonCount( self.PolygonCount )

	-- "Set Bounding Info"
	self.BoundBoxMax = Vector( header.Max.X, header.Max.Y, header.Max.Z )
	self.BoundBoxMin = Vector( header.Min.X, header.Min.Y, header.Min.Z )

	self.BoundSphereCenter = Vector( header.SphCenter.X, header.SphCenter.Y, header.SphCenter.Z )
	self.BoundSphereRadius = header.SphRadius

	-- "Flags"
	-- section.Warn( INSTANCE.Class, ":LoadW3d - Skipping setting flags" )

	--"Configure the load sequence for prelighting."
	-- section.Warn( INSTANCE.Class, ":LoadW3d - Skipping prelighting" )

	self:ReadChunks( cload, context )

	-- "
	-- If this is a pre-3.0 mesh and it has vertex influences,
	-- fixup the bone indices to account for the new root node
	-- "
	-- section.Warn( INSTANCE.Class, ":LoadW3d - Skipping pre-3.0 mesh checks" )

	-- "If this mesh is collideable and no AABTree was in the file, generate one now"
	-- section.Warn( INSTANCE.Class, ":LoadW3d - Skipping generating culling tree" )

	--- "Transfer the materials into the MatInfo"
	self:InstallMaterials( context )

	-- Omitted deleting context

	-- "Post-propcess the model: optimize passes, activate fog etc."
	self:PostProcess()

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

function INSTANCE:CreateDecal()
	typecheck.NotImplementedError()
end

function INSTANCE:DeleteDecal()
	typecheck.NotImplementedError()
end

function INSTANCE:EnableAlternateMaterialDescription()
	typecheck.NotImplementedError()
end

function INSTANCE:IsAlternateMaterialDescriptionEnabled()
	typecheck.NotImplementedError()
end

function INSTANCE:NeedsVertexNormals()
	typecheck.NotImplementedError()
end

function INSTANCE:InitForNPatchRendering()
	typecheck.NotImplementedError()
end

function INSTANCE:GetGapFiller()
	typecheck.NotImplementedError()
end

function INSTANCE:SetHTree()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTextureArray()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMaterialArray()
	typecheck.NotImplementedError()
end

function INSTANCE:GetShaderArray()
	typecheck.NotImplementedError()
end

function INSTANCE:RegisterType()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDeformedVertices()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDeformedScreenspaceVertices()
	typecheck.NotImplementedError()
end

function INSTANCE:ComposeDeformedVertexBuffer()
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
function INSTANCE:ReadChunks( cload, context )
	local ids = w3dFileIds.W3D_CHUNK_TYPE
	local oldIds = obsoleteW3dFileIds.OBSOLETE_W3D_CHUNK_TYPES
	-- "  
	-- Read in the chunk header
	-- If there are no more chunks within the chunk mesh,
	-- we are done.
	-- "  
	while cload:OpenChunk() do
		-- "Process the chunk"
		local error = wW3dErrorTypeEnum.WW3D_ERROR_OK

		local chunkId = cload:CurChunkId()

		if chunkId == ids.W3D_CHUNK_VERTICES then
			-- "Call up to [MeshGeometryInstance]"
			error = self:ReadVertices( cload )

		elseif (
			   chunkId == oldIds.W3D_CHUNK_SURRENDER_NORMALS
			or chunkId == ids.W3D_CHUNK_VERTEX_NORMALS
		) then
			-- "Call up to [MeshGeometryInstance]"
			error = self:ReadVertexNormals( cload )

		elseif chunkId == oldIds.W3D_CHUNK_TEXCOORDS then
			error = self:ReadTexCoords( cload, context )

		elseif (
			   chunkId == oldIds.O_W3D_CHUNK_MATERIALS
			or chunkId == oldIds.O_W3D_CHUNK_MATERIALS2
		) then
			section.Error( "Obsolete material chunk encountered in mesh: ", context.Header.ContainerName, ".", context.Header.MeshName )

		elseif chunkId == oldIds.W3D_CHUNK_MATERIALS3 then
			section.Warn( "Obsolete material chunk encountered in mesh: ", context.Header.ContainerName, ".", context.Header.MeshName )
			error = self:ReadV3Materials( cload, context )

		elseif chunkId == oldIds.O_W3D_CHUNK_SURRENDER_TRIANGLES then
			section.Error( "Obsolete Triangle Chunk Encountered!" )

		elseif chunkId == ids.W3D_CHUNK_TRIANGLES then
			-- "Call up to [MeshGeometryInstance]"
			error = self:ReadTriangles( cload )

		elseif chunkId == oldIds.W3D_CHUNK_PER_TRI_MATERIALS then
			error = self:ReadPerTriMaterials( cload, context )

		elseif chunkId == ids.W3D_CHUNK_MESH_USER_TEXT then
			-- "Call up to [MeshGeometryInstance]"
			error = self:ReadUserText( cload )

		elseif chunkId == oldIds.W3D_CHUNK_VERTEX_COLORS then
			error = self:ReadVertexColors( cload, context )

		elseif chunkId == ids.W3D_CHUNK_VERTEX_INFLUENCES then
			-- "Call up to [MeshGeometryInstance]"
			error = self:ReadVertexInfluences( cload )

		elseif chunkId == ids.W3D_CHUNK_VERTEX_SHADE_INDICES then
			-- "Call up to [MeshGeometryInstance]"
			error = self:ReadVertexShadeIndices( cload )

		elseif chunkId == ids.W3D_CHUNK_MATERIAL_INFO then
			error = self:ReadMaterialInfo( cload, context )

		elseif chunkId == ids.W3D_CHUNK_SHADERS then
			error = self:ReadShaders( cload, context )

		elseif chunkId == ids.W3D_CHUNK_VERTEX_MATERIALS then
			error = self:ReadVertexMaterials( cload, context )

		elseif chunkId == ids.W3D_CHUNK_TEXTURES then
			error = self:ReadTextures( cload, context )

		elseif chunkId == ids.W3D_CHUNK_MATERIAL_PASS then
			error = self:ReadMaterialPass( cload, context )

		elseif chunkId == ids.W3D_CHUNK_DEFORM then
			section.Error( "Obsolete deform chunk encountered in mesh: ", context.Header.ContainerName, ".", context.Header.MeshName )

		elseif chunkId == oldIds.W3D_CHUNK_DAMAGE then
			section.Error( "Obsolete damage chunk encountered in mesh: ", context.Header.ContainerName, ".", context.Header.MeshName )

		elseif (
			   chunkId == ids.W3D_CHUNK_PRELIT_UNLIT
			or chunkId == ids.W3D_CHUNK_PRELIT_VERTEX
			or chunkId == ids.W3D_CHUNK_PRELIT_LIGHTMAP_MULTI_PASS
			or chunkId == ids.W3D_CHUNK_PRELIT_LIGHTMAP_MULTI_TEXTURE
		) then
			self:ReadPrelitMaterial( cload, context )

		elseif chunkId == ids.W3D_CHUNK_AABTREE then
			-- section.Warn( INSTANCE.Class, ":ReadChunks - Skipping Reading AAB Tree" )
			-- Omitted reading AAB tree
			-- self:ReadAABTree( cload )
		end

		cload:CloseChunk()

		if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
			return error
		end
	end

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read in the texture coordinates chunk"
--- @param cload ChunkLoadInstance
--- @param context table
--- @return WW3dErrorType
function INSTANCE:ReadTexCoords( cload, context )
	local structSize = deserializeLib.GetComplexDataTypeSize( "W3dTexCoordStruct" )
	local elementCount = cload:CurChunkLength() / structSize

	local uvArray = {}

	-- "  
	-- Read the uv's into the first u-v pass array
	-- NOTE: this is an obsolete function.  Texture coordinates are now
	-- loaded in the pass chunks
	-- "  
	for i = 0, self.VertexCount do

		local readByteCount, readBytes = cload:Read( structSize )
		if readByteCount ~= structSize then
			return wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED
		end
		--- @cast readBytes string
		local texCoord = deserializeLib.DeserializeComplexDataType( "W3dTexCoordStruct", readBytes ) --[[@as W3dTexCoordStruct]]

		uvArray[i] = Vector( texCoord.U, 1.0 - texCoord.V )
	end

	self.DefinitionMaterialDescription:InstallUvArray( context.CurrentPass, context.CurrentTextureStage, uvArray, elementCount )

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

function INSTANCE:ReadMaterials()
	typecheck.NotImplementedError()
end

function INSTANCE:ReadV2Materials()
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadV3Materials( cload, context )
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadPerTriMaterials( cload, context )
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadVertexColors( cload, context )
	typecheck.NotImplementedError()
end

--- "Read the material info chunk"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadMaterialInfo( cload, context )
	local materialInfo = cload:ReadStruct( "W3dMaterialInfoStruct" )
	if materialInfo == nil then
		return wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED
	end
	context.MaterialInfo = materialInfo
	self:SetPassCount( context.MaterialInfo.PassCount )
	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadShaders( cload, context )
	for i = 1, context.MaterialInfo.ShaderCount do
		local shader = cload:ReadStruct( "W3dShaderStruct" )
		if shader == nil then
			return wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED
		end
		local newShader = w3dUtilityClass.ConvertShader( shader )

		local index = context:AddShader( newShader )
		assert( index == i )
	end
	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadVertexMaterials( cload, context )
	while cload:OpenChunk() do
		assert( cload:CurChunkId() == w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_VERTEX_MATERIAL )
		local vertexMaterial = vertexMaterialClass.New()
		local error = vertexMaterial:LoadW3d( cload )
		if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
			return error
		end
		context:AddVertexMaterial( vertexMaterial )

		cload:CloseChunk()
	end
	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadTextures( cload, context )
	-- "Keep reading textures until there are no more..."
	local newTexture = textureClass.LoadTexture( cload )
	while newTexture ~= nil do
		context:AddTexture( newTexture )
		newTexture = textureClass.LoadTexture( cload )
	end

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadMaterialPass( cload, context )
	context.CurrentTextureStage = 0

	local ids = w3dFileIds.W3D_CHUNK_TYPE

	while cload:OpenChunk() do
		local error = wW3dErrorTypeEnum.WW3D_ERROR_OK
		local chunkId = cload:CurChunkId()

		if chunkId == ids.W3D_CHUNK_VERTEX_MATERIAL_IDS then
			error = self:ReadVertexMaterialIds( cload, context )

		elseif chunkId == ids.W3D_CHUNK_SHADER_IDS then
			error = self:ReadShaderIds( cload, context )

		elseif chunkId == ids.W3D_CHUNK_DCG then
			error = self:ReadDcg( cload, context )

		elseif chunkId == ids.W3D_CHUNK_DIG then
			error = self:ReadDig( cload, context )

		elseif chunkId == ids.W3D_CHUNK_SCG then
			error = self:ReadScg( cload, context )

		elseif chunkId == ids.W3D_CHUNK_TEXTURE_STAGE then
			error = self:ReadTextureStage( cload, context )
		end

		if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
			return error
		end
		cload:CloseChunk()
	end

	context.CurrentPass = context.CurrentPass + 1

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read the vmat ids for a pass"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadVertexMaterialIds( cload, context )
	-- "Determine whether this chunk should be read into the default or alternate material description"
	local materialDescription = self.DefinitionMaterialDescription
	if self.DefinitionMaterialDescription:HasMaterialData( context.CurrentPass ) then
		materialDescription = context.AlternateMaterialDescription
	end

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read the shader indexes for a pass"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadShaderIds( cload, context )
	-- "Determine whether this chunk should be read into the default or alternate material description"
	local materialDescription = self.DefinitionMaterialDescription
	if self.DefinitionMaterialDescription:HasShaderData( context.CurrentPass ) then
		materialDescription = context.AlternateMaterialDescription
	end

	-- "Read in the shader id's and plug in the appropriate shader"
	local expectedByteSize = deserializeLib.GetDataTypeSize( fundamentalDataTypeEnum.UInt32 )
	local shaderId
	if cload:CurChunkLength() == 1 * expectedByteSize then
		local _, readBytes = cload:Read( expectedByteSize ) --[[@as integer]]
		shaderId = deserializeLib.DeserializeUInt32( readBytes --[[@as string]] )

		-- Correct for Lua being 1 indexed
		shaderId = shaderId + 1

		local shader = context:PeekShader( shaderId )
		materialDescription:SetSingleShader( shader, context.CurrentPass )

		-- "Turn on sorting of pass [1] has non-zero dest blend (unless alpha testing on)"
		if (    context.CurrentPass == 1
			and shader:GetDstBlendFunc() ~= dstBlendFuncEnum.Zero
			and shader:GetAlphaTest() == alphaTestEnum.Disable
			and self.SortLevel == w3dFileIds.SORT_LEVEL_NONE
		) then
			self:SetFlag( meshGeometryFlagsTypeEnum.SORT, true )
		end
	else
		for i = 1, self:GetPolygonCount() do
			local _, readBytes = cload:Read( expectedByteSize ) --[[@as integer]]
			shaderId = deserializeLib.DeserializeUInt32( readBytes --[[@as string]] )

			-- Correct for Lua being 1 indexed
			shaderId = shaderId + 1

			local shader = context:PeekShader( shaderId )
			materialDescription:SetShader( i, shader, context.CurrentPass )

			-- "Turn on sorting of pass [1] has non-zero dest blend (unless alpha testing on)"
			if (    context.CurrentPass == 1
				and shader:GetDstBlendFunc() ~= dstBlendFuncEnum.Zero
				and shader:GetAlphaTest() == alphaTestEnum.Disable
				and self.SortLevel == w3dFileIds.SORT_LEVEL_NONE
			) then
				self:SetFlag( meshGeometryFlagsTypeEnum.SORT, true )
			end
		end
	end
	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read the specular color for a pass"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadScg( cload, context )
	typecheck.NotImplementedError()

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read the per-vertex diffuse illumination for a pass"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadDig( cload, context )
	typecheck.NotImplementedError()

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read the per-vertex diffuse color for a pass"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadDcg( cload, context )
	-- "Determine whether the chunk should be read into the default or alternate material description"
	local materialDescription = self.DefinitionMaterialDescription
	if self.DefinitionMaterialDescription:GetDcgSource( context.CurrentPass ) ~= colorSourceTypeEnum.MATERIAL then
		materialDescription = context.AlternateMaterialDescription
	end

	--[[
	"
	The W3D file format supports arbitrary vertex color arrays for each pass; however since
	our conversion to hardware T&L, we only support two unique color arrays.  So here is 
	what is happening in this function:
	1 - If this is the first diffuse color array we've encountered, load the values.
	2 - Otherwise, if we are in PRELIT_VERTEX mode, put the alpha from this array into the color array.
	3 - Always set the DCG source for this pass to the array.
	Our tools *currently* will only generate two color arrays in the case where one of them
	is being used for alpha and the other is used for precomputed vertex lighting...  This will
	break if our tools change.  The file format isn't restricting you from defining something
	we can't render right now...
	"
	--]]
	if materialDescription:HasColorArray( 1 ) == false then
		
		local dcg = materialDescription:GetColorArray( 1 )

	elseif  context.PrelitChunkID == w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_PRELIT_VERTEX then

	end

	materialDescription:SetDcgSource( context.CurrentPass, colorSourceTypeEnum.COLOR1 )

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read texture stage chunks"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadTextureStage( cload, context )
	local ids = w3dFileIds.W3D_CHUNK_TYPE
	local oldIds = obsoleteW3dFileIds.OBSOLETE_W3D_CHUNK_TYPES

	while cload:OpenChunk() do
		local error = wW3dErrorTypeEnum.WW3D_ERROR_OK
		local chunkId = cload:CurChunkId()

		if chunkId == ids.W3D_CHUNK_TEXTURE_IDS then
			error = self:ReadTextureIds( cload, context )

		elseif (
			   chunkId == ids.W3D_CHUNK_STAGE_TEXCOORDS
			or chunkId == oldIds.W3D_CHUNK_TEXCOORDS
		) then
			error = self:ReadStageTextureCoordinates( cload, context )

		elseif chunkId == ids.W3D_CHUNK_PER_FACE_TEXCOORD_IDS then
			error = self:ReadPerFaceTextureCoordinateIds( cload, context )
		end

		if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
			return error
		end
		cload:CloseChunk()
	end

	context.CurrentTextureStage = context.CurrentTextureStage + 1
	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read the texture ids for a pass,stage"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadTextureIds( cload, context )
	local textureId
	local pass = context.CurrentPass
	local stage = context.CurrentTextureStage

	-- "Determine whether this chunk should be read into the default or alternate material description"
	local materialDscription = self.DefinitionMaterialDescription
	if self.DefinitionMaterialDescription:HasTextureData( pass, stage ) then
		materialDscription = context.AlternateMaterialDescription
	end

	-- "Read in the texture(s) array"
	if cload:CurChunkLength() == 1 * deserializeLib.GetFundamentalDataTypeSize( fundamentalDataTypeEnum.UInt32 ) then
		textureId = cload:Read( fundamentalDataTypeEnum.UInt32 )
		materialDscription:SetSingleTexture( context:PeekTexture( textureId ), pass, stage )
	else
		for i = 1, self:GetPolygonCount() do
			local textureId = cload:Read( fundamentalDataTypeEnum.UInt32 )
			if textureId ~= 0xffffffff then
				materialDscription:SetTexture( i, context:PeekTexture( textureId ), pass, stage )
			end
		end
	end

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read the texcoords for a pass,stage"
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadStageTextureCoordinates(cload, context)
	-- "Determine whether this chunk should be read into the default or alternate material description"
	local materialDescription = self.DefinitionMaterialDescription
	if self.DefinitionMaterialDescription:HasUv( context.CurrentPass, context.CurrentTextureStage ) then
		materialDescription = context.AlternateMaterialDescription
	end

	-- "Read in the texture coordinates"
	local elementCount = cload:CurChunkLength() / deserializeLib.GetComplexDataTypeSize( "W3dTexCoordStruct" )
	local uvs = context:GetTemporaryUvArray( elementCount )

	if uvs ~= nil then
		local textureCoordinates
		for i = 1, elementCount do
			textureCoordinates = cload:ReadStruct( "W3dTexCoordStruct" )
			if textureCoordinates == nil then
				section.Error( self.Class, " - Failed to read stage texture coordinates UV ", i )
				return wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED
			end
			uvs[i] = Vector(
				textureCoordinates.U,
				1.0 - textureCoordinates.V
			)
		end
	end

	materialDescription:InstallUvArray( context.CurrentPass, context.CurrentTextureStage, uvs, elementCount )

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read uv indices for given (pass,stage)."
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadPerFaceTextureCoordinateIds(cload, context)
	typecheck.NotImplementedError()

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Read prelit material chunks."
--- @param cload ChunkLoadInstance
--- @param context MeshLoadContextInstance
--- @return WW3dErrorType
function INSTANCE:ReadPrelitMaterial( cload, context )
	-- "If this chunk ID matches the selected prelit chunk ID then load it, otherwise skip it."
	if cload:CurChunkId() == context.PrelitChunkID then

		local ids = w3dFileIds.W3D_CHUNK_TYPE

		-- "While there are chunks in the prelit material chunk wrapper..."
		while cload:OpenChunk() do
			local error = wW3dErrorTypeEnum.WW3D_ERROR_OK
			local chunkId = cload:CurChunkId()

			if chunkId == ids.W3D_CHUNK_MATERIAL_INFO then
				error = self:ReadMaterialInfo( cload, context )

			elseif chunkId == ids.W3D_CHUNK_VERTEX_MATERIALS then
				error = self:ReadVertexMaterials( cload, context )

			elseif chunkId == ids.W3D_CHUNK_SHADERS then
				error = self:ReadShaders( cload, context )

			elseif chunkId == ids.W3D_CHUNK_TEXTURES then
				error = self:ReadTextures( cload, context )

			elseif chunkId == ids.W3D_CHUNK_MATERIAL_PASS then
				error = self:ReadMaterialPass( cload, context )
			end
			cload:CloseChunk()

			if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
				return error
			end
		end
	end

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

--- "Post loading, perform and processing on this model."
function INSTANCE:PostProcess()
	-- "Turn off backface culling if the mesh is supposed to be two-sided"
	if self:GetFlag( meshGeometryFlagsTypeEnum.TWO_SIDED ) then
		self.DefinitionMaterialDescription:DisableBackfaceCulling()
		if self.AlternateMaterialDescription ~= nil then
			self.AlternateMaterialDescription:DisableBackfaceCulling()
		end
	end

	-- "Fog activation"
	if ww3dAssetManagerClass.GetInstance():GetActivateFogOnLoad() then
		self:PostProcessFog()
	end

	-- "If the mesh is sorting, pick an appropriate static sort level if default isn't set"
	if self:GetFlag( meshGeometryFlagsTypeEnum.SORT ) and self.SortLevel == w3dFileIds.SORT_LEVEL_NONE and wW3dClass.IsMungeSortOnLoadEnabled() then
		self:ComputeStaticSortLevels()
	end
end

function INSTANCE:PostProcessFog()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSortFlags()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputeStaticSortLevels()
	typecheck.NotImplementedError()
end

--- @param context MeshLoadContextInstance
function INSTANCE:InstallMaterials( context )
	-- "If alternate material chunks were loaded, initialize the [AlternateMaterialDescription]"
	self:InstallAlternateMaterialDesc( context )

	-- "Finish configuring the vertex materials and color arrays."
	local lightingEnabled = true

	-- "Vertex-lit models need the lighting turned off!"
	if self:GetFlag( meshGeometryFlagsTypeEnum.PRELIT_VERTEX ) then
		lightingEnabled = false
	end
	self.DefinitionMaterialDescription:PostLoadProcess( lightingEnabled, self )
	if self.AlternateMaterialDescription ~= nil then
		self.AlternateMaterialDescription:PostLoadProcess( lightingEnabled, self )
	end

	-- "Transfer the refs to our textures into the [MaterialInfo]"
	for i = 1, context:TextureCount() do
		self.MaterialInfo:AddTexture( context:PeekTexture( i ) )
	end

	-- "Transfer the refs to our vertex materials into the [MaterialInfo]"
	for i = 1, context:VertexMaterialCount() do
		self.MaterialInfo:AddVertexMaterial( context:PeekVertexMaterial( i ) )
	end
end

function INSTANCE:CloneMaterials()
	typecheck.NotImplementedError()
end

--- @param context MeshLoadContextInstance
function INSTANCE:InstallAlternateMaterialDesc( context )
	if context.AlternateMaterialDescription:IsEmpty() == false then
		self.AlternateMaterialDescription = meshMaterialDescriptionClass.New()
		self.AlternateMaterialDescription:InitAlternate( self.DefinitionMaterialDescription, context.AlternateMaterialDescription )
	end
end
