-- Based on AggregateDefClass within Code/ww3d2/agg_def.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class AggregateDefinitionClass
--- @field Instance AggregateDefinitionInstance The metatable used by AggregateDefinitionInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "AggregateDefinitionClass"

--- @class AggregateDefinitionInstance
--- @field Static AggregateDefinitionClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_AggregateDefinition" )
INSTANCE.Class = "AggregateDefinitionInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAggregateDefinition = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type WW3dErrorTypes
	local wW3dErrorTypes = CNC.Import( "code/ww3d2/w3d-errors.lua" )

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type RenderObjectClass
	local renderObjectClass = CNC.Import( "code/ww3d2/render-object.lua" )

	--- @type AggregateDefinitionClass
	local aggregateDefinitionClass = CNC.Import( "code/ww3d2/aggregate-definition.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )
--#endregion

--#region Imported Enums

	local wW3dErrorTypeEnum = wW3dErrorTypes.WW3D_ERROR_TYPE
	local w3dChunkTypeEnum = w3dFileIds.W3D_CHUNK_TYPE
	local renderObjectClassIdEnum = renderObjectClass.RENDER_OBJECT_CLASS_ID
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class AggregateDefinitionClass

    --- Creates a new AggregateDefinitionInstance
	--- @param src AggregateDefinitionInstance|RenderObjectClass?
    --- @return AggregateDefinitionInstance
    function STATIC.New( src )
        return robustclass.New( "Renegade_AggregateDefinition", src )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) AggregateDefinitionInstance, `false` otherwise
    function STATIC.IsAggregateDefinition( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAggregateDefinition and true or false
    end

    typecheck.RegisterType( "AggregateDefinitionInstance", STATIC.IsAggregateDefinition )
end


--- @class AggregateDefinitionInstance
--- @field Version integer
--- @field SubObjectList W3dAggregateSubObjectStruct[]
--- @field Info W3dAggregateInfoStruct
--- @field MiscInfo W3dAggregateMiscInfo
--- @field Name string

--- @param src AggregateDefinitionInstance|RenderObjectClass?
function INSTANCE:Renegade_AggregateDefinition( src )
	self.SubObjectList = {}

	-- "Set our member data to default settings"
	self.Info = {
		BaseModelName = "",
		SubObjectCount = 0
	}
	self.MiscInfo = {
		OriginalClassId = renderObjectClassIdEnum.CLASSID_HLOD,
		Flags = 0,
		Reserved = {}
	}

	-- ( src: AggregateDefinitionInstance )
	if typecheck.IsOfType( src, "" ) then
		typecheck.NotImplementedError()

	-- ( baseModel: RenderObjectInstance )
	elseif typecheck.IsOfType( src, "" ) then
		INSTANCE.Initialize( self, src --[[@as RenderObjectInstance]] )
	end
end

function INSTANCE:_Renegade_AggregateDefinition()
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @return WW3dErrorType
function INSTANCE:LoadW3d( cload )
	while cload:OpenChunk() do
		local error = wW3dErrorTypeEnum.WW3D_ERROR_OK

		local id = cload:CurChunkId()
		if id == w3dChunkTypeEnum.W3D_CHUNK_AGGREGATE_HEADER then
			error = INSTANCE.ReadHeader( self, cload )

			if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
				section.Error( "Failed to load AggregateDefinitionInstance header" )
				return error
			end

		elseif id == w3dChunkTypeEnum.W3D_CHUNK_AGGREGATE_INFO then
			error = INSTANCE.ReadInfo( self, cload )

			if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
				section.Error( "Failed to load AggregateDefinitionInstance info" )
				return error
			end

		elseif id == w3dChunkTypeEnum.W3D_CHUNK_TEXTURE_REPLACER_INFO then
			-- I'm omitting the texture replacer header struct because it's only used to throw an error
			-- The struct has a size of 8 (a uint32)
			cload:Read( 8 )

		elseif id == w3dChunkTypeEnum.W3D_CHUNK_AGGREGATE_CLASS_INFO then
			error = INSTANCE.ReadClassInfo( self, cload )

			if error ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
				section.Error( "Failed to load AggregateDefinitionInstance class info" )
				return error
			end
		else
			-- "Unknown chunk"
		end

		cload:CloseChunk()
	end

	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

function INSTANCE:SaveW3d()
	typecheck.NotImplementedError()
end

--- @return string
function INSTANCE:GetName()
	return self.Name
end

--- @param name string
function INSTANCE:SetName( name )
	self.Name = name
end

--- @return RenderObjectInstance
function INSTANCE:Create()
	-- "Attempt to create an instance of the hierarchy"
	local model = INSTANCE.CreateRenderObject( self, self.Info.BaseModelName )
	if model ~= nil then
		-- "Perform the aggregation"
		INSTANCE.AttachSubObjects( self, model )

		-- "Let the new object nknow what its new name and base name are."
		model:SetName( self.Name )
		model:SetBaseModelName( self.Info.BaseModelName )
		model:SetSubObjectsMatchLod(
			bit.band(
				self.MiscInfo.Flags,
				w3dFileIds.W3D_AGGREGATE_FORCE_SUB_OBJ_LOD
			) == w3dFileIds.W3D_AGGREGATE_FORCE_SUB_OBJ_LOD
		)
	else
		section.Error( "Unable to load aggregate '", self.Info.BaseModelName ,"'." )
	end

	-- "Return a pointer to the new aggregate"
	--- @cast model RenderObjectInstance
	return model
end

--- @return AggregateDefinitionInstance
function INSTANCE:Clone()
	return aggregateDefinitionClass.New( self )
end

--- @return integer
function INSTANCE:ClassId()
	return self.MiscInfo.OriginalClassId
end

--- @param baseModel RenderObjectInstance
function INSTANCE:Initialize( baseModel )
	-- "Start with fresh lists"
	INSTANCE.FreeSubobjectList( self )

	-- "Determine what the render objects original name was."
	local originalModelName = baseModel:GetBaseModelName() or baseModel:GetName()

	-- "Record information about this base model"
	self.Info.BaseModelName = originalModelName
	self.Info.SubObjectCount = 0
	self.MiscInfo.OriginalClassId = baseModel:ClassId()
	self.MiscInfo.Flags = 0
	self.MiscInfo.Flags = bit.bor(
		self.MiscInfo.Flags,
		(
			baseModel:IsSubObjectsMatchLodEnabled() and w3dFileIds.W3D_AGGREGATE_FORCE_SUB_OBJ_LOD or 0
		)
	)

	-- "Pass the aggregate name along"
	self:SetName( baseModel:GetName() )

	-- "  
	-- Create a new instance of the model which we can use to compare with the supplied model and
	-- determine which 'bones-models' and textures are new.  
	-- "  

	-- "Build lists of changes from the delta between the original model and the provided one"
end

--- @param cload ChunkLoadInstance
--- @return WW3dErrorType
function INSTANCE:ReadHeader( cload )
	-- "Assume error"
	local returnValue = wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED

	-- "Is this the header chunk?"
	local header = cload:ReadStruct( "W3dAggregateHeaderStruct" )
	if header ~= nil then
		-- "Copy the name from the header structure"
		self.Name = header.Name
		self.Version = header.Version

		-- "Success!"
		returnValue = wW3dErrorTypeEnum.WW3D_ERROR_OK
	end

	-- "Return the [WW3dErrorTypeEnum] return code"
	return returnValue
end

--- @param cload ChunkLoadInstance
--- @return WW3dErrorType
function INSTANCE:ReadInfo( cload )
	-- "Assume error"
	local returnValue = wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED

	local infoStruct = cload:ReadStruct( "W3dAggregateInfoStruct" )
	if infoStruct ~= nil then
		self.Info = infoStruct

		-- "Success!"
		returnValue = wW3dErrorTypeEnum.WW3D_ERROR_OK

		-- "Read all the subobjects from the file"
		for subObjectIndex = 1, self.Info.SubObjectCount do
			if returnValue ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
				break
			end

			-- "Read this subobject's definition from the file"
			returnValue = INSTANCE.ReadSubObject( self, cload )
		end
	end

	-- "Return the [WW3dErrorTypeEnum] return code"
	return returnValue
end

--- @param cload ChunkLoadInstance
--- @return WW3dErrorType
function INSTANCE:ReadSubObject( cload )
	-- "Assume error"
	local returnValue = wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED

	-- "Read the subobject information from the file"
	local subObjectInfo = cload:ReadStruct( "W3dAggregateSubObjectStruct" )
	if subObjectInfo ~= nil then
		-- "Add this subobject to our list"
		INSTANCE.AddSubobject( self, subObjectInfo )

		-- "Success!"
		returnValue = wW3dErrorTypeEnum.WW3D_ERROR_OK
	end

	-- "Return the [WW3dErrorTypeEnum] return code"
	return returnValue
end

--- @param cload ChunkLoadInstance
--- @return WW3dErrorType
function INSTANCE:ReadClassInfo( cload )
	-- "Assume error"
	local returnValue = wW3dErrorTypeEnum.WW3D_ERROR_LOAD_FAILED

	local miscInfo = cload:ReadStruct( "W3dAggregateMiscInfo" )
	if miscInfo ~= nil then
		self.MiscInfo = miscInfo
		-- "Success!"
		returnValue = wW3dErrorTypeEnum.WW3D_ERROR_OK
	end

	-- "Return the [WW3dErrorTypeEnum] return code"
	return returnValue
end

function INSTANCE:SaveHeader()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveInfo()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveSubobject()
	typecheck.NotImplementedError()
end

function INSTANCE:SaveClassInfo()
	typecheck.NotImplementedError()
end

--- @param baseModel RenderObjectInstance
function INSTANCE:AttachSubObjects( baseModel )
	-- "Now loop through all the subobjects and attach them to the appropriate bone"
	for index = 1, #self.SubObjectList do
		local subObjectInfo = self.SubObjectList[index]
		if subObjectInfo ~= nil then

			-- "Now create this subobject and attach it to its bone."
			local renderObject = INSTANCE.CreateRenderObject( self, subObjectInfo.SubObjectName )
			if renderObject ~= nil then
				-- "Attach this object to the requested bone"
				if baseModel:AddSubObjectToBone( renderObject, subObjectInfo.BoneName ) == false then
					section.Error( "Unable to attach '", subObjectInfo.SubObjectName, "' to '", subObjectInfo.BoneName, "'" )
				end

			else
				section.Error( "Unable to load aggregate subobject '", subObjectInfo.SubObjectName, "'" )
			end
		end
	end
end

function INSTANCE:FindSubobject()
	typecheck.NotImplementedError()
end

function INSTANCE:FreeSubobjectList()
	self.SubObjectList = {}
end

--- @param subObjectInfo W3dAggregateSubObjectStruct
function INSTANCE:AddSubobject( subObjectInfo )
	-- "Create a new structure and copy the contents of the src"
	--- @type W3dAggregateSubObjectStruct
	local newEntry = {
		SubObjectName = subObjectInfo.SubObjectName,
		BoneName = subObjectInfo.BoneName
	}

	-- "Add this new entry to the list"
	self.SubObjectList[#self.SubObjectList+1] = newEntry
end

--- @param assetName string
--- @return boolean
function INSTANCE:LoadAssets( assetName )

	typecheck.NotImplementedError()
	do return false end

	-- "Assume failure"
	local returnValue = false

	-- "Param OK?"
	if assetName ~= nil then
		-- "Determine what the current working directory is"
		local path = ""

		-- "Ensure the path is directory delimited"

		-- "Assume the filename is simply the 'asset name' + the w3d extension"

		-- "If the file exists, then load it into the asset manager."
		returnValue = ww3dAssetManagerClass.GetInstance():Load3dAssets( path )

	end

	-- "Return the true/false result code"
	return returnValue
end

--- @param assetName string
--- @return RenderObjectInstance?
function INSTANCE:CreateRenderObject( assetName )
	-- "Assume error"
	--- @type RenderObjectInstance?
	local renderObject = nil

	-- "Attempt to get an instance of the render object from the asset manager"
	renderObject = ww3dAssetManagerClass.GetInstance():CreateRenderObject( assetName )

	-- "If we couldn't find the render object in the asset manager, then attempt to load it from file"
	if renderObject == nil and INSTANCE.LoadAssets( self, assetName ) then
		-- "It should be in the asset manager now, so attempt to get it again"
		renderObject = ww3dAssetManagerClass.GetInstance():CreateRenderObject( assetName )
	end

	-- "Return a pointer to the render object"
	return renderObject
end

function INSTANCE:IsObjectInList()
	typecheck.NotImplementedError()
end

function INSTANCE:BuildSubobjectList()
	typecheck.NotImplementedError()
end
