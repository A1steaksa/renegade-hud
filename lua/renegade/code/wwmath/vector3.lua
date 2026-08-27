-- Based on Vector3 within Code/WWMath/vector3.h

-- Updates the metatable of Vector to add functions from Vector3 that are missing

--- @class Vector
local VECTOR = FindMetaTable( "Vector" )

--- "Sets each component of the vector to the min of this and [`other`]"
--- @param other Vector
function VECTOR:UpdateMin( other )
    if other.x < self.x then self.x = other.x end
    if other.y < self.y then self.y = other.y end
    if other.z < self.z then self.z = other.z end
end

--- "Sets each component of the vector to the max of this and [`other`]"
--- @param other Vector
function VECTOR:UpdateMax( other )
    if other.x > self.x then self.x = other.x end
    if other.y > self.y then self.y = other.y end
    if other.z > self.z then self.z = other.z end
end