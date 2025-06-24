-- Based on Matrix3D within Code/WWMath/matrix3d.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Matrix3d
    --- @class Matrix3dInstance
    --- @field Static Matrix3d The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Matrix3d" )

    --- The static components of Matrix3d
    --- @class Matrix3d
    --- @field Instance Matrix3dInstance The Metatable used by Matrix3dInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsMatrix3d = true
end


-- #region Imports

    --- @type Vector4
    local vector4 = CNC.Import( "renhud/code/wwmath/vector4.lua" )
-- #endregion

--[[
	"Three important notes:
	- I use *column-vectors*
	- I use a *right-handed* coordinate system
	- These matrices are *orthogonal*
	  
	3D Transformation matrices.  This class is really a 4x4 homogeneous 
	matrix where the last row is assumed to always be 0 0 0 1.  However,
	since I don't store the last row, you cant do some things that you can
	do with a real 4x4 homogeneous matrix.
	
	I use column-vectors so normally transformations are post-multiplied
	and camera transformations should be pre-multiplied.  The methods of
	this class called Translate, Rotate_X, etc. all perform post-multiplication
	with the current matix.  These methods (Translate, Rotate_X, etc) also
	have been hand-coded to only perform the necessary arithmetic.  The
	* operator can be used for general purpose matrix multiplication or to
	transform a vector by a matrix.

	Some operations in this class assume that the matrix is orthogonal."
--]]

--[[ Static Functions and Variables ]] do
    local CLASS = "Matrix3d"

    --- [[ Public ]]

    --- @class Matrix3d

    --- Creates a new Matrix3dInstance
    --- @overload fun(): Matrix3dInstance
    --- @overload fun( init: boolean ): Matrix3dInstance
    --- @overload fun( matrixValues: number[] ): Matrix3dInstance
    --- @overload fun( pos: Vector ): Matrix3dInstance
    --- @overload fun( matrixToCopy: Matrix3dInstance ): Matrix3dInstance
    --- @overload fun( axis: Vector, angle: number ): Matrix3dInstance
    --- @overload fun( rotation: Matrix3dInstance, pos: Vector ): Matrix3dInstance
    --- @overload fun( axis: Vector, sine: number, cosine: number ): Matrix3dInstance
    --- @overload fun( x: Vector, y: Vector, z: Vector, pos: Vector ): Matrix3dInstance
    --- @overload fun( m11: number, m12: number, m13: number, m14: number, m21: number, m22: number, m23: number, m24: number, m31: number, m32: number, m33: number, m34: number ): Matrix3dInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Matrix3d", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Matrix3dInstance, `false` otherwise
    function STATIC.IsMatrix3d( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMatrix3d and true or false
    end

    typecheck.RegisterType( "Matrix3dInstance", STATIC.IsMatrix3d )

    --[[ Matrix Multiplication Without Temporaries ]] do

        --- @param a Matrix3dInstance
        --- @param b Matrix3dInstance
        --- @return Vector
        function STATIC.Multiply( a, b )
            typecheck.NotImplementedError( CLASS, "Multiply" )
        end

        --- @param transformationMatrix Matrix3dInstance
        --- @param input Vector
        --- @return Vector
        function STATIC.TransformVector( transformationMatrix, input )
            typecheck.NotImplementedError( CLASS, "TransformVector" )
        end

        --- @param transformationMatrix Matrix3dInstance
        --- @param input Vector
        --- @return Vector
        function STATIC.RotateVector( transformationMatrix, input )
            typecheck.NotImplementedError( CLASS, "RotateVector" )
        end
    end

    --[[ Inverse Transformation ]] do

        --[[
            "Transform a vector by the inverse of this matrix"
            
            (note: assumes the matrix is orthogonally; 
            if you've manually scaled or sheared the matrix this 
            function will not give correct results)"
        --]]

        --- @param transformationMatrix Matrix3dInstance
        --- @param input Vector
        --- @return Vector
        function STATIC.InverseTransformVector( transformationMatrix, input )
            typecheck.NotImplementedError( CLASS, "InverseTransformVector" )
        end

        --- @param transformationMatrix Matrix3dInstance
        --- @param input Vector
        --- @return Vector
        function STATIC.InverseRotateVector( transformationMatrix, input )
            typecheck.NotImplementedError( CLASS, "InverseRotateVector" )
        end
    end

    --- "Solve a linear system of 3 equations and 3 unknowns."
    --- @return boolean # "The 3x3 portion of the matrix is inverted and the final column is your answer"
    --- @param system Matrix3dInstance
    function STATIC.SolveLinearSystem( system )
        typecheck.NotImplementedError( CLASS, "SolveLinearSystem" )
    end

    --[[ Static Matrices ]] do

        STATIC.Identity = STATIC.New(
            1,   0,   0,   0,
            0,   1,   0,   0,
            0,   0,   1,   0
        )

        STATIC.RotateX90 = STATIC.New(
            1,   0,   0,   0,
            0,   0,  -1,   0,
            0,   1,   0,   0
        )

        STATIC.RotateX180 = STATIC.New(
            1,   0,   0,   0,
            0,  -1,   0,   0,
            0,   0,  -1,   0
        )

        STATIC.RotateY90 = STATIC.New(
            0,   0,   1,   0,
            0,   1,   0,   0,
           -1,   0,   0,   0
        )

        STATIC.RotateY180 = STATIC.New(
           -1,   0,   0,   0,
            0,   1,   0,   0,
            0,   0,  -1,   0
        )

        STATIC.RotateY270 = STATIC.New(
            0,   0,  -1,   0,
            0,   1,   0,   0,
            1,   0,   0,   0
        )

        STATIC.RotateZ90 = STATIC.New(
            0,  -1,   0,   0,
            1,   0,   0,   0,
            0,   0,   1,   0
        )

        STATIC.RotateZ180 = STATIC.New(
           -1,   0,   0,   0,
            0,  -1,   0,   0,
            0,   0,   1,   0
        )

        STATIC.RotateZ270 = STATIC.New(
            0,   1,   0,   0,
           -1,   0,   0,   0,
            0,   0,   1,   0
        )
    end
end


--[[ Instanced Functions and Variables ]] do
    local CLASS = "Matrix3dInstance"

    --- [[ Public ]]

    --- @class Matrix3dInstance
    --- @field Row Vector4Instance[]
    --- @operator mul( Vector ): Vector
    --- @operator mul( Matrix3dInstance ): Matrix3dInstance

    --- Constructs a new Matrix3dInstance
    function INSTANCE:Renegade_Matrix3d( ... )
        local args = { ... }
        local argCount = select( "#", ... )
        typecheck.AssertArgCount( CLASS, argCount, { 0, 1, 2, 3, 4, 12 } )

        self.Row = {
            vector4.New(),
            vector4.New(),
            vector4.New(),
            vector4.New()
        }

        -- ()
        if argCount == 0 then
            return
        end

        if argCount == 1 then
            typecheck.AssertArgType( CLASS, 1, args[1], { "boolean", "table", "Vector", "Matrix3dInstance" } )

            -- ( init: boolean )
            if typecheck.IsOfType( args[1], "boolean" ) then
                local init = args[1] --[[@as boolean]]

                if init then self:MakeIdentity() end
                return
            end

            -- ( init: number[] )
            if typecheck.IsOfType( args[1], "table" ) then
                local matrixValues = args[1] --[[@as number[] ]]

                local row1 = self.Row[1]
                row1[1] = matrixValues[0]
                row1[2] = matrixValues[1]
                row1[3] = matrixValues[2]
                row1[4] = matrixValues[3]

                local row2 = self.Row[2]
                row2[1] = matrixValues[4]
                row2[2] = matrixValues[5]
                row2[3] = matrixValues[6]
                row2[4] = matrixValues[7]

                local row3 = self.Row[3]
                row3[1] = matrixValues[8]
                row3[2] = matrixValues[9]
                row3[3] = matrixValues[10]
                row3[4] = matrixValues[11]
                return
            end

            -- ( pos: Vector )
            if typecheck.IsOfType( args[1], "Vector" ) then
                local pos = args[1] --[[@as Vector]]

                self:Set( pos )
                return
            end

            -- ( matrixToCopy: Matrix3dInstance )
            if typecheck.IsOfType( args[1], "Matrix3dInstance" ) then
                local matrixToCopy = args[1] --[[@as Matrix3dInstance]]

                local otherRow = matrixToCopy.Row

                local row1 = self.Row[1]
                local otherRow1 = otherRow[1]
                row1[1] = otherRow1[1]
                row1[2] = otherRow1[2]
                row1[3] = otherRow1[3]
                row1[4] = otherRow1[4]

                local row2 = self.Row[2]
                local otherRow2 = otherRow[2]
                row2[1] = otherRow2[1]
                row2[2] = otherRow2[2]
                row2[3] = otherRow2[3]
                row2[4] = otherRow2[4]

                local row3 = self.Row[3]
                local otherRow3 = otherRow[3]
                row3[1] = otherRow3[1]
                row3[2] = otherRow3[2]
                row3[3] = otherRow3[3]
                row3[4] = otherRow3[4]
                
                return
            end
        end

        if argCount == 2 then
            typecheck.AssertArgType( CLASS, 1, args[1], { "Vector", "Matrix3dInstance", "QuaternionInstance" } )
            typecheck.AssertArgType( CLASS, 2, args[2], { "number", "Vector" } )

            -- ( axis: Vector, angle: number )
            if typecheck.IsOfType( args[1], "Vector" ) then
                typecheck.AssertArgType( CLASS, 2, args[2], "number" )
                local axis  = args[1] --[[@as Vector]]
                local angle = args[2] --[[@as number]]

                self:Set( axis, angle )
                return
            end

            -- ( rotation: Matrix3dInstance, pos: Vector )
            if typecheck.IsOfType( args[1], "Matrix3dInstance" ) then
                typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )
                local rotation = args[1] --[[@as Matrix3dInstance]]
                local pos      = args[2] --[[@as Vector]]

                self:Set( rotation, pos )
                return
            end

            -- ( rotation: QuaternionInstance, pos: Vector )
            if typecheck.IsOfType( args[1], "QuaternionInstance" ) then
                typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )
                local rotation = args[1] --[[@as QuaternionInstance]]
                local pos      = args[2] --[[@as Vector]]

                self:Set( rotation, pos )
                return
            end
        end

        -- ( axis: Vector, sine: number, cosine: number )
        if argCount == 3 then
            typecheck.AssertArgType( CLASS, 1, args[1], "Vector" )
            typecheck.AssertArgType( CLASS, 2, args[2], "number" )
            typecheck.AssertArgType( CLASS, 3, args[3], "number" )
            local axis   = args[1] --[[@as Vector]]
            local sine   = args[2] --[[@as number]]
            local cosine = args[3] --[[@as number]]

            self:Set( axis, sine, cosine )
            return
        end

        -- ( x: Vector, y: Vectors, z: Vector, pos: Vector )
        if argCount == 4 then
            typecheck.AssertArgType( CLASS, 1, args[1], "Vector" )
            typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )
            typecheck.AssertArgType( CLASS, 3, args[3], "Vector" )
            typecheck.AssertArgType( CLASS, 4, args[4], "Vector" )

            local x   = args[1] --[[@as Vector]]
            local y   = args[1] --[[@as Vector]]
            local z   = args[1] --[[@as Vector]]
            local pos = args[1] --[[@as Vector]]

            self:Set( x, y, z, pos )
            return
        end

        -- ( m11: number, m12: number, m13: number, m14: number, 
        --   m21: number, m22: number, m23: number, m24: number, 
        --   m31: number, m32: number, m33: number, m34: number )
        if argCount == 12 then
            typecheck.AssertArgType( CLASS, 1,  args[1],  "number" )
            typecheck.AssertArgType( CLASS, 2,  args[2],  "number" )
            typecheck.AssertArgType( CLASS, 3,  args[3],  "number" )
            typecheck.AssertArgType( CLASS, 4,  args[4],  "number" )
            typecheck.AssertArgType( CLASS, 5,  args[5],  "number" )
            typecheck.AssertArgType( CLASS, 6,  args[6],  "number" )
            typecheck.AssertArgType( CLASS, 7,  args[7],  "number" )
            typecheck.AssertArgType( CLASS, 8,  args[8],  "number" )
            typecheck.AssertArgType( CLASS, 9,  args[9],  "number" )
            typecheck.AssertArgType( CLASS, 10, args[10], "number" )
            typecheck.AssertArgType( CLASS, 11, args[11], "number" )
            typecheck.AssertArgType( CLASS, 12, args[12], "number" )

            self.Row[1]:Set( args[1], args[2],  args[3],  args[4]  )
            self.Row[2]:Set( args[5], args[6],  args[7],  args[8]  )
            self.Row[3]:Set( args[9], args[10], args[11], args[12] )
            return
        end
    end

    --- @overload fun( self: Matrix3d, pos: Vector ): nil
    --- @overload fun( self: Matrix3d, matrixValues: number[] ): nil
    ---
    --- @overload fun( self: Matrix3d, axis: Vector, angle: number ): nil
    --- @overload fun( self: Matrix3d, rotation: Matrix3dInstance, pos: Vector ): nil
    --- @overload fun( self: Matrix3d, rotation: QuaternionInstance, pos: Vector ): nil
    ---
    --- @overload fun( self: Matrix3d, axis: Vector, sine: number, cosine: number ): nil
    ---
    --- @overload fun( self: Matrix3d, x: Vector, y: Vector, z: Vector, pos: Vector ): nil
    ---
    --- @overload fun( self: Matrix3d, m11: number, m12: number, m13: number, m14: number, m21: number, m22: number, m23: number, m24: number, m31: number, m32: number, m33: number, m34: number ): nil
    function INSTANCE:Set( ... )
        local args = { ... }
        local argCount = select( "#", ... )
        typecheck.AssertArgCount( CLASS, argCount, { 1, 2, 3, 4, 12 } )

        if argCount == 1 then
            typecheck.AssertArgType( CLASS, 1, args[1], { "Vector", "table" } )

            -- ( pos: Vector )
            if typecheck.IsOfType( args[1], "Vector" ) then
                local pos = args[1] --[[@as Vector]]

                self.Row[1]:Set( 1, 0, 0, pos.x )
                self.Row[2]:Set( 0, 1, 0, pos.y )
                self.Row[3]:Set( 0, 0, 1, pos.z )
                return
            end

            -- ( matrixValues: number[] )
            if typecheck.IsOfType( args[1], "table" ) then
                local matrixValues = args[1] --[[@as number[] ]]

                self.Row[1]:Set( matrixValues[1],  matrixValues[2],  matrixValues[3],  matrixValues[4]  )
                self.Row[2]:Set( matrixValues[5],  matrixValues[6],  matrixValues[7],  matrixValues[8]  )
                self.Row[3]:Set( matrixValues[9],  matrixValues[10], matrixValues[11], matrixValues[12] )
                return
            end
        end

        if argCount == 2 then
            typecheck.AssertArgType( CLASS, 1, args[1], { "Vector", "Matrix3dInstance", "QuaternionInstance" } )

            -- ( axis: Vector, angle: number )
            if typecheck.IsOfType( args[1], "Vector" ) then
                local axis  = args[1] --[[@as Vector]]
                local angle = typecheck.AssertArgType( CLASS, 2, args[2], "number" ) --[[@as number]]

                local cos = math.cos( angle )
                local sin = math.sin( angle )

                self:Set( axis, sin, cos )
                return
            end

            -- ( rotation: Matrix3Instance, pos: Vector )
            if typecheck.IsOfType( args[1], "Matrix3Instance" ) then
                typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )

                local rotation  = args[1] --[[@as Matrix3Instance]]
                local pos       = args[2] --[[@as Vector]]

                typecheck.NotImplementedError( CLASS, "( rotation: Matrix3Instance, pos: Vector )" )

                return
            end

            -- ( rotation: QuaternionInstance, pos: Vector )
            if typecheck.IsOfType( args[1], "QuaternionInstance" ) then
                typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )

                local rotation  = args[1] --[[@as QuaternionInstance]]
                local pos       = args[2] --[[@as Vector]]

                self:SetRotation( rotation )
                self:SetTranslation( pos )
                return
            end

            return
        end

        -- ( axis: Vector, sine: number, cosine: number )
        if argCount == 3 then
            local axis   = typecheck.AssertArgType( CLASS, 1, args[1], "Vector" ) --[[@as Vector]]
            local sine   = typecheck.AssertArgType( CLASS, 2, args[2], "number" ) --[[@as number]]
            local cosine = typecheck.AssertArgType( CLASS, 3, args[3], "number" ) --[[@as number]]

            self.Row[1]:Set(
                ( axis.x * axis.x + cosine * ( 1 - axis.x * axis.x ) ),
                ( axis.x * axis.y * ( 1 - cosine ) - axis.z * sine ),
                ( axis.z * axis.x * ( 1 - cosine ) + axis.y * sine ),
                0
            )

            self.Row[2]:Set(
                ( axis.x * axis.y * ( 1 - cosine ) + axis.z * sine ),
                ( axis.y * axis.y + cosine * ( 1 - axis.y * axis.y ) ),
                ( axis.y * axis.z * ( 1 - cosine ) - axis.x * sine ),
                0
            )

            self.Row[3]:Set(
                ( axis.z * axis.x * ( 1 - cosine ) - axis.y * sine ),
                ( axis.y * axis.z * ( 1 - cosine ) + axis.x * sine ),
                ( axis.z * axis.z + cosine * ( 1 - axis.z * axis.z ) ),
                0
            )

            return
        end

        -- ( x: Vector, y: Vector, z: Vector, pos: Vector )
        if argCount == 4 then
            typecheck.AssertArgType( CLASS, 1, args[1], "Vector" )
            typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )
            typecheck.AssertArgType( CLASS, 3, args[3], "Vector" )
            typecheck.AssertArgType( CLASS, 3, args[4], "Vector" )

            local x     = args[1] --[[@as Vector]]
            local y     = args[2] --[[@as Vector]]
            local z     = args[3] --[[@as Vector]]
            local pos   = args[4] --[[@as Vector]]

            self.Row[1]:Set( x.x, y.x, z.x, pos.x )
            self.Row[2]:Set( x.y, y.y, z.y, pos.y )
            self.Row[3]:Set( x.z, y.z, z.z, pos.z )
            return
        end

        -- (
        --    m11: number, m12: number, m13: number, m14: number,
        --    m21: number, m22: number, m23: number, m24: number,
        --    m31: number, m32: number, m33: number, m34: number
        -- )
        if argCount == 12 then
            typecheck.AssertArgType( CLASS, 1, args[1], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 2, args[2], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 3, args[3], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 4, args[4], "number" ) --[[@as number]]

            typecheck.AssertArgType( CLASS, 5, args[5], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 6, args[6], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 7, args[7], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 8, args[8], "number" ) --[[@as number]]

            typecheck.AssertArgType( CLASS, 9,  args[9],  "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 10, args[10], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 11, args[11], "number" ) --[[@as number]]
            typecheck.AssertArgType( CLASS, 12, args[12], "number" ) --[[@as number]]

            local m11 = args[1] --[[@as number]]
            local m12 = args[2] --[[@as number]]
            local m13 = args[3] --[[@as number]]
            local m14 = args[4] --[[@as number]]

            local m21 = args[5] --[[@as number]]
            local m22 = args[6] --[[@as number]]
            local m23 = args[7] --[[@as number]]
            local m24 = args[8] --[[@as number]]

            local m31 = args[9]  --[[@as number]]
            local m32 = args[10] --[[@as number]]
            local m33 = args[11] --[[@as number]]
            local m34 = args[12] --[[@as number]]

            self.Row[1]:Set( m11, m12, m13, m14 )
            self.Row[2]:Set( m21, m22, m23, m24 )
            self.Row[3]:Set( m31, m32, m33, m34 )
            return
        end
    end

    --[[ Operators ]] do

        --- @overload fun( self: Matrix3dInstance, other: Vector ): Vector
        --- @overload fun( self: Matrix3dInstance, other: Matrix3dInstance ): Matrix3dInstance
        function INSTANCE:__mul( other )
            typecheck.AssertArgType( CLASS, 1, other, { "Matrix3dInstance", "Vector" } )

            local selfValues = self.Row

            if isvector( other ) then
                --- @cast other Vector

                return Vector(
                    ( -- X
                        selfValues[1][1] * other.x +
                        selfValues[1][2] * other.y +
                        selfValues[1][3] * other.z +
                        selfValues[1][4]
                    ),
                    ( -- Y
                        selfValues[2][1] * other.x +
                        selfValues[2][2] * other.y +
                        selfValues[2][3] * other.z +
                        selfValues[2][4]
                    ),
                    ( -- Z
                        selfValues[3][1] * other.x +
                        selfValues[3][2] * other.y +
                        selfValues[3][3] * other.z +
                        selfValues[3][4]
                    )
                )
            else
                --- @cast other Matrix3dInstance

                local result = STATIC.New()
                local resultValues = result.Row

                local otherValues = other.Row

                --- @type number, number, number
                local temp1, temp2, temp3

                for row = 1, 4 do
                    temp1 = otherValues[1][row]
                    temp2 = otherValues[2][row]
                    temp3 = otherValues[3][row]

                    resultValues[1][row] = selfValues[1][1] * temp1 + selfValues[1][2] * temp2 + selfValues[1][3] * temp3
                    resultValues[2][row] = selfValues[2][1] * temp1 + selfValues[2][2] * temp2 + selfValues[2][3] * temp3
                    resultValues[3][row] = selfValues[3][1] * temp1 + selfValues[3][2] * temp2 + selfValues[3][3] * temp3

                    if row == 4 then
                        resultValues[1][row] = resultValues[1][row] + selfValues[1][4]
                        resultValues[2][row] = resultValues[2][row] + selfValues[2][4]
                        resultValues[3][row] = resultValues[3][row] + selfValues[3][4]
                    end
                end

                return result
            end
        end
    end

    --[[ Translation ]] do

        --- @return Vector
        function INSTANCE:GetTranslation()
            local row = self.Row
            return Vector( row[1][4], row[2][4], row[3][4] )
        end

        --- @param translation Vector
        function INSTANCE:SetTranslation( translation )
            local row = self.Row
            row[1][4] = translation.x
            row[2][4] = translation.y
            row[3][4] = translation.z
        end

        --- @return number
        function INSTANCE:GetXTranslation()
            return self.Row[1][4]
        end

        --- @param x number
        function INSTANCE:SetXTranslation( x )
            self.Row[1][4] = x
        end

        --- @return number
        function INSTANCE:GetYTranslation()
            return self.Row[2][4]
        end

        --- @param y number
        function INSTANCE:SetYTranslation( y )
            self.Row[2][4] = y
        end

        --- @return number
        function INSTANCE:GetZTranslation()
            return self.Row[3][4]
        end

        --- @param z number
        function INSTANCE:SetZTranslation( z )
            self.Row[3][4] = z
        end

        --- @param adjustment Vector
        function INSTANCE:AdjustTranslation( adjustment )
            local row = self.Row
            row[1][4] = row[1][4] + adjustment.x
            row[2][4] = row[2][4] + adjustment.y
            row[3][4] = row[3][4] + adjustment.z
        end

        --- @param adjustment number
        function INSTANCE:AdjustXTranslation( adjustment )
            local row = self.Row
            row[1][4] = row[1][4] + adjustment
        end

        --- @param adjustment number
        function INSTANCE:AdjustYTranslation( adjustment )
            local row = self.Row
            row[2][4] = row[2][4] + adjustment
        end

        --- @param adjustment number
        function INSTANCE:AdjustZTranslation( adjustment )
            local row = self.Row
            row[3][4] = row[3][4] + adjustment
        end
    end

    --[[ Rotation ]] do

        --- @overload fun( rotation: Matrix3dInstance ): nil
        --- @overload fun( rotation: QuaternionInstance ): nil
        function INSTANCE:SetRotation( ... )
            local args = { ... }
            local argCount = select( "#", ... )
            typecheck.AssertArgCount( CLASS, argCount, 1 )

            if typecheck.IsOfType( args[1], "Matrix3dInstance" ) then
                local rotation = args[1] --[[@as Matrix3dInstance]]

                local row = self.Row
                local rotRow = rotation.Row

                row[1][1] = rotRow[1][1]
                row[1][2] = rotRow[1][2]
                row[1][3] = rotRow[1][3]

                row[2][1] = rotRow[2][1]
                row[2][2] = rotRow[2][2]
                row[2][3] = rotRow[2][3]

                row[3][1] = rotRow[3][1]
                row[3][2] = rotRow[3][2]
                row[3][3] = rotRow[3][3]
                return
            end

            if typecheck.IsOfType( args[1], "QuaternionInstance" ) then
                typecheck.NotImplementedError( CLASS, "Quaternion" )
                return
            end
        end

        --- "Approximates the rotation about the X axis"
        --- @return number
        function INSTANCE:GetXRotation()
            local row = self.Row
            return math.atan2( row[3][2], row[2][2] )
        end

        --- "Approximates the rotation about the Y axis"
        --- @return number
        function INSTANCE:GetYRotation()
            local row = self.Row
            return math.atan2( row[1][3], row[3][3] )
        end

        --- "Approximates the rotation about the Z axis"
        --- @return number
        function INSTANCE:GetZRotation()
            local row = self.Row
            return math.atan2( row[2][1], row[1][1] )
        end
    end

    --[[ Transformation ]] do

        --- "Initializes the matrix to be the identity matrix"
        function INSTANCE:MakeIdentity()
            local row = self.Row
            row[1]:Set( 1, 0, 0, 0 )
            row[2]:Set( 0, 1, 0, 0 )
            row[3]:Set( 0, 0, 1, 0 )
        end

        --- @overload fun( x: number, y: number, z: number ): nil
        --- @overload fun( translation: Vector ): nil
        function INSTANCE:Translate( ... )
            local args = {...}
            local argCount = select( "#", ... )
            typecheck.AssertArgCount( CLASS, argCount, { 1, 3 } )

            --- @type number, number, number
            local x, y, z

            if argCount == 1 then
                typecheck.AssertArgType( CLASS, 1, args[1], "Vector" )

                local translation = args[1] --[[@as Vector]]

                x = translation.x
                y = translation.y
                z = translation.z
            end

            if argCount == 3 then
                typecheck.AssertArgType( CLASS, 1, args[1], "number" )
                typecheck.AssertArgType( CLASS, 2, args[2], "number" )
                typecheck.AssertArgType( CLASS, 3, args[3], "number" )

                x = args[1] --[[@as number]]
                y = args[2] --[[@as number]]
                z = args[3] --[[@as number]]
            end

            local row = self.Row
            row[1][4] = row[1][4] + row[1][1] * x + row[1][2] * y + row[1][3] * z
            row[2][4] = row[2][4] + row[2][1] * x + row[2][2] * y + row[2][3] * z
            row[3][4] = row[3][4] + row[3][1] * x + row[3][2] * y + row[3][3] * z
        end

        --- @param x number
        function INSTANCE:TranslateX( x )
            typecheck.NotImplementedError( CLASS, "TranslateX" )
        end

        --- @param y number
        function INSTANCE:TranslateY( y )
            typecheck.NotImplementedError( CLASS, "TranslateY" )
        end

        --- @param z number
        function INSTANCE:TranslateZ( z )
            typecheck.NotImplementedError( CLASS, "TranslateZ" )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:RotateX( ... )
            local args = { ... }
            local argCount = select( "#", ... )
            typecheck.AssertArgCount( CLASS, argCount, { 1, 2 } )

            --- @type number, number
            local sine, cosine

            -- ( theta: number )
            if argCount == 1 then
                typecheck.AssertArgType( CLASS, 1, args[1], "number" )

                local theta = args[1] --[[@as number]]

                sine   = math.sin( theta )
                cosine = math.cos( theta )
            end

            -- ( sine: number, cosine: number )
            if argCount == 2 then
                typecheck.AssertArgType( CLASS, 1, args[1], "number" )
                typecheck.AssertArgType( CLASS, 2, args[2], "number" )

                sine   = args[1] --[[@as number]]
                cosine = args[2] --[[@as number]]
            end

            local row = self.Row

            local temp1 = row[1][2]
            local temp2 = row[1][3]
            row[1][2] = (  cosine * temp1 + sine   * temp2 )
            row[1][3] = ( -sine   * temp1 + cosine * temp2 )

            temp1 = row[2][2]
            temp2 = row[2][3];
            row[2][2] = (  cosine * temp1 + sine   * temp2 )
            row[2][3] = ( -sine   * temp1 + cosine * temp2 )

            temp1 = row[3][2]
            temp2 = row[3][3]
            row[3][2] = (  cosine * temp1 + sine   * temp2 )
            row[3][3] = ( -sine   * temp1 + cosine * temp2 )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:RotateY( ... )
            local args = { ... }
            local argCount = select( "#", ... )
            typecheck.AssertArgCount( CLASS, argCount, { 1, 2 } )

            --- @type number, number
            local sine, cosine

            -- ( theta: number )
            if argCount == 1 then
                typecheck.AssertArgType( CLASS, 1, args[1], "number" )

                local theta = args[1] --[[@as number]]

                sine   = math.sin( theta )
                cosine = math.cos( theta )
            end

            -- ( sine: number, cosine: number )
            if argCount == 2 then
                typecheck.AssertArgType( CLASS, 1, args[1], "number" )
                typecheck.AssertArgType( CLASS, 2, args[2], "number" )

                sine   = args[1] --[[@as number]]
                cosine = args[2] --[[@as number]]
            end

            local row = self.Row

            local temp1 = row[1][1]
            local temp2 = row[1][3]
            row[1][1] = ( cosine * temp1 - sine   * temp2 )
            row[1][3] = ( sine   * temp1 + cosine * temp2 )

            temp1 = row[2][1]
            temp2 = row[2][3];
            row[2][1] = ( cosine * temp1 - sine   * temp2 )
            row[2][3] = ( sine   * temp1 + cosine * temp2 )

            temp1 = row[3][1]
            temp2 = row[3][3]
            row[3][1] = ( cosine * temp1 - sine   * temp2 )
            row[3][3] = ( sine   * temp1 + cosine * temp2 )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:RotateZ( ... )
            local args = { ... }
            local argCount = select( "#", ... )
            typecheck.AssertArgCount( CLASS, argCount, { 1, 2 } )

            --- @type number, number
            local sine, cosine

            -- ( theta: number )
            if argCount == 1 then
                typecheck.AssertArgType( CLASS, 1, args[1], "number" )

                local theta = args[1] --[[@as number]]

                sine   = math.sin( theta )
                cosine = math.cos( theta )
            end

            -- ( sine: number, cosine: number )
            if argCount == 2 then
                typecheck.AssertArgType( CLASS, 1, args[1], "number" )
                typecheck.AssertArgType( CLASS, 2, args[2], "number" )

                sine   = args[1] --[[@as number]]
                cosine = args[2] --[[@as number]]
            end

            local row = self.Row

            local temp1 = row[1][1]
            local temp2 = row[1][2]
            row[1][1] = (  cosine * temp1 + sine   * temp2 )
            row[1][2] = ( -sine   * temp1 + cosine * temp2 )

            temp1 = row[2][1]
            temp2 = row[2][2];
            row[2][1] = (  cosine * temp1 + sine   * temp2 )
            row[2][2] = ( -sine   * temp1 + cosine * temp2 )

            temp1 = row[3][1]
            temp2 = row[3][2]
            row[3][1] = (  cosine * temp1 + sine   * temp2 )
            row[3][2] = ( -sine   * temp1 + cosine * temp2 )
        end
    end

    --[[ Scale ]] do

        --[[
            "Use Scale methods with Extreme Caution
            The Matrix Inverse function, only works
            with Orthogonal Matrices, for optimization purposes"
        --]]

        --- @overload fun( scale: number ): nil
        --- @overload fun( scale: Vector ): nil
        --- @overload fun( x: number, y: number, z: number ): nil
        function INSTANCE:Scale( ... )
            typecheck.NotImplementedError( CLASS, "Scale" )
        end
    end

    --[[ Pre-Multiplied Functions ]] do

        --[[
            "Each of these performs an "optimized" pre-multiplication with they
            current matrix. All angles are assumed to be radians. The "In_Place"
            versions do not affect the translation part of the matrix,
        --]]

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:PreRotateX( ... )
            typecheck.NotImplementedError( CLASS, "PreRotateX" )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:PreRotateY( ... )
            typecheck.NotImplementedError( CLASS, "PreRotateY" )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:PreRotateZ( ... )
            typecheck.NotImplementedError( CLASS, "PreRotateZ" )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:InPlacePreRotateX( ... )
            typecheck.NotImplementedError( CLASS, "InPlacePreRotateX" )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:InPlacePreRotateY( ... )
            typecheck.NotImplementedError( CLASS, "InPlacePreRotateY" )
        end

        --- @overload fun( self: Matrix3dInstance, theta: number ): nil
        --- @overload fun( self: Matrix3dInstance, sine: number, cosine: number ): nil
        function INSTANCE:InPlacePreRotateZ( ... )
            typecheck.NotImplementedError( CLASS, "InPlacePreRotateZ" )
        end
    end

    --[[ Look At ]] do

        --- "Points the negative Z axis at the target.  Assumes that
        --- the "world" uses x-y as the ground and z as altitude."  
        --- "Used for pointing cameras at targets."
        --- @param lookFrom Vector
        --- @param lookAt Vector
        --- @param roll number
        function INSTANCE:LookAt( lookFrom, lookAt, roll )
            --- @type number, number, number, number
            local sinPitch, cosPitch, sinYaw, cosYaw

            local dX = lookAt.x - lookFrom.x
            local dY = lookAt.y - lookFrom.y
            local dZ = lookAt.z - lookFrom.z

            local rad2 = ( dX * dX ) + ( dY * dY )
            local length = math.sqrt( rad2 )

            if rad2 ~= 0 then
                local invertedLength = 1 / length
                sinYaw = dY * invertedLength
                cosYaw = dX * invertedLength
            else
                sinYaw = 0
                cosYaw = 1
            end

            rad2 = rad2 + ( dZ * dZ )

            if rad2 ~= 0 then
                local invertedLength2 = 1 / math.sqrt( rad2 )
                sinPitch = dZ * invertedLength2
                cosPitch = length * invertedLength2
            else
                sinPitch = 0
                cosPitch = 1
            end

            local row = self.Row
            local row1, row2, row3 = row[1], row[2], row[3]

            row1.x, row1.y, row1.z =  0,  0, -1
            row2.x, row2.y, row2.z = -1,  0,  0
            row3.x, row3.y, row3.z =  0,  1,  0

            row[1].w = lookFrom.x
            row[2].w = lookFrom.y
            row[3].w = lookFrom.z

            -- "Yaw rotation to make the matrix look at the projection of the target into the x-y plane"
            self:RotateY( sinYaw, cosYaw )

            -- Rotate about local x axis to pitch up to the target's position
            self:RotateX( -sinPitch, -cosPitch )

            -- Roll about the local Z axis (negate since we look down -z)
            self:RotateZ( roll )
        end

        -- "[The] look_at function follows the camera coordinate convention."  
        -- "This one follows the object convention used in Commando and G."  
        -- "I special cased this convention since it is used so much by us rather
        -- than supporting every one of the 24(?) possible conventions..."
        --- @param p Vector
        --- @param target Vector
        --- @param roll number
        function INSTANCE:EntityLookAt( p, target, roll )
            typecheck.NotImplementedError( CLASS, "LookAt" )
        end
    end

    --[[ Rotate Vector ]] do

        --- @param vec Vector
        --- @return Vector
        function INSTANCE:RotateVector( vec )
            local row = self.Row
            return Vector(
                row[1][1] * vec.x + row[1][2] * vec.y + row[1][3] * vec.z,
                row[2][1] * vec.x + row[2][2] * vec.y + row[2][3] * vec.z,
                row[3][1] * vec.x + row[3][2] * vec.y + row[3][3] * vec.z
            )
        end

        --- @param vec Vector
        --- @return Vector
        function INSTANCE:InverseRotateVector( vec )
            typecheck.NotImplementedError( CLASS, "InverseRotateVector" )
        end
    end

    --[[ Directions ]] do

        --- Gets a Vector representing the matrix's local X direction
        --- @return Vector
        function INSTANCE:GetXVector()
            local row = self.Row
            return Vector( row[1][1], row[2][1], row[3][1] )
        end

        --- Gets a Vector representing the matrix's local Y direction
        --- @return Vector
        function INSTANCE:GetYVector()
            local row = self.Row
            return Vector( row[1][2], row[2][2], row[3][2] )
        end

        --- Gets a Vector representing the matrix's local Z direction
        --- @return Vector
        function INSTANCE:GetZVector()
            local row = self.Row
            return Vector( row[1][3], row[2][3], row[3][3] )
        end
    end

    --[[ Inverses ]] do

        --[[
            "TODO: currently the "intended-to-be" general inverse function 
            just calls the special case Orthogonal inverse functions."

            "Also, when we implement general case, check where we were using
            Get_Inverse since usually it should be changed to Get_Orthogonal_Inverse..."
        --]]

        --- @return Matrix3dInstance
        function INSTANCE:GetInverse()
            return self:GetOrthogonalInverse()
        end

        --- "Note: This only works if the matrix is really orthogonal"
        --- @return Matrix3dInstance # The inverse of the matrix
        function INSTANCE:GetOrthogonalInverse()

            local result = STATIC.New()
            local resRow = result.Row

            local row = self.Row

            --[[ Transposing the rotation submatrix ]] do

                resRow[1][1] = row[1][1]
                resRow[1][2] = row[2][1]
                resRow[1][3] = row[3][1]

                resRow[2][1] = row[1][2]
                resRow[2][2] = row[2][2]
                resRow[2][3] = row[3][2]

                resRow[3][1] = row[1][3]
                resRow[3][2] = row[2][3]
                resRow[3][3] = row[3][3]
            end

            --[[ Calculate Translation ]] do

                local translation = self:GetTranslation()
                translation = result:RotateVector( translation )
                translation = -translation

                resRow[1][4] = translation.x
                resRow[2][4] = translation.y
                resRow[3][4] = translation.z
            end

            return result
        end
    end

    --- "Used for importing SurRender matrices"
    --- @param matrix number[][]
    function INSTANCE:Copy3x3Matrix( matrix )
        typecheck.NotImplementedError( CLASS, "Copy3x3Matrix" )
    end

    --[[ AABox ]] do

        --[[
            "Optimized Axis-Aligned Box transforms."
            
            "One for each of the common forms of axis aligned box: 
            min, max vectors
            center, extent vectors."
        --]]

        --- @param min Vector
        --- @param max Vector
        --- @param setMin Vector
        --- @param setMax Vector
        function INSTANCE:TransformMinMaxAABox( min, max, setMin, setMax )
            typecheck.NotImplementedError( CLASS, "TransformMinMaxAABox" )
        end

        --- @param center Vector
        --- @param extent Vector
        --- @return Vector newCenter
        --- @return Vector newExtent
        function INSTANCE:TransformCenterExtentAABox( center, extent )
            local row = self.Row

            --- @type Vector, Vector
            local newCenter, newExtent = Vector(), Vector()

            -- "Push each extent out to the projections of the original extents"
            for i = 1, 3 do
                -- "Start the center out at the translation portion of the matrix and the extent at zero"
                newCenter[i] = row[i][4]
                newExtent[i] = 0

                for j = 1, 3 do
                    newCenter[i] = newCenter[i] + row[i][j] * center[j]
                    newExtent[i] = newExtent[i] + math.abs( row[i][j] * extent[j] )
                end
            end

            return newCenter, newExtent
        end
    end

    --[[ Orthogonal ]] do

        function INSTANCE:IsOrthogonal()
            typecheck.NotImplementedError( CLASS, "IsOrthogonal" )
        end

        --- Force the Matrix to be orthogonal
        function INSTANCE:ReOrthogonalize()
            typecheck.NotImplementedError( CLASS, "ReOrthogonalize" )
        end
    end

    --- [[ Private ]]

    --- @class Matrix3dInstance

end