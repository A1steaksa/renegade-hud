-- Based on TextureClass within Code/ww3d2/texture.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class TextureClass
--- @field Instance TextureInstance The metatable used by TextureInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "TextureClass"

--- @class TextureInstance
--- @field Static TextureClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Texture" )
INSTANCE.Class = "TextureInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsTexture = true

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	local enumBuilder = enumBuilderClass.New()

	--- @enum PoolType
	STATIC.POOL_TYPE = {
		POOL_DEFAULT   = enumBuilder:Set( 0 ),
        POOL_MANAGED   = enumBuilder:Next(),
        POOL_SYSTEMMEM = enumBuilder:Next(),
	}
	local poolTypeEnum = STATIC.POOL_TYPE

	--- @enum FilterType
	STATIC.FILTER_TYPE = {
		FILTER_TYPE_NONE = enumBuilder:Set( 0 ),
        FILTER_TYPE_FAST    = enumBuilder:Next(),
        FILTER_TYPE_BEST    = enumBuilder:Next(),
        FILTER_TYPE_DEFAULT = enumBuilder:Next(),
        FILTER_TYPE_COUNT   = enumBuilder:Next(),
	}
	local filterTypeEnum = STATIC.FILTER_TYPE

	--- @enum TextureFilterMode
	STATIC.TEXTURE_FILTER_MODE = {
		TEXTURE_FILTER_BILINEAR    = enumBuilder:Set( 0 ),
        TEXTURE_FILTER_TRILINEAR   = enumBuilder:Next(),
        TEXTURE_FILTER_ANISOTROPIC = enumBuilder:Next(),
	}
	local textureFilterModeEnum = STATIC.TEXTURE_FILTER_MODE

	--- @enum TextureAddressMode
	STATIC.TEXTURE_ADDRESS_MODE = {
		TEXTURE_ADDRESS_REPEAT = enumBuilder:Set( 0 ),
        TEXTURE_ADDRESS_CLAMP  = enumBuilder:Next()
	}
	local textureAddressModeEnum = STATIC.TEXTURE_ADDRESS_MODE

	--- @enum MipCountType
	STATIC.MIP_COUNT_TYPE = {
		MIP_LEVELS_ALL = enumBuilder:Set( 0 ), -- "Generate all mipmap levels down to 1x1 size"
		MIP_LEVELS_1   = enumBuilder:Next(),
		MIP_LEVELS_2   = enumBuilder:Next(),
		MIP_LEVELS_3   = enumBuilder:Next(),
		MIP_LEVELS_4   = enumBuilder:Next(),
		MIP_LEVELS_5   = enumBuilder:Next(),
		MIP_LEVELS_6   = enumBuilder:Next(),
		MIP_LEVELS_7   = enumBuilder:Next(),
		MIP_LEVELS_8   = enumBuilder:Next(),
		MIP_LEVELS_10  = enumBuilder:Next(),
		MIP_LEVELS_11  = enumBuilder:Next(),
		MIP_LEVELS_12  = enumBuilder:Next(),
	}
	local mipCountTypeEnum = STATIC.MIP_COUNT_TYPE
--#endregion

--#region Imports

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type WW3dFileFormatIds
	local wW3dFileFormatIds = CNC.Import( "code/ww3d2/ww3d-format.lua" )

	--- @type WW3dClass
	local wW3dClass = CNC.Import( "code/ww3d2/ww3d.lua" )

	--- @type TextUtils
	local textUtils = CNC.Import( "sh_text-utils.lua" )
--#endregion

--#region Imported Enums

	local wW3dFormatEnum = wW3dFileFormatIds.WW3D_FORMAT
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class TextureClass

	STATIC.UnusedTextureId = 0

    --- Creates a new TextureInstance
	--- @overload fun( width: integer, height: integer, format: WW3dFormat, mipLevelCount: MipCountType?, pool: PoolType?, renderTarget: boolean? )
	--- @overload fun( name: string, fullPath: string?, mipLevelCount: MipCountType?, textureFormat: WW3dFormat?, allowCompression: boolean? )
    --- @return TextureInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Texture", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) TextureInstance, `false` otherwise
    function STATIC.IsTexture( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsTexture and true or false
    end

    typecheck.RegisterType( "TextureInstance", STATIC.IsTexture )

	function STATIC.GetTotalLockedSurfaceSize()
		typecheck.NotImplementedError()
	end

	function STATIC.GetTotalTextureSize()
		typecheck.NotImplementedError()
	end

	function STATIC.GetTotalLightmapTextureSize()
		typecheck.NotImplementedError()
	end

	function STATIC.GetTotalProceduralTextureSize()
		typecheck.NotImplementedError()
	end

	function STATIC.GetTotalLockedSurfaceCount()
		typecheck.NotImplementedError()
	end

	function STATIC.GetTotalTextureCount()
		typecheck.NotImplementedError()
	end

	function STATIC.GetTotalLightmapTextureCount()
		typecheck.NotImplementedError()
	end

	function STATIC.GetTotalProceduralTextureCount()
		typecheck.NotImplementedError()
	end

	function STATIC.InitFilters()
		typecheck.NotImplementedError()
	end

	function STATIC.SetDefaultMinFilter()
		typecheck.NotImplementedError()
	end

	function STATIC.SetDefaultMagFilter()
		typecheck.NotImplementedError()
	end

	function STATIC.SetDefaultMipFilter()
		typecheck.NotImplementedError()
	end

	function STATIC.InvalidateOldUnusedTextures()
		typecheck.NotImplementedError()
	end

	function STATIC.ApplyNull()
		typecheck.NotImplementedError()
	end

	--- @param cload ChunkLoadInstance
	--- @return TextureInstance?
	function STATIC.LoadTexture( cload )
		-- "Assume failure"
		--- @type TextureInstance?
		local newTexture

		local ids = w3dFileIds.W3D_CHUNK_TYPE

		local name
		if cload:OpenChunk() and cload:CurChunkId() == ids.W3D_CHUNK_TEXTURE then
			--- @type W3dTextureInfoStruct?
			local textureInfo
			local hasTextureInfo = false

			-- "Read in the texture filename, and a possible texture info structure."
			while cload:OpenChunk() do
				local chunkId = cload:CurChunkId()

				if chunkId == ids.W3D_CHUNK_TEXTURE_NAME then
					local _, readBytes = cload:Read( cload:CurChunkLength() )
					name = readBytes --[[@as string]]
					section.Print( "Texture name: ", name )

				elseif chunkId == ids.W3D_CHUNK_TEXTURE_INFO then
					textureInfo = cload:ReadStruct( "W3dTextureInfoStruct" )
					hasTextureInfo = true
				end
				cload:CloseChunk()
			end
			cload:CloseChunk()

			if hasTextureInfo then
				--- @cast textureInfo W3dTextureInfoStruct

				local noLod = bit.band( textureInfo.Attributes, w3dFileIds.W3DTEXTURE_NO_LOD ) == w3dFileIds.W3DTEXTURE_NO_LOD

				typecheck.NotImplementedError()
			else
				newTexture = ww3dAssetManagerClass.GetInstance():GetTexture( name )
			end
		end

		--- "Return a pointer to the new texture"
		return newTexture
	end
end

local DEFAULT_INACTIVATION_TIME = 20000

--- @class TextureInstance
--- @field TextureMinFilter FilterType
--- @field TextureMagFilter FilterType
--- @field MipMapFilter FilterType
--- @field UAddressMode TextureAddressMode
--- @field VAddressMode TextureAddressMode
--- @field D3dTexture ITexture
--- @field Initialized boolean
--- @field Name string
--- @field FullPath string?
--- @field TextureId any
--- @field _IsLightmap boolean
--- @field _IsProcedural boolean
--- @field IsCompressionAllowed boolean
--- @field InactivationTime number "In miliseconds"
--- @field ExtendedInactivationTime number "This is set by the engine, if needed"
--- @field LastInactivationSyncTime number
--- @field LastAccessed number
--- @field TextureFormat WW3dFormat
--- @field Width integer
--- @field Height integer
--- @field Pool PoolType
--- @field Dirty boolean
--- @field MipLevelCount MipCountType
--- @field private TextureLoadTask TextureLoadTaskInstance
--- @field private ThumbnailLoadTask TextureLoadTaskInstance

--- @overload fun( self: TextureInstance, width: integer, height: integer, format: WW3dFormat, mipLevelCount: MipCountType?, pool: PoolType?, renderTarget: boolean? )
--- @overload fun( self: TextureInstance, name: string, fullPath: string?, mipLevelCount: MipCountType?, textureFormat: WW3dFormat?, allowCompression: boolean? )
function INSTANCE:Renegade_Texture( ... )
    local args = { ... }
    local argCount = select( "#", ... )

	local arg1 = args[1]

	typecheck.AssertArgType( self.Class, 1, arg1, { "number", "string" } )

	-- (width: integer, height: integer, format: WW3dFormat, mipLevelCount: MipCountType?, pool: PoolType?, renderTarget: boolean?)
	if typecheck.IsOfType( arg1, "number" ) then
		typecheck.NotImplementedError()

	-- (name: string, fullPath: string?, mipLevelCount: MipCountType?, textureFormat: WW3dFormat?, allowCompression: boolean?)
	else
		local name             = arg1 	 --[[@as string]]
		local fullPath         = args[2] --[[@as string?]]
		local mipLevelCount    = args[3] --[[@as MipCountType?]] or mipCountTypeEnum.MIP_LEVELS_ALL
		local textureFormat    = args[4] --[[@as WW3dFormat?]] or wW3dFormatEnum.WW3D_FORMAT_UNKNOWN
		local allowCompression = args[5] --[[@as boolean]] or true

		self.D3dTexture = nil
		STATIC.UnusedTextureId = STATIC.UnusedTextureId + 1
		self.TextureId = STATIC.UnusedTextureId
		self.Initialized = false
		self.TextureMinFilter = filterTypeEnum.FILTER_TYPE_DEFAULT
		self.TextureMagFilter = filterTypeEnum.FILTER_TYPE_DEFAULT
		self.MipMapFilter = ( mipLevelCount ~= mipCountTypeEnum.MIP_LEVELS_1 ) and filterTypeEnum.FILTER_TYPE_DEFAULT or filterTypeEnum.FILTER_TYPE_NONE
		self.UAddressMode = textureAddressModeEnum.TEXTURE_ADDRESS_REPEAT
		self.VAddressMode = textureAddressModeEnum.TEXTURE_ADDRESS_REPEAT
		self.MipLevelCount = mipLevelCount
		self.Pool = poolTypeEnum.POOL_MANAGED
		self.Dirty = false
		self.IsLightmap = false
		self.IsProcedural = false
		self.TextureFormat = textureFormat
		self.IsCompressionAllowed = allowCompression
		self.TextureLoadTask = nil
		self.ThumbnailLoadTask = nil
		self.Width = 0
		self.Height = 0
		self.InactivationTime = DEFAULT_INACTIVATION_TIME -- "Default inactivation time 30 seconds"
		self.ExtendedInactivationTime = 0
		self.LastInactivationSyncTime = 0

		local format = self.TextureFormat
		if (
			   format == wW3dFormatEnum.WW3D_FORMAT_DXT1
			or format == wW3dFormatEnum.WW3D_FORMAT_DXT2
			or format == wW3dFormatEnum.WW3D_FORMAT_DXT3
			or format == wW3dFormatEnum.WW3D_FORMAT_DXT4
			or format == wW3dFormatEnum.WW3D_FORMAT_DXT5
		) then
			self.IsCompressionAllowed = true

		elseif (
			   format == wW3dFormatEnum.WW3D_FORMAT_U8V8     -- "Bumpmap"
			or format == wW3dFormatEnum.WW3D_FORMAT_L6V5U5   -- "Bumpmap"
			or format == wW3dFormatEnum.WW3D_FORMAT_X8L8V8U8 -- "Bumpmap"
		) then
			-- "
			-- If requesting bumpmap format that isn't available we'll just return the surface in whatever color
			-- format the texture file is in.  (this is illegal case, the format support should always be queried
			-- before creating a bump texture!)
			-- "
			-- Omitted check to see if the bump map format is valid

			-- "  
			-- If bump format is valid, make sure compression is not allowed so that we don't even attempt to load
			-- from a compressed file (quality isn't good enough for bump map).  Also disable mipmapping.
			-- "  
			self.IsCompressionAllowed = false
			self.MipLevelCount = mipCountTypeEnum.MIP_LEVELS_1
			self.MipMapFilter = filterTypeEnum.FILTER_TYPE_NONE
		end

		local containsPlus = ( textUtils.IndexOf( name, "+" ) ~= nil )
		if containsPlus then
			self.IsLightmap = true

			-- "  
			-- Set bilinear filtering for lightmaps (they are very stretched and
			-- low detail so we don't care for anisotropic or trilinear filtering...)  
			-- "  
			self.TextureMinFilter = filterTypeEnum.FILTER_TYPE_FAST
			self.TextureMagFilter = filterTypeEnum.FILTER_TYPE_FAST
			if mipLevelCount ~= mipCountTypeEnum.MIP_LEVELS_1 then
				self.MipMapFilter = filterTypeEnum.FILTER_TYPE_FAST
			end
		end
		self:SetTextureName( name )
		self:SetFullPath( fullPath )
		if not wW3dClass.IsTexturingEnabled() then
			self.Initialized = true
			self.D3dTexture = nil
		end

		-- "Find original size from the thumbnail (but don't create thumbnail texture yet!)"
		-- Omitted getting width and height from thumbnail manager
		section.Warn( self.Class, " - Skipped getting size from thumbnail manager" )

		self.LastAccessed = wW3dClass.GetSyncTime()

		-- "If the thumbnails are not enabled, init the texture at this point to avoid stalling when the mesh is rendered."
		if not wW3dClass.GetThumbnailEnabled() then
			-- Omitted checking for DX8 thread
			self:Init()
		end
	end
end

function INSTANCE:_Renegade_Texture()
	typecheck.NotImplementedError()
end

--- @param name string
function INSTANCE:SetTextureName( name )
	self.Name = name
end

--- @param path string?
function INSTANCE:SetFullPath( path )
	self.FullPath = path
end

function INSTANCE:GetTextureName()
	return self.Name
end

function INSTANCE:GetFullPath()
	typecheck.NotImplementedError()
end

function INSTANCE:GetId()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMipLevelCount()
	typecheck.NotImplementedError()
end

function INSTANCE:GetWidth()
	typecheck.NotImplementedError()
end

function INSTANCE:GetHeight()
	typecheck.NotImplementedError()
end

function INSTANCE:Init()
	typecheck.NotImplementedError()
end

function INSTANCE:SetInactivationTime()
	typecheck.NotImplementedError()
end

function INSTANCE:GetInactivationTime()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSurfaceLevel()
	typecheck.NotImplementedError()
end

function INSTANCE:GetD3dSurfaceLevel()
	typecheck.NotImplementedError()
end

function INSTANCE:GetPriority()
	typecheck.NotImplementedError()
end

function INSTANCE:SetPriority()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMinFilter()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMagFilter()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMipMapping()
	typecheck.NotImplementedError()
end

function INSTANCE:SetMinFilter()
	typecheck.NotImplementedError()
end

function INSTANCE:SetMagFilter()
	typecheck.NotImplementedError()
end

function INSTANCE:SetMipMapping()
	typecheck.NotImplementedError()
end

function INSTANCE:GetUAddrMode()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVAddrMode()
	typecheck.NotImplementedError()
end

function INSTANCE:SetUAddrMode()
	typecheck.NotImplementedError()
end

function INSTANCE:SetVAddrMode()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTextureMemoryUsage()
	typecheck.NotImplementedError()
end

--- @return boolean
function INSTANCE:IsInitialized()
	return self.Initialized
end

--- @return boolean
function INSTANCE:IsLightmap()
	return self._IsLightmap
end

--- @return boolean
function INSTANCE:IsProcedural()
	return self._IsProcedural
end

function INSTANCE:Invalidate()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekDx8Texture()
	typecheck.NotImplementedError()
end

function INSTANCE:IsMissingTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:IsDirty()
	typecheck.NotImplementedError()
end

function INSTANCE:Clean()
	typecheck.NotImplementedError()
end

function INSTANCE:GetReduction()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTextureFormat()
	typecheck.NotImplementedError()
end

function INSTANCE:IsCompressionAllowed()
	typecheck.NotImplementedError()
end

function INSTANCE:Apply()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadLockedSurface()
	typecheck.NotImplementedError()
end

function INSTANCE:ApplyNewSurface()
	typecheck.NotImplementedError()
end

