-- A library for data type validation and error reporting

--- @class TypeCheck
local LIB

--[[ Library Setup ]] do

    if typecheck then
        LIB = getmetatable( typecheck )
    else
        LIB = {}
        LIB.__index = LIB

        typecheck = setmetatable( {}, LIB )
    end

    LIB.ProjectName = "C&C Renegade"
end


--[[ Static Functions and Variables ]] do

    local CLASS = "typecheck"

    --- [[ Public ]]

    LIB.ErrorTextColor = Color( 240, 240, 240 )
    LIB.ErrorPrefixColor = Color( 220, 0, 0 )

    --[[ Type Registration ]] do

        --- A registered data type
        --- @class CustomType
        --- @field TypeName string
        --- @field CheckFunction fun( arg: any ): boolean

        --- @type table<string, CustomType> Key: Type Name, Value: Type Data
        LIB.CustomTypes = LIB.CustomTypes or {}

        --- @param typeName string The name of the type being registered. This will be the type name used when checking types. Case insensitive.
        --- @param checkFunction fun( arg: any ): boolean
        function LIB.RegisterType( typeName, checkFunction )
            typeName = string.lower( typeName ):Trim()

            typecheck.CustomTypes[ typeName ] = {
                TypeName = typeName,
                CheckFunction = checkFunction
            }
        end

        -- Register built-in type checks
        LIB.RegisterType( "Color", IsColor )
    end


    --[[ Validation Functions ]] do

        --- Determines if a given value is of a given type or types
        --- @param valueToCheck any
        --- @param expectedTypes string|string[]
        function LIB.IsOfType( valueToCheck, expectedTypes )
            expectedTypes = LIB.EnsureStringTable( expectedTypes )

            local valueType = type( valueToCheck ):lower():Trim()

            for _, expectedType in ipairs( expectedTypes ) do
                local customType = LIB.CustomTypes[ expectedType ]

                local isCorrectType = false
                if customType then
                    -- If a custom data type has been registered with this type name, use the custom type's check function
                    -- to validate whether the argument is actually this type.
                    isCorrectType = customType.CheckFunction( valueToCheck )
                else
                    -- If no custom check has been registered, compare the data type strings directly
                    isCorrectType = valueType == expectedType
                end

                -- Stop checking if we found a correct type
                if isCorrectType then
                    return true
                end
            end

            return false
        end

        --- Throws an error if the number of arguments passed in does not match an expected number of arguments
        --- @param className string
        --- @param argNumber integer
        --- @param arg any
        --- @param expectedArgTypes string|string[]
        function LIB.AssertArgType( className, argNumber, arg, expectedArgTypes )
            local functionName = LIB.GetCallerFunctionName()

            local expectedTypes = LIB.EnsureStringTable( expectedArgTypes )
            expectedTypes = LIB.CleanStrings( expectedTypes )

            if not LIB.IsOfType( arg, expectedTypes ) then
                LIB.ArgumentTypeError( className, functionName, argNumber, LIB.GetType( arg ), expectedTypes  )
            end
        end

        --- Throws an error with the number of arguments a function received
        --- @param className string
        --- @param argCount integer
        --- @param expectedArgCounts integer|integer[]? The expected argument count or a sequential table of the expected argument counts.  If omitted, the argument count will be assumed to be incorrect.
        function LIB.AssertArgCount( className, argCount, expectedArgCounts )
            local functionName = LIB.GetCallerFunctionName()

            if not expectedArgCounts then
                LIB.Error( className, functionName, "received an invalid number of arguments (" .. argCount .. ")" )
                return
            end

            -- If a single expected arg count was passed, convert it to a table 
            if isnumber( expectedArgCounts ) then
                expectedArgCounts = { expectedArgCounts --[[@as integer]] }
            end

            -- If the actual arg count doesn't match one of the expected ones, throw an error
            --- @cast expectedArgCounts integer[]
            local isValidArgCount = table.HasValue( expectedArgCounts, argCount )
            if not isValidArgCount then
                -- Variable naming hell
                local expectedArgCountCount = #expectedArgCounts

                local expectedString
                if expectedArgCountCount == 1 then
                    expectedString = expectedArgCounts[1]
                elseif expectedArgCountCount == 2 then
                    expectedString = "either " .. expectedArgCounts[1] .. " or " .. expectedArgCounts[2]
                else
                    expectedString = table.concat( expectedArgCounts, ", ", 1, expectedArgCountCount - 1 )
                    expectedString = expectedString .. ", or " .. expectedArgCounts[ expectedArgCountCount ]
                end

                LIB.Error( className, functionName, "received an invalid number of arguments. Expected " .. expectedString .. " but got " .. argCount )
            end
        end
    end


    --[[ Error Messages ]] do

        --- Throws an error
        --- @param className string
        --- @param functionName string? [Default: Constructor]
        --- @param message any This will be converted to a string
        function LIB.Error( className, functionName, message )
            if not functionName then
                functionName = "Constructor"
            end

            local prefix = "ERROR: " .. LIB.ProjectName .. ":" .. className .. ":" .. functionName .. "():"

            local errorMessage = tostring( message )

            MsgC( LIB.ErrorPrefixColor, prefix, LIB.ErrorTextColor, " " .. errorMessage )
            error( "" )
        end

        --- Throws an error about a specific argument number
        --- @param className string
        --- @param functionName string? [Default: Constructor]
        --- @param message any This will be converted to a string
        function LIB.ArgumentError( className, functionName, argumentNumber, message )
            LIB.Error( className, functionName, "Argument " .. argumentNumber .. ": " .. tostring( message ) )
        end

        --- Throws an error 
        --- @param className string
        --- @param functionName string? [Default: Constructor]
        --- @param argNumber integer
        --- @param argType string
        --- @param expectedTypes string|string[]
        function LIB.ArgumentTypeError( className, functionName, argNumber, argType, expectedTypes )
            expectedTypes = LIB.EnsureStringTable( expectedTypes )

            local expectedString
            local expectedArgumentTypeCount = #expectedTypes
            if expectedArgumentTypeCount == 1 then
                expectedString = expectedTypes[1]
            elseif expectedArgumentTypeCount == 2 then
                expectedString = "either " .. expectedTypes[1] .. " or " .. expectedTypes[2]
            else
                expectedString = table.concat( expectedTypes, ", ", 1, expectedArgumentTypeCount - 1 )
                expectedString = expectedString .. ", or " .. expectedTypes[ expectedArgumentTypeCount ]
            end

            local errorMessage = "Incorrect type. Expected " .. expectedString .. " but got " .. argType

            LIB.ArgumentError( className, functionName, argNumber, errorMessage )
        end

        --- Throws an error stating that the function or code path has not been implemented
        ---@param className string
        ---@param codePathName string? (Optional) The specific path within the function that has not been implemented
        function LIB.NotImplementedError( className, codePathName )
            local errorMessage = "Function is not yet implemented"
            if codePathName then
                errorMessage = codePathName .. " is not yet implemented"
            end

            local functionName = LIB.GetCallerFunctionName()

            LIB.Error( className, functionName, errorMessage )
        end
    end


    --- [[ Private ]]

    --[[ Utility Functions ]] do

        --- @return string # The name of the function that called whichever function calls this function.
        function LIB.GetCallerFunctionName()
            local info = debug.getinfo( 3 )
            local functionName = info.name

            if functionName == "ConstructorForemost" then
                functionName = "Constructor"
            end

            return functionName
        end

        --- @param value any
        function LIB.GetType( value )
            -- Anything other than a table can be returned immediately
            local baseType = LIB.CleanString( type( value ) )
            if baseType ~= "table" then
                return baseType
            end

            -- Tables can be custom types so we need to pass it through each custom check function
            -- to see if it's a table or a custom type
            for typeName, typeData in pairs( LIB.CustomTypes ) do
                if typeData.CheckFunction( value ) then
                    return typeName
                end
            end

            -- If none of the custom types matched, it's just a normal table
            return "table"
        end

        --- Trims and lowercases an array of strings
        --- @param strings string[]
        --- @return string[]
        --- @private
        function LIB.CleanStrings( strings )
            local results = {}
            for index = 1, #strings do
                results[index] = LIB.CleanString( strings[index] )
            end

            return results
        end

        --- Trims and lowercases a given string
        --- @param str string
        function LIB.CleanString( str )
            return str:lower():Trim()
        end

        --- If the passed value is not a sequential table of strings, it is placed into a table
        --- @param value string|string[]
        --- @return string[] # The initial value or the initial value within a new sequential table
        --- @private
        function LIB.EnsureStringTable( value )
            if isstring( value ) then
                return { value --[[@as string]] }
            elseif istable( value ) then
                --- @cast value string[]

                -- Determine if the table value is a correctly formatted sequential table of strings
                if table.IsSequential( value ) then
                    local sequentialEntryCount = #value
                    if sequentialEntryCount > 0 then
                        if isstring( value[1] ) then
                            return value
                        else
                            typecheck.ArgumentTypeError( CLASS, "EnsureStringTable", 1, type( value[1] ) .. "[]", { "string", "string[]" } )
                            return {} -- To make LuaLS happy
                        end
                    else
                        -- An empty table is considered a string table I guess
                        return value
                    end
                else
                    typecheck.ArgumentError( CLASS, "EnsureStringTable", 1, "Table is not sequential" )
                    return {} -- To make LuaLS happy
                end

            else
                typecheck.ArgumentTypeError( CLASS, "EnsureStringTable", 1, type(value), { "string", "string[]" } )
                return {} -- To make LuaLS happy
            end
        end
    end
end