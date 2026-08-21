-- Based on AAPlaneClass within Code/WWMath/aaplane.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class AAPlaneClass
--- @field Instance AAPlaneInstance The metatable used by AAPlaneInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "AAPlaneClass"

--- @class AAPlaneInstance
--- @field Static AAPlaneClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_AAPlane" )
INSTANCE.Class = "AAPlaneInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAAPlane = true

--#region Exported Enums

    --- @enum AxisEnum
    STATIC.AXIS_ENUM = {
        XNORMAL = 0,
        YNORMAL = 1,
        ZNORMAL = 2
    }
    local axisEnum = STATIC.AXIS_ENUM
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class AAPlaneClass

    --- Creates a new AAPlaneInstance
    --- @overload fun(): AAPlaneInstance
    --- @overload fun( normal: AxisEnum, distance: number ): AAPlaneInstance
    function STATIC.New( normal, distance )
        return robustclass.New( "Renegade_AAPlane", normal, distance )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) AAPlaneInstance, `false` otherwise
    function STATIC.IsAAPlane( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAAPlane and true or false
    end

    typecheck.RegisterType( "AAPlaneInstance", STATIC.IsAAPlane )
end


--- @class AAPlaneInstance
--- @field Normal AxisEnum
--- @field Distance number

--- @param normal AxisEnum
--- @param distance number
function INSTANCE:Renegade_AAPlane( normal, distance )
    self.Normal = normal
    self.Distance = distance
end

--- @param normal AxisEnum
--- @param distance number
function INSTANCE:Set( normal, distance )
    self.Normal = normal
    self.Distance = distance
end

--- @return Vector
function INSTANCE:GetNormal()
    local normal = Vector( 0, 0, 0 )
    normal[ self.Normal + 1 ] = 1
    return normal
end
