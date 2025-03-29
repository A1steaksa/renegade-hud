local customChecks = {
    ["rect"] = CNC_RENEGADE.Rect.IsRect,
    ["color"] = IsColor
}


---@param functionPath string
---@param argNumber integer
---@param expectedType string
---@param arg any
function typecheck( functionPath, argNumber, expectedType, arg )
    expectedType = string.lower( string.Trim( expectedType ) )
    local argType = string.lower( string.Trim( type(arg ) ) )

    local customCheck = customChecks[ expectedType ]

    local isCorrectType = false

    if customCheck then
        isCorrectType = customCheck( arg )
    else
        isCorrectType = argType == expectedType
    end

    if not isCorrectType then
        error( functionPath .. " argument " .. argNumber .. ": expected " .. expectedType .. " but got " .. type( arg ) )
    end
end