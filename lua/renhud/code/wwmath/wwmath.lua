-- Based on WWMath within Code/WWMath/wwmath.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of WWMath
    --- @class WWMath
    STATIC = CNC.CreateExport()
end


--[[ Static Functions and Variables ]] do
    local CLASS = "WWMath"

    --- [[ Public ]]

    --- @class WWMath

    STATIC.EPSILON  = 0.0001
    STATIC.EPSILON2 = STATIC.EPSILON * STATIC.EPSILON
    STATIC.PI       = 3.141592654
    STATIC.SQRT2    = 1.414213562
    STATIC.SQRT3    = 1.732050808
    STATIC.OOSQRT2  = 0.707106781
    STATIC.OOSQRT3  = 0.577350269

    --STATIC.FLOAT_MAX = (FLT_MAX)
    --STATIC.FLOAT_MIN = (FLT_MIN)
end