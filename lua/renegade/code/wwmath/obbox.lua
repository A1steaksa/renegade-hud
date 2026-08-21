-- Based on obbox within Code/WWMath/obbox.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class OBBoxClass
--- @field instance OBBoxInstance The metatable used by OBBoxInstance
local STATIC = CNC.CreateExport()
STATIC.Class = "OBBoxClass"
local isHotload = not table.IsEmpty( STATIC )

--- @class OBBoxInstance
--- @field Static OBBoxClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_OBBox" )
INSTANCE.Class = "OBBoxInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsOBBox = true


--#region Exported Enums
--#endregion


--#region Imports

	--- @type Matrix3Class
	local matrix3Class = CNC.Import( "code/wwmath/matrix3.lua" )
--#endregion


--#region Imported Enums
--#endregion


--[[ Static Functions and Variables ]] do

    --- "  
    --- ## Oriented-Bounding-Box Class  
    --- This is a collision box in world space.  
    --- * Center - Position of the center of the box  
    --- * Extents - Size of the box  
    --- * Basis - Rotation matrix defining the orientation of the box  
    --- 
    --- To find the world space coordinates of the `+x`, `+y`, `+z` corner 
    --- of the bounding box you could use this equation:
    --- ```lua
    --- local corner = self.Center + self.Basis * self.Extent
    --- ```
    --- "  
    --- @class OBBoxClass


    --- Creates a new OBBoxInstance
    --- @vararg any
    --- @return OBBoxInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_OBBox", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) OBBoxInstance, `false` otherwise
    function STATIC.IsOBBox( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsOBBox and true or false
    end

    typecheck.RegisterType( "OBBoxInstance", STATIC.IsOBBox )

    --- @param transformationMatrix Matrix3Instance
    --- @param input OBBoxInstance
    --- @param output OBBoxInstance
    function STATIC.Transform( transformationMatrix, input, output )
        typecheck.NotImplementedError()
    end
end

--- @class OBBoxInstance
--- @field Basis Matrix3Instance
--- @field Center Vector
--- @field Extent Vector

--- Constructs a new OBBoxInstance
--- @vararg any
function INSTANCE:Renegade_OBBox( ... )
    local args = { ... }
    local argCount = select( "#", ... )

    self.Basis = matrix3Class.New( true )
    self.Center = Vector()
    self.Extent = Vector()
end


--- @param points Vector
--- @param numPoints integer
function INSTANCE:InitFromBoxPoints( points, numPoints )
    typecheck.NotImplementedError()
end

--- @param minExtent number? [Default: 0.5]
--- @param maxExtent number? [Default: 1.0]
function INSTANCE:InitRandom( minExtent, maxExtent )
    if not minExtent then minExtent = 0.5 end
    if not maxExtent then maxExtent = 1.0 end

    typecheck.NotImplementedError()
end

--- @param axis Vector 
--- @return number
function INSTANCE:ProjectToAxis( axis )
    typecheck.NotImplementedError()
end

--- @return number
function INSTANCE:Volume()
    local extent = self.Extent
    return 2 * extent.x * 2 * extent.y * 2 * extent.z
end

--- @param params number[]
--- @param setPoint Vector
function INSTANCE:ComputePoint( params, setPoint )
    typecheck.NotImplementedError()
end

--- @param setExtent Vector
function INSTANCE:ComputeAxisAlignedExtent( setExtent )
    typecheck.NotImplementedError()
end