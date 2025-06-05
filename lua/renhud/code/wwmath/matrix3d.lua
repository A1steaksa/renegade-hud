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


--#region Imports

--#endregion


--#region Enums

--#endregion

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

    ---@param arg any
    ---@return boolean `true` if the passed argument is a(n) Matrix3dInstance, `false` otherwise
    function STATIC.IsMatrix3d( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMatrix3d
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

    --- Constructs a new Matrix3dInstance
    function INSTANCE:Renegade_Matrix3d( ... )
        local args = { ... }
        local argCount = select( "#", ... )
        typecheck.AssertVarArgCount( CLASS, { 0, 1, 2, 3, 4, 12 }, ... )

        self.VMatrix = Matrix()

        -- ()
        if argCount == 0 then
            return
        end

        if argCount == 1 then
            typecheck.AssertType( CLASS, 1, args[1], { "boolean", "table", "Vector", "Matrix3dInstance" } )

            -- ( init: boolean )
            if typecheck.IsOfType( args[1], "boolean" ) then
                local init = args[1] --[[@as boolean]]

                if init then self:MakeIdentity() end
                return
            end

            -- ( init: number[] )
            if typecheck.IsOfType( args[1], "table" ) then
                local matrixValues = args[1] --[[@as number[] ]]
                self.VMatrix:SetUnpacked(
                    matrixValues[0], matrixValues[1], matrixValues[2],  matrixValues[3],
                    matrixValues[4], matrixValues[5], matrixValues[6],  matrixValues[7],
                    matrixValues[8], matrixValues[9], matrixValues[10], matrixValues[11],
                    0, 0, 0, 1
                )
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

                self.VMatrix:Set( matrixToCopy.VMatrix )
                return
            end
        end

        if argCount == 2 then
            typecheck.AssertType( CLASS, 1, args[1], { "Vector", "Matrix3dInstance", "QuaternionInstance" } )
            typecheck.AssertType( CLASS, 2, args[2], { "number", "Vector" } )

            -- ( axis: Vector, angle: number )
            if typecheck.IsOfType( args[1], "Vector" ) then
                typecheck.AssertType( CLASS, 2, args[2], "number" )
                local axis  = args[1] --[[@as Vector]]
                local angle = args[2] --[[@as number]]

                self:Set( axis, angle )
                return
            end

            -- ( rotation: Matrix3dInstance, pos: Vector )
            if typecheck.IsOfType( args[1], "Matrix3dInstance" ) then
                typecheck.AssertType( CLASS, 2, args[2], "Vector" )
                local rotation = args[1] --[[@as Matrix3dInstance]]
                local pos      = args[2] --[[@as Vector]]

                self:Set( rotation, pos )
                return
            end

            -- ( rotation: QuaternionInstance, pos: Vector )
            if typecheck.IsOfType( args[1], "QuaternionInstance" ) then
                typecheck.AssertType( CLASS, 2, args[2], "Vector" )
                local rotation = args[1] --[[@as QuaternionInstance]]
                local pos      = args[2] --[[@as Vector]]

                self:Set( rotation, pos )
                return
            end
        end

        -- ( axis: Vector, sine: number, cosine: number )
        if argCount == 3 then
            typecheck.AssertType( CLASS, 1, args[1], "Vector" )
            typecheck.AssertType( CLASS, 2, args[2], "number" )
            typecheck.AssertType( CLASS, 3, args[3], "number" )
            local axis   = args[1] --[[@as Vector]]
            local sine   = args[2] --[[@as number]]
            local cosine = args[3] --[[@as number]]

            self:Set( axis, sine, cosine )
            return
        end

        -- ( x: Vector, y: Vectors, z: Vector, pos: Vector )
        if argCount == 4 then
            typecheck.AssertType( CLASS, 1, args[1], "Vector" )
            typecheck.AssertType( CLASS, 2, args[2], "Vector" )
            typecheck.AssertType( CLASS, 3, args[3], "Vector" )
            typecheck.AssertType( CLASS, 4, args[4], "Vector" )

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
            typecheck.AssertType( CLASS, 1,  args[1],  "number" )
            typecheck.AssertType( CLASS, 2,  args[2],  "number" )
            typecheck.AssertType( CLASS, 3,  args[3],  "number" )
            typecheck.AssertType( CLASS, 4,  args[4],  "number" )
            typecheck.AssertType( CLASS, 5,  args[5],  "number" )
            typecheck.AssertType( CLASS, 6,  args[6],  "number" )
            typecheck.AssertType( CLASS, 7,  args[7],  "number" )
            typecheck.AssertType( CLASS, 8,  args[8],  "number" )
            typecheck.AssertType( CLASS, 9,  args[9],  "number" )
            typecheck.AssertType( CLASS, 10, args[10], "number" )
            typecheck.AssertType( CLASS, 11, args[11], "number" )
            typecheck.AssertType( CLASS, 12, args[12], "number" )

            local m11, m12, m13, m14 = args[1]  --[[@as number]], args[2]  --[[@as number]], args[3]  --[[@as number]], args[4]  --[[@as number]]
            local m21, m22, m23, m24 = args[5]  --[[@as number]], args[6]  --[[@as number]], args[7]  --[[@as number]], args[8]  --[[@as number]]
            local m31, m32, m33, m34 = args[9]  --[[@as number]], args[10] --[[@as number]], args[11] --[[@as number]], args[12] --[[@as number]]

            self.VMatrix:SetUnpacked(
                m11, m12, m13, m14,
                m21, m22, m23, m24,
                m31, m32, m33, m34,
                0, 0, 0, 1
            )
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
        typecheck.AssertVarArgCount( CLASS, { 1, 2, 3, 4, 12 }, ... )

        if argCount == 1 then
            typecheck.AssertArgType( CLASS, 1, args, { "Vector", "table" } )

            -- ( pos: Vector )
            if typecheck.IsOfType( args[1], "Vector" ) then
                local pos = args[1] --[[@as Vector]]

                self.VMatrix:SetUnpacked(
                    1, 0, 0, pos.x,
                    0, 1, 0, pos.y,
                    0, 0, 1, pos.z,
                    0, 0, 0, 1
                )
                return
            end

            -- ( matrixValues: number[] )
            if typecheck.IsOfType( args[1], "table" ) then
                local matrixValues = args[1] --[[@as number[] ]]

                self.VMatrix:SetUnpacked(
                    matrixValues[1],  matrixValues[2],  matrixValues[3],  matrixValues[4],
                    matrixValues[5],  matrixValues[6],  matrixValues[7],  matrixValues[8],
                    matrixValues[9],  matrixValues[10], matrixValues[11], matrixValues[12],
                    0, 0, 0, 1
                )
                return
            end
        end


        if argCount == 2 then
            typecheck.AssertArgType( CLASS, 1, args, { "Vector", "Matrix3dInstance", "QuaternionInstance" } )

            -- ( axis: Vector, angle: number )
            if typecheck.IsOfType( args[1], "Vector" ) then
                local axis  = args[1] --[[@as Vector]]
                local angle = typecheck.AssertArgType( CLASS, 2, args, "number" ) --[[@as number]]

                local cos = math.cos( angle )
                local sin = math.sin( angle )

                self:Set( axis, sin, cos )
                return
            end

            -- ( rotation: Matrix3dInstance, pos: Vector )
            if typecheck.IsOfType( args[1], "Matrix3dInstance" ) then
                typecheck.AssertArgType( CLASS, 2, args, "Vector" )

                local rotation  = args[1] --[[@as Matrix3dInstance]]
                local pos       = args[2] --[[@as Vector]]

                local rotMatrix = rotation.VMatrix

                self.VMatrix:SetUnpacked(
                	rotMatrix:GetField( 1, 1 ), rotMatrix:GetField( 1, 2 ), rotMatrix:GetField( 1, 3 ), pos.x,
                    rotMatrix:GetField( 2, 1 ), rotMatrix:GetField( 2, 2 ), rotMatrix:GetField( 2, 3 ), pos.y,
                    rotMatrix:GetField( 3, 1 ), rotMatrix:GetField( 3, 2 ), rotMatrix:GetField( 3, 3 ), pos.z,
                    0, 0, 0, 1
                )
                return
            end

            -- ( rotation: QuaternionInstance, pos: Vector )
            if typecheck.IsOfType( args[1], "QuaternionInstance" ) then
                typecheck.AssertArgType( CLASS, 2, args, "Vector" )

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
            local axis   = typecheck.AssertArgType( CLASS, 1, args, "Vector" ) --[[@as Vector]]
            local sine   = typecheck.AssertArgType( CLASS, 2, args, "number" ) --[[@as number]]
            local cosine = typecheck.AssertArgType( CLASS, 3, args, "number" ) --[[@as number]]

            self.VMatrix:SetUnpacked(
                ( axis.x * axis.x + cosine * ( 1 - axis.x * axis.x ) ),
                ( axis.x * axis.y * ( 1 - cosine ) - axis.z * sine ),
                ( axis.z * axis.x * ( 1 - cosine ) + axis.y * sine ),
                0,
                ( axis.x * axis.y * ( 1 - cosine ) + axis.z * sine ),
                ( axis.y * axis.y + cosine * ( 1 - axis.y * axis.y ) ),
                ( axis.y * axis.z * ( 1 - cosine ) - axis.x * sine ),
                0,
                ( axis.z * axis.x * ( 1 - cosine ) - axis.y * sine ),
                ( axis.y * axis.z * ( 1 - cosine ) + axis.x * sine ),
                ( axis.z * axis.z + cosine * ( 1 - axis.z * axis.z ) ),
                0,
                0, 0, 0, 1
            )

            return
        end

        -- ( x: Vector, y: Vector, z: Vector, pos: Vector )
        if argCount == 4 then
            local x     = typecheck.AssertArgType( CLASS, 1, args, "Vector" ) --[[@as Vector]]
            local y     = typecheck.AssertArgType( CLASS, 2, args, "Vector" ) --[[@as Vector]]
            local z     = typecheck.AssertArgType( CLASS, 3, args, "Vector" ) --[[@as Vector]]
            local pos   = typecheck.AssertArgType( CLASS, 3, args, "Vector" ) --[[@as Vector]]

            self.VMatrix:SetUnpacked(
                x.x, y.x, z.x, pos.x,
                x.y, y.y, z.y, pos.y,
                x.z, y.z, z.z, pos.z,
                0, 0, 0, 1
            )
            return
        end

        -- (
        --    m11: number, m12: number, m13: number, m14: number,
        --    m21: number, m22: number, m23: number, m24: number,
        --    m31: number, m32: number, m33: number, m34: number
        -- )
        if argCount == 12 then
            local m11 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m12 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m13 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m14 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]

            local m21 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m22 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m23 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m24 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]

            local m31 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m32 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m33 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]
            local m34 = typecheck.AssertArgType( CLASS, 1, args, "number" ) --[[@as number]]

            self.VMatrix:SetUnpacked(
                m11, m12, m13, m14,
                m21, m22, m23, m24,
                m31, m32, m33, m34,
                0, 0, 0, 1
            )
            return
        end
    end

    --[[ Translation ]] do

        --- @return Vector
        function INSTANCE:GetTranslation()
            local matrix = self.VMatrix
            return Vector( matrix:GetField( 1, 4 ), matrix:GetField( 2, 4 ), matrix:GetField( 3, 4 ) )
        end

        --- @param translation Vector
        function INSTANCE:SetTranslation( translation )
            local matrix = self.VMatrix
            matrix:SetField( 1, 4, translation.x )
            matrix:SetField( 2, 4, translation.y )
            matrix:SetField( 3, 4, translation.z )
        end

        --- @return number
        function INSTANCE:GetXTranslation()
            return self.VMatrix:GetField( 1, 4 )
        end

        --- @param x number
        function INSTANCE:SetXTranslation( x )
            self.VMatrix:SetField( 1, 4, x )
        end

        --- @return number
        function INSTANCE:GetYTranslation()
            return self.VMatrix:GetField( 2, 4 )
        end

        --- @param y number
        function INSTANCE:SetYTranslation( y )
            self.VMatrix:SetField( 2, 4, y )
        end

        --- @return number
        function INSTANCE:GetZTranslation()
            return self.VMatrix:GetField( 3, 4 )
        end

        --- @param z number
        function INSTANCE:SetXTranslation( z )
            self.VMatrix:SetField( 3, 4, z )
        end

        --- @param adjustment Vector
        function INSTANCE:AdjustTranslation( adjustment )
            local matrix = self.VMatrix

            matrix:SetField( 1, 4, matrix:GetField( 1, 4 ) + adjustment.x )
            matrix:SetField( 2, 4, matrix:GetField( 2, 4 ) + adjustment.y )
            matrix:SetField( 3, 4, matrix:GetField( 3, 4 ) + adjustment.z )
        end

        --- @param adjustment number
        function INSTANCE:AdjustXTranslation( adjustment )
            local matrix = self.VMatrix
            matrix:SetField( 1, 4, matrix:GetField( 1, 4 ) + adjustment )
        end

        --- @param adjustment number
        function INSTANCE:AdjustYTranslation( adjustment )
            local matrix = self.VMatrix
            matrix:SetField( 1, 4, matrix:GetField( 2, 4 ) + adjustment )
        end

        --- @param adjustment number
        function INSTANCE:AdjustZTranslation( adjustment )
            local matrix = self.VMatrix
            matrix:SetField( 1, 4, matrix:GetField( 3, 4 ) + adjustment )
        end
    end

    --[[ Rotation ]] do

        --- @overload fun( rotation: Matrix3dInstance ): nil
        --- @overload fun( rotation: QuaternionInstance ): nil
        function INSTANCE:SetRotation( ... )
            local args = { ... }
            typecheck.AssertVarArgCount( CLASS, 1, ... )

            if typecheck.IsOfType( args[1], "Matrix3dInstance" ) then
                local rotation = args[1] --[[@as Matrix3dInstance]]
                local rotTbl = rotation.VMatrix:ToTable()

                local matrix = self.VMatrix

                matrix:SetField( 1, 1, rotTbl[1][1] )
                matrix:SetField( 1, 2, rotTbl[1][2] )
                matrix:SetField( 1, 3, rotTbl[1][3] )

                matrix:SetField( 2, 1, rotTbl[2][1] )
                matrix:SetField( 2, 2, rotTbl[2][2] )
                matrix:SetField( 2, 3, rotTbl[2][3] )

                matrix:SetField( 3, 1, rotTbl[3][1] )
                matrix:SetField( 3, 2, rotTbl[3][2] )
                matrix:SetField( 3, 3, rotTbl[3][3] )
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
            local matrix = self.VMatrix
            return math.atan2(
                matrix:GetField( 3, 2 ),
                matrix:GetField( 2, 2 )
            )
        end

        --- "Approximates the rotation about the Y axis"
        --- @return number
        function INSTANCE:GetYRotation()
            local matrix = self.VMatrix
            return math.atan2(
                matrix:GetField( 1, 3 ),
                matrix:GetField( 3, 3 )
            )
        end

        --- "Approximates the rotation about the Z axis"
        --- @return number
        function INSTANCE:GetZRotation()
            local matrix = self.VMatrix
            return math.atan2(
                matrix:GetField( 2, 1 ),
                matrix:GetField( 1, 1 )
            )
        end
    end

    --[[ Transformation ]] do

        --- "Initializes the matrix to be the identity matrix"
        function INSTANCE:MakeIdentity()
            self.VMatrix:SetUnpacked(
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
            )
        end

        --- @overload fun( x: number, y: number, z: number ): nil
        --- @overload fun( translation: Vector ): nil
        function INSTANCE:Translate( ... )
            typecheck.NotImplementedError( CLASS, "Translate" )
        end

        --- @param x number
        function INSTANCE:TranslateX( x )
            typecheck.NotImplementedError( CLASS, "TranslateX" )
        end

        --- @param y number
        function INSTANCE:TranslateX( y )
            typecheck.NotImplementedError( CLASS, "TranslateY" )
        end

        --- @param z number
        function INSTANCE:TranslateX( z )
            typecheck.NotImplementedError( CLASS, "TranslateZ" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:RotateX( ... )
            typecheck.NotImplementedError( CLASS, "RotateX" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:RotateY( ... )
            typecheck.NotImplementedError( CLASS, "RotateY" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:RotateZ( ... )
            typecheck.NotImplementedError( CLASS, "RotateZ" )
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

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:PreRotateX( ... )
            typecheck.NotImplementedError( CLASS, "PreRotateX" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:PreRotateY( ... )
            typecheck.NotImplementedError( CLASS, "PreRotateY" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:PreRotateZ( ... )
            typecheck.NotImplementedError( CLASS, "PreRotateZ" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:InPlacePreRotateX( ... )
            typecheck.NotImplementedError( CLASS, "InPlacePreRotateX" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:InPlacePreRotateY( ... )
            typecheck.NotImplementedError( CLASS, "InPlacePreRotateY" )
        end

        --- @overload fun( theta: number ): nil
        --- @overload fun( sine: number, cosine: number ): nil
        function INSTANCE:InPlacePreRotateZ( ... )
            typecheck.NotImplementedError( CLASS, "InPlacePreRotateZ" )
        end
    end

    --[[ Look At ]] do

        --- "Points the negative Z axis at the target.  Assumes that
        --- the "world" uses x-y as the ground and z as altitude."  
        --- "Used for pointing cameras at targets."
        --- @param p Vector
        --- @param target Vector
        --- @param roll number
        function INSTANCE:LookAt( p, target, roll )
            typecheck.NotImplementedError( CLASS, "LookAt" )
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
            typecheck.NotImplementedError( CLASS, "RotateVector" )
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
            local matrix = self.VMatrix
            return Vector(
                matrix:GetField( 1, 1 ),
                matrix:GetField( 2, 1 ),
                matrix:GetField( 3, 1 )
            )
        end

        --- Gets a Vector representing the matrix's local Y direction
        --- @return Vector
        function INSTANCE:GetYVector()
            local matrix = self.VMatrix
            return Vector(
                matrix:GetField( 1, 2 ),
                matrix:GetField( 2, 2 ),
                matrix:GetField( 3, 2 )
            )
        end

        --- Gets a Vector representing the matrix's local Z direction
        --- @return Vector
        function INSTANCE:GetZVector()
            local matrix = self.VMatrix
            return Vector(
                matrix:GetField( 1, 3 ),
                matrix:GetField( 2, 3 ),
                matrix:GetField( 3, 3 )
            )
        end
    end

    --[[ Inverses ]] do

        --[[
            "TODO: currently the "intended-to-be" general inverse function 
            just calls the special case Orthogonal inverse functions."

            "Also, when we implement general case, check where we were using
            Get_Inverse since usually it should be changed to Get_Orthogonal_Inverse..."
        --]]

        --- @param setInverse Matrix3dInstance
        function INSTANCE:GetInverse( setInverse )
            typecheck.NotImplementedError( CLASS, "GetInverse" )
        end

        --- @param setInverse Matrix3dInstance
        function INSTANCE:GetOrthogonalInverse( setInverse )
            typecheck.NotImplementedError( CLASS, "GetOrthogonalInverse" )
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
        --- @param setCenter Vector
        --- @param setExtent Vector
        function INSTANCE:TransformCenterExtentAABox( center, extent, setCenter, setExtent )
            typecheck.NotImplementedError( CLASS, "TransformCenterExtentAABox" )
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
    --- @field private VMatrix VMatrix The Garry's Mod VMatrix that underlies this Matrix3d

end