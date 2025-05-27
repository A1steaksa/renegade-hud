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


--#region Imports

    --- @type WWMath
    local wwMath = CNC.Import( "renhud/code/wwmath/wwmath.lua" )
--#endregion


--[[ Static Functions and Variables ]] do
    local CLASS = "CollisionMath"

    local COLLISION_EPSILON = 0.001

    --- [[ Public ]]

    --- @class CollisionMath

    --- @param normal Vector
    --- @param extent Vector
    --- @return Vector
    function STATIC.GetFarExtent( normal, extent )
        local result = Vector( 0, 0 )

        if normal.x > 0 then
            result.x = extent.x
        else
            result.x = -extent.x
        end

        if normal.y > 0 then
            result.y = extent.y
        else
            result.y = -extent.y
        end

        if normal.z > 0 then
            result.z = extent.z
        else
            result.z = -extent.z
        end

        return result
    end

    --- This function is hiding in Code/WWMath/colmathplane.h instead of in the .cpp file
    --- with the rest of the Plane functions.
    --- @param plane PlaneInstance
    --- @param point Vector
    --- @return OverlapType
    STATIC.AddOverlapTest( "PlaneInstance", "Vector", function( plane, point )
        local delta = point:Dot( plane.Normal ) - plane.Distance

        if delta > STATIC.COINCIDENCE_EPSILON then
            return overlapType.POSITIVE
        end

        if delta < STATIC.COINCIDENCE_EPSILON then
            return overlapType.NEGATIVE
        end

        return overlapType.ON
    end )

    --- This function is hiding in Code/WWMath/colmathplane.h instead of in the .cpp file
    --- with the rest of the Plane functions.
    --- @param plane PlaneInstance
    --- @param box AABoxInstance
    --- @return OverlapType
    STATIC.AddOverlapTest( "PlaneInstance", "AABoxInstance", function( plane, box )
        -- "First, we determine the the near and far points of the box in the direction of the plane normal"
        local positiveFarPoint = STATIC.GetFarExtent( plane.Normal, box.Extent )
        local negativeFarPoint = -positiveFarPoint

        positiveFarPoint = positiveFarPoint + box.Center
        negativeFarPoint = negativeFarPoint + box.Center

        if STATIC.OverlapTest( plane, negativeFarPoint ) == overlapType.POSITIVE then
            return overlapType.POSITIVE
        end

        if STATIC.OverlapTest( plane, positiveFarPoint ) == overlapType.NEGATIVE then
            return overlapType.NEGATIVE
        end

        return overlapType.BOTH
    end )

end