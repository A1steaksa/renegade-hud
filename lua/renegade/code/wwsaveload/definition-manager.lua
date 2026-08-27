-- Based on DefinitionMgrClass within Code/wwsaveload/definitionmgr.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type SaveLoadSubSystemClass
local saveLoadSubSystemClass = CNC.Import( "code/wwsaveload/save-load-sub-system.lua" )

--- @class DefinitionManagerClass : SaveLoadSubSystemClass
--- @field instance DefinitionManagerInstance The metatable used by DefinitionManagerInstance
local STATIC = CNC.CreateExport( saveLoadSubSystemClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "DefinitionManagerClass"

--- @class DefinitionManagerInstance : SaveLoadSubSystemInstance
--- @field Static DefinitionManagerClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_DefinitionManager : Renegade_SaveLoadSubSystem" )
INSTANCE.Class = "DefinitionManagerInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsDefinitionManager = true


--#region Exported Enums

    --- @enum IdType
    STATIC.ID_TYPE = {
        CLASS       = 1,
        SUPERCLASS  = 2
    }
    local idTypeEnum = STATIC.ID_TYPE
--#endregion


--#region Imports

    --- @type EnumBuilderClass
    local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    --- @type CombatChunkIdClass
    local combatChunkId = CNC.Import( "code/combat/combat-chunk-id.lua" )

    --- @type SaveLoadSystemClass
    local saveLoadSystemClass = CNC.Import( "code/wwsaveload/save-load.lua" )

    --- @type SaveLoadIds
    local saveLoadIdsClass = CNC.Import( "code/wwsaveload/save-load-ids.lua" )

    --- @type DefinitionClassIds
    local definitionClassIds = CNC.Import( "code/wwsaveload/definition-class-ids.lua" )
--#endregion


--#region Imported Enums

    local chunkIdEnum = saveLoadIdsClass.ChunkIds
    local classIdEnum = definitionClassIds.CLASS_ID
--#endregion


--[[ Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
        CHUNKID_VARIABLES   = enumBuilder:Set( 0x00000100 ),
        CHUNKID_OBJECTS     = enumBuilder:Next(),
        CHUNKID_OBJECT      = enumBuilder:Next(),
    }
end

--[[ Micro-Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.MicroChunkIds = {
        VARID_NEXTDEFID = enumBuilder:Set( 0x01 )
    }
end


--[[ Static Functions and Variables ]] do

    --- @class DefinitionManagerClass

    --- @type table<integer, DefinitionInstance>
    STATIC.IdToDefinition = {}

    --- @type table<string, DefinitionInstance>
    STATIC.NameToDefinition = {}

    --- Creates a new DefinitionManagerInstance
    --- @return DefinitionManagerInstance
    function STATIC.New()
        return robustclass.New( "Renegade_DefinitionManager" )
    end

    --- Called automatically after this class is imported
    function STATIC.StaticConstructor()
        STATIC.TheDefinitionManager = STATIC.New()
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) DefinitionManagerInstance, `false` otherwise
    function STATIC.IsDefinitionManager( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsDefinitionManager and true or false
    end

    typecheck.RegisterType( "DefinitionManagerInstance", STATIC.IsDefinitionManager )

    --[[ Type Identification ]] do

        --- @param id integer
        --- @param twiddle boolean? [Default: `true`]
        --- @return DefinitionInstance?
        function STATIC.FindDefinition( id, twiddle )
            if not twiddle then twiddle = true end

            local definition = STATIC.IdToDefinition[id]

            -- "Should we twiddle this definition?"
            -- "(Twiddling refers to our randomizing framework for definitions)"
            if twiddle and definition ~= nil and definition:GetClassId() == classIdEnum.TWIDDLERS then
                typecheck.NotImplementedError( "Definition \"twiddling\" in FindDefinition" )
            end

            return definition
        end

        --- @param name string
        --- @param twiddle boolean? [Default: `true`]
        --- @return DefinitionInstance?
        function STATIC.FindNamedDefinition( name, twiddle )
            local definition = STATIC.NameToDefinition[name]

            if twiddle then
                typecheck.NotImplementedError()
            end

            return definition
        end

        --- @param name string
        --- @param classId integer
        --- @param twiddle boolean? [Default: `true`]
        --- @return DefinitionInstance
        function STATIC.FindTypedDefinition( name, classId, twiddle )
            typecheck.NotImplementedError()
        end

        --- @param superclassId integer? [Default: All]
        function STATIC.ListAvailableDefinitions( superclassId )
            typecheck.NotImplementedError()
        end

        --- @param classId integer
        --- @return integer
        function STATIC.GetNewId( classId )
            typecheck.NotImplementedError()
        end
    end

    --[[ Definition Registration ]] do

        --- @param definition DefinitionInstance
        function STATIC.RegisterDefinition( definition )
            typecheck.NotImplementedError()
        end

        --- @param definition DefinitionInstance
        function STATIC.UnregisterDefinition( definition )
            typecheck.NotImplementedError()
        end
    end

    --[[ Definition Enumeration ]] do

        --- @overload fun( id: integer, type: IdType? ): DefinitionClass
        --- @overload fun(): DefinitionClass
        function STATIC.GetFirst( id, type )
            typecheck.NotImplementedError()
        end

        --- @overload fun( currDef: DefinitionClass, id: integer, type: IdType? ): DefinitionClass
        --- @overload fun( currDef: DefinitionClass ): DefinitionClass
        function STATIC.GetNext( currDef, id, type )
            typecheck.NotImplementedError()
        end
    end

    function STATIC.FreeDefinitions()
        STATIC.IdToDefinition = {}
        STATIC.NameToDefinition = {}
    end
end


--- @class DefinitionManagerInstance

function INSTANCE:Renegade_DefinitionManager()
    saveLoadSubSystemClass.Instance.Renegade_SaveLoadSubSystem( self )
end

--[[ From SaveLoadSubSystemClass ]] do

    --- @return integer
    function INSTANCE:ChunkId()
        return chunkIdEnum.CHUNKID_SAVELOAD_DEFMGR
    end

    --- @return boolean
    function INSTANCE:ContainsData()
        return true
    end

    --- @param csave ChunkSaveInstance
    --- @return boolean
    function INSTANCE:Save( csave )
        typecheck.NotImplementedError()
    end

    --- @param cload ChunkLoadInstance
    --- @return boolean
    function INSTANCE:Load( cload )
        local retVal = true

        section.Start( "Definition Manager Load" )
        while cload:OpenChunk() do
            local chunkId = cload:CurChunkId()

            if chunkId == STATIC.ChunkIds.CHUNKID_VARIABLES then
                retVal = retVal and self:LoadVariables( cload )
            elseif chunkId == STATIC.ChunkIds.CHUNKID_OBJECTS then
                retVal = retVal and self:LoadObjects( cload )
            end

            cload:CloseChunk()
        end
        section.End()

        return retVal
    end

    --- @return string
    function INSTANCE:Name()
        return "DefinitionMgrClass"
    end
end


--[[ Persistence Methods ]] do

    --- @param csave ChunkSaveInstance
    --- @return boolean
    function INSTANCE:SaveObjects( csave )
        typecheck.NotImplementedError()
    end

    --- @param cload ChunkLoadInstance
    --- @return boolean
    function INSTANCE:LoadObjects( cload )
        local retVal = true

        local loadedDefinitionCount = 0
        local chunkIdsWithoutFactories = {}

        section.Start( "Loading Definition Manager Objects" )
        while cload:OpenChunk() do
            -- "Load this definition from the chunk (if possible)"
            local factory = saveLoadSystemClass.FindPersistFactory( cload:CurChunkId() )
            -- section.Print( "Factory for Chunk ID ", cload:CurChunkId(), " is '", factory, "'" )

            if factory ~= nil then
                local definition = factory:Load( cload )
                loadedDefinitionCount = loadedDefinitionCount + 1
                if definition then

                    -- section.Print( "Loaded definition ID ", definition.Id, " for '", definition.Name, "'" )

                    -- "Add this definition to our array"
                    STATIC.IdToDefinition[definition:GetId()] = definition
                    STATIC.NameToDefinition[definition:GetName()] = definition
                end
            else
                chunkIdsWithoutFactories[cload:CurChunkId()] = true
            end

            cload:CloseChunk()
        end

        -- "Sort the definition"
        -- Omitted sorting definitions for now

        -- "Assign a mgr link to each definition"
        -- Omitted manager link for now

        section.End( "Loaded ", loadedDefinitionCount, " definitions" )

        section.Start( "Definition Chunk IDs without factories:" )
        for chunkId, _ in pairs( chunkIdsWithoutFactories ) do
            section.Print( chunkId )
        end
        section.End( table.Count( chunkIdsWithoutFactories ), " total missing factories" )

        return retVal
    end

    --- @param csave ChunkSaveInstance
    --- @return boolean
    function INSTANCE:SaveVariables( csave )
        typecheck.NotImplementedError()
    end

    --- @param cload ChunkLoadInstance
    --- @return boolean
    function INSTANCE:LoadVariables( cload )
        local retVal = true

        section.Start( "Loading Definition Manager Variables" )

        local microChunksSkipped = 0

        -- "Loop through all the microchunks that define the variables"
        while cload:OpenMicroChunk() do
            microChunksSkipped = microChunksSkipped + 1
            cload:CloseMicroChunk()
        end

        section.End( "(Fake) Loaded ", microChunksSkipped, " variable microchunks" )

        return retVal
    end
end