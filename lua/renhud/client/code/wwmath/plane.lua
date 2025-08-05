-- Based on PlaneClass within Code/WWMath/plane.h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Plane
    --- @class PlaneInstance
    --- @field Static Plane The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Plane" )

    --- The static components of Plane
    --- @class Plane
    --- @field Instance PlaneInstance The Metatable used by PlaneInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsPlane = true
end


--#region Enums

    --- @enum PlaneRelativePosition
    STATIC.PLANE_RELATIVE_POSITION = {
        FRONT = 0,
        BACK  = 1,
        ON    = 2,
    }
    local planeRelativePosition = STATIC.PLANE_RELATIVE_POSITION
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "Plane"

    --- [[ Public ]]

    --- Creates a new PlaneInstance
    --- @return PlaneInstance
    --- @overload fun( normalX: number, normalY: number, normalZ: number, distance: number )
    --- @overload fun( point1: Vector, point2: Vector, point3: Vector )
    --- @overload fun( normal: Vector, distance: number )
    --- @overload fun( normal: Vector, point: Vector )
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Plane", ... )
    end

    ---@param arg any
    ---@return boolean `true` if the passed argument is a Plane, `false` otherwise
    function STATIC.IsPlane( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsPlane and true or false
    end

    typecheck.RegisterType( "PlaneInstance", STATIC.IsPlane )

    ---@param planeA PlaneInstance
    ---@param planeB PlaneInstance
    ---@param lineDirection Vector
    ---@param linePoint Vector
    function IntersectPlanes( planeA, planeB, lineDirection, linePoint )
        typecheck.NotImplementedError( CLASS, "IntersectPlanes" )
    end
end


--[[ Instanced Functions and Variables ]] do

    local CLASS = "PlaneInstance"

    --- [[ Public ]]

    --- @class PlaneInstance
    --- @field Normal Vector The normal direction of the plane
    --- @field Distance number The plane's position expressed as its distance along its normal from the origin


    --- Constructs a new PlaneInstance
    --- @vararg any
    function INSTANCE:Renegade_Plane( ... )
        self:Set( ... )
    end

    --- @overload fun( normalX: number, normalY: number, normalZ: number, distance: number )
    --- @overload fun( point1: Vector, point2: Vector, point3: Vector )
    --- @overload fun( normal: Vector, distance: number )
    --- @overload fun( normal: Vector, point: Vector )
    function INSTANCE:Set( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        typecheck.AssertArgCount( CLASS, argCount, { 0, 2, 3, 4 } )

        if argCount == 0 then
            self.Normal = Vector( 0, 0, 1 )
            self.Distance = 0
            return
        end

        local firstArg  = args[1]
        local secondArg = args[2]
        local thirdArg  = args[3]
        local fourthArg = args[4]

        if argCount == 2 then
            typecheck.AssertArgType( CLASS, 1, firstArg, "vector" )
            typecheck.AssertArgType( CLASS, 2, secondArg, { "number", "vector" } )

            --- @type Vector
            local normal = firstArg

            -- normal: Vector, distance: number
            if isnumber( secondArg ) then
                --- @type number
                local distance = secondArg

                self.Normal = normal
                self.Distance = distance
                return
            end

            -- normal: Vector, point: Vector
            if isvector( secondArg ) then
                ---@type Vector
                local point = secondArg

                self.Normal = normal
                self.Distance = self.Normal:Dot( point )
                return
            end
        end

        -- point1: Vector, point2: Vector, point3: Vector
        if argCount == 3 then
            typecheck.AssertArgType( CLASS, 1, firstArg, "vector" )
            typecheck.AssertArgType( CLASS, 2, secondArg, "vector" )
            typecheck.AssertArgType( CLASS, 3, thirdArg, "vector" )

            --- @type Vector
            local point1 = firstArg

            --- @type Vector
            local point2 = secondArg

            --- @type Vector
            local point3 = thirdArg

            self.Normal = ( point2 - point1 ):Cross( point3 - point1 )

            if not self.Normal:IsZero() then
                -- Points are not colinear.  Normalize Normal and calculate Distance
                self.Normal:Normalize()
                self.Distance = self.Normal:Dot( point1 )
            else
                -- Points are colinear, return default plane to avoid constructor failure
                self.Normal = Vector( 0, 0, 1 )
                self.Distance = 0
            end

            return
        end

        if argCount == 4 then
            typecheck.AssertArgType( CLASS, 1, firstArg, "number" )
            typecheck.AssertArgType( CLASS, 2, secondArg, "number" )
            typecheck.AssertArgType( CLASS, 3, thirdArg, "number" )
            typecheck.AssertArgType( CLASS, 4, fourthArg, "number" )

            --- @type number
            local coefficient1 = firstArg

            --- @type number
            local coefficient2 = secondArg

            --- @type number
            local coefficient3 = thirdArg

            --- @type number
            local coefficient4 = fourthArg

            self.Normal.x = coefficient1
            self.Normal.y = coefficient2
            self.Normal.z = coefficient3
            self.Distance = coefficient4
            return
        end
    end

    --- @param point0 Vector
    --- @param point1 Vector
    --- @param setT number
    --- @return boolean
    function INSTANCE:ComputeIntersection( point0, point1, setT )
        typecheck.NotImplementedError( CLASS, "ComputeIntersection" )
    end

    --- @return boolean
    function INSTANCE:InFront( ... )
        local args = { ... }

        typecheck.AssertArgType( CLASS, 1, args[1], { "vector", "sphere" } )

        if isvector( args[1] ) then
            typecheck.NotImplementedError( CLASS, "Vector check" )
        end

        -- Omitted sphere check logic as there is currently no sphere usecase
        typecheck.NotImplementedError( CLASS, "Sphere check" )
    end

    -- Omitted function InFrontOrIntersecting due to sphere dependency
end