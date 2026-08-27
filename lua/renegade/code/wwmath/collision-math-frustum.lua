-- Based on CollisionMath within Code/WWMath/colmathfrustum.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class CollisionMathClass
local STATIC = CNC.Import( "code/wwmath/collision-math.lua" )
STATIC.Class = "CollisionMathClass"
local isHotload = not table.IsEmpty( STATIC )


--#region Enums

    local overlapType = STATIC.OVERLAP_TYPE
--#endregion


--[[ Static Functions and Variables ]] do

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