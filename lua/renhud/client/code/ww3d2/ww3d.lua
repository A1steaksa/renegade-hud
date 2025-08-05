-- Based on Code/ww3d2/ww3d.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--[[ Class Setup ]] do

    --- The static components of WW3d
    --- @class WW3d
    LIB = CNC.CreateExport()
end


--[[ Static Functions and Variables ]] do

    local CLASS = "Shader"

    --- [[ Public ]]

    --- @param isBiased boolean `true` if 2D rendering should be biased, `false` otherwise
    function LIB.SetScreenUvBias( isBiased )
        LIB._IsScreenUvBiased = isBiased
    end

    --- @return boolean `true` if 2D rendering should be biased, `false` otherwise
    function LIB.IsScreenUvBiased()
        return LIB._IsScreenUvBiased
    end
end