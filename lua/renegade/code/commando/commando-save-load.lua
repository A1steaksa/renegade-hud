-- Based on CommandoSaveLoadClass within Code/Commando/commandosaveload.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type SaveLoadSubSystemClass
local saveLoadSubSystemClass = CNC.Import( "code/wwsaveload/save-load-sub-system.lua" )

--- @class CommandoSaveLoadClass : SaveLoadSubSystemClass
--- @field Instance CommandoSaveLoadInstance The metatable used by CommandoSaveLoadInstance
local STATIC = CNC.CreateExport( saveLoadSubSystemClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "CommandoSaveLoadClass"

--- @class CommandoSaveLoadInstance : SaveLoadSubSystemInstance
--- @field Static CommandoSaveLoadClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_CommandoSaveLoad : Renegade_SaveLoadSubSystem" )
INSTANCE.Class = "CommandoSaveLoadInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsCommandoSaveLoad = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type EnumBuilderClass
    local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	--- @type CommandoChunkIds
	local commandoChunkIds = CNC.Import( "code/commando/commando-chunk-ids.lua" )

	--- @type NetworkClass
    local networkClass = CNC.Import( "code/commando/network.lua" )

    --- @type CampaignManagerClass
    local campaignManagerClass = CNC.Import( "code/commando/campaign.lua" )

	--- @type GodClass
    local godClass = CNC.Import( "code/commando/god.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Chunk IDs ]] do

	local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
        CHUNKID_NETWORK  = enumBuilder:Set( 1011991043 ),
		CHUNKID_GOD 	 = enumBuilder:Next(),
		CHUNKID_CAMPAIGN = enumBuilder:Next()
    }
end

--[[ Static Functions and Variables ]] do

    --- @class CommandoSaveLoadClass

    --- Creates a new CommandoSaveLoadInstance
    --- @return CommandoSaveLoadInstance
    function STATIC.New()
        return robustclass.New( "Renegade_CommandoSaveLoad" )
    end

	--- Called automatically after this class is imported
    function STATIC.StaticConstructor()
        STATIC.CommandoSaveLoad = STATIC.New()
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) CommandoSaveLoadInstance, `false` otherwise
    function STATIC.IsCommandoSaveLoad( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCommandoSaveLoad and true or false
    end

    typecheck.RegisterType( "CommandoSaveLoadInstance", STATIC.IsCommandoSaveLoad )
end


--- @class CommandoSaveLoadInstance

function INSTANCE:Renegade_CommandoSaveLoad()
	saveLoadSubSystemClass.Instance.Renegade_SaveLoadSubSystem( self )
end

function INSTANCE:_Renegade_CommandoSaveLoad()
	-- Empty in the original code
end

--- @return integer
function INSTANCE:ChunkId()
	return commandoChunkIds.CHUNK_ID.CHUNKID_COMMANDO
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @return boolean
function INSTANCE:Load( cload )
	local ids = STATIC.ChunkIds
	while cload:OpenChunk() do
		local chunkId = cload:CurChunkId()
		if chunkId == ids.CHUNKID_NETWORK then
			networkClass.Load( cload )

		elseif chunkId == ids.CHUNKID_GOD then
			godClass.Load( cload )

		elseif chunkId == ids.CHUNKID_CAMPAIGN then
			campaignManagerClass.Load( cload )

		else
			section.Warn( "Unrecognized Commando Chunk ID ", chunkId )
		end
		cload:CloseChunk()
	end
	return true
end

--- @return string
function INSTANCE:Name()
	return "CommandoSaveLoadClass"
end
