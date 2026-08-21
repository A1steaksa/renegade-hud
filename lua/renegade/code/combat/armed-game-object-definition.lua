-- Based on ArmedGameObjDef within Code/Combat/armedgameobj.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

-- Parent Class
--- @type PhysicalGameObjectDefinitionClass
local physicalGameObjectDefinitionClass = CNC.Import( "code/combat/physical-game-object-definition.lua" )

--- @class ArmedGameObjectDefinitionClass : PhysicalGameObjectDefinitionClass
local STATIC = CNC.CreateExport( physicalGameObjectDefinitionClass )
STATIC.Class = "ArmedGameObjectDefinitionClass"
local isHotload = not table.IsEmpty( STATIC )

--- @class ArmedGameObjectDefinitionInstance : PhysicalGameObjectDefinitionInstance
local INSTANCE = robustclass.Register( "Renegade_ArmedGameObjectDefinition : Renegade_PhysicalGameObjectDefinition" )
INSTANCE.Class = "ArmedGameObjectDefinitionInstance"
INSTANCE.IsArmedGameObjectDefinitionClass = true
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC

--#region Exported Enums
--#endregion

--#region Imports

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )

	--- @type ChunkIOClass
	local chunkIOClass = CNC.Import( "code/wwlib/chunk-io.lua" )
--#endregion

--#region Imported Enums

	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
--#endregion


--[[ Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
        CHUNKID_DEF_PARENT                                  = enumBuilder:Set( 418001829 ),
        CHUNKID_DEF_VARIABLES                               = enumBuilder:Next(),

        MICROCHUNKID_DEF_WEAPON_TILT_RATE                   = enumBuilder:Set( 1 ),
        MICROCHUNKID_DEF_WEAPON_TILT_MIN                    = enumBuilder:Next(),
        MICROCHUNKID_DEF_WEAPON_TILT_MAX                    = enumBuilder:Next(),
        MICROCHUNKID_DEF_WEAPON_TURN_RATE                   = enumBuilder:Next(),
        MICROCHUNKID_DEF_WEAPON_TURN_MIN                    = enumBuilder:Next(),
        MICROCHUNKID_DEF_WEAPON_TURN_MAX                    = enumBuilder:Next(),
        XXXMICROCHUNKID_DEF_PRIMARY_ROUNDS                  = enumBuilder:Next(),
        XXXMICROCHUNKID_DEF_PRIMARY_AMMO_WEAPON_DEF_ID      = enumBuilder:Next(),
        XXXMICROCHUNKID_DEF_SECONDARY_AMMO_WEAPON_DEF_ID    = enumBuilder:Next(),
        XXXMICROCHUNKID_DEF_SECONDARY_ROUNDS                = enumBuilder:Next(),
        MICROCHUNKID_DEF_WEAPON_DEF_ID                      = enumBuilder:Next(),
        MICROCHUNKID_DEF_WEAPON_ROUNDS                      = enumBuilder:Next(),
        MICROCHUNKID_DEF_WEAPON_ERROR                       = enumBuilder:Next(),
        MICROCHUNKID_DEF_SECONDARY_WEAPON_DEF_ID            = enumBuilder:Next(),
    }
end


--[[ Static Functions and Variables ]] do

    --- @class ArmedGameObjectDefinitionClass

    --- Creates a new ArmedGameObjectDefinitionClass
    --- @vararg any
    --- @return ArmedGameObjectDefinitionClass
    function STATIC.New( ... )
        return robustclass.New( "Renegade_ArmedGameObjectDefinition", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) ArmedGameObjectDefinitionInstance, `false` otherwise
    function STATIC.IsArmedGameObjectDefinitionClass( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsArmedGameObjectDefinitionClass and true or false
    end

    typecheck.RegisterType( "ArmedGameObjectDefinitionInstance", STATIC.IsArmedGameObjectDefinitionClass )
end


--- @class ArmedGameObjectDefinitionInstance
--- @field WeaponTiltRate number
--- @field WeaponTiltMin number
--- @field WeaponTiltMax number
--- @field WeaponTurnRate number
--- @field WeaponTurnMin number
--- @field WeaponTurnMax number
--- @field WeaponError number
--- @field WeaponDefinitionId integer
--- @field SecondaryWeaponDefinitionId integer
--- @field WeaponRounds integer

--- Constructs a new ArmedGameObjectDefinitionInstance
function INSTANCE:Renegade_ArmedGameObjectDefinition()
    physicalGameObjectDefinitionClass.Instance.Renegade_PhysicalGameObjectDefinition( self )

    self.WeaponTiltRate = 1
    self.WeaponTiltMin = -10000.0
    self.WeaponTiltMax =  10000.0
    self.WeaponTurnRate = 1
    self.WeaponTurnMin = -10000.0
    self.WeaponTurnMax =  10000.0
    self.WeaponError = 0
    self.WeaponDefinitionId = 0
    self.SecondaryWeaponDefinitionId = 0
    self.WeaponRounds = -1
end

--- @param cload ChunkLoadInstance
--- @return boolean true
function INSTANCE:Load( cload )
    local ids = STATIC.ChunkIds

    while cload:OpenChunk() do
        local chunkId = cload:CurChunkId()

        if chunkId == STATIC.ChunkIds.CHUNKID_DEF_PARENT then
            physicalGameObjectDefinitionClass.Instance.Load( self, cload )
        elseif chunkId == STATIC.ChunkIds.CHUNKID_DEF_VARIABLES then
            while cload:OpenMicroChunk() do
                local didRead =
                    chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_TILT_RATE, fundamentalDataTypeEnum.Float, self, "WeaponTiltRate" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_TILT_MIN, fundamentalDataTypeEnum.Float, self, "WeaponTiltMin" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_TILT_MAX, fundamentalDataTypeEnum.Float, self, "WeaponTiltMax" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_TURN_RATE, fundamentalDataTypeEnum.Float, self, "WeaponTurnRate" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_TURN_MIN, fundamentalDataTypeEnum.Float, self, "WeaponTurnMin" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_TURN_MAX, fundamentalDataTypeEnum.Float, self, "WeaponTurnMax" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_DEF_ID, fundamentalDataTypeEnum.Int, self, "WeaponDefID" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_SECONDARY_WEAPON_DEF_ID, fundamentalDataTypeEnum.Int, self, "SecondaryWeaponDefID" )
                    or chunkIOClass.ReadSafeMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_ROUNDS, fundamentalDataTypeEnum.Int, self, "WeaponRounds" )
                    or chunkIOClass.ReadMicroChunk( cload, ids.MICROCHUNKID_DEF_WEAPON_ERROR, fundamentalDataTypeEnum.Float, self, "WeaponError" )

                if not didRead then
                    section.Print( "Unrecognized ", INSTANCE.Class, " Variable Chunk ID", cload:CurMicroChunkId() )
                end

                cload:CloseMicroChunk()
            end
        else
            section.Print( "Unrecognized ", INSTANCE.Class, " Chunk ID", cload:CurChunkId() )
        end

        cload:CloseChunk()
    end

    return true
end