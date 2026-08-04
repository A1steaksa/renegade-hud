-- A library to make it easy to convert byte strings into various data types and structs containing those data types

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class DeserializeLib
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "DeserializeLib"

--#region Exported Enums

    --- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

    --- @enum FundamentalDataType
    STATIC.FUNDAMENTAL_DATA_TYPE = {
        UInt32  = enumBuilder:Set( 1 ),
        UInt16  = enumBuilder:Next(),
        UInt8   = enumBuilder:Next(),
        Int     = enumBuilder:Next(),
        Float   = enumBuilder:Next(),
        Float32 = enumBuilder:Next(),
        Boolean = enumBuilder:Next(),
        String  = enumBuilder:Next(),
        Pointer = enumBuilder:Next(),
    }
    local fundamentalDataTypeEnum = STATIC.FUNDAMENTAL_DATA_TYPE
--#endregion


--#region Imports

	--- @type TextUtils
	local textUtils = CNC.Import( "sh_text-utils.lua" )
--#endregion


--#region Imported Enums
--#endregion


--- @class FundamentalDataTypeInfo
--- @field Name string The pretty, print-able name of this data type
--- @field DataType FundamentalDataType 
--- @field DefaultValue any What the default state of this data type is when initialized without a specific value
--- @field Size integer The number of bytes this data type takes up
--- @field ConversionFunction fun( bytes: string ): any

--- @class ComplexDataTypeInfo
--- @field Name string The name that will be used to reference to this data type
--- @field Schema ComplexDataTypeSchema The layout of the complex data type
--- @field Size integer The size, in bytes, of this data type

--- A schema is simply an ordered list of fields
--- @alias ComplexDataTypeSchema ComplexDataTypeSchemaField[]

--- @class ComplexDataTypeSchemaField
--- @field Name string The key that this field will be stored under
--- @field Type string|FundamentalDataType Either the name of a complex data type or a fundamental data type enum
--- @field Size integer? (Optional) The number of bytes this field consumes if the data type isn't fixed-length
--- @field ArrayLength integer? (Optional) Makes this field into an array if set

--- @class DeserializeLib

--- @type table<FundamentalDataType, FundamentalDataTypeInfo>
STATIC.FundamentalDataTypeRegistry = {}

--- @type table<string, ComplexDataTypeInfo>
STATIC.ComplexDataTypeRegistry = {}


function STATIC.StaticConstructor()
    STATIC.RegisterFundamentalDataType( "UInt32",  fundamentalDataTypeEnum.UInt32,      0, 4,  STATIC.DeserializeUInt32  )
    STATIC.RegisterFundamentalDataType( "UInt16",  fundamentalDataTypeEnum.UInt16,      0, 2,  STATIC.DeserializeUInt16  )
    STATIC.RegisterFundamentalDataType( "UInt8",   fundamentalDataTypeEnum.UInt8,       0, 1,  STATIC.DeserializeUInt8   )
    STATIC.RegisterFundamentalDataType( "Int",     fundamentalDataTypeEnum.Int,         0, 4,  STATIC.DeserializeUInt32  )
    STATIC.RegisterFundamentalDataType( "Float",   fundamentalDataTypeEnum.Float,     0.0, 4,  STATIC.DeserializeFloat   )
    STATIC.RegisterFundamentalDataType( "Float32", fundamentalDataTypeEnum.Float32,   0.0, 4,  STATIC.DeserializeFloat   )
    STATIC.RegisterFundamentalDataType( "Boolean", fundamentalDataTypeEnum.Boolean, false, 1,  STATIC.DeserializeBoolean )
    STATIC.RegisterFundamentalDataType( "Pointer", fundamentalDataTypeEnum.Pointer,   nil, 8,  STATIC.DeserializePointer )

    STATIC.RegisterComplexDataType( "Vector", {
        { Name = "X", Type = fundamentalDataTypeEnum.Float },
        { Name = "Y", Type = fundamentalDataTypeEnum.Float },
        { Name = "Z", Type = fundamentalDataTypeEnum.Float },
    } )
end


--[[ Registration ]] do

    --- @param name string
    --- @param dataType FundamentalDataType
    --- @param defaultValue any
    --- @param size integer
    --- @param conversionFunction fun( bytes: string ): any
    function STATIC.RegisterFundamentalDataType( name, dataType, defaultValue, size, conversionFunction )
        STATIC.FundamentalDataTypeRegistry[dataType] = {
            Name               = name,
            DataType           = dataType,
            Size               = size,
            DefaultValue       = defaultValue,
            ConversionFunction = conversionFunction
        }
    end

    --- @param name string
    --- @param schema ComplexDataTypeSchema
    function STATIC.RegisterComplexDataType( name, schema )
        -- Calculate the size of this complex data type
        local size = 0
        for _, schemaEntry in ipairs( schema ) do
            if schemaEntry.Type == fundamentalDataTypeEnum.String then
                size = size + schemaEntry.Size
                continue
            end

            -- Account for arrays
            local countMultiplier = schemaEntry.ArrayLength or 1
            local dataTypeSize = STATIC.GetDataTypeSize( schemaEntry.Type )
            local totalFieldSize = dataTypeSize * countMultiplier

            size = size + totalFieldSize
        end

        STATIC.ComplexDataTypeRegistry[name] = {
            Name     = name,
            Schema   = schema,
            Size     = size
        }
    end
end


--[[ Accessors ]] do

    --- @param dataType any
    --- @return boolean
    function STATIC.IsFundamentalDataType( dataType )
        return STATIC.FundamentalDataTypeRegistry[dataType] ~= nil
    end

    --- @param dataType any
    --- @return boolean
    function STATIC.IsComplexDataType( dataType )
        return STATIC.ComplexDataTypeRegistry[dataType] ~= nil
    end

    --- @param dataType FundamentalDataType|string
    --- @return integer
    function STATIC.GetDataTypeSize( dataType )
        if STATIC.IsFundamentalDataType( dataType ) then
            return STATIC.GetFundamentalDataTypeSize( dataType --[[@as FundamentalDataType]] )
        elseif STATIC.IsComplexDataType( dataType ) then
            return STATIC.GetComplexDataTypeSize( dataType --[[@as string]] )
        end

        section.Error( "Unable to get size of datatype '", dataType, "' which is neither a registered fundamental or complex data type" )
        return -1
    end

    --- @param dataType FundamentalDataType
    --- @return integer
    function STATIC.GetFundamentalDataTypeSize( dataType )
        local registerEntry = STATIC.FundamentalDataTypeRegistry[dataType]
        if registerEntry == nil then
            section.Error( "The provided data type '", dataType, "' is not a registered fundamental data type" )
            return -1
        end

        return registerEntry.Size
    end

    --- @param dataType FundamentalDataType
    --- @return any
    function STATIC.GetFundamentalDataTypeDefault( dataType )
        return STATIC.FundamentalDataTypeRegistry[dataType].DefaultValue
    end

    --- @param dataType string
    --- @return integer
    function STATIC.GetComplexDataTypeSize( dataType )
        local registerEntry = STATIC.ComplexDataTypeRegistry[dataType]
        if registerEntry == nil then
            section.Error( "The provided data type '", dataType, "' is not a registered complex data type" )
            return -1
        end

        return registerEntry.Size
    end
end


--[[ Deserializers ]] do

    -- Credit for the original parsing code goes to:
    -- ----------------------------------------------------------------------------
    -- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
    -- notice, you can do whatever you want with this stuff. If we
    -- meet someday, and you think this stuff is worth it, you can
    -- buy me a beer in return.
    -- ----------------------------------------------------------------------------

    --- @param dataType FundamentalDataType|string
    --- @param bytes string
    --- @return any
    function STATIC.Deserialize( dataType, bytes )
        -- Strings get special handling
        if dataType == fundamentalDataTypeEnum.String then
            -- If there's a null byte in the string, treat that as the end of the string
            local nullIndex = textUtils.IndexOf( bytes, "\0" )
            if nullIndex ~= nil then
                return bytes:sub( 0, nullIndex - 1 )
            end

            return bytes
        end

        if STATIC.IsFundamentalDataType( dataType ) then
            return STATIC.DeserializeFundamentalDataType( dataType --[[@as FundamentalDataType]], bytes )
        elseif STATIC.IsComplexDataType( dataType ) then
            return STATIC.DeserializeComplexDataType( dataType --[[@as string]], bytes )
        end

        section.Error( "Unable to deserialize datatype '", dataType, "' which is neither a registered fundamental or complex data type" )
    end

    --- @param dataType string
    --- @param bytes string
    --- @return any
    function STATIC.DeserializeComplexDataType( dataType, bytes )
        local registeryEntry = STATIC.ComplexDataTypeRegistry[dataType]
        if registeryEntry == nil then
            section.Error( "The provided data type '", dataType, "' is not a registered complex data type" )
            return
        end

        local result = {}

        local schema = registeryEntry.Schema
        for _, field in ipairs( schema ) do
            local isArray = ( field.ArrayLength ~= nil )
            local isfundamentalDataType = isnumber( field.Type )
            -- Figure out how many bytes each of this data type takes up
            local bytesToRead
            if field.Type == fundamentalDataTypeEnum.String then
                bytesToRead = field.Size
            elseif isfundamentalDataType then
                bytesToRead = STATIC.GetFundamentalDataTypeSize( field.Type --[[@as FundamentalDataType]] )
            else
                bytesToRead = STATIC.GetComplexDataTypeSize( field.Type --[[@as string]] )
            end

            if isArray then
                local fieldArray = {}
                result[field.Name] = fieldArray

                -- Deserialize each element of the array
                for i = 1, field.ArrayLength do
                    -- Get this array element's bytes
                    local extractedBytes = bytes:sub( 1, bytesToRead )
                    bytes = bytes:sub( bytesToRead + 1)

                    fieldArray[i] = STATIC.Deserialize( field.Type, extractedBytes )
                end
            else
                -- Get this field's bytes
                local extractedBytes = bytes:sub( 1, bytesToRead )
                bytes = bytes:sub( bytesToRead + 1 )
                if extractedBytes:len() ~= bytesToRead then
                    section.Error( "Tried to extract ", bytesToRead, " bytes but got ", extractedBytes:len(), " bytes instead" )
                end

                result[field.Name] = STATIC.Deserialize( field.Type, extractedBytes )
            end
        end

        return result
    end

    --- @param dataType FundamentalDataType
    --- @param bytes string
    --- @return any
    function STATIC.DeserializeFundamentalDataType( dataType, bytes )
        local registeryEntry = STATIC.FundamentalDataTypeRegistry[dataType]
        if registeryEntry == nil then
            section.Error( "The provided data type '", dataType, "' is not a registered fundamental data type" )
            return
        end

        return registeryEntry.ConversionFunction( bytes )
    end

    --- @param bytes string
    --- @return integer
    function STATIC.DeserializeUInt32( bytes )
        local b1, b2, b3, b4 = bytes:byte( 1, 4 )
        return (
            b4 * 0x1000000 +
			b3 * 0x10000 +
			b2 * 0x100 +
			b1
        )
    end

    --- @param bytes string
    --- @return integer
    function STATIC.DeserializeUInt16( bytes )
        local b1, b2 = bytes:byte( 1, 2 )
        return (
			b2 * 0x100 +
			b1
        )
    end

    --- @param bytes string
    --- @return integer
    function STATIC.DeserializePointer( bytes )
        local b1, b2, b3, b4, b5, b6, b7, b8 = bytes:byte( 1, 8 )
        return (
            b8 * 0x100000000000000 +
            b7 * 0x1000000000000 +
            b6 * 0x10000000000 +
            b5 * 0x100000000 +
            b4 * 0x1000000 +
			b3 * 0x10000 +
			b2 * 0x100 +
			b1
        )
    end

    --- @param bytes string
    --- @return integer
    function STATIC.DeserializeUInt8( bytes )
        return bytes:byte( 1 )
    end

    --- @param bytes string
    --- @return number
    function STATIC.DeserializeFloat( bytes )
        local b4, b3, b2, b1 = bytes:byte( 1, 4 )

        local sign = ( b1 > 128 and -1 ) or 1
        local mantissa = b2 % 0x80 * 0x10000 + b3 * 0x100 + b4
        local exp = math.floor( ( ( b1 % 128 ) * 0x100 + b2 ) / 0x80 ) - 127
        local convertedNumber = 2 ^ exp * ( mantissa / 0x800000 + 1 )
        local result = sign * convertedNumber

        return math.IsNearlyEqual( result, 0, 0.0000001 ) and 0 or result
    end

    --- @param bytes string
    --- @return boolean
    function STATIC.DeserializeBoolean( bytes )
        return STATIC.DeserializeUInt8( bytes ) == 1
    end
end

