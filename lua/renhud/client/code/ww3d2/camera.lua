-- Based on CameraClass within Code/ww3d2/camera.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Camera
    --- @class CameraInstance
    --- @field Static Camera The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Camera" )

    --- The static components of Camera
    --- @class Camera
    --- @field Instance CameraInstance The Metatable used by CameraInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsCamera = true
end


--#region Imports

    --- @type CollisionMath
    local collisionMath = CNC.Import( "renhud/client/code/wwmath/collision-math.lua" )

    --- @type Viewport
    local viewport = CNC.Import( "renhud/client/code/ww3d2/viewport.lua" )

    --- @type Frustum
    local frustum = CNC.Import( "renhud/client/code/wwmath/frustum.lua" )

    --- @type Matrix3d
    local matrix3d = CNC.Import( "renhud/client/code/wwmath/matrix3d.lua" )

    --- @type WWMath
    local wWMath = CNC.Import( "renhud/client/code/wwmath/wwmath.lua" )

    --- @type Matrix4
    local matrix4 = CNC.Import( "renhud/client/code/wwmath/matrix4.lua" )

    --- @type Render2d
    local render2d = CNC.Import( "renhud/client/code/ww3d2/render-2d.lua" )
--#endregion


--#region Enums

    --- @enum ProjectionResultType
    STATIC.PROJECTION_RESULT_TYPE = {
        INSIDE_FRUSTUM    = 0,
        OUTSIDE_FRUSTUM   = 1,
        OUTSIDE_NEAR_CLIP = 2,
        OUTSIDE_FAR_CLIP  = 3,
    }
    local projectionResultType = STATIC.PROJECTION_RESULT_TYPE

    --- @enum ProjectionType
    STATIC.PROJECTION_TYPE = {
        PERSPECTIVE = 0,
        ORTHO       = 1,
    }
    local projectionType = STATIC.PROJECTION_TYPE
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "Camera"

    --- [[ Public ]]

    --- @class Camera

    --- Creates a new CameraInstance
    --- @overload fun(): CameraInstance
    --- @overload fun( src: CameraInstance ): CameraInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Camera", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) CameraInstance, `false` otherwise
    function STATIC.IsCamera( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCamera and true or false
    end

    typecheck.RegisterType( "CameraInstance", STATIC.IsCamera )
end

--[[ Instanced Functions and Variables ]] do

    local CLASS = "CameraInstance"

    --- [[ Public ]]

    --- @class CameraInstance

    --- Constructs a new CameraInstance
    --- @vararg any
    function INSTANCE:Renegade_Camera( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        self.ViewPlane = viewport.New()
        self.Frustum = frustum.New()
        self.ViewSpaceFrustum = frustum.New()

        -- ( nil )
        if argCount == 0 then
            self.Projection = projectionType.PERSPECTIVE
            self.Viewport = viewport.New( Vector( 0, 0 ), Vector( 1, 1 ) )
            self.AspectRatio = 4/3
            self.ZNear = 1
            self.ZFar = 1000
            self.ZBufferMin = 0
            self.ZBufferMax = 1
            self.FrustumValid = false

            self.ProjectionTransform = matrix4.New()

            -- Omitted self:SetTransform() call as the camera class does not currently modify-
            -- the game view, it only reads from it.

            self:SetViewPlane( math.rad( 50 ) )
            return
        end

        -- ( src: CameraInstance )
        if argCount == 1 then
            local src = args[1] --[[@as CameraInstance]]

            typecheck.AssertArgType( CLASS, 1, src, "Camera" )

            self.Projection = src.Projection
            self.Viewport = src.Viewport
            self.ViewPlane = src.ViewPlane
            self.ZNear = src.ZNear
            self.ZFar = src.ZFar
            self.FrustumValid = src.FrustumValid
            self.Frustum = src.Frustum
            self.NearClipBBox = src.NearClipBBox
            self.ProjectionTransform = src.ProjectionTransform
            self.CameraInverseTransform = src.CameraInverseTransform
            self.AspectRatio = src.AspectRatio
            self.ZBufferMin = src.ZBufferMin
            self.ZBufferMax = src.ZBufferMax

            -- "just being paraniod in case any parent class doesn't completely copy the entire state..."
            self.FrustumValid = false
            return
        end

        typecheck.AssertArgCount( CLASS, argCount )
    end

    --- @param box AABoxInstance
    --- @return boolean
    function INSTANCE:CullBox( box )
        local frustum = self:GetFrustum()
        local overlapResults = collisionMath.OverlapTest( frustum, box )
        return  overlapResults == collisionMath.OVERLAP_TYPE.OUTSIDE
    end

    --- @return FrustumInstance
    function INSTANCE:GetFrustum()
        self:UpdateFrustum()
        return self.Frustum
    end

    --- @return FrustumInstance
    function INSTANCE:GetViewSpaceFrustum()
        self:UpdateFrustum()
        return self.ViewSpaceFrustum
    end

    --- Originally part of RenderObjClass in Code/ww3d2/rendobj.h/cpp
    --- Camera extends RenderObjClass but I don't feel like porting that right now
    --- @return Matrix3dInstance
    function INSTANCE:GetTransform()
        local viewInfo = render.GetViewSetup() --[[@as ViewSetup]]
        local viewAng = viewInfo.angles

        local matrix = matrix3d.New( false )
        local row = matrix.Row
        local row1, row2, row3 = row[1], row[2], row[3]

        row1.x, row1.y, row1.z =  0,  0, -1
        row2.x, row2.y, row2.z = -1,  0,  0
        row3.x, row3.y, row3.z =  0,  1,  0

        row1.w = viewInfo.origin.x
        row2.w = viewInfo.origin.y
        row3.w = viewInfo.origin.z

        -- Rotate the camera's matrix, adjusting the Source angles to match Renegade's coordinate space
        matrix:RotateY( math.rad(  viewAng.yaw   ) )
        matrix:RotateX( math.rad( -viewAng.pitch ) )
        matrix:RotateZ( math.rad( -viewAng.roll  ) )

        return matrix
    end

    --- @return Vector viewPlaneMin, Vector viewPlaneMax
    function INSTANCE:GetViewPlane()
        return self.ViewPlane.Min, self.ViewPlane.Max
    end

    --- @overload fun( self: CameraInstance, min: Vector, max: Vector ): nil
    --- @overload fun( self: CameraInstance, horizontalFov: number, verticalFov: number? ): nil
    function INSTANCE:SetViewPlane( ... )
        local args = { ... }
        local argCount = select( "#", ... )
        typecheck.AssertArgCount( CLASS, argCount, { 1, 2 } )
        typecheck.AssertArgType( CLASS, 1, args[1], { "vector", "number" } )

        -- ( min: Vector, max: Vector )
        if isvector( args[1] ) then
            typecheck.AssertArgType( CLASS, 2, args[2], "vector" )

            local min = args[1] --[[@as Vector]]
            local max = args[2] --[[@as Vector]]

            self.ViewPlane.Min = min
            self.ViewPlane.Max = max
            self.AspectRatio = ( max.x - min.x ) / ( max.y - min.y )
            self.FrustumValid = false

        -- ( horizontalFov: number, verticalFov: number? )
        else
            typecheck.AssertArgType( CLASS, 1, args[1], "number" )

            local horizontalFov = args[1] --[[@as number]]
            local verticalFov = -1
            if argCount == 2 then
                typecheck.AssertArgType( CLASS, 2, args[2], "number" )
                verticalFov = args[2] --[[@as number]]
            end

            local halfWidth = math.tan( horizontalFov / 2 )
            local halfHeight = 0
            if verticalFov == -1 then
                halfHeight = ( 1 / self.AspectRatio ) * halfWidth -- "Use the aspect ratio"
            else
                halfHeight = math.tan( verticalFov / 2 )
                self.AspectRatio = halfWidth / halfHeight -- "Or, initialize the aspect ratio"
            end

            self.ViewPlane.Min = Vector( -halfWidth, -halfHeight )
            self.ViewPlane.max = Vector( halfWidth, halfHeight )
            self.FrustumValid = false
        end
    end

    --- @param camPoint Vector
    --- @return Vector
    --- @return ProjectionResultType
    function INSTANCE:ProjectCameraSpacePoint( camPoint )
        self:UpdateFrustum()

        local projectedPoint = Vector()

        -- If the camPoint is behind the near clipping plane, just return (0,0,0)
        if camPoint.z > -self.ZNear + wWMath.EPSILON then
            projectedPoint:SetUnpacked( 0, 0, 0 )
            return projectedPoint, projectionResultType.OUTSIDE_NEAR_CLIP
        end

        local viewPoint = self.ProjectionTransform * camPoint

        local oow = 1 / viewPoint.w
        projectedPoint.x = viewPoint.x * oow
        projectedPoint.y = viewPoint.y * oow
        projectedPoint.z = viewPoint.z * oow

        if projectedPoint.z > 1 then
            return projectedPoint, projectionResultType.OUTSIDE_FAR_CLIP
        end

        local isXOutOfFrustum = projectedPoint.x < -1 or projectedPoint.x > 1
        local isYOutOfFrustum = projectedPoint.y < -1 or projectedPoint.y > 1
        if isXOutOfFrustum or isYOutOfFrustum then
            return projectedPoint, projectionResultType.OUTSIDE_FRUSTUM
        end

        return projectedPoint, projectionResultType.INSIDE_FRUSTUM
    end

    ---@param zNear number
    ---@param zFar number
    function INSTANCE:SetClipPlanes( zNear, zFar )
        self.FrustumValid = false
        self.ZNear = zNear
        self.ZFar = zFar
    end

    --- @return number nearPlaneDistance, number farPlaneDistance
    function INSTANCE:GetClipPlanes()
        return self.ZNear, self.ZFar
    end

    --- [[ Protected ]]

    --- @class CameraInstance
    --- @field protected Projection ProjectionType
    --- @field protected Viewport ViewportInstance "pixel viewport to render into"
    --- @field protected ViewPlane ViewportInstance "Corners of a slice through the frustum at z=1.0"
    --- @field protected AspectRatio number "Aspect ratio of the camera, width / height"
    --- @field protected ZNear number "Near clip plane distance"
    --- @field protected ZFar number "Far clip plane distance"
    --- @field protected ZBufferMin number "Smallest value we'll write into the z-Buffer (usually 0)"
    --- @field protected ZBufferMax number "Largest value we'll write into the z-buffer (usually 1)"
    --- @field protected FrustumValid boolean
    --- @field protected Frustum FrustumInstance "World-space frustum and clip planes"
    --- @field protected ViewSpaceFrustum FrustumInstance "View-space frustum and clip planes"
    --- @field protected NearClipBBox OBBoxInstance "OBBox which bounds the near clip plane"
    --- @field protected ProjectionTransform Matrix4Instance
    --- @field protected CameraInverseTransform Matrix3dInstance

    --- @protected
    function INSTANCE:UpdateFrustum()
        -- Omitted frustum validation
        --if self.FrustumValid then return end

        local cameraMatrix = self:GetTransform()

        local viewportMin, viewportMax = self:GetViewPlane() -- "Normalized view plane at a depth of 1"
        local zNearDistance, zFarDistance = self:GetClipPlanes()

        -- "Forward is negative Z in our viewspace coordinate system"
        local zNear = -zNearDistance
        local zFar = -zFarDistance

        -- "Update the frustum"
        self.FrustumValid = true
        self.Frustum:Init( cameraMatrix, viewportMin, viewportMax, zNear, zFar )
        self.ViewSpaceFrustum:Init( matrix3d.New( true ), viewportMin, viewportMax, zNear, zFar )

        -- Omitted viewspace frustum init    

        -- "Update the OBB around the near clip rectangle"
        --self.NearClipBBox.Center = cameraMatrix * Vector( 0, 0, zNear )
        --self.NearClipBBox.Extendt.x = ( viewportMax.x - viewportMin.x ) * -zNear * 0.5
        --self.NearClipBBox.Extendt.y = ( viewportMax.y - viewportMin.y ) * -zNear * 0.5
        --self.NearClipBBox.Extendt.z = 0.01
        --self.NearClipBBox.Basis.Set( cameraMatrix )

        -- "Update the inverse camera matrix"
        self.CameraInverseTransform = self:GetTransform():GetInverse()

        -- "Update the projection matrix"
        if self.Projection == projectionType.PERSPECTIVE then

            local viewSetup = render.GetViewSetup() --[[@as ViewSetup]]
            local horizontalFov = math.rad( viewSetup.fov )

            local screen = render2d.GetScreenResolution()
            local aspectRatio = screen:Width() / screen:Height()
            local verticalFov = 2 * math.atan( math.tan( horizontalFov / 2 ) / aspectRatio )

            self.ProjectionTransform:InitPerspective(
                horizontalFov, verticalFov,
                zNearDistance, zFarDistance
            )

            -- self.ProjectionTransform:InitPerspective(
            --     viewportMin.x * zNearDistance,
            --     viewportMax.x * zNearDistance,
            --     viewportMin.y * zNearDistance,
            --     viewportMax.y * zNearDistance,
            --     zNearDistance,
            --     zFarDistance
            -- )
        else
            self.ProjectionTransform:InitOrthographic(
                viewportMin.x,
                viewportMax.x,
                viewportMin.y,
                viewportMax.x,
                zNearDistance,
                zFarDistance
            )
        end
    end
end