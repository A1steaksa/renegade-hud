-- Based on RenderInfoClass within Code/ww3d2/rinfo.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class RenderInfoClass
--- @field Instance RenderInfoInstance The metatable used by RenderInfoInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "RenderInfoClass"

--- @class RenderInfoInstance
--- @field Static RenderInfoClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_RenderInfo" )
INSTANCE.Class = "RenderInfoInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsRenderInfo = true

--#region Exported Enums
    --- @type EnumBuilderClass
    local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

    --- @enum RenderInfoOverrideFlags
    STATIC.RENDER_INFO_OVERRIDE_FLAGS = {
        RINFO_OVERRIDE_DEFAULT                = 0x0000, -- "No overrides"
        RINFO_OVERRIDE_FORCE_TWO_SIDED        = 0x0001, -- "Override mesh settings to force no backface culling"
        RINFO_OVERRIDE_FORCE_SORTING          = 0x0002, -- "Override mesh settings to force sorting"
        RINFO_OVERRIDE_ADDITIONAL_PASSES_ONLY = 0x0004,	-- "Do not render base passes (only additional passes)"
        RINFO_OVERRIDE_SHADOW_RENDERING       = 0x0008  -- "Hint: we are rendering a shadow"
    }
    local renderInfoOverrideFlagsEnum = STATIC.RENDER_INFO_OVERRIDE_FLAGS
--#endregion

--#region Imports

--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class RenderInfoClass

    --- Creates a new RenderInfoInstance
    --- @param camera CameraInstance
    --- @return RenderInfoInstance
    function STATIC.New( camera )
        return robustclass.New( "Renegade_RenderInfo", camera )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) RenderInfoInstance, `false` otherwise
    function STATIC.IsRenderInfo( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsRenderInfo and true or false
    end

    typecheck.RegisterType( "RenderInfoInstance", STATIC.IsRenderInfo )
end


--- @class RenderInfoInstance
--- @field Camera CameraInstance
--- @field FogScale number
--- @field FogStart number
--- @field FogEnd number
--- @field LightEnvironment LightEnvironmentInstance
--- @field AdditionalMaterialPassArray MaterialPassInstance
--- @field AdditionalMaterialPassCount UnsignedInstance
--- @field RejectedMaterialPasses UnsignedInstance
--- @field OverrideFlag RinfoOverrideFlagsInstance
--- @field OverrideFlagLevel UnsignedInstance

--- @param camera CameraInstance
function INSTANCE:Renegade_RenderInfo( camera )
    self.Camera   = camera
    self.FogStart = 0.0
    self.FogEnd   = 0.0
    self.FogScale = 0.0
    self.LightEnvironment = nil
    self.AdditionalMaterialPassCount = 0
    self.RejectedMaterialPasses = 0
    self.OverrideFlagLevel = 1

    self.OverrideFlag = {}

    -- "Need to have one entry in the override flags stack, initialize it to default values."
    self.OverrideFlag[self.OverrideFlagLevel] = renderInfoOverrideFlagsEnum.RINFO_OVERRIDE_DEFAULT
end

function INSTANCE:_Renegade_RenderInfo()
	typecheck.NotImplementedError()
end

function INSTANCE:PushMaterialPass()
	typecheck.NotImplementedError()
end

function INSTANCE:PopMaterialPass()
	typecheck.NotImplementedError()
end

function INSTANCE:AdditionalPassCount()
	typecheck.NotImplementedError()
end

function INSTANCE:PeekAdditionalPass()
	typecheck.NotImplementedError()
end

function INSTANCE:PushOverrideFlags()
	typecheck.NotImplementedError()
end

function INSTANCE:PopOverrideFlags()
	typecheck.NotImplementedError()
end

function INSTANCE:CurrentOverrideFlags()
	typecheck.NotImplementedError()
end
