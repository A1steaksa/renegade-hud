-- Based on AABoxClass within Code/WWMath/aabox.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of AABox
    --- @class AABoxInstance
    --- @field Static AABox The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_AABox" )

    --- The static components of AABox
    --- @class AABox
    --- @field Instance AABoxInstance The Metatable used by AABoxInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsAABox = true
end


--[[ Static Functions and Variables ]] do

    local CLASS = "AABox"

    --- [[ Public ]]

    --- @class AABox

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

    --- @param transformMatrix VMatrix
    --- @param toTransform AABoxInstance
    --- @return AABoxInstance
    function STATIC.Transform( transformMatrix, toTransform )
        typecheck.NotImplementedError( CLASS, "Transform" )
    end
end


--[[ Instanced Functions and Variables ]] do

    local CLASS = "AABoxInstance"

    --- [[ Public ]]

    --- @class AABoxInstance
    --- @field Center Vector World Space Center
    --- @field Extent Vector The size of the box each of the three dimensions

    --- Constructs a new AABoxInstance
    function INSTANCE:Renegade_AABox( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        -- ( nil )
        if argCount == 0 then
            self.Center = Vector( 0, 0, 0 )
            self.Extent = Vector( 0, 0, 0 )
            return
        end

        if argCount == 1 then
            typecheck.AssertArgType( CLASS, 1, args[1], "table" )

            -- ( points: Vector[] )
            local firstIndexContainsVector = isvector( args[1][1] )
            if firstIndexContainsVector then
                local points = args[1] --[[@as Vector[] ]]

                self:Init( points )

                return
            end

            -- Omitted MinMaxAABox logic
            typecheck.NotImplementedError( CLASS, "MinMaxAABox constructor" )
        end

        -- ( center: Vector, extent: Vector )
        if argCount == 2 then
            typecheck.AssertArgType( CLASS, 1, args[1], "Vector" )
            typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )

            local center = args[1] --[[@as Vector]]
            local extent = args[2] --[[@as Vector]]

            self.Center = center
            self.Extent = extent

            return
        end

        typecheck.AssertArgCount( CLASS, argCount )
    end

    --- @param other AABoxInstance
    function INSTANCE:__eq( other )
        if not STATIC.IsAABox( other ) then
            return false
        end

        return ( self.Center == other.Center ) and ( self.Extent == other.Extent )
    end

    --- @overload fun( points: Vector[] )
    function INSTANCE:Init( ... )
        local args = { ... }
        local argCount = select( "#", ... )
        typecheck.AssertArgCount( CLASS, argCount, 1 )

        if argCount == 1 then
            typecheck.AssertArgType( CLASS, 1, args[1], "table" )

            -- ( points: Vector[] )
            local isVectorList = args[1][1] and isvector( args[1][1] )
            if isVectorList then

                local points = args[1] --[[@as Vector[] ]]

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

            typecheck.NotImplementedError( CLASS, "Init", "MinMaxAABox and LineSeg" )
        end
    end

    --- @param min Vector
    --- @param max Vector
    function INSTANCE:InitMinMax( min, max )
        typecheck.NotImplementedError( CLASS, "InitMinMax" )
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
        typecheck.NotImplementedError( CLASS, "AddPoint" )
    end

    function INSTANCE:AddBox( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        typecheck.NotImplementedError( CLASS, "AddBox" )

        typecheck.AssertArgCount( CLASS, argCount )
    end

    --- @param axis Vector
    --- @return number
    function INSTANCE:ProjectToAxis( axis )
        typecheck.NotImplementedError( CLASS, "ProjectToAxis" )
    end

    ---@param transformMatrix VMatrix
    ---@param input AABoxInstance
    ---@return AABoxInstance
    function INSTANCE:Transform( transformMatrix, input )
        typecheck.NotImplementedError( CLASS, "Transform" )
    end

    --- @param pos Vector
    function INSTANCE:Translate( pos )
        typecheck.NotImplementedError( CLASS, "Translate" )
    end

    --- @return number
    function INSTANCE:Volume()
        return 2 * self.Extent.x * 2 * self.Extent.y * 2 * self.Extent.z
    end

    function INSTANCE:Contains( ... )
        typecheck.NotImplementedError( CLASS, "Contains" )
    end
end