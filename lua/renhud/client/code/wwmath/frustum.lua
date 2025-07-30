-- Based on FrustumClass within Code/WWMath/frustum.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Frustum
    --- @class FrustumInstance
    --- @field Static Frustum The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Frustum" )

    --- The static components of Frustum
    --- @class Frustum
    --- @field Instance FrustumInstance The Metatable used by FrustumInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsFrustum = true
end


--#region Imports

    --- @type Plane
    local plane = CNC.Import( "renhud/client/code/wwmath/plane.lua" )

    --- @type CameraBridge
    local cameraBridge = CNC.Import( "renhud/client/bridges/camera.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "Frustum"

    --- [[ Public ]]

    --- Creates a new FrustumInstance
    --- @return FrustumInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Frustum" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) FrustumInstance, `false` otherwise
    function STATIC.IsFrustum( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsFrustum and true or false
    end

    typecheck.RegisterType( "FrustumInstance", STATIC.IsFrustum )
end

--[[ Instanced Functions and Variables ]] do

    local CLASS = "FrustumInstance"

    --- [[ Public ]]

    --- @class FrustumInstance
    --- @field CameraTransform Matrix3dInstance
    --- @field Planes table<integer, PlaneInstance>
    --- @field Corners Vector[]
    --- @field BoundMin Vector
    --- @field BoundMax Vector

    --- Constructs a new FrustumInstance
    --- @vararg any
    function INSTANCE:Renegade_Frustum()
    end

    --- @param camera Matrix3dInstance
    --- @param viewplaneMin Vector
    --- @param viewplaneMax Vector
    --- @param zNear number
    --- @param zFar number  )
    function INSTANCE:Init( camera, viewplaneMin, viewplaneMax, zNear, zFar )

        self.CameraTransform = camera

        -- "Forward is negative z in our viewspace coordinate system-"
        -- "-just flip the sign if the user passed in positive values."
        if zNear > 0 and zFar > 0 then
            zNear = -zNear
            zFar  = -zFar
        end

        -- "Calculate the corners of the camera frustum."  
	    -- "Generate the camera-space frustum corners by linearly-"  
        -- "-extrapolating the viewplane to the near and far z clipping planes."  

	    -- "The camera frustum corners are defined in the following order:"  
	    -- "When looking at the frustum from the position of the camera, the near four corners are"  
	    -- "numbered: upper left 0, upper right 1, lower left 2, lower right 3. The far plane's"  
	    -- "Frustum corners are numbered from 4 to 7 in an analogous fashion."  
        -- "(remember: the camera space has x going to the right, y up and z backwards)."  
        self.Corners = self.Corners or {}
        local corners = self.Corners
        corners[0] = Vector( viewplaneMin.x, viewplaneMax.y, 1 )
        corners[4] = Vector( viewplaneMin.x, viewplaneMax.y, 1 )
        corners[0] = corners[0] * zNear
        corners[4] = corners[4] * zFar

        corners[1] = Vector( viewplaneMax.x, viewplaneMax.y, 1 )
        corners[5] = Vector( viewplaneMax.x, viewplaneMax.y, 1 )
        corners[1] = corners[1] * zNear
        corners[5] = corners[5] * zFar

        corners[2] = Vector( viewplaneMin.x, viewplaneMin.y, 1 )
        corners[6] = Vector( viewplaneMin.x, viewplaneMin.y, 1 )
        corners[2] = corners[2] * zNear
        corners[6] = corners[6] * zFar

        corners[3] = Vector( viewplaneMax.x, viewplaneMin.y, 1 )
        corners[7] = Vector( viewplaneMax.x, viewplaneMin.y, 1 )
        corners[3] = corners[3] * zNear
        corners[7] = corners[7] * zFar

        -- "Transform the eight corners of the view frustum from camera space to world space"
        for i = 0, 7 do
            local adjustedCorner = self.CameraTransform * corners[i]
            corners[i] = Vector( adjustedCorner.x, adjustedCorner.y, adjustedCorner.z )
        end

        -- "Create the six frustum bounding planes from the eight corner Corners"
        -- "The bounding planes are oriented so that their normals point outward"
        self.Planes = {}
        self.Planes[0] = plane.New( corners[0], corners[3], corners[1] ) -- Near
        self.Planes[1] = plane.New( corners[0], corners[5], corners[4] ) -- Bottom
        self.Planes[2] = plane.New( corners[0], corners[6], corners[2] ) -- Right
        self.Planes[3] = plane.New( corners[2], corners[7], corners[3] ) -- Top
        self.Planes[4] = plane.New( corners[1], corners[7], corners[5] ) -- Left
        self.Planes[5] = plane.New( corners[4], corners[7], corners[6] ) -- Far

        -- "Find the bounding box of the entire frustum (may be used for sloppy quick rejection)"
        self.BoundMin = Vector( corners[0] )
        self.BoundMax = Vector( corners[0] )
        for i = 0, 7 do
            local corner = corners[i]

            -- X Min
            if corner.x < self.BoundMin.x then
                self.BoundMin.x = corner.x
            end
            -- X Max
            if corner.x > self.BoundMax.x then
                self.BoundMax.x = corner.x
            end

            -- Y Min
            if corner.y < self.BoundMin.y then
                self.BoundMin.y = corner.y
            end
            -- Y Max
            if corner.y > self.BoundMax.y then
                self.BoundMax.y = corner.y
            end

            -- Z Min
            if corner.z < self.BoundMin.z then
                self.BoundMin.z = corner.z
            end
            -- Z Max
            if corner.z > self.BoundMax.z then
                self.BoundMax.z = corner.z
            end
        end
    end

    --- @return Vector
    function INSTANCE:GetBoundMin()
        return self.BoundMin
    end

    --- @return Vector
    function INSTANCE:GetBoundMax()
        return self.BoundMax
    end
end