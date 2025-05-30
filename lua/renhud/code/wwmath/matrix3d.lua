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

    CNC.Export( STATIC )
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

end


--[[ Instanced Functions and Variables ]] do
    local CLASS = "Matrix3dInstance"

    --- [[ Public ]]

    --- @class Matrix3dInstance

    --- Constructs a new Matrix3dInstance
    function INSTANCE:Renegade_Matrix3d( ... )
        local args = { ... }
        local argCount = select( "#", ... )
        typecheck.AssertArgCount( CLASS, argCount, { 0, 1, 2, 3, 4, 12 } )

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

                self.Row[0] = { matrixValues[0], matrixValues[1], matrixValues[2],  matrixValues[3]  }
                self.Row[1] = { matrixValues[4], matrixValues[5], matrixValues[6],  matrixValues[7]  }
                self.Row[2] = { matrixValues[8], matrixValues[9], matrixValues[10], matrixValues[11] }
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

                self.Row[0] = matrixToCopy.Row[0]
                self.Row[1] = matrixToCopy.Row[1]
                self.Row[2] = matrixToCopy.Row[2]
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

            local m11, m12, m13, m14 = args[1]  --[[@as number]], args[2]  --[[@as number]], args[3]  --[[@as number]], args[4]  --[[@as number]]
            local m21, m22, m23, m24 = args[5]  --[[@as number]], args[6]  --[[@as number]], args[7]  --[[@as number]], args[8]  --[[@as number]]
            local m31, m32, m33, m34 = args[9]  --[[@as number]], args[10] --[[@as number]], args[11] --[[@as number]], args[12] --[[@as number]]

            self.Row[0] = { m11, m12, m13, m14 }
            self.Row[1] = { m21, m22, m23, m24 }
            self.Row[2] = { m31, m32, m33, m34 }
            return
        end
    end

    --- @overload fun()
    function INSTANCE:Set( ... )
        local args = { ... }
        local argCount = select( "#", ... )
        typecheck.AssertArgCount( CLASS, argCount, { 1, 2, 3, 4, 12 } )

    end

    --- "Initializes the matrix to be the identity matrix"
    function INSTANCE:MakeIdentity()
        self.Row[0] = { 1, 0, 0, 0 }
        self.Row[1] = { 0, 1, 0, 0 }
        self.Row[2] = { 0, 0, 1, 0 }
    end


    --- [[ Protected ]]

    --- @class Matrix3dInstance

    --- @type number[][]
    --- @protected
    INSTANCE.Row = {}


    --- [[ Private ]]

    --- @class Matrix3dInstance

end