-- Based on TextureMapperClass within Code/ww3d2/mapper.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class TextureMapperClass
--- @field Instance TextureMapperInstance The metatable used by TextureMapperInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "TextureMapperClass"

--- @class TextureMapperInstance
--- @field Static TextureMapperClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_TextureMapper" )
INSTANCE.Class = "TextureMapperInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsTextureMapper = true

--#region Exported Enums

    --- @type EnumBuilderClass
    local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

    --- @enum MapperId
    STATIC.MAPPER_ID = {
        MAPPER_ID_UNKNOWN                  = enumBuilder:Set( 0 ),
        MAPPER_ID_LINEAR_OFFSET            = enumBuilder:Next(),
        MAPPER_ID_CLASSIC_ENVIRONMENT      = enumBuilder:Next(),
        MAPPER_ID_ENVIRONMENT              = enumBuilder:Next(),
        MAPPER_ID_SCREEN                   = enumBuilder:Next(),
        MAPPER_ID_ANIMATING_1D             = enumBuilder:Next(),
        MAPPER_ID_AXIAL                    = enumBuilder:Next(),
        MAPPER_ID_SILHOUETTE               = enumBuilder:Next(),
        MAPPER_ID_SCALE                    = enumBuilder:Next(),
        MAPPER_ID_GRID                     = enumBuilder:Next(),
        MAPPER_ID_ROTATE                   = enumBuilder:Next(),
        MAPPER_ID_SINE_LINEAR_OFFSET       = enumBuilder:Next(),
        MAPPER_ID_STEP_LINEAR_OFFSET       = enumBuilder:Next(),
        MAPPER_ID_ZIGZAG_LINEAR_OFFSET     = enumBuilder:Next(),
        MAPPER_ID_WS_CLASSIC_ENVIRONMENT   = enumBuilder:Next(),
        MAPPER_ID_WS_ENVIRONMENT           = enumBuilder:Next(),
        MAPPER_ID_GRID_CLASSIC_ENVIRONMENT = enumBuilder:Next(),
        MAPPER_ID_GRID_ENVIRONMENT         = enumBuilder:Next(),
        MAPPER_ID_RANDOM                   = enumBuilder:Next(),
        MAPPER_ID_EDGE                     = enumBuilder:Next(),
        MAPPER_ID_BUMPENV                  = enumBuilder:Next(),
    }
    local mapperIdEnum = STATIC.MAPPER_ID

--#endregion

--#region Imports

	--- @type MeshMaterialDescriptionClass
	local meshMaterialDescriptionClass = CNC.Import( "code/ww3d2/mesh-material-description.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class TextureMapperClass

    --- Creates a new TextureMapperInstance
    --- @param stage integer? [Default: 1]
    --- @overload fun( src: TextureMapperInstance )
    --- @return TextureMapperInstance
    function STATIC.New( stage )
        return robustclass.New( "Renegade_TextureMapper", stage )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) TextureMapperInstance, `false` otherwise
    function STATIC.IsTextureMapper( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsTextureMapper and true or false
    end

    typecheck.RegisterType( "TextureMapperInstance", STATIC.IsTextureMapper )
end


--- @class TextureMapperInstance
--- @field protected Stage integer

--- @param stage integer? [Default: 1]
--- @overload fun( src: TextureMapperInstance )
function INSTANCE:Renegade_TextureMapper( stage )
    if stage == nil then stage = 1 end
    typecheck.AssertArgType( self.Class, 1, stage, { "number", "TextureMapperInstance" } )

    -- ( stage: integer? )
    if typecheck.IsOfType( stage, "number" ) then
        self.Stage = stage --[[@as integer]]


        if self.Stage > meshMaterialDescriptionClass.MAX_TEX_STAGES then
            self.Stage = meshMaterialDescriptionClass.MAX_TEX_STAGES
        end

    -- ( src: TextureMapperInstance )
    else
        local src = stage --[[@as TextureMapperInstance]]

        self.Stage = src.Stage
    end

end

function INSTANCE:Reset()
    -- empty in the original code
end

--- @return TextureMapperInstance
function INSTANCE:Clone()
	CNC.VirtualFunction()
end

--- @return MapperId
function INSTANCE:MapperId()
	return mapperIdEnum.MAPPER_ID_UNKNOWN
end

--- @return boolean
function INSTANCE:IsTimeVariant()
	return false
end

--- @param uvArrayIndex integer
function INSTANCE:Apply( uvArrayIndex )
	CNC.VirtualFunction()
end

--- @return boolean
function INSTANCE:NeedsNormals()
	return false
end

--- @param stage integer
function INSTANCE:SetStage( stage )
	self.Stage = stage
end

--- @return integer
function INSTANCE:GetStage()
	return self.Stage
end
