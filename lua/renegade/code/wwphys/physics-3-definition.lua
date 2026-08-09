-- Based on Phys3DefClass within Code/wwphys/phys3.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type MoveablePhysicsDefinitionClass
local moveablePhysicsDefinitionClass = CNC.Import( "code/wwphys/moveable-physics-definition.lua" )

--- @class Physics3DefinitionClass : MoveablePhysicsDefinitionClass
--- @field Instance Physics3DefinitionInstance The metatable used by Physics3DefinitionInstance
local STATIC = CNC.CreateExport( moveablePhysicsDefinitionClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "Physics3DefinitionClass"

--- @class Physics3DefinitionInstance : MoveablePhysicsDefinitionInstance
--- @field Static Physics3DefinitionClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Physics3Definition : Renegade_MoveablePhysicsDefinition" )
INSTANCE.Class = "Physics3DefinitionInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsPhysics3Def = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	--- @type ChunkIOClass
	local chunkIOClass = CNC.Import( "code/wwlib/chunk-io.lua" )

	--- @type SimplePersistFactoryClass
	local simplePersistFactoryClass = CNC.Import( "code/wwsaveload/simple-persist-factory.lua" )

	--- @type WWPhysicsIds
	local wWPhysicsIds = CNC.Import( "code/wwphys/ww-physics-ids.lua" )

    --- @type Physics3Class
    local physics3Class = CNC.Import( "code/wwphys/physics-3.lua" )

    --- @type DeserializeLib
    local deserializeLib = CNC.Import( "sh_deserialize.lua" )
--#endregion

--#region Imported Enums

	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
	local wWPhysicsFactoryIdEnum = wWPhysicsIds.WW_PHYSICS_FACTORY_ID
    local wWPhysicsDefinitionIdEnum = wWPhysicsIds.WW_PHYSICS_DEFINITION_ID
--#endregion


--[[ Chunk IDs ]] do

    local enumBuilder = enumBuilderClass.New()

    STATIC.ChunkIds = {
        PHYS3DEF_CHUNK_MOVEABLEPHYSDEF = enumBuilder:Set( 0x04486000 ), -- "(parent class)"
        PHYS3DEF_CHUNK_VARIABLES       = enumBuilder:Next(),

        PHYS3DEF_VARIABLE_NORMSPEED  = enumBuilder:Set( 0x00 ),
        PHYS3DEF_VARIABLE_SLIDEANGLE = enumBuilder:Next(),
        PHYS3DEF_VARIABLE_STEPHEIGHT = enumBuilder:Next(),
    }
end

--[[ Static Functions and Variables ]] do

    --- "Initialization/Game-Database support for [Physics3Class]"
    --- @class Physics3DefinitionClass

    --- Creates a new Physics3DefinitionInstance
    --- @return Physics3DefinitionInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Physics3Definition" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Physics3DefinitionInstance, `false` otherwise
    function STATIC.IsPhysics3Definition( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPhysics3Def and true or false
    end

    typecheck.RegisterType( "Physics3DefinitionInstance", STATIC.IsPhysics3Definition )

    function STATIC.StaticConstructor()
        STATIC.Physics3DefinitionFactory = simplePersistFactoryClass.New( STATIC, wWPhysicsFactoryIdEnum.PHYSICS_CHUNKID_PHYS3DEF )
    end
end

--- @class Physics3DefinitionInstance
--- @field NormalizedSpeed number "Speed to move when controller is at 1.0"
--- @field SlideAngle number "Slope angle at which this object slides off"
--- @field StepHeight number "Step [size] that this object will hop over"

function INSTANCE:Renegade_Physics3Definition()
    moveablePhysicsDefinitionClass.Instance.Renegade_MoveablePhysicsDefinition( self )

    self.NormalizedSpeed = physics3Class.DEFAULT_NORMALIZED_SPEED
    self.SlideAngle = physics3Class.DEFAULT_SLIDE_ANGLE
    self.StepHeight = physics3Class.DEFAULT_STEP_HEIGHT
end

--- @return WWPhysicsDefinitionId
function INSTANCE:GetClassId()
    return wWPhysicsDefinitionIdEnum.CLASSID_PHYS3DEF
end

--- @param connectedEntity Entity
--- @return PersistInstance
function INSTANCE:Create( connectedEntity )
    local object = physics3Class.New()
    object:Init( self, connectedEntity )
    return object
end

--[[ From [PhysicsDefinitionInstance] ]] do

    --- @return string
    function INSTANCE:GetTypeName()
        return "Phys3Def"
    end

    --- @param typeName string
    --- @return boolean
    function INSTANCE:IsType( typeName )
        if self:GetTypeName():lower() == typeName:lower() then
            return true
        else
            return moveablePhysicsDefinitionClass.Instance.IsType( self, typeName )
        end
    end
end


--[[ From [PersistInstance] ]] do

    --- @return PersistFactoryInstance
    function INSTANCE:GetFactory()
        return STATIC.Physics3DefinitionFactory
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
            if chunkId == ids.PHYS3DEF_CHUNK_MOVEABLEPHYSDEF then
                moveablePhysicsDefinitionClass.Instance.Load( self, cload )

            elseif chunkId == ids.PHYS3DEF_CHUNK_VARIABLES then
                while cload:OpenMicroChunk() do
                    local didRead = (
                           chunkIOClass.ReadMicroChunk( cload, ids.PHYS3DEF_VARIABLE_NORMSPEED,  fundamentalDataTypeEnum.Float, self, "NormSpeed" )
                        or chunkIOClass.ReadMicroChunk( cload, ids.PHYS3DEF_VARIABLE_SLIDEANGLE, fundamentalDataTypeEnum.Float, self, "SlideAngle" )
                        or chunkIOClass.ReadMicroChunk( cload, ids.PHYS3DEF_VARIABLE_STEPHEIGHT, fundamentalDataTypeEnum.Float, self, "StepHeight" )
                    )

                    if not didRead then
                        section.Warn( "Unhandled ", INSTANCE.Class, " Micro Chunk ID: ", cload:CurMicroChunkId() )
                    end

                    cload:CloseMicroChunk()
                end
            else
                section.Warn( "Unhandled ", INSTANCE.Class, " Chunk ID: ", chunkId )
            end

            cload:CloseChunk()
        end

        return true
    end
end
