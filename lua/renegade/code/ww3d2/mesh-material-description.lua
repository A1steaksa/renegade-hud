-- Based on MeshMaterialDescriptionClass within Code/ww3d2/meshmatdesc.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class MeshMaterialDescriptionClass
--- @field Instance MeshMaterialDescriptionInstance The metatable used by MeshMaterialDescriptionInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "MeshMaterialDescriptionClass"

--- @class MeshMaterialDescriptionInstance
--- @field Static MeshMaterialDescriptionClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_MeshMaterialDescription" )
INSTANCE.Class = "MeshMaterialDescriptionInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMeshMatDesc = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type VertexMaterialClass
	local vertexMaterialClass = CNC.Import( "code/ww3d2/vertex-material.lua" )

	--- @type MeshMaterialDescriptionClass
	local meshMaterialDescriptionClass = CNC.Import( "code/ww3d2/mesh-material-description.lua" )

	--- @type ShaderClass
	local shaderClass = CNC.Import( "code/ww3d2/shader.lua" )
--#endregion

--#region Imported Enums

	local colorSourceTypeEnum = vertexMaterialClass.COLOR_SOURCE_TYPE
	local cullModeEnum = shaderClass.CULL_MODE
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class MeshMaterialDescriptionClass
	--- @field NullShader any

	STATIC.MAX_PASSES = 4
	STATIC.MAX_TEX_STAGES = 2
	STATIC.MAX_COLOR_ARRAYS = 2
	STATIC.MAX_UV_ARRAYS = STATIC.MAX_PASSES * STATIC.MAX_TEX_STAGES

    --- Creates a new MeshMaterialDescriptionInstance
    --- @return MeshMaterialDescriptionInstance
    function STATIC.New()
        return robustclass.New( "Renegade_MeshMaterialDescription" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) MeshMaterialDescriptionInstance, `false` otherwise
    function STATIC.IsMeshMaterialDescription( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMeshMaterialDescription and true or false
    end

    typecheck.RegisterType( "MeshMaterialDescriptionInstance", STATIC.IsMeshMaterialDescription )
end


--- @class MeshMaterialDescriptionInstance
--- @field PassCount integer
--- @field VertexCount integer
--- @field PolygonCount integer
--- @field Uv Vector[][]
--- @field UvSource integer[][]
--- @field ColorArray any
--- @field DcgSource ColorSourceType[]
--- @field DigSource ColorSourceType[]
--- @field Texture TextureInstance[][]
--- @field Shader ShaderInstance[]
--- @field Material VertexMaterialInstance[]
--- @field TextureArray TextureInstance[][]
--- @field MaterialArray VertexMaterialInstance[]
--- @field ShaderArray ShaderInstance[][]

--- @param that MeshMaterialDescriptionInstance?
function INSTANCE:Renegade_MeshMaterialDescription( that )
	self.PassCount = 1
	self.VertexCount = 0
	self.PolygonCount = 0

	self.ColorArray = {}
	self.Uv = {}

	self.UvSource = {}
	self.Texture = {}
	self.TextureArray = {}

	self.Shader = {}
	self.Material = {}
	self.ShaderArray = {}
	self.MaterialArray = {}

	self.DcgSource = {}
	self.DigSource = {}

	-- ()
	if that == nil then
		for pass = 0, STATIC.MAX_PASSES do
			self.UvSource[pass] = {}
			self.Texture[pass] = {}
			self.TextureArray[pass] = {}

			for stage = 0, STATIC.MAX_TEX_STAGES do
				self.UvSource[pass][stage] = -1
				self.Texture[pass][stage] = nil
				self.TextureArray[pass][stage] = nil
			end

			-- Omitted setting color sources
			-- self.DcgSource[pass] = colorSourceTypeEnum.MATERIAL
			-- self.DigSource[pass] = colorSourceTypeEnum.MATERIAL

			self.Shader[pass] = nil
			self.Material[pass] = nil
			self.ShaderArray[pass] = nil
			self.MaterialArray[pass] = nil
		end

	-- ( that: MeshMaterialDescriptionInstance )
	else
		typecheck.AssertArgType( self.Class, 1, that, "MeshMaterialDescriptionInstance" )

		typecheck.NotImplementedError()
	end
end

function INSTANCE:_Renegade_MeshMaterialDescription()
	typecheck.NotImplementedError()
end

--- @param polyCount integer
--- @param vertCount integer
--- @param passCount integer
function INSTANCE:Reset( polyCount, vertCount, passCount )
	self.PolygonCount = polyCount
	self.VertexCount = vertCount
	self.PassCount = passCount

	self.ColorArray = {}
	self.Uv = {}

	for pass = 0, STATIC.MAX_PASSES do
		self.UvSource[pass] = {}
		self.Texture[pass] = {}
		self.TextureArray[pass] = {}

		for stage = 0, STATIC.MAX_TEX_STAGES do
			self.UvSource[pass][stage] = -1
			self.Texture[pass][stage] = nil
			self.TextureArray[pass][stage] = nil
		end
	end
end

--- @param defaultMaterials MeshMaterialDescriptionInstance
--- @param alternateMaterials MeshMaterialDescriptionInstance
function INSTANCE:InitAlternate( defaultMaterials, alternateMaterials )
	--- "Just copy the counts"
	self.PassCount = defaultMaterials.PassCount
	self.VertexCount = defaultMaterials.VertexCount
	self.PolygonCount = defaultMaterials.PolygonCount

	-- "Color arrays"
	for array = 1, STATIC.MAX_COLOR_ARRAYS do
		if alternateMaterials.ColorArray[array] ~= nil then
			self.ColorArray[array] = alternateMaterials.ColorArray[array]
		else
			self.ColorArray[array] = defaultMaterials.ColorArray[array]
		end
	end

	-- "  
	-- Copy the uv-arrays from the alternate materials to start.  Needed uv arrays from
	-- the default material set will be brought over as encountered below
	-- "  
	for i = 1, alternateMaterials:GetUvArrayCount() do
		self.Uv[i] = alternateMaterials.Uv[i]
	end

	-- "Add-ref the arrays in [defaultMaterials] except when the same array is present in [alternateMaterials]"
	for pass = 1, STATIC.MAX_PASSES do
		for stage = 1, STATIC.MAX_TEX_STAGES do
			-- "  
			-- UV [Coordinate] arrays, Each UVSource[pass][stage] which is -1 in the [alternateMaterials]
			-- but not -1 in the [defaultMaterials] causes us to copy over a uv array from the [defaultMaterials]
			-- and set its index into our UVSource array  
			-- "  
			if alternateMaterials.UvSource[pass][stage] == -1 then
				if defaultMaterials.UvSource[pass][stage] ~= -1 then

					-- "Look uyp the uv array in [defaultMaterials] that we need to bring over."
					local defaultUvSource = defaultMaterials.UvSource[pass][stage]
					local uvArray = defaultMaterials.Uv[defaultUvSource]
					local foundIndex = -1

					-- "Check if we already have it"
					for i = 1, self:GetUvArrayCount() do
						if uvArray == self.Uv[i] then
							foundIndex = i
							break
						end
					end

					-- "  
					-- If we already have it, just set the source index.  Otherwise add-ref it
					-- into a new slot in our uv array and set that index.
					-- "
					if foundIndex ~= -1 then
						self.UvSource[pass][stage] = foundIndex
					else
						local newIndex = self:GetUvArrayCount() + 1
						self.Uv[newIndex] = defaultMaterials.Uv[defaultUvSource]
						self.UvSource[pass][stage] = newIndex
					end
				end
			else
				self.UvSource[pass][stage] = alternateMaterials.UvSource[pass][stage]
			end

			-- "  
			-- Texture pointer(s):  If [alternateMaterials] has either a single texture or an array of textures,
			-- then add-ref only the texture data it contains.  Otherwise, add-ref the data in [defaultMaterials].
			-- "  
			if ( alternateMaterials.Texture[pass][stage] ~= nil ) or (alternateMaterials.TextureArray[pass][stage]) then
				self.Texture[pass][stage] = alternateMaterials.Texture[pass][stage]
				self.TextureArray[pass][stage] = alternateMaterials.TextureArray[pass][stage]
			else
				self.Texture[pass][stage] = defaultMaterials.Texture[pass][stage]
				self.TextureArray[pass][stage] = defaultMaterials.TextureArray[pass][stage]
			end
		end

		-- "Vertex color configuration"
		if alternateMaterials.DcgSource[pass] == colorSourceTypeEnum.MATERIAL then
			self.DcgSource[pass] = defaultMaterials.DcgSource[pass]
		else
			self.DcgSource[pass] = alternateMaterials.DcgSource[pass]
		end

		-- "Shaders, currently I can't tell if the alternate data has a shader... Can't override the shader for now."
		self.Shader[pass] = defaultMaterials.Shader[pass]
		self.ShaderArray[pass] = defaultMaterials.ShaderArray[pass]

		-- "Vertex Materials.  If [alternateMaterials] has either a single or array of materials, then copy them"
        if ( alternateMaterials.Material[pass] ~= nil ) or ( alternateMaterials.MaterialArray[pass] ~= nil ) then
            self.Material[pass] = alternateMaterials.Material[pass]
            self.MaterialArray[pass] = alternateMaterials.MaterialArray[pass]
        else
            -- "Don't share vertex materials! (because the UVSources can be different!)"
            if defaultMaterials.Material[pass] then
                self.Material[pass] = vertexMaterialClass.New( defaultMaterials.Material[pass] )
            else
                if defaultMaterials.MaterialArray[pass] then
                    section.Error( "Unimplemented case: mesh has more than one default vertex material but no alternate vertex materials have been defined." )
                end
                self.Material[pass] = nil
            end
        end

	end
end

--- @return boolean
function INSTANCE:IsEmpty()
	for array = 1, STATIC.MAX_COLOR_ARRAYS do
		if self.ColorArray[array] ~= nil then return false end
	end

	for uvArray = 1, STATIC.MAX_UV_ARRAYS do
		if self.Uv[uvArray] ~= nil then return false end
	end

	for pass = 1, STATIC.MAX_PASSES do
		for stage = 1, STATIC.MAX_TEX_STAGES do
			if self.Texture[pass][stage] ~= nil then return false end
			if self.TextureArray[pass][stage] ~= nil then return false end
		end

		if self.Material[pass] ~= nil then return false end
		if self.MaterialArray[pass] ~= nil then return false end
	end

	return true
end

--[[ Counts ]] do

	--- @param passCount integer
	function INSTANCE:SetPassCount( passCount )
		self.PassCount = passCount
	end

	--- @return integer
	function INSTANCE:GetPassCount()
		return self.PassCount
	end

	--- @param vertexCount integer
	function INSTANCE:SetVertexCount( vertexCount )
		self.VertexCount = vertexCount
	end

	--- @return integer
	function INSTANCE:GetVertexCount()
		return self.VertexCount
	end

	--- @param polygonCount integer
	function INSTANCE:SetPolygonCount( polygonCount )
		self.PolygonCount = polygonCount
	end

	--- @return integer
	function INSTANCE:GetPolygonCount()
		return self.PolygonCount
	end
end


function INSTANCE:GetUvArray()
	typecheck.NotImplementedError()
end

--- @param pass integer
--- @param stage integer
--- @param uvs Vector[]?
--- @param count integer
function INSTANCE:InstallUvArray( pass, stage, uvs, count )

	-- Omitting checking CRCs

	local newIndex = #self.Uv+1

	self.Uv[newIndex] = uvs
	self:SetUvSource( pass, stage, newIndex )
end

--- @param pass integer
--- @param stage integer
--- @param sourceIndex integer
function INSTANCE:SetUvSource( pass, stage, sourceIndex )
	self.UvSource[pass][stage] = sourceIndex
end

--- @param pass integer
--- @param stage integer
--- @return integer
function INSTANCE:GetUvSource( pass, stage )
	typecheck.NotImplementedError()
end

--- @return integer
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

function INSTANCE:SetDcgSource( pass, source )
	self.DcgSource[pass] = source
end

--- @param pass integer
--- @param source ColorSourceType
function INSTANCE:SetDigSource( pass, source )
	self.DigSource[pass] = source
end

--- @param pass integer
--- @return ColorSourceType
function INSTANCE:GetDcgSource( pass )
	return self.DcgSource[pass]
end

--- @param pass integer
--- @return ColorSourceType
function INSTANCE:GetDigSource( pass )
	return self.DigSource[pass]
end

--- @param index integer
--- @param create boolean
--- @return integer[]?
function INSTANCE:GetColorArray( index, create )
	if create and not self.ColorArray[index] then
		self.ColorArray[index] = {}
	end

	if self.ColorArray[index] then
		return self.ColorArray[index]
	end

	return nil
end

--- @param vertexMaterial VertexMaterialInstance
--- @param pass integer
function INSTANCE:SetSingleMaterial( vertexMaterial, pass )
	self.Material[pass] = vertexMaterial
end

--- @param texture TextureInstance
--- @param pass integer
--- @param stage integer
function INSTANCE:SetSingleTexture( texture, pass, stage )
	self.Texture[pass][stage] = texture
end

--- @param shader ShaderInstance
--- @param pass integer
function INSTANCE:SetSingleShader( shader, pass )
	self.Shader[pass] = shader
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

--- @param vertexMaterialIndex integer
--- @param vertexMaterial VertexMaterialInstance
--- @param pass integer
function INSTANCE:SetMaterial( vertexMaterialIndex, vertexMaterial, pass )
	local materials = self:GetMaterialArray( pass, true )
	materials[vertexMaterialIndex] = vertexMaterial
end

--- @param shaderIndex integer
--- @param shader ShaderInstance
--- @param pass integer
function INSTANCE:SetShader( shaderIndex, shader, pass )
	local shaders = self:GetShaderArray( pass, true )
	shaders[shaderIndex] = shader
end

--- @param pidx integer
--- @param texture TextureInstance
--- @param pass integer
--- @param stage integer
function INSTANCE:SetTexture( pidx, texture, pass, stage )
	local textures = self:GetTextureArray( pass, stage, true )
	textures[pidx] = texture
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

--- @param pass integer
--- @param stage integer
--- @return boolean
function INSTANCE:HasUv( pass, stage )
	return self.UvSource[pass][stage] ~= -1
end

--- @param array integer
--- @return boolean
function INSTANCE:HasColorArray( array )
	return self.ColorArray[array] ~= nil
end

--- @param pass integer
--- @param stage integer
--- @return boolean
function INSTANCE:HasTextureData( pass, stage )
	return ( self.Texture[pass][stage] ~= nil ) or ( self.TextureArray[pass][stage] ~= nil )
end

--- @param pass integer
--- @return boolean
function INSTANCE:HasShaderData( pass )
	return ( self.Shader[pass] ~= nil ) or ( self.MaterialArray[pass] ~= nil )
end

--- @param pass integer
--- @return boolean
function INSTANCE:HasMaterialData( pass )
	return ( self.Material[pass] ~= nil ) or ( self.MaterialArray[pass] ~= nil )
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

--- @param vertexMaterialIndex integer
--- @param pass integer
--- @return VertexMaterialInstance
function INSTANCE:PeekMaterial( vertexMaterialIndex, pass )
	if self.MaterialArray[pass] then
		return self.MaterialArray[pass][vertexMaterialIndex]
	end
	return self.Material[pass]
end

--- @param peekIndex integer
--- @param pass integer
--- @param stage integer
--- @return TextureInstance
function INSTANCE:PeekTexture( peekIndex, pass, stage )
	if self.TextureArray[pass][stage] then
		return self.TextureArray[pass][stage][ peekIndex ]
	end
	return self.Texture[pass][stage]
end

--- @param pass integer
--- @param stage integer
--- @param create boolean
--- @return TextureInstance[]
function INSTANCE:GetTextureArray( pass, stage, create )
	if create and self.TextureArray[pass][stage] == nil then
		self.TextureArray[pass][stage] = {}
	end
	return self.TextureArray[pass][stage]
end

--- @param pass integer
--- @param create boolean
--- @return VertexMaterialInstance[]
function INSTANCE:GetMaterialArray( pass, create )
	if create and self.MaterialArray[pass] == nil then
		self.MaterialArray[pass] = {}
	end
	return self.TextureArray[pass]
end

--- @param pass integer
--- @param create boolean
--- @return ShaderInstance[]?
function INSTANCE:GetShaderArray( pass, create )
	if create and self.ShaderArray[pass] == nil then
		self.ShaderArray[pass] = {}
	end
	if self.ShaderArray[pass] then
		return self.ShaderArray[pass]
	end
	return nil
end

function INSTANCE:MakeUvArrayUnique()
	typecheck.NotImplementedError()
end

function INSTANCE:MakeColorArrayUnique()
	typecheck.NotImplementedError()
end

--- @param lightingEnabled boolean
--- @param parent MeshModelInstance
function INSTANCE:PostLoadProcess( lightingEnabled, parent )
	-- "  
	-- Configure all vertex materials to source the uv coordinates and colors from the correct arrays
	-- Pre-multiply the vertex color arrays.
	-- "  
	local setLightingToFalse = true
	for pass = 1, self.PassCount do

		-- "If this pass doesn't have a vertex material, create one"
		if ( self.Material[pass] == nil ) and ( self.MaterialArray[pass] == nil ) then
			self.Material[pass] = vertexMaterialClass.New()
		end

		-- "Configure the materials to source the uv coordinates and colors"
		if self.Material[pass] ~= nil then
			self:ConfigureMaterial( self.Material[pass], pass, lightingEnabled )
		else
			local previousMaterial = nil
			local material = self:PeekMaterial( pass, 1 )

			for vertexIndex = 1, self.VertexCount do
				material = self:PeekMaterial( vertexIndex, pass )
				if ( material ~= previousMaterial ) and ( material ~= nil ) then
					self:ConfigureMaterial( material, pass, lightingEnabled )
					previousMaterial = material
				end
			end
		end

		-- "Analyze material array types and apply hacks for supporting SR-lighting pipeline if possible."

		-- "If no color arrays, we don't have a problem"
		if not self.ColorArray[1] and not self.ColorArray[2] then continue end

		typecheck.NotImplementedError()
	end
end

function INSTANCE:DisableLighting()
	typecheck.NotImplementedError()
end

function INSTANCE:DoMappersNeedNormals()
	typecheck.NotImplementedError()
end

--- @param material VertexMaterialInstance
--- @param pass integer
--- @param lightingEnabled boolean
function INSTANCE:ConfigureMaterial( material, pass, lightingEnabled )
	material:SetDiffuseColorSource( self.DcgSource[pass] )
	material:SetEmissiveColorSource( self.DigSource[pass] )

	material:SetLighting( lightingEnabled )

	for stage = 1, meshMaterialDescriptionClass.MAX_TEX_STAGES do
		local source = self.UvSource[pass][stage]
		if source == -1 then
			source = 0
		end
		material:SetUvSource( stage, source )
	end
end

function INSTANCE:DisableBackfaceCulling()
	for pass = 1, self.PassCount do
		self.Shader[pass]:SetCullMode( cullModeEnum.Disable )
		if self.ShaderArray[pass] then
			for triangle = 1, #self.ShaderArray[pass] do
				self.ShaderArray[pass][triangle]:SetCullMode( cullModeEnum.Disable )
			end
		end
	end
end

function INSTANCE:DeletePass()
	typecheck.NotImplementedError()
end
