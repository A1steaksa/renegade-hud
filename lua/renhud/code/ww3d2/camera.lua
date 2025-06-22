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
    local collisionMath = CNC.Import( "renhud/code/wwmath/collision-math.lua" )

    --- @type Viewport
    local viewport = CNC.Import( "renhud/code/ww3d2/viewport.lua" )

    --- @type Frustum
    local frustum = CNC.Import( "renhud/code/wwmath/frustum.lua" )
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
            self.CameraInvTransform = src.CameraInvTransform
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

    --- Originally part of RenderObjClass in Code/ww3d2/rendobj.h/cpp
    --- Camera extends RenderObjClass but I don't feel like porting that right now
    function INSTANCE:GetTransform()
        local matrix = Matrix()

        local viewInfo = render.GetViewSetup() --[[@as ViewSetup]]

        matrix:Translate( viewInfo.origin )
        matrix:Rotate( viewInfo.angles )

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
    --- @field protected ProjectionTransform VMatrix
    --- @field protected CameraInvTransform VMatrix

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

        -- Omitted viewspace frustum init    

        -- "Update the OBB around the near clip rectangle"
        --self.NearClipBBox.Center = cameraMatrix * Vector( 0, 0, zNear )
        --self.NearClipBBox.Extendt.x = ( viewportMax.x - viewportMin.x ) * -zNear * 0.5
        --self.NearClipBBox.Extendt.y = ( viewportMax.y - viewportMin.y ) * -zNear * 0.5
        --self.NearClipBBox.Extendt.z = 0.01
        --self.NearClipBBox.Basis.Set( cameraMatrix )

        -- Omitted projection matrix updating
    end
end