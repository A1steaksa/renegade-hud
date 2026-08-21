-- Based on ControlClass within Code/Combat/control.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class ControlClass
--- @field Instance ControlInstance The metatable used by ControlInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "ControlClass"

--- @class ControlInstance
--- @field Static ControlClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Control" )
INSTANCE.Class = "ControlInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsControl = true

--#region Exported Enums

    --- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

	--- @enum AnalogControl
	STATIC.ANALOG_CONTROL = {
		ANALOG_MOVE_FORWARD  = enumBuilder:Set( 0 ),
		ANALOG_MOVE_LEFT     = enumBuilder:Next(),
		ANALOG_MOVE_UP       = enumBuilder:Next(),
		ANALOG_TURN_LEFT     = enumBuilder:Next(),
		ANALOG_CONTROL_COUNT = enumBuilder:Next(),
	}
    local analogControlEnum = STATIC.ANALOG_CONTROL

--#endregion

--#region Imports

	--- @type ClassUtils
	local classUtils = CNC.Import( "sh_class-utils.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class ControlClass

    --- Creates a new ControlInstance
    --- @return ControlInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Control" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) ControlInstance, `false` otherwise
    function STATIC.IsControl( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsControl and true or false
    end

    typecheck.RegisterType( "ControlInstance", STATIC.IsControl )

	function STATIC.SetPrecision()
		typecheck.NotImplementedError()
	end
end


--- @class ControlInstance
--- @field OneTimeBooleanBits integer
--- @field PendingOneTimeBooleanBits integer
--- @field ContinuousBooleanBits integer
--- @field PendingContinuousBooleanBits integer
--- @field AnalogValues number[]

function INSTANCE:Renegade_Control()
	self.PendingOneTimeBooleanBits = 0
	self:ClearControl()
end

function INSTANCE:_Renegade_Control()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:ClearControl()
	self.OneTimeBooleanBits = 0
	self.ContinuousBooleanBits = 0
	self.AnalogValues = classUtils.InitializeValueArray( 0, analogControlEnum.ANALOG_CONTROL_COUNT )
end

function INSTANCE:ClearBoolean()
	typecheck.NotImplementedError()
end

function INSTANCE:SetBoolean()
	typecheck.NotImplementedError()
end

function INSTANCE:GetBoolean()
	typecheck.NotImplementedError()
end

function INSTANCE:ClearOneTimeBoolean()
    self.OneTimeBooleanBits = 0
end

function INSTANCE:GetOneTimeBooleanBits()
	typecheck.NotImplementedError()
end

function INSTANCE:GetContinuousBooleanBits()
	typecheck.NotImplementedError()
end

function INSTANCE:SetAnalog()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAnalog()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportCs()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportCs()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportSc()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportSc()
	typecheck.NotImplementedError()
end
