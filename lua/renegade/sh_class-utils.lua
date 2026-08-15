--- @class Renegade
local CNC = CNC_RENEGADE

--- @class ClassUtils
local LIB = CNC.CreateExport()
LIB.Class = "ClassUtils"

-- #region Imports

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )
-- #endregion

-- #region Imported Enums
-- #endregion

--- A placeholder function to be used in place of a function body when declaring a virtual function that
--- should never be called directly and should instead always be overridden by child classes. 
function LIB.VirtualFunction()
    section.Error( "This function is virtual and should always be replaced" )
end
CNC.VirtualFunction = LIB.VirtualFunction

--- Creates an array of a given length where each index contains an instance of a given datatype initialized with no arguments sent to the constructor
--- @generic T
--- @param dataType `T`|FundamentalDataType
--- @param count integer
--- @return T[]
function LIB.InitializeTypeArray( dataType, count )
    local result = {}

    -- Classes
    if isstring( dataType ) then
        for index = 1, count do
            result[index] = robustclass.Create( dataType )
        end

    -- Fundamental data types
    else
        local defaultValue = deserializeLib.GetFundamentalDataTypeDefault( dataType )

        for index = 1, count do
            result[index] = defaultValue
        end
    end


    return result
end

--- Creates an array of a given length where each index contains the provided value.
--- @generic T
--- @param value T
--- @param count integer
--- @return T[]
function LIB.InitializeValueArray( value, count )
    local result = {}

    for index = 1, count do
        result[index] = value
    end

    return result
end

CNC.VirtualFunction = LIB.VirtualFunction