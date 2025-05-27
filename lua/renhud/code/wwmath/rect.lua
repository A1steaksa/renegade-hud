-- Based on RectInstance within Code/WWMath/rect.h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Rect
    --- @class RectInstance
    INSTANCE = robustclass.Register( "Renegade_Rect" )

    --- The static components of Rect
    --- @class Rect
    --- @field Instance RectInstance The Metatable used by RectInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsRect = true
end


--[[ Static Functions and Variables ]] do

    local CLASS = "Rect"

    --- [[ Public ]]

    --- Creates a new Rect
    --- @overload fun( left: number, top: number, right: number, bottom: number ): RectInstance Creates a new Rect from the horizontal and vertical coordinates of its four edges
    --- @overload fun( topLeft: Vector, bottomRight: Vector ): RectInstance Creates a new RectInstance from Vectors that define its top-left and bottom-right corners
    --- @overload fun( rectToCopy: RectInstance ): RectInstance Creates a new RectInstance by copying the values of an existing one
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Rect", ... )
    end

    ---@param arg any
    ---@return boolean `true` if the passed argument is a Rect, `false` otherwise
    function STATIC.IsRect( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsRect
    end

    typecheck.RegisterType( "RectInstance", STATIC.IsRect )
end


--[[ Instanced Functions and Variables ]] do

    local CLASS = "RectInstance"

    --- [[ Public ]]

    --- @class RectInstance
    --- @field Left number
    --- @field Top number
    --- @field Right number
    --- @field Bottom number

    --- Constructs a new Rect
    --- @vararg any
    function INSTANCE:Renegade_Rect( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        -- An empty Rect
        -- ( nil )
        if argCount == 0 then
            self:Replace( 0, 0, 0, 0 )
            return
        end

        -- Copying another Rect
        -- ( rect: RectInstance )
        if argCount == 1 then
            local rect = args[1] --[[@as RectInstance]]

            typecheck.AssertArgType( CLASS, 1, rect, "RectInstance" )

            self:Copy( rect )
            return
        end

        -- Creating from top-left and bottom-right Vectors
        -- ( topLeft: Vector, bottomRight: Vector )
        if argCount == 2 then
            local topLeft = args[1] --[[@as Vector]]
            local bottomRight = args[2] --[[@as Vector]]

            typecheck.AssertArgType( CLASS, 1, topLeft, "Vector" )
            typecheck.AssertArgType( CLASS, 2, bottomRight, "Vector" )

            self:ReplaceVectors( topLeft, bottomRight )
            return
        end

        -- Creating from edge positions
        -- ( left: number, top: number, right: number, bottom: number )
        if argCount == 4 then
            local left = args[1] --[[@as number]]
            local top = args[2] --[[@as number]]
            local right = args[3] --[[@as number]]
            local bottom = args[4] --[[@as number]]

            typecheck.AssertArgType( CLASS, 1, left, "number" )
            typecheck.AssertArgType( CLASS, 2, top, "number" )
            typecheck.AssertArgType( CLASS, 3, right, "number" )
            typecheck.AssertArgType( CLASS, 4, bottom, "number" )

            self:Replace( left, top, right, bottom )
            return
        end

        typecheck.AssertArgCount( CLASS, argCount )
    end

    --[[ Assignment ]] do

        --- Replaces this Rectangle's values with a given Rectangle's
        --- @param rectangle RectInstance The Rectangle to copy the values of
        function INSTANCE:Copy( rectangle )
            self.Left   = rectangle.Left
            self.Top    = rectangle.Top
            self.Right  = rectangle.Right
            self.Bottom = rectangle.Bottom
        end

        --- Replaces this Rectangle's values with new ones
        --- @param left number The new horizontal position of the left edge of the Rectangle, in pixels
        --- @param top number The new vertical position of the top edge of the Rectangle, in pixels
        --- @param right number The new horizontal position of the right edge of the Rectangle, in pixels
        --- @param bottom number The new vertical position of the bottom edge of the Rectangle, in pixels
        function INSTANCE:Replace( left, top, right, bottom )
            self.Left    = left
            self.Top     = top
            self.Right   = right
            self.Bottom  = bottom
        end

        --- Replaces this Rectangle's values with new ones based on Vectors representing opposing corners
        --- @param topLeft Vector The new position of the top-left corner of the Rectangle, in pixels
        --- @param bottomRight Vector The new position of the bottom-right corner of the Rectangle, in pixels
        function INSTANCE:ReplaceVectors( topLeft, bottomRight )
            self.Left    = topLeft.x
            self.Top     = topLeft.y
            self.Right   = bottomRight.x
            self.Bottom  = bottomRight.y
        end
    end

    --[[ Access ]] do

        --- @return number Width The width of the Rectangle, in pixels
        function INSTANCE:Width()
            return self.Right - self.Left
        end

        --- @return number Height The height of the Rectangle, in pixels
        function INSTANCE:Height()
            return self.Bottom - self.Top
        end

        --- @return Vector center The center of the Rectangle
        function INSTANCE:Center()
            return Vector(
                ( self.Left + self.Right ) / 2,
                ( self.Top + self.Bottom ) / 2
            )
        end

        --- @return Vector extents The offset from the center of the Rectangle to reach its corners
        function INSTANCE:Extent()
            return Vector(
                ( self.Right - self.Left ) / 2,
                ( self.Bottom - self.Top ) / 2
            )
        end

        --- @return Vector upperLeft The top-left corner of the Rectangle
        function INSTANCE:UpperLeft()
            return Vector( self.Left, self.Top )
        end

        --- @return Vector lowerRight The bottom-right corner of the Rectangle
        function INSTANCE:LowerRight()
            return Vector( self.Right, self.Bottom )
        end

        --- @return Vector upperRight The top-right corner of the Rectangle
        function INSTANCE:UpperRight()
            return Vector( self.Right, self.Top )
        end

        --- @return Vector lowerLeft The bottom-left corner of the Rectangle
        function INSTANCE:LowerLeft()
            return Vector( self.Left, self.Bottom )
        end
    end

    --[[ Scaling ]] do

        --- @class RectInstance
        --- @operator mul( number ): RectInstance
        --- @operator div( number ): RectInstance

        --- Scales this Rectangle by a number
        --- @param a number|RectInstance
        --- @param b number|RectInstance
        --- @return RectInstance result A new Rectangle containing the result of the scaling
        function INSTANCE.__mul( a, b )
            local aIsTable = istable( a )

            local rectangle = aIsTable and a or b
            --- @cast rectangle RectInstance

            local scale = aIsTable and b or a
            --- @cast scale number

            local newRectangle = robustclass.New( "Renegade_Rect", rectangle )
            newRectangle:Scale( scale )

            return newRectangle
        end

        --- Scales this Rectangle by the inverse of a number
        --- @param a RectInstance|number
        --- @param b RectInstance|number
        --- @return RectInstance result A new Rectangle containing the result of the scaling
        function INSTANCE.__div( a, b )
            local aIsTable = istable( a )

            local rectangle = aIsTable and a or b
            --- @cast rectangle RectInstance

            local scale = aIsTable and b or a
            --- @cast scale number

            local newRectangle = robustclass.New( "Renegade_Rect", rectangle )
            newRectangle:Scale( 1 / scale )

            return newRectangle
        end

        --- Scales the Rectangle relative to its center position
        --- @param scale number The amount to multiply each edge position by
        --- @return RectInstance self The Rectangle that was modified, to allow call chaining
        function INSTANCE:ScaleRelativeCenter( scale )
            --- @cast self RectInstance

            local center = self:Center()

            -- Move the Rectangle to be relative to 0,0
            -- This makes scaling it easier
            self = self - center

            self:Scale( scale )

            -- Move the now-scaled Rectangle back to where it was
            self = self + center

            return self
        end

        --- Scales all of the Rectangle's edge positions by a scalar.
        --- @param scale number The amount to multiply each edge position by
        --- @return RectInstance self The Rectangle that was modified, to allow call chaining
        function INSTANCE:Scale( scale )
            self.Left   = self.Left   * scale
            self.Top    = self.Top    * scale
            self.Right  = self.Right  * scale
            self.Bottom = self.Bottom * scale

            return self
        end

        --- Scales a Rectangle's Top and Bottom edges by the Y component of a given Vector 
        --- and its Left and Right edges by the X component of that same Vector.
        --- @param scale Vector The scalar that the Rectangle's edges will be scaled by
        --- @return RectInstance self The Rectangle that was modified, to allow call chaining
        function INSTANCE:ScaleVector( scale )
            self.Left   = self.Left   * scale.x
            self.Top    = self.Top    * scale.y
            self.Right  = self.Right  * scale.x
            self.Bottom = self.Bottom * scale.y

            return self
        end

        --- Scales a Rectangle's Top and Bottom edges by the Y component of a given Vector 
        --- and its Left and Right edges by the X component of that same Vector.
        --- @param scale Vector The scalar that the Rectangle's edges will be scaled by
        --- @return RectInstance self The Rectangle that was modified, to allow call chaining
        function INSTANCE:InverseScaleVector( scale )
            self.Left   = self.Left   / scale.x
            self.Top    = self.Top    / scale.y
            self.Right  = self.Right  / scale.x
            self.Bottom = self.Bottom / scale.y

            return self
        end
    end

    --[[ Offset ]] do

        --- @class RectInstance
        --- @operator add( number ): RectInstance
        --- @operator add( RectInstance ): RectInstance
        --- @operator sub( number ): RectInstance
        --- @operator sub( RectInstance ): RectInstance

        --- Moves the Rectangle's edge positions based on a given Vector
        --- @param a RectInstance|Vector
        --- @param b RectInstance|Vector
        --- @return RectInstance result A new Rectangle containing the result of the offset
        function INSTANCE.__add( a, b )
            local aIsRect = STATIC.IsRect( a )
            local bIsRect = STATIC.IsRect( b )

            -- Adding two RectInstances together results in a union
            if aIsRect and bIsRect then
                --- @cast a RectInstance
                --- @cast b RectInstance

                return a:Union( b )
            end

            local rectangle = aIsRect and a or b
            --- @cast rectangle RectInstance

            local offset = aIsRect and b or a
            --- @cast offset Vector

            local newRectangle = robustclass.New( "Renegade_Rect", rectangle )

            newRectangle.Left   = newRectangle.Left   + offset.x
            newRectangle.Top    = newRectangle.Top    + offset.y
            newRectangle.Right  = newRectangle.Right  + offset.x
            newRectangle.Bottom = newRectangle.Bottom + offset.y

            return newRectangle
        end

        --- Moves the Rectangle's edge positions based on the negation of a given Vector
        --- @param a RectInstance|Vector
        --- @param b RectInstance|Vector
        --- @return RectInstance result A new Rectangle containing the result of the offset
        function INSTANCE.__sub( a, b )
            local aIsTable = istable( a )

            local rectangle = aIsTable and a or b
            --- @cast rectangle RectInstance

            local offset = aIsTable and b or a
            --- @cast offset Vector

            local newRectangle = robustclass.New( "Renegade_Rect", rectangle )

            newRectangle.Left   = newRectangle.Left   - offset.x
            newRectangle.Top    = newRectangle.Top    - offset.y
            newRectangle.Right  = newRectangle.Right  - offset.x
            newRectangle.Bottom = newRectangle.Bottom - offset.y

            return newRectangle
        end
    end

    --- Enlarges this Rectangle's horizontal and vertical edges by an amount
    --- specified on the X and Y axes, respectively, of a given Vector
    --- @param offsets Vector The per-axis amount to expand the borders of the Rectangle
    function INSTANCE:Inflate( offsets )
        self.Left   = self.Left   - offsets.x
        self.Top    = self.Top    - offsets.y
        self.Right  = self.Right  + offsets.x
        self.Bottom = self.Bottom + offsets.y
    end

    --- Creates a new Rectangle that contains the bounds of this and another Rectangle
    --- @param rectangle RectInstance The other Rectangle whose bounds the new Rectangle should contain
    --- @return RectInstance # A new Rectangle containing this Rectangle and the given Rectangle
    function INSTANCE:Union( rectangle )
        local newRectangle = robustclass.New( "Renegade_Rect", self )

        newRectangle.Left   = math.min( newRectangle.Left,   rectangle.Left   )
        newRectangle.Top    = math.min( newRectangle.Top,    rectangle.Top    )
        newRectangle.Right  = math.max( newRectangle.Right,  rectangle.Right  )
        newRectangle.Bottom = math.max( newRectangle.Bottom, rectangle.Bottom )

        return newRectangle
    end

    --- Moves the Rectangle's edge positions based on the negation of a given Vector
    --- @param a RectInstance
    --- @param b RectInstance
    --- @return boolean
    function INSTANCE.__eq( a, b )
        if getmetatable( a ) ~= INSTANCE or getmetatable( b ) ~= INSTANCE then return false end
        return  a.Left   == b.Left   and
                a.Top    == b.Top    and
                a.Right  == b.Right  and
                a.Bottom == b.Bottom
    end

    --- Determines if this Rectangle contains a given point
    --- @param pos Vector The position to be compared against this Rectangle
    --- @return boolean
    function INSTANCE:Contains( pos )
        return  pos.x >= self.Left  and
                pos.x <= self.Right and
                pos.y >= self.Top   and
                pos.y <= self.Bottom
    end

    --- Aligns this Rectangle's edges with a grid with a cell size indicated by a given Vector
    --- @param units Vector The size of each grid cell
    function INSTANCE:SnapToUnits( units )
        self.Left   = math.floor( ( self.Left   / units.x + 0.5 ) * units.x )
        self.Right  = math.floor( ( self.Right  / units.x + 0.5 ) * units.x )
        self.Top    = math.floor( ( self.Top    / units.y + 0.5 ) * units.y )
        self.Bottom = math.floor( ( self.Bottom / units.y + 0.5 ) * units.y )
    end

    function INSTANCE.__tostring( self )
        return
        "Rect: "   ..
        "Left: "   .. ( self.Left   or "nil" ) .. ", " ..
        "Top: "    .. ( self.Top    or "nil" ) .. ", " ..
        "Right: "  .. ( self.Right  or "nil" ) .. ", " ..
        "Bottom: " .. ( self.Bottom or "nil" ) .. ", " ..
        "Width: "  .. self:Width()             .. ", " ..
        "Height: " .. self:Height()
    end
end