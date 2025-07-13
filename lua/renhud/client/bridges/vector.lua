-- This file contains code to bridge the gap between Garry's Mod Vectors and C&C Renegade's concept of Vector3 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )

--- @class VectorBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )

--[[ Static Functions and Variables ]] do

    local CLASS = "VectorBridge"

    --- [[ Public ]]

    --- Sets each component of a Vector to the minimum value for that component between itself and another Vector
    --- @param toUpdate Vector
    --- @param other Vector
    function LIB.UpdateMin( toUpdate, other )
        if other.x < toUpdate.x then toUpdate.x = other.x end
        if other.y < toUpdate.y then toUpdate.y = other.y end
        if other.z < toUpdate.z then toUpdate.z = other.z end
    end

    --- Sets each component of a Vector to the maximum value for that component between itself and another Vector
    --- @param toUpdate Vector
    --- @param other Vector
    function LIB.UpdateMax( toUpdate, other )
        if other.x > toUpdate.x then toUpdate.x = other.x end
        if other.y > toUpdate.y then toUpdate.y = other.y end
        if other.z > toUpdate.z then toUpdate.z = other.z end
    end
end