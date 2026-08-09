-- Based on AABoxClass within Code/WWMath/aabox.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class AABoxClass
--- @field instance AABoxInstance The metatable used by AABoxInstance
local STATIC = CNC.CreateExport()
STATIC.Class = "AABoxClass"
local isHotload = not table.IsEmpty( STATIC )

--- @class AABoxInstance
--- @field Static AABoxClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_AABox" )
INSTANCE.Class = "AABoxInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAABox = true


--#region Imports

    --- @type VectorBridgeClass
    local vectorBridgeClass = CNC.Import( "bridges/sh_vector.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    --- @class AABoxClass

    --- Creates a new AABoxInstance
    --- @overload fun(): AABoxInstance
    --- @overload fun( minMaxBox: MinMaxAABoxInstance ): AABoxInstance
    --- @overload fun( center: Vector, extent: Vector ): AABoxInstance
    --- @overload fun( center: Vector, extent: Vector ): AABoxInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_AABox", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) AABoxInstance, `false` otherwise
    function STATIC.IsAABox( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAABox and true or false
    end

    typecheck.RegisterType( "AABoxInstance", STATIC.IsAABox )

    --- @param transformMatrix Matrix3dInstance
    --- @param toTransform AABoxInstance
    --- @return AABoxInstance
    function STATIC.Transform( transformMatrix, toTransform )
        typecheck.NotImplementedError( "Transform" )
    end
end


--- @class AABoxInstance
--- @field Center Vector World Space Center
--- @field Extent Vector The size of the box each of the three dimensions

--- Constructs a new AABoxInstance
--- @overload fun( self ): AABoxInstance
--- @overload fun( self, minMaxBox: MinMaxAABoxInstance ): AABoxInstance
--- @overload fun( self, center: Vector, extent: Vector ): AABoxInstance
--- @overload fun( self, center: Vector, extent: Vector ): AABoxInstance
function INSTANCE:Renegade_AABox( ... )
    local args = { ... }
    local argCount = select( "#", ... )

    typecheck.AssertArgCount( STATIC.Class, argCount, { 0, 1, 2 } )

    -- ( nil )
    if argCount == 0 then
        self.Center = Vector( 0, 0, 0 )
        self.Extent = Vector( 0, 0, 0 )
        return
    end

    if argCount == 1 then
        local arg = args[1]
        typecheck.AssertArgType( STATIC.Class, 1, arg, { "table", "MinMaxAABoxInstance" } )

        -- ( minMaxBox: MinMaxAABoxInstance )
        if typecheck.IsOfType( arg, "MinMaxAABoxInstance" ) then
            local minMaxBox = args[1] --[[@as MinMaxAABoxInstance]]

            self:Init( minMaxBox )
            return
        end

        -- ( points: Vector[] )
        local firstIndexContainsVector = isvector( args[1][1] )
        if firstIndexContainsVector then
            local points = args[1] --[[@as Vector[] ]]

            self:Init( points )
            return
        end
    end

    -- ( center: Vector, extent: Vector )
    if argCount == 2 then
        typecheck.AssertArgType( STATIC.Class, 1, args[1], "Vector" )
        typecheck.AssertArgType( STATIC.Class, 2, args[2], "Vector" )

        local center = args[1] --[[@as Vector]]
        local extent = args[2] --[[@as Vector]]

        self.Center = center
        self.Extent = extent
        return
    end
end

--- @param other AABoxInstance
function INSTANCE:__eq( other )
    if not STATIC.IsAABox( other ) then
        return false
    end

    return ( self.Center == other.Center ) and ( self.Extent == other.Extent )
end

--- @overload fun( self, minMaxBox: MinMaxAABoxInstance )
--- @overload fun( self, center: Vector, extent: Vector )
--- @overload fun( self, points: Vector[] )
function INSTANCE:Init( ... )
    local args = { ... }
    local argCount = select( "#", ... )
    typecheck.AssertArgCount( INSTANCE.Class, argCount, { 1, 2 } )

    if argCount == 1 then
        local arg = args[1]
        typecheck.AssertArgType( STATIC.Class, 1, arg, { "table", "MinMaxAABoxInstance" } )

        -- "Initialize from a min-max form of a box"
        -- ( minMaxbox: MinMaxAABoxInstance )
        if typecheck.IsOfType( arg, "MinMaxAABoxInstance" ) then
            local minMaxBox = arg --[[@as MinMaxAABoxInstance]]

            self.Center = ( minMaxBox.MaxCorner + minMaxBox.MinCorner ) * 0.5
            self.Extent = ( minMaxBox.MaxCorner - minMaxBox.MinCorner ) * 0.5
            return
        end

        -- ( points: Vector[] )
        local isVectorList = arg[1] and isvector( arg[1] )
        if isVectorList then

            local points = arg --[[@as Vector[] ]]

            local min = Vector( 0, 0, 0 )
            local max = Vector( 0, 0, 0 )

            for i = 1, #points do
                local point = points[i]
                if min.x > point.x then min.x = point.x end
                if min.y > point.y then min.y = point.y end
                if min.z > point.z then min.z = point.z end

                if min.x < point.x then min.x = point.x end
                if min.y < point.y then min.y = point.y end
                if min.z < point.z then min.z = point.z end
            end

            self.Center = ( max + min ) * 0.5
            self.Extent = ( max - min ) * 0.5
            return
        end

        typecheck.NotImplementedError( "LineSeg" )
    end

    if argCount == 2 then
        local arg1 = args[1]
        local arg2 = args[2]
        if typecheck.IsOfType( args[1], "Vector" ) then
            typecheck.AssertArgType( INSTANCE.Class, 2, arg2, "Vector" )
            local center = arg1 --[[@as Vector]]
            local extent = arg2 --[[@as Vector]]

            self.Center = center
            self.Extent = extent
            return
        end

    end

end

--- Initializes this box to a random state
--- @param minCenter number? [Default: -1]
--- @param maxCenter number? [Default: 1]
--- @param minExtent number? [Default: 0.5]
--- @param maxExtent number? [Default: 1]
function INSTANCE:InitRandom( minCenter, maxCenter, minExtent, maxExtent )
    if not minCenter then minCenter = -1 end
    if not maxCenter then maxCenter = 1 end
    if not minExtent then minExtent = 0.5 end
    if not maxExtent then maxExtent = 1 end

    local centerRange = maxCenter - minCenter

    self.Center.x = minCenter + math.random() * centerRange
    self.Center.y = minCenter + math.random() * centerRange
    self.Center.z = minCenter + math.random() * centerRange

    self.Extent.x = minCenter + math.random() * centerRange
    self.Extent.y = minCenter + math.random() * centerRange
    self.Extent.z = minCenter + math.random() * centerRange
end

--- @param point Vector
function INSTANCE:AddPoint( point )
    typecheck.NotImplementedError( "AddPoint" )
end

function INSTANCE:AddBox( ... )
    local args = { ... }
    local argCount = select( "#", ... )
    typecheck.AssertArgCount( STATIC.Class, argCount, { 1 } )

    local otherBox = args[1]

    if typecheck.IsOfType( otherBox, "AABoxInstance" ) then
        --- @cast otherBox AABoxInstance

        local newMin = self.Center - self.Extent
        local newMax = self.Center + self.Extent

        vectorBridgeClass.UpdateMin( newMin, ( otherBox.Center - otherBox.Extent ) )
        vectorBridgeClass.UpdateMax( newMax, ( otherBox.Center + otherBox.Extent ) )

        self.Center = ( newMax + newMin ) * 0.5
        self.Extent = ( newMax - newMin ) * 0.5

        return
    end

    typecheck.NotImplementedError( "AddBox" )
end

--- @param axis Vector
--- @return number
function INSTANCE:ProjectToAxis( axis )
    typecheck.NotImplementedError( "ProjectToAxis" )
end

--- "  
--- Transform an aabox  
--- 
--- Note that this function extends the box to enclose its transformed form.  
--- "  
--- @param transformationMatrix Matrix3dInstance
function INSTANCE:Transform( transformationMatrix)
    local oldCenter = self.Center
    local oldExtent = self.Extent
    self.Center, self.Extent = transformationMatrix:TransformCenterExtentAABox( oldCenter, oldExtent )
end

--- @param pos Vector
function INSTANCE:Translate( pos )
    typecheck.NotImplementedError( "Translate" )
end

--- @return number
function INSTANCE:Volume()
    return 2 * self.Extent.x * 2 * self.Extent.y * 2 * self.Extent.z
end

--- @return boolean
function INSTANCE:Contains( ... )
    typecheck.NotImplementedError( "Contains" )
end