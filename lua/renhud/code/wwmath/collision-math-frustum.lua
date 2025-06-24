-- Based on CollisionMath within Code/WWMath/colmathfrustum.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- @class CollisionMath
    STATIC = CNC.Import( "renhud/code/wwmath/collision-math.lua" )
end

--#region Enums

    local overlapType = STATIC.OVERLAP_TYPE
--#endregion


--[[ Static Functions and Variables ]] do
    local CLASS = "CollisionMath"

    local COLLISION_EPSILON = 0.001

    --- [[ Public ]]

    --- @class CollisionMath

    --- @param frustum FrustumInstance
    --- @param box AABoxInstance
    STATIC.AddOverlapTest( "FrustumInstance", "AABoxInstance", function( frustum, box )
        local mask = 0

        for i = 0, 5 do
            local plane = frustum.Planes[i]

            local result = STATIC.OverlapTest( plane, box )
            if result == overlapType.OUTSIDE then
                return overlapType.OUTSIDE
            end
            mask = bit.bor( mask, result )
        end

        if mask == overlapType.INSIDE then
            return overlapType.INSIDE
        end

        return overlapType.OVERLAPPED
    end )

end