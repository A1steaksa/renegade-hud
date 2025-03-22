-- Based on Code/WWMath/rect.h

---@class Renegade
---@field Rect Rect

CNC_RENEGADE.Rect = CNC_RENEGADE.Rect or {}

---@class Rect
local LIB = CNC_RENEGADE.Rect

---@class Rectangle
---@field Left number
---@field Top number
---@field Right number
---@field Bottom number
local META = {}
META.__index = META

--#region Assignment

---Replaces this Rectangle's values with a given Rectangle's
---@param rectangle Rectangle The Rectangle to copy the values of
function META:Copy( rectangle )
    self.Left   = rectangle.Left
    self.Top    = rectangle.Top
    self.Right  = rectangle.Right
    self.Bottom = rectangle.Bottom
end

---Replaces this Rectangle's values with new ones
---@param left number The new horizontal position of the left edge of the Rectangle, in pixels
---@param top number The new vertical position of the top edge of the Rectangle, in pixels
---@param right number The new horizontal position of the right edge of the Rectangle, in pixels
---@param bottom number The new vertical position of the bottom edge of the Rectangle, in pixels
function META:Replace( left, top, right, bottom )
    self.Left    = left
    self.Top     = top
    self.Right   = right
    self.Bottom  = bottom
end

---Replaces this Rectangle's values with new ones based on Vectors representing opposing corners
---@param topLeft Vector The new position of the top-left corner of the Rectangle, in pixels
---@param bottomRight Vector The new position of the bottom-right corner of the Rectangle, in pixels
function META:ReplaceVectors( topLeft, bottomRight )
    self.Left    = topLeft.x
    self.Top     = topLeft.y
    self.Right   = bottomRight.x
    self.Bottom  = bottomRight.y
end
--#endregion

--#region Constructors

---Constructs a new, empty Rectangle
---@return Rectangle
function LIB.EmptyRectangle()
    return setmetatable( {}, META )
end

---Constructs a new Rectangle by copying an existing one
---@param rectangle Rectangle The Rectangle to be copied
---@return Rectangle
function LIB.CopyRectangle( rectangle )
    local rect = LIB.EmptyRectangle()
    rect:Copy( rectangle )
    return rect
end

---Constructs a new Rectangle
---@param left number The horizontal position of the left edge of the Rectangle, in pixels
---@param top number The vertical position of the top edge of the Rectangle, in pixels
---@param right number The horizontal position of the right edge of the Rectangle, in pixels
---@param bottom number The vertical position of the bottom edge of the Rectangle, in pixels
function LIB.NewRectangle( left, top, right, bottom )
    local rect = LIB.EmptyRectangle()
    rect:Replace( left, top, right, bottom )
    return rect
end

---Constructs a new Rectangle out of two vectors representing opposing corners
---@param topLeft Vector The position of the top-left corner of the Rectangle, in pixels
---@param bottomRight Vector The position of the bottom-right corner of the Rectangle, in pixels
function LIB.VectorRectangle( topLeft, bottomRight )
    local rect = LIB.EmptyRectangle()
    rect:ReplaceVectors( topLeft, bottomRight )
    return rect
end

--#endregion

--#region Access

---@return number Width The width of the Rectangle, in pixels
function META:Width()
    return self.Right - self.Left
end

---@return number Height The height of the Rectangle, in pixels
function META:Height()
    return self.Bottom - self.Top
end

---@return Vector center The center of the Rectangle
function META:Center()
    return Vector(
        ( self.Left + self.Right ) / 2,
        ( self.Top + self.Bottom ) / 2
    )
end

---@return Vector extents The offset from the center of the Rectangle to reach its corners
function META:Extent()
    return Vector(
        ( self.Right - self.Left ) / 2,
        ( self.Bottom - self.Top ) / 2
    )
end

---@return Vector upperLeft The top-left corner of the Rectangle
function META:UpperLeft()
    return Vector( self.Left, self.Top )
end

---@return Vector lowerRight The bottom-right corner of the Rectangle
function META:LowerRight()
    return Vector( self.Right, self.Bottom )
end

---@return Vector upperRight The top-right corner of the Rectangle
function META:UpperRight()
    return Vector( self.Right, self.Top )
end

---@return Vector lowerLeft The bottom-left corner of the Rectangle
function META:LowerLeft()
    return Vector( self.Left, self.Bottom )
end

--#endregion

--#region Scaling

---Scales this Rectangle by a number
---@param a number|Rectangle
---@param b number|Rectangle
---@return Rectangle result A new Rectangle containing the result of the scaling
function META.__mul( a, b )
    local aIsTable = istable( a )

    local rectangle = aIsTable and a or b
    ---@cast rectangle Rectangle

    local scale = aIsTable and b or a
    ---@cast scale number

    local newRectangle = LIB.CopyRectangle( rectangle )
    newRectangle:Scale( scale )

    return newRectangle
end

---Scales this Rectangle by the inverse of a number
---@param a Rectangle|number
---@param b Rectangle|number
---@return Rectangle result A new Rectangle containing the result of the scaling
function META.__div( a, b )
    local aIsTable = istable( a )

    local rectangle = aIsTable and a or b
    ---@cast rectangle Rectangle

    local scale = aIsTable and b or a
    ---@cast scale number

    local newRectangle = LIB.CopyRectangle( rectangle )
    newRectangle:Scale( 1 / scale )

    return newRectangle
end

---Scales the Rectangle relative to its center position
---@param scale number The amount to multiply each edge position by
---@return Rectangle self The Rectangle that was modified, to allow call chaining
function META:ScaleRelativeCenter( scale )
    ---@cast self Rectangle

    local center = self:Center()

    -- Move the Rectangle to be relative to 0,0
    -- This makes scaling it easier
    self = self - center

    self:Scale( scale )

    -- Move the now-scaled Rectangle back to where it was
    self = self + center

    return self
end

---Scales all of the Rectangle's edge positions by a scalar.
---@param scale number The amount to multiply each edge position by
---@return Rectangle self The Rectangle that was modified, to allow call chaining
function META:Scale( scale )
    self.Left   = self.Left   * scale
    self.Top    = self.Top    * scale
    self.Right  = self.Right  * scale
    self.Bottom = self.Bottom * scale

    return self
end

---Scales a Rectangle's Top and Bottom edges by the Y component of a given Vector 
---and its Left and Right edges by the X component of that same Vector.
---@param scale Vector The scalar that the Rectangle's edges will be scaled by
---@return Rectangle self The Rectangle that was modified, to allow call chaining
function META:ScaleVector( scale )
    self.Left   = self.Left   * scale.x
    self.Top    = self.Top    * scale.y
    self.Right  = self.Right  * scale.x
    self.Bottom = self.Bottom * scale.y

    return self
end

---Scales a Rectangle's Top and Bottom edges by the Y component of a given Vector 
---and its Left and Right edges by the X component of that same Vector.
---@param scale Vector The scalar that the Rectangle's edges will be scaled by
---@return Rectangle self The Rectangle that was modified, to allow call chaining
function META:InverseScaleVector( scale )
    self.Left   = self.Left   / scale.x
    self.Top    = self.Top    / scale.y
    self.Right  = self.Right  / scale.x
    self.Bottom = self.Bottom / scale.y

    return self
end

--#endregion

--#region Offset

---Moves the Rectangle's edge positions based on a given Vector
---@param a Rectangle|Vector
---@param b Rectangle|Vector
---@return Rectangle result A new Rectangle containing the result of the offset
function META.__add( a, b )
    local aIsTable = istable( a )

    local rectangle = aIsTable and a or b
    ---@cast rectangle Rectangle

    local offset = aIsTable and b or a
    ---@cast offset Vector

    local newRectangle = LIB.CopyRectangle( rectangle )

    newRectangle.Left   = newRectangle.Left   + offset.x
    newRectangle.Top    = newRectangle.Top    + offset.y
    newRectangle.Right  = newRectangle.Right  + offset.x
    newRectangle.Bottom = newRectangle.Bottom + offset.y

    return newRectangle
end

---Moves the Rectangle's edge positions based on the negation of a given Vector
---@param a Rectangle|Vector
---@param b Rectangle|Vector
---@return Rectangle result A new Rectangle containing the result of the offset
function META.__sub( a, b )
    local aIsTable = istable( a )

    local rectangle = aIsTable and a or b
    ---@cast rectangle Rectangle

    local offset = aIsTable and b or a
    ---@cast offset Vector

    local newRectangle = LIB.CopyRectangle( rectangle )

    newRectangle.Left   = newRectangle.Left   - offset.x
    newRectangle.Top    = newRectangle.Top    - offset.y
    newRectangle.Right  = newRectangle.Right  - offset.x
    newRectangle.Bottom = newRectangle.Bottom - offset.y

    return newRectangle
end

--#endregion

--#region Misc

---Enlarges this Rectangle's horizontal and vertical edges by an amount
---specified on the X and Y axes, respectively, of a given Vector
---@param offsets Vector The per-axis amount to expand the borders of the Rectangle
function META:Inflate( offsets )
    self.Left   = self.Left   - offsets.x
    self.Top    = self.Top    - offsets.y
    self.Right  = self.Right  + offsets.x
    self.Bottom = self.Bottom + offsets.y
end

---Creates a new Rectangle that contains the bounds of this and another Rectangle
---@param rectangle Rectangle The other Rectangle whose bounds the new Rectangle should contain
---@return Rectangle # A new Rectangle containing this Rectangle and the given Rectangle
function META:Union( rectangle )
    local newRectangle = LIB.CopyRectangle( self )

    newRectangle.Left   = math.min( newRectangle.Left,   rectangle.Left   )
    newRectangle.Top    = math.min( newRectangle.Top,    rectangle.Top    )
    newRectangle.Right  = math.max( newRectangle.Right,  rectangle.Right  )
    newRectangle.Bottom = math.max( newRectangle.Bottom, rectangle.Bottom )

    return newRectangle
end

---Moves the Rectangle's edge positions based on the negation of a given Vector
---@param a Rectangle
---@param b Rectangle
---@return boolean
function META.__eq( a, b )
    if getmetatable( a ) ~= META or getmetatable( b ) ~= META then return false end
    return  a.Left   == b.Left   and
            a.Top    == b.Top    and
            a.Right  == b.Right  and
            a.Bottom == b.Bottom
end

---Determines if this Rectangle contains a given point
---@param pos Vector The position to be compared against this Rectangle
---@return boolean
function META:Contains( pos )
    return  pos.x >= self.Left  and
            pos.x <= self.Right and
            pos.y >= self.Top   and
            pos.y <= self.Bottom
end

---Aligns this Rectangle's edges with a grid with a cell size indicated by a given Vector
---@param units Vector The size of each grid cell
function META:SnapToUnits( units )
    self.Left   = math.floor( ( self.Left   / units.x + 0.5 ) * units.x )
    self.Right  = math.floor( ( self.Right  / units.x + 0.5 ) * units.x )
    self.Top    = math.floor( ( self.Top    / units.y + 0.5 ) * units.y )
    self.Bottom = math.floor( ( self.Bottom / units.y + 0.5 ) * units.y )
end


function META.__tostring( self )
    return 
    "L: "..self.Left..", "..
    "T: "..self.Top..", "..
    "R: "..self.Right..", "..
    "B: "..self.Bottom..", "..
    "Width: "..self:Width()..", "..
    "Height: "..self:Height()
end

--#endregionq