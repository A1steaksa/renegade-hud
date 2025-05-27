-- Based on CollisionMath within Code/WWMath/colmath.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of CollisionMath
    --- @class CollisionMath
    STATIC = CNC.CreateExport()
end

--#region Enums
    --- Overlap Functions.
    --- Classify the second operand with respect to the first operand.
    --- For example Overlap_Test(plane,point) tests whether 'point' is in front of or
    --- Behind 'plane'.
    --- OverlapType: This enumeration is the result of an overlap test.
    --- It indicates whether the the object is in the positive (front/outside) space
    --- Of the volume, the negative (back/inside) space of the volume, or both (overlapping)
    --- @enum OverlapType
    STATIC.OVERLAP_TYPE = {
        POSITIVE        = 0x01,
        NEGATIVE        = 0x02,
        ON         = 0x04,
        BOTH       = 0x08,
        OUTSIDE    = 0x01,
        INSIDE     = 0x02,
        OVERLAPPED = 0x08,
        FRONT      = 0x01,
        BACK       = 0x02,
    }
    local overlapType = STATIC.OVERLAP_TYPE
--#endregion

--[[ Static Functions and Variables ]] do
    local CLASS = "CollisionMath"

    --- A map of (Type A, Type B): Func( A, B ): OverlapType
    --- @type table<string, table<string, function>>
    --- @private
    STATIC.OverlapTestFunctions = {}

    STATIC.COINCIDENCE_EPSILON = 0.000001;

    --- [[ Public ]]

    --- @class CollisionMath

    --- Registers a new overlap check function for two data types
    --- @param aType string
    --- @param bType string
    --- @param overlapFunction fun( a: any, b: any ):OverlapType
    function STATIC.AddOverlapTest( aType, bType, overlapFunction )
        typecheck.AssertArgType( CLASS, 1, aType, "string" )
        typecheck.AssertArgType( CLASS, 2, bType, "string" )
        typecheck.AssertArgType( CLASS, 3, overlapFunction, "function" )

        aType = aType:Trim():lower()
        bType = bType:Trim():lower()

        local aTable = STATIC.OverlapTestFunctions[aType]
        if not aTable then
            aTable = {}
            STATIC.OverlapTestFunctions[aType] = aTable
        end

        STATIC.OverlapTestFunctions[aType][bType] = overlapFunction
    end

    --[[ Populate Overlap Test Functions ]] do
        include( "renhud/code/wwmath/collision-math-frustum.lua" )
        include( "renhud/code/wwmath/collision-math-plane.lua" )
    end

    --- Converts an integer mask value into its corresponding OverlapType
    --- @param mask integer
    --- @return OverlapType
    function STATIC.EvaluateOverlapMask( mask )
        -- "Check if all verts are 'on'"
        if mask == overlapType.ON then
            return overlapType.ON
        end

        -- "Check if all verts are either 'on' or 'positive'"
        if bit.band( mask, bit.bnot( bit.bor( overlapType.POSITIVE, overlapType.ON ) ) ) == 0 then
            return overlapType.POSITIVE
        end

        -- "Check if all verts are either 'on' or 'back'"
        -- I believe 'back' should be 'negative' in this comment
        if bit.band( mask, bit.bnot( bit.bor( overlapType.NEGATIVE, overlapType.ON ) ) ) == 0 then
            return overlapType.NEGATIVE
        end

        -- "Overwise, poly spans the plane"
        return overlapType.BOTH
    end

    --- Determines how, if at all, two shapes intersect or overlap
    --- @param a any 
    --- @param b any
    --- @return OverlapType
    function STATIC.OverlapTest( a, b )
        local aType = typecheck.GetType( a )
        local bType = typecheck.GetType( b )

        local aTable = STATIC.OverlapTestFunctions[aType]
        if not aTable then
            typecheck.NotImplementedError( CLASS, "First operand of type '" .. aType .. "'" )
        end

        local checkFunction = aTable[bType]
        if not checkFunction then
            typecheck.NotImplementedError( CLASS, "First operand of type '" .. aType .. "' and second operand of type '" .. bType .. "'" )
        end

        return checkFunction( a, b )
    end

end