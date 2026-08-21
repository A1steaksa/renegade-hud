-- Based on WW3DAssetManager within Code/ww3d2/assetmgr.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class Ww3dAssetManagerClass
--- @field Instance WW3dAssetManagerInstance The metatable used by Ww3dAssetManagerInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "Ww3dAssetManagerClass"

--- @class WW3dAssetManagerInstance
--- @field Static Ww3dAssetManagerClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Ww3dAssetManager" )
INSTANCE.Class = "Ww3dAssetManagerInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsWw3dAssetManager = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type RenderObjectClass
	local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

	--- @type MeshClass
	local meshClass = CNC.Import( "code/ww3d2/mesh.lua" )

	--- @type MeshModelClass
	local meshModelClass = CNC.Import( "code/ww3d2/mesh-model.lua" )

	--- @type PrototypeClass
	local prototypeClass = CNC.Import( "code/ww3d2/prototype.lua" )

	--- @type NullPrototypeClass
	local nullPrototypeClass = CNC.Import( "code/ww3d2/null-prototype.lua" )

	--- @type Null3dObjectClass
	local null3dObjectClass = CNC.Import( "code/ww3d2/null-3d-object.lua" )

	--- @type FileFactoryClass
	local fileFactoryClass = CNC.Import( "code/wwlib/file-factory.lua" )

	--- @type ChunkLoadClass
	local chunkLoadClass = CNC.Import( "code/wwlib/chunk-load.lua" )

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type TextUtils
	local textUtils = CNC.Import( "sh_text-utils.lua" )

	--- @type WW3dFileFormatIds
	local wW3dFileFormatIds = CNC.Import( "code/ww3d2/ww3d-format.lua" )

	--- @type TextureClass
	local textureClass = CNC.Import( "code/ww3d2/texture.lua" )

	--- @type BoxRenderObjectClass
	local boxRenderObjectClass = CNC.Import( "code/ww3d2/box-render-object.lua" )

	--- @type HLodLoaderClass
	local hLodLoaderClass = CNC.Import( "code/ww3d2/h-lod-loader.lua" )

	--- @type HTreeManagerClass
	local hTreeManagerClass = CNC.Import( "code/ww3d2/h-tree-manager.lua" )

	--- @type HAnimationManagerClass
	local hAnimationManagerClass = CNC.Import( "code/ww3d2/h-animation-manager.lua" )

	--- @type AggregateLoaderClass
	local aggregateLoaderClass = CNC.Import( "code/ww3d2/aggregate-loader.lua" )

	--- @type HModelLoaderClass
	local hModelLoaderClass = CNC.Import( "code/ww3d2/h-model-loader.lua" )
--#endregion

--#region Imported Enums

	local wW3dFormatEnum = wW3dFileFormatIds.WW3D_FORMAT
	local mipCountTypeEnum = textureClass.MIP_COUNT_TYPE
--#endregion

--[[
Porting Notes:
* I'm omitting the Prototypes array and just using the PrototypeHashTable instead as that aligns more with Lua
--]]

--[[ Static Functions and Variables ]] do

    --- @class Ww3dAssetManagerClass
	--- @field TheInstance WW3dAssetManagerInstance
	--- @field NullPrototype NullPrototypeInstance

	STATIC.PROTOLOADERS_VECTOR_SIZE = 32
	STATIC.PROTOLOADERS_GROWTH_RATE = 16

	STATIC.PROTOTYPES_VECTOR_SIZE =	256
	STATIC.PROTOTYPES_GROWTH_RATE =	32

    --- Creates a new Ww3dAssetManagerInstance
    --- @return WW3dAssetManagerInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Ww3dAssetManager" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Ww3dAssetManagerInstance, `false` otherwise
    function STATIC.IsWw3dAssetManager( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsWw3dAssetManager and true or false
    end

    typecheck.RegisterType( "Ww3dAssetManagerInstance", STATIC.IsWw3dAssetManager )

	function STATIC.StaticConstructor()
		STATIC.NullPrototype = nullPrototypeClass.New()
	end

	--- "
	--- Access to the single instance of a WW3DAssetManager.  The user
	--- can subclass their own asset manager class but should only
	--- create one instance.  (a violation of this will be caught with
	--- a run-time assertion)
	--- "
	--- @return WW3dAssetManagerInstance
	function STATIC.GetInstance()
		return STATIC.TheInstance
	end

	function STATIC.DeleteThis()
		typecheck.NotImplementedError()
	end

	function STATIC.LogTextureStatistics()
		typecheck.NotImplementedError()
	end
end


--- @class WW3dAssetManagerInstance
--- @field PrototypeLoaders PrototypeLoaderInstance[] "These objects are responsible for importing certain W3D chunk types and turning them into prototypes"
--- @field PrototypeHashTable table<string,PrototypeInstance>
--- @field HTreeManager HTreeManagerInstance
--- @field HAnimationManager HAnimationManagerInstance
--- @field TextureCache any
--- @field Font3ddatas any
--- @field FontCharsList any
--- @field Ww3dLoadOnDemand boolean
--- @field ActivateFogOnLoad boolean
--- @field MetalManager any
--- @field _TextureHash table<string, TextureInstance>

--- "Constructor"
function INSTANCE:Renegade_Ww3dAssetManager()
	self.PrototypeLoaders = {}
	self._TextureHash = {}

	self.HTreeManager = hTreeManagerClass.New()
	self.HAnimationManager = hAnimationManagerClass.New()

	self.Ww3dLoadOnDemand = false
	self.ActivateFogOnLoad = false
	self.MetalManager = nil

	assert( STATIC.TheInstance == nil )
	STATIC.TheInstance = self

	-- Ommitted setting growth rates

	-- "Install the default loaders"
	self:RegisterPrototypeLoader( prototypeClass.MeshLoader )
	self:RegisterPrototypeLoader( prototypeClass.HModelLoader )
	-- self:RegisterPrototypeLoader( collectionLoaderClass.CollectionLoader )
	self:RegisterPrototypeLoader( boxRenderObjectClass.BoxLoader )
	self:RegisterPrototypeLoader( hLodLoaderClass.HLodLoader )
	-- self:RegisterPrototypeLoader( distantLodPrototypeClass.DistantLodLoader )
	self:RegisterPrototypeLoader( aggregateLoaderClass.AggregateLoader )
	self:RegisterPrototypeLoader( null3dObjectClass.NullLoader )
	-- self:RegisterPrototypeLoader( dazzleRenderObjectClass.DazzleLoader )

	-- "Allocate the hash table and clear it."
	self.PrototypeHashTable = {}
end

--- "Destructor"
function INSTANCE:_Renegade_Ww3dAssetManager()
	if self.MetalManager then
		self.MetalManager = nil
	end
	self:Free()
	STATIC.TheInstance = nil

	-- "If we need to, free the hash table"
	if self.PrototypeHashTable ~= nil then
		self.PrototypeHashTable = nil
	end
end

--- "Load 3D assets from a file"
--- @param fileName string
--- @return boolean
--- @overload fun( self: WW3dAssetManagerInstance, w3dFile: FileInstance ): boolean
function INSTANCE:Load3dAssets( fileName )
	typecheck.AssertArgType( self.Class, 1, fileName, { "string", "FileInstance", "BufferedFileInstance" } )

	-- ( fileName: string ): boolean
	if typecheck.IsOfType( fileName, "string" ) then
		local result = false

		local file = fileFactoryClass.TheFileFactory:GetFile( fileName )
		if file then
			if file:IsAvailable() then
				result = self:Load3dAssets( file )
			end
			fileFactoryClass.TheFileFactory:ReturnFile( file )
		end

		return result

	-- ( w3dFile: FileInstance ): boolean
	else
		local w3dFile = fileName --[[@as FileInstance]]

		if not w3dFile:Open() then
			return false
		end

		local cload = chunkLoadClass.New( w3dFile )

		while cload:OpenChunk() do
			local chunkId = cload:CurChunkId()

			if chunkId == w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_HIERARCHY then
				section.Warn( "Skipping loading asset chunk for HTreeManager" )
				-- STATIC.HTreeManager:LoadTree( cload )

			elseif (
				   chunkId == w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_ANIMATION
				or chunkId == w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_COMPRESSED_ANIMATION
				or chunkId == w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_MORPH_ANIMATION
			) then
				section.Warn( "Skipping loading asset chunk for HAnimManager" )
				-- STATIC.HAnimManager:LoadAnim( cload )

			else
				self:LoadPrototype( cload )
			end

			cload:CloseChunk()
		end

		w3dFile:Close()

		return true
	end
end

function INSTANCE:FreeAssets()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseUnusedAssets()
	typecheck.NotImplementedError()
end

--- "Create me an instance of one of the prototype render objects"
--- @param connectedEntity Entity
--- @param name string
--- @param sourceModelPath string
--- @return RenderObjectInstance?
function INSTANCE:CreateRenderObject( connectedEntity, name, sourceModelPath )
	-- "Try to find a prototype"
	local prototype = self:FindPrototype( name )

	-- "If we didn't find one, try to load on demand"
	if self.Ww3dLoadOnDemand and prototype == nil then
		section.Start( "Loading Render Object Prototype on demand for: ", name )

		local fileName
		local periodIndex = textUtils.IndexOf( name, "." )
		if periodIndex ~= nil then
			fileName = name:sub( 0, periodIndex - 1 ) .. ".w3d"
		else
			fileName = name .. ".w3d"
		end

		-- "If we can't find it, try the parent directory"
		if self:Load3dAssets( fileName ) == nil then
			local newFileName = "..\\" .. fileName
			self:Load3dAssets( newFileName )
		end

		-- "Try again"
		prototype = self:FindPrototype( name )

		section.End()
	end

	if prototype == nil then
		return -- "Failed to find a prototype"
	end

	return prototype:Create()
end

--- "Checks whether a render object with the given name [exists]"
--- @param name string
--- @return boolean
function INSTANCE:RenderObjectExists( name )
	if self:FindPrototype( name ) == nil then
		return false
	else
		return true
	end
end

function INSTANCE:CreateRenderObjectIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseRenderObjectIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateHAnimationIterator()
	typecheck.NotImplementedError()
end

--- @param name string
--- @return HAnimationInstance?
function INSTANCE:GetHAnimation( name )
	-- "Try to find the hanim"
	local animation = self.HAnimationManager:GetAnimation( name )

	-- "If we didn't find it, try to load on demand"
	if self.Ww3dLoadOnDemand and animation == nil then
		-- "If this is NOT a known missing anim"
		if not self.HAnimationManager:IsMissing( name ) then

			-- Omitted reporting the load on demand call to AssetStatusClass

			local fileName
			local dotIndex = textUtils.IndexOf( name, "." )
			local animationName
			if dotIndex ~= nil then
				animationName = name:sub( dotIndex + 1 )
				fileName = animationName .. ".w3d"
			else
				section.Error( INSTANCE.Class, " - GetHAnimation - Animation ", name, " has no . in the name" )
				return
			end

			-- "If we can't find it, try the parent directory"
			if self:Load3dAssets( fileName ) == false then
				local newFileName = "..\\" .. fileName
				self:Load3dAssets( newFileName )
			end

			-- "Try [again]"
			animation = self.HAnimationManager:GetAnimation( name )
			if animation == nil then
				-- "This is now a KNOWN missing anim"
				self.HAnimationManager:RegisterMissing( name )
				-- Omitted reporting missing HAnim to AssetStatusClass
			end
		end
	end

	return animation
end

function INSTANCE:AddAnimation()
	typecheck.NotImplementedError()
end

function INSTANCE:TextureHash()
	typecheck.NotImplementedError()
end

--- @param fileName string
--- @param mipLevelCount MipCountType? [Default: `MIP_LEVELS_ALL`]
--- @param textureFormat WW3dFormat? [Default: `WW3D_FORMAT_UNKNOWN`]
--- @param allowCompression boolean? [Default: `true`]
--- @return TextureInstance?
function INSTANCE:GetTexture( fileName, mipLevelCount, textureFormat, allowCompression )
	mipLevelCount = ( mipLevelCount ~= nil ) and mipLevelCount or mipCountTypeEnum.MIP_LEVELS_ALL
	textureFormat = ( textureFormat ~= nil ) and textureFormat or wW3dFormatEnum.WW3D_FORMAT_UNKNOWN
	allowCompression = ( allowCompression ~= nil ) and allowCompression or true

	-- "We cannot currently mip-map bumpmaps"
	if textureFormat == wW3dFormatEnum.WW3D_FORMAT_U8V8 then
		mipLevelCount = mipCountTypeEnum.MIP_LEVELS_1
	end

	-- "Bail if the user isn't really asking for anything"
	if fileName == nil or fileName:len() == 0 then
		return nil
	end

	local lowerCaseName = fileName:lower()

	-- "See if the texture has already been loaded."
	local texture = self._TextureHash[lowerCaseName]
	if texture and ( texture:IsInitialized() == true ) and ( textureFormat ~= wW3dFormatEnum.WW3D_FORMAT_UNKNOWN ) then
		if texture:GetTextureFormat() ~= textureFormat then
			section.Error( "Texture ", fileName, " has already been loaded with different format" )
		end
	end

	-- "Didn't have it so we have to create a new texture"
	if not texture then
		texture = textureClass.New( lowerCaseName, nil, mipLevelCount, textureFormat, allowCompression )
		self._TextureHash[texture:GetTextureName()] = texture
	end

	return texture
end

function INSTANCE:ReleaseAllTextures()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseUnusedTextures()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseTexture()
	typecheck.NotImplementedError()
end

function INSTANCE:LoadProceduralTextures()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekMetalMapManager()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFont3dinstance()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFontChars()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateHTreeIterator()
	typecheck.NotImplementedError()
end

--- "Returns a pointer to the named HTree"
--- @param name string
--- @return HTreeInstance?
function INSTANCE:GetHTree( name )
	-- "Try to find the htree"
	local hTree = self.HTreeManager:GetTree( name )

	-- "If we didn't find it, try to load on demand"
	if self.Ww3dLoadOnDemand and hTree == nil then
		section.Warn( "Loading HTree on demand: '", name, "'" )

		local fileName = name .. ".w3d"

		-- "If we can't find it, try the parent [directory]"
		if INSTANCE.Load3dAssets( self, fileName ) == false then
			local newFileName = "..\\" .. fileName
			INSTANCE.Load3dAssets( self, newFileName )
		end

		-- "Try again"
		hTree = self.HTreeManager:GetTree( name )

		if hTree == nil then
			section.Error( "Failed to load HTree on demand: '", name, "'" )
		end
	end

	return hTree
end

--- "  
--- Add a new loader to the system  
---
--- The library will automatically install loaders for the 'built-in' render object types.  
--- This function exists so that the user can design App-specific render objects, define a 
--- chunk format for them, and have the asset manager load them in like everything else.  
--- "
--- @param loader PrototypeLoaderInstance "...a global or static instance of your loader type."
function INSTANCE:RegisterPrototypeLoader( loader )
	assert( loader ~= nil )
	self.PrototypeLoaders[#self.PrototypeLoaders+1] = loader
end

--- "Adds the prototype to the hash table"
--- @param newPrototype PrototypeInstance
function INSTANCE:AddPrototype( newPrototype )
	assert( newPrototype ~= nil )

	-- Omitted the majority of the code as it is not needed in Lua
	local key = newPrototype:GetName():TrimRight( "\0" ):lower()
	self.PrototypeHashTable[key] = newPrototype
end

--- "Removes all references to the [prototype]"
--- @param prototype PrototypeInstance
--- @overload fun( self: WW3dAssetManagerInstance, name: string )
function INSTANCE:RemovePrototype( prototype )
	typecheck.AssertArgType( self.Class, 1, prototype, { "string", "PrototypeInstance" } )

	-- Omitted the majority of the code as it is not needed in Lua

	local key

	-- ( prototype: PrototypeInstance )
	if typecheck.IsOfType( prototype, "PrototypeInstance" ) then
		key = prototype:GetName()

	-- ( name: string )
	else
		key = prototype --[[@as string]]
	end

	key = key:TrimRight( "\0" ):lower()
	self.PrototypeHashTable[key] = nil
end

--- "Searches the hash table for the prototype"
--- @param name string
--- @return PrototypeInstance
function INSTANCE:FindPrototype( name )

	-- "Special case Null render object.  So we always have it..."
	if name == nil then
		return STATIC.NullPrototype
	end

	-- "Find the prototype"
	-- Omitted a while loop looking at CRC hashes
	name = name:TrimRight( "\0" ):lower()
	local result = self.PrototypeHashTable[name]
	return result
end

--[[ Load on Demand ]] do

	--- @return boolean
	function INSTANCE:GetWw3dLoadOnDemand()
		return self.Ww3dLoadOnDemand
	end

	--- @param shouldLoadOnDemand boolean
	function INSTANCE:SetWw3dLoadOnDemand( shouldLoadOnDemand )
		self.Ww3dLoadOnDemand = shouldLoadOnDemand
	end
end

--[[ Add Fog to Objects on Load ]] do

	--- @return boolean
	function INSTANCE:GetActivateFogOnLoad()
		return self.ActivateFogOnLoad
	end

	--- @param shouldActivateFog boolean
	function INSTANCE:SetActivateFogOnLoad( shouldActivateFog )
		self.ActivateFogOnLoad = shouldActivateFog
	end
end


function INSTANCE:LogAllTextures()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateFont3ddataIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:AddFont3ddata()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveFont3ddata()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFont3ddata()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseAllFont3ddatas()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseUnusedFont3ddatas()
	typecheck.NotImplementedError()
end

function INSTANCE:ReleaseAllFontChars()
	typecheck.NotImplementedError()
end

function INSTANCE:Free()
	typecheck.NotImplementedError()
end

--- "Find the loader that handles this chunk type"
--- @param chunkId integer "Chunk type that the loader needs to handle"
--- @return PrototypeLoaderInstance? "...the appropriate loader or [nil] if one wasn't found"
function INSTANCE:FindPrototypeLoader( chunkId )
	for i, loader in ipairs( self.PrototypeLoaders ) do
		if loader:ChunkType() == chunkId then
			return loader
		end
	end
end

--- "Loads a prototype from a W3D chunk"
--- @param cload ChunkLoadInstance
--- @return boolean
function INSTANCE:LoadPrototype( cload )

	-- "Get the chunk id"
	local chunkId = cload:CurChunkId()
	local chunkIdName = table.KeyFromValue( w3dFileIds.W3D_CHUNK_TYPE, chunkId )
	local chunkIdNameString = ( chunkIdName ~= nil and " (" .. chunkIdName .. ")" or nil )

	-- "Find a loader that handles that type of chunk"
	local loader = self:FindPrototypeLoader( chunkId )
	local newPrototype

	section.Start( "Loading Chunk ID ", chunkId, chunkIdNameString )

	if loader ~= nil then
		-- "Ask it to create a prototype from the contents of the chunk."
		newPrototype = loader:LoadW3d( cload )

		section.End()
	else
		section.Error(
			"Failed to find prototype loader for Chunk ID ",
			chunkId,
			chunkIdNameString
		)
		return false
	end

	--- "
	--- Now, see if the prototype that we loaded has a duplicate name
	--- with any of our currently loaded prototypes (can't have that!)
	--- "
	if newPrototype ~= nil then
		if not self:RenderObjectExists( newPrototype:GetName() ) then
			-- "Add the new, unique prototype to our list"
			self:AddPrototype( newPrototype )
		else
			-- "Warn the user about a name collision with this prototype and dump it"
			section.Warn( "Render Object Name Collision: ", newPrototype:GetName() )
			newPrototype = nil
			return false
		end
	else
		--- "Warn user that a prototype was not generated from this chunk type"
		section.Warn( "Could not generate prototype!  Chunk = ", chunkId )
		return false
	end

	return true
end
