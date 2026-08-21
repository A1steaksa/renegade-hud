-- Based on Matrix3 within Code/WWMath/matrix3.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class Matrix3Class
--- @field Instance Matrix3Instance The metatable used by Matrix3Instance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "Matrix3Class"

--- @class Matrix3Instance
--- @field Static Matrix3Class The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Matrix3" )
INSTANCE.Class = "Matrix3Instance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMatrix3 = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class Matrix3Class
	--- @field Identity Matrix3Instance
	--- @field RotateX90 Matrix3Instance
	--- @field RotateX180 Matrix3Instance
	--- @field RotateX270 Matrix3Instance
	--- @field RotateY90 Matrix3Instance
	--- @field RotateY180 Matrix3Instance
	--- @field RotateY270 Matrix3Instance
	--- @field RotateZ90 Matrix3Instance
	--- @field RotateZ180 Matrix3Instance
	--- @field RotateZ270 Matrix3Instance

    --- Creates a new Matrix3Instance
    --- @return Matrix3Instance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Matrix3", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Matrix3Instance, `false` otherwise
    function STATIC.IsMatrix3( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMatrix3 and true or false
    end

    typecheck.RegisterType( "Matrix3Instance", STATIC.IsMatrix3 )

	function STATIC.Add()
		typecheck.NotImplementedError()
	end

	function STATIC.Subtract()
		typecheck.NotImplementedError()
	end

	function STATIC.Multiply()
		typecheck.NotImplementedError()
	end

	function STATIC.Multiply()
		typecheck.NotImplementedError()
	end

	--- @param matrix Matrix3Instance
	--- @param vector Vector
	--- @return Vector
	function STATIC.RotateVector( matrix, vector )
		return Vector(
			matrix[1][1] * vector.x + matrix[1][2] * vector.y + matrix[1][3] * vector.z,
			matrix[2][1] * vector.x + matrix[2][2] * vector.y + matrix[2][3] * vector.z,
			matrix[3][1] * vector.x + matrix[3][2] * vector.y + matrix[3][3] * vector.z
		)
	end

	function STATIC.TransposeRotateVector()
		typecheck.NotImplementedError()
	end

	function STATIC.StaticConstructor()

		STATIC.Identity = STATIC.New(
			1.0,    0.0,    0.0,
			0.0,    1.0,    0.0,
			0.0,    0.0,    1.0
		)

		STATIC.RotateX90 = STATIC.New(
			1.0,	0.0,	0.0,
			0.0,	0.0,   -1.0,
			0.0,	1.0,	0.0
		)

		STATIC.RotateX180 = STATIC.New(
			1.0,    0.0,	0.0,
			0.0,   -1.0,    0.0,
			0.0,    0.0,   -1.0
		)

		STATIC.RotateX270 = STATIC.New(
			1.0,	0.0,	0.0,
			0.0,	0.0,	1.0,
			0.0,   -1.0,	0.0
		)

		STATIC.RotateY90 = STATIC.New(
			0.0,	0.0,	1.0,
			0.0,	1.0,	0.0,
		-1.0,	0.0,	0.0
		)

		STATIC.RotateY180 = STATIC.New(
		-1.0,	0.0,	0.0,
			0.0,	1.0,	0.0,
			0.0,	0.0,   -1.0
		)

		STATIC.RotateY270 = STATIC.New(
			0.0,	0.0,   -1.0,
			0.0,	1.0,	0.0,
			1.0,	0.0,	0.0
		)

		STATIC.RotateZ90 = STATIC.New(
			0.0,   -1.0,	0.0,
			1.0,	0.0,	0.0,
			0.0,	0.0,	1.0
		)

		STATIC.RotateZ180 = STATIC.New(
		-1.0,	0.0,	0.0,
			0.0,   -1.0,	0.0,
			0.0,	0.0,	1.0
		)

		STATIC.RotateZ270 = STATIC.New(
			0.0,	1.0,	0.0,
		-1.0,    0.0,    0.0,
			0.0,	0.0,	1.0
		)
	end
end


--- @class Matrix3Instance
--- @field Row Vector[]

--- @overload fun( self, identity: boolean )
--- @overload fun( self, m11: number, m12: number, m13: number, m21: number, m22: number, m23: number, m31: number, m32: number, m33: number )
function INSTANCE:Renegade_Matrix3( ... )
	local args = {...}
	local argCount = select( "#", ... )

	typecheck.AssertArgCount( INSTANCE.Class, argCount, { 1, 9 } )

	if argCount == 1 then
		local arg = args[1]

		-- "Constructor, optionally initialize to Identitiy matrix"
		-- ( identity: boolean )
		if typecheck.IsOfType( arg, "boolean" ) then
			local identity = arg --[[@as boolean]]

			if identity then
				self.Row = {
					Vector( 1.0, 0.0, 0.0 ),
					Vector( 0.0, 1.0, 0.0 ),
					Vector( 0.0, 0.0, 1.0 )
				}
			else
				self.Row = {
					Vector( 0, 0, 0 ),
					Vector( 0, 0, 0 ),
					Vector( 0, 0, 0 )
				}
			end
			return
		end

		typecheck.NotImplementedError()
	end

	-- ( m11: number, m12: number, m13: number, m21: number, m22: number, m23: number, m31: number, m32: number, m33: number )
	if argCount == 9 then
		local m11, m12, m13 = args[1] --[[@as number]], args[2] --[[@as number]], args[3] --[[@as number]]
		local m21, m22, m23 = args[4] --[[@as number]], args[5] --[[@as number]], args[6] --[[@as number]]
		local m31, m32, m33 = args[7] --[[@as number]], args[8] --[[@as number]], args[9] --[[@as number]]
		self.Row = {
			Vector( m11, m12, m13 ),
			Vector( m21, m22, m23 ),
			Vector( m31, m32, m33 )
		}
		return
	end

	typecheck.NotImplementedError()
end

--- @param value Matrix3dInstance|Matrix4Instance|QuaternionInstance
function INSTANCE:Set( value )
	typecheck.AssertArgType( INSTANCE.Class, 1, value, { "Matrix3dInstance", "Matrix4Instance", "QuaternionInstance" } )

	--( value: Matrix3dInstance|Matrix4Instance )
	if typecheck.IsOfType( value, { "Matrix3dInstance", "Matrix4Instance" } ) then
		--- @cast value Matrix3dInstance|Matrix4Instance
		local valRow = value.Row
		self.Row[1]:SetUnpacked( valRow[1][1], valRow[1][2], valRow[1][3] )
		self.Row[2]:SetUnpacked( valRow[2][1], valRow[2][2], valRow[2][3] )
		self.Row[3]:SetUnpacked( valRow[3][1], valRow[3][2], valRow[3][3] )
		return

	--( value: QuaternionInstance )
	else
		--- @cast value QuaternionInstance
		typecheck.NotImplementedError()

		return
	end
end

function INSTANCE:Transpose()
	typecheck.NotImplementedError()
end

function INSTANCE:Inverse()
	typecheck.NotImplementedError()
end

function INSTANCE:Determinant()
	typecheck.NotImplementedError()
end

function INSTANCE:MakeIdentity()
	typecheck.NotImplementedError()
end

function INSTANCE:RotateX()
	typecheck.NotImplementedError()
end

function INSTANCE:RotateY()
	typecheck.NotImplementedError()
end

function INSTANCE:RotateZ()
	typecheck.NotImplementedError()
end

function INSTANCE:GetXRotation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetYRotation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetZRotation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetXVector()
	typecheck.NotImplementedError()
end

function INSTANCE:GetYVector()
	typecheck.NotImplementedError()
end

function INSTANCE:GetZVector()
	typecheck.NotImplementedError()
end

function INSTANCE:Swap()
	typecheck.NotImplementedError()
end

function INSTANCE:IsOrthogonal()
	typecheck.NotImplementedError()
end

function INSTANCE:ReOrthogonalize()
	typecheck.NotImplementedError()
end

function INSTANCE:RotateAABoxExtent()
	typecheck.NotImplementedError()
end
