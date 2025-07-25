-- Based on CCameraClass within Code/Combat/ccamera.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    -- Import parent class
    CNC.Import( "renhud/client/code/ww3d2/camera.lua" )

    --- The instanced components of CommandoCamera
    --- @class CommandoCameraInstance : CameraInstance
    --- @field Static CommandoCamera The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_CommandoCamera : Renegade_Camera" )

    --- The static components of CommandoCamera
    --- @class CommandoCamera
    --- @field Instance CommandoCameraInstance The Metatable used by CommandoCameraInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsCommandoCamera = true
end


--#region Imports

    --- @type CombatManager
    local combatManager = CNC.Import( "renhud/client/code/combat/combat-manager.lua" )

    --- @type HudInfo
    local hudInfo = CNC.Import( "renhud/client/code/combat/hud-info.lua" )

    --- @type CommandoCameraProfile
    local commandoCameraProfile = CNC.Import( "renhud/client/code/combat/commando-camera-profile.lua" )

    --- @type BuildingsBridge
    local buildingsBridge = CNC.Import( "renhud/client/bridges/buildings.lua" )

    --- @type PhysicalGameObjectsBridge
    local physicalGameObjectsBridge = CNC.Import( "renhud/client/bridges/physical-game-objects.lua" )

    --- @type SmartGameObjectsBridge
    local smartGameObjectsBridge = CNC.Import( "renhud/client/bridges/smart-game-objects.lua" )

    --- @type InfoEntityLib
    local infoEntityLib = CNC.Import( "renhud/sh_info-entity.lua")
--#endregion


--#region Enums

    --- @enum SnapshotMode
    STATIC.SNAPSHOT_MODE = {
        OFF      = 0,
        ON       = 1,
        PROGRESS = 2,
    }
    local snapshot = STATIC.SNAPSHOT_MODE
--#endregion


--[[ Static Functions and Variables ]] do
    local CLASS = "CommandoCamera"

    --- [[ Public ]]

    --- @class CommandoCamera

    --- Creates a new CommandoCameraInstance
    --- @return CommandoCameraInstance
    function STATIC.New()
        return robustclass.New( "Renegade_CommandoCamera" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) CommandoCameraInstance, `false` otherwise
    function STATIC.IsCommandoCamera( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCommandoCamera and true or false
    end

    typecheck.RegisterType( "CommandoCameraInstance", STATIC.IsCommandoCamera )

    function STATIC.Init()
        typecheck.NotImplementedError( CLASS, "Init" )
    end
end


--[[ Instanced Functions and Variables ]] do
    local CLASS = "CommandoCameraInstance"

    local MIN_FOV = 0.02
    local MAX_FOV = 2.6

    local CCAMERA_NEARZ             = 0.26 -- "Near clip plane distance"
    local CCAMERA_FARZ              = 300  -- "Far clip plane distance"
    local CCAMERA_SHRINK_NEARZ_DIST = 0.5  -- "Third person distance below which we start shrinking nearz"
    local CCAMERA_MIN_NEARZ         = 0.2  -- "How small nearz gets when we're up against a wall"

    local FirstPersonOffsetTweak = Vector( 0, 0, 0 )

    -- "Speed at which the camera pushes back out to its default position
    -- after a collision.  1.0 = goes all the way in 1 second"
    local CAMERA_UNWIND_SPEED = 1

    --- [[ Public ]]

    --- @class CommandoCameraInstance

    --- Constructs a new CommandoCameraInstance
    function INSTANCE:Renegade_CommandoCamera()
        self.HostModel = NULL
        self.AnchorPosition = Vector( 0,0,0 )
	    self._IsValid = false
	    self.Tilt = 0
	    self.Heading = 0
	    self.DistanceFraction = 1
	    self._Enable2dTargeting = false
	    self._EnableWeaponHelp = false
	    self.CameraTarget2dOffset = Vector( 0.5, 0.5 )
	    self.LerpTimeTotal = 0
	    self.LerpTimeRemaining = 0
	    self.LastAnchorPosition = Vector( 0, 0, 0 )
	    self.LastHeading = 0
	    self.CurrentProfile = NULL
	    self.LastProfile = NULL
	    self.DefaultProfile = NULL
	    self.NearClipPlane = CCAMERA_NEARZ
	    self.FarClipPlane = CCAMERA_FARZ
	    self._IsStarSniping = false
	    self.WasStarSniping = false
	    self.CinematicSnipingEnabled = false
	    self.CinematicSnipingDesiredZoom = 0
	    self.SniperZoom = 0
	    self.SniperDistance = 0
	    self.SniperListener = NULL
	    self._SnapshotMode = snapshot.OFF
	    self.WeaponHelpTimer = 0
	    self.WeaponHelpTarget = NULL
	    self.LagPersistTimer = 0
	    self.DisableLag = false

        self:SetClipPlanes( self.NearClipPlane, self.FarClipPlane )
        self:SetViewPlane( math.rad( 90 ) )

        -- Omitted sniper listener
        --self.SniperListener = listener3d.New()

        self.DefaultProfileName = "default"
        self.DefaultProfile = commandoCameraProfile.Find( self.DefaultProfileName )
        self:UseDefaultProfile()
    end

    --- Updates the camera's parameters each frame
    function INSTANCE:Update()

        self:ApplyWeaponHelp()

        self:DetermineTargetingPosition()

        -- Omitted camera update logic
        --[[
        self:HandleInput()

        if self._SnapshotMode ~= snapshot.OFF then
            self:HandleSnapshotMode()
            return
        end

        -- if using a host model, update the camera from it
        if self:IsUsingHostModel() then
            self:UseHostModel()
            return
        end

        local anchorPosition = self.AnchorPosition
        local cameraHeading = self.Heading

        local frameTime = FrameTime()

        local combatStar = LocalPlayer()

        local profile

        local interpolating = false

        if LerpTimeTotal then
            interpolating = true

            local lerp = math.Clamp( LerpTimeRemaining / LerpTimeTotal, 0, 1 )

            LerpTimeRemaining = LerpTimeRemaining - frameTime
            if LerpTimeRemaining <= 0 then
                LerpTimeRemaining = 0
                LerpTimeTotal = 0

                -- Set up last, so out Lag code doesn't use the old
                LastAnchorPosition = anchorPosition
                LastHeading	= self.Heading
            end
            profile = self.CurrentProfile

            if self.LastProfile then
                profile:Lerp( self.CurrentProfile, self.LastProfile, lerp )
            end

            anchorPosition = LerpVector( lerp, anchorPosition, LastAnchorPosition )

            cameraHeading =	RadianLerp( cameraHeading, LastHeading, lerp )

        else
            profile = self.CurrentProfile
            LastProfile = self.CurrentProfile
            LastProfileName = self.CurrentProfileName

            if profile.Lag.Length() > 0 then
                -- This is an attempt to not lag when in an elevator
                local lagOk = false
                if ( not IsValid( combatStar ) or not combatStar:IsOnGround() ) then
                    lagOk = true
                    LagPersistTimer = 1  -- Persist the lag for 1 second
                else
                    if LagPersistTimer > 0 then
                        lagOk = true
                        LagPersistTimer = LagPersistTimer - frameTime
                    end
                end

                if self.DisableLag then
                    lagOk = false
                    DisableLag = false
                end

                if lagOk then
                    -- Get position local to the camera
                    local localLastPosition
                    local localCurrentPosition

                    local transformMatrix = self:GetTransform()
                    Matrix3D::Inverse_Transform_Vector( transformMatrix, LastAnchorPosition, localLastPosition )
                    Matrix3D::Inverse_Transform_Vector( transformMatrix, anchorPosition, localCurrentPosition )

                    local lerp = profile.Lag * math.Clamp( LagPersistTimer, 0, 1 )
                    lerp.x = math.pow( lerp.x, 10 * frameTime ) -- Left/Right
                    lerp.y = math.pow( lerp.y, 10 * frameTime ) -- Up/Down
                    lerp.z = math.pow( lerp.z, 10 * frameTime ) -- Forward/Back
                    lerp = Vector( 1,1,1 ) - lerp
                    localCurrentPosition.X = localLastPosition.X + ( localCurrentPosition.X - localLastPosition.X ) * lerp.X
                    localCurrentPosition.Y = localLastPosition.Y + ( localCurrentPosition.Y - localLastPosition.Y ) * lerp.Y
                    localCurrentPosition.Z = localLastPosition.Z + ( localCurrentPosition.Z - localLastPosition.Z ) * lerp.Z
                    Matrix3D::Transform_Vector( transformMatrix, localCurrentPosition, anchorPosition )

                    local diff = anchorPosition - LastAnchorPosition
                    if ( diff:Length() < 5 ) then -- Don't lerp over long distances
                        anchorPosition = LerpVector( 0.25, anchorPosition, LastAnchorPosition )
                    else
                        LagPersistTimer = 0
                        DisableLag = true
                    end

                end
            end

            LastAnchorPosition = anchorPosition
            LastHeading	= self.Heading
        end

        self:SetViewPlane( profile:GetFov() ) -- Apply Zoom


        -- Calculate the Camera Transform
        local transformMatrix = Matrix() -- Setup base position
        transformMatrix:Identity()
        transformMatrix:Translate( anchorPosition )
        transformMatrix:Translate( Vector( 0, 0, profile:GetHeight() ) )

        ConvertWorldToCamera( transformMatrix ) -- Setup orientation
        transformMatrix:RotateY( cameraHeading ) -- Apply rotations
        transformMatrix:RotateX( -profile:GetViewTilt() - self.Tilt )

        -- Only do this when the profile has a distance value
        if ( profile:GetDistance() ~= 0 ) then
            -- Translate along Z so that our near clip plane is behind the head
            local nearz, farz = self:GetClipPlanes()
            local headRadius = 0.2 -- HEAD_RADIUS should be renamed and become part of the profile?
            transformMatrix:TranslateZ( nearz + headRadius )
        end

        local intermediatePos = transformMatrix:GetTranslation() -- Save base position
        local intermediateTm = transformMatrix -- Save base transform

        -- Generate a translation path for the camera which is 'tilt' off of the z-axis
        local cameraMove = Vector( 0, 0, profile:GetDistance() )
        cameraMove:RotateX( -profile:GetTranslationTilt() )
        cameraMove:RotateX( -math.max( -self.Tilt * profile:GetTiltTweak(), 0 ) )
        transformMatrix:Translate( cameraMove ) -- Pull back
        local endPos = transformMatrix:GetTranslation() -- Save the end position

        -- Sweep the view plane back until it hits something
        if ( profile:GetDistance() ~= 0 ) then
            -- (gth) FIXME!
            -- Sort of a hack here, trying to make the camera not collide with the star
            -- Really this should make sure we don't collide with whatever the camera is starting inside
            self:IgnoreStarAndVehicle()

            -- Collide the bounding box of the near clip plane
            -- Have to SetTransform so that the camera can calculate the box for us
            CastResultStruct res
            self:SetTransform( intermediateTm )
            self:SetClipPlanes( NearClipPlane,FarClipPlane )
            local box = self:GetNearClipBoundingBox()
            local boxTest = physOBBoxCollisionTestClass.New( box, endPos - intermediatePos, res, DEFAULT_COLLISION_GROUP, COLLISION_TYPE_CAMERA )
            PhysicsSceneClass::Get_Instance()->CastOBBox( boxTest )

            -- Solve the problem of the camera when getting out of the car
            if res.StartBad and interpolating and boxtest.CollidedPhysObj then
                -- ignore what we hit and do it again
                PhysClass * hit = boxTest.CollidedPhysObj
                hit->Inc_Ignore_Counter()
                res.Reset()
                PhysicsSceneClass::Get_Instance()->CastOBBox( boxTest )
                hit->Dec_Ignore_Counter()
            end

            -- Move the camera to the collision if needed.
            if res.Fraction < DistanceFraction then
                DistanceFraction = res.Fraction -- Always pull camera in if a collision occured
            end
            if res.Fraction > DistanceFraction then
                DistanceFraction = DistanceFraction + math.min( res.Fraction-DistanceFraction, CAMERA_UNWIND_SPEED * frameTime )
            end

            if DistanceFraction < 1.0 then
                transformMatrix:SetTranslation( intermediatePos + DistanceFraction * ( end_pos - intermediatePos ) )
                end_pos = transformMatrix:GetTranslation()
            end

            -- Now put the star back to his original 'ignore' state
            self:UnignoreStarAndVehicle()

        else
            -- This is a camera which doesn't translate back.  Just check its near clip plane for intersection
            -- with the world and if it does intersect, pull the near clip plane in to its minimum.
            self:IgnoreStarAndVehicle()

            -- Collide the bounding box of the near clip plane
            -- Have to Set_Transform so that the camera can calculate the box for us
            CastResultStruct res
            self:SetTransform( transformMatrix )
            self:SetClipPlanes( NearClipPlane, FarClipPlane )
            local box = self:GetNearClipBoundingBox()

            local nullVector = Vector( 0, 0, 0 )
            local boxTest = physOBBoxCollisionTestClass.New( box, nullVector, res, DEFAULT_COLLISION_GROUP, COLLISION_TYPE_CAMERA )
            PhysicsSceneClass::Get_Instance()->CastOBBox( boxTest )

            -- Set the near clip plane depending on whether the default near clip plane intersected any geometry
            if res.StartBad then
                self:SetClipPlanes( CCAMERA_MIN_NEARZ, self.FarClipPlane )
            else
                self:SetClipPlanes( self.NearClipPlane, self.FarClipPlane )
            end

            self:UnignoreStarAndVehicle()
        end

        self:SetTransform( transformMatrix ) -- Set our new transform

        -- First, set the aiming point to where the camera is looking
        if ( self:DetermineTargetingPosition() == false ) then
            -- Then, modify the aiming point for weapon help, if not on a target
            self:ApplyWeaponHelp()
        end

        -- Lastly, pass the aiming point to the star and tell the star what we are looking at
        local isStarDeterminingTarget = combatManager.IsStarDeterminingTarget()
        if ( IsValid( combatStar ) and isStarDeterminingTarget ) then
            -- Omitted setting combat star target
            --combatStar:SetTargeting( self.StarTargetingPosition )
        end
        --]]
    end

    --- @return boolean
    function INSTANCE:IsInCinematic()
        return self.HostModel ~= NULL
    end

    --- @return boolean
    function INSTANCE:IsValid()
        return self._IsValid
    end

    --- @return Vector
    function INSTANCE:GetCameraTarget2dOffset()
        return self.CameraTarget2dOffset
    end

    --- @param pos Vector
    function INSTANCE:SetAnchorPosition( pos )
        typecheck.NotImplementedError( CLASS, "SetAnchorPosition" )
    end

    --- @param target Vector
    function INSTANCE:ForceLook( target )
        typecheck.NotImplementedError( CLASS, "ForceLook" )
    end

    --[[ Profile Access ]] do

        --- @param name string
        function INSTANCE:UseProfile( name )
            typecheck.NotImplementedError( CLASS, "UseProfile" )
        end

        function INSTANCE:UseDefaultProfile()
            self.CurrentProfile = self.DefaultProfile
            self.CurrentProfileName = self.DefaultProfileName
        end

        --- @param height number
        function INSTANCE:SetProfileHeight( height )
            typecheck.NotImplementedError( CLASS, "SetProfileHeight" )
        end

        --- @param distance number
        function INSTANCE:SetProfileDistance( distance )
            typecheck.NotImplementedError( CLASS, "SetProfileDistance" )
        end

        --- @return number
        function INSTANCE:GetProfileZoom()
            typecheck.NotImplementedError( CLASS, "GetProfileZoom" )
        end
    end

    --[[ Orientation ]] do

        --- @param heading number
        function INSTANCE:ForceHeading( heading )
            self.Heading = heading
        end

        --- @return number
        function INSTANCE:GetHeading()
            return self.Heading
        end

        --- @param tilt number
        function INSTANCE:SetTilt( tilt )
            self.Tilt = tilt
        end

        --- @return number
        function INSTANCE:GetTilt()
            return self.Tilt
        end
    end

    --- @param time number
    function INSTANCE:SetLerpTime( time )
        typecheck.NotImplementedError( CLASS, "SetLerpTime" )
    end

    --- @return boolean
    function INSTANCE:IsLerping()
        return self.LerpTimeTotal ~= 0
    end

    --- @param host RenderObjInstance
    function INSTANCE:SetHostModel( host )
        typecheck.NotImplementedError( CLASS, "SetHostModel" )
    end

    --- @return boolean
    function INSTANCE:IsUsingHostModel()
        return self.HostModel ~= NULL
    end

    --- @param isEnabled boolean
    function INSTANCE:Enable2dTargeting( isEnabled )
        self._Enable2dTargeting = isEnabled
    end

    --- @return boolean
    function INSTANCE:Is2dTargeting()
        return self._Enable2dTargeting
    end

    --- @param isEnabled boolean
    function INSTANCE:EnableWeaponHelp( isEnabled )
        self._EnableWeaponHelp = isEnabled
    end

    --- @return boolean
    function INSTANCE:IsWeaponHelpEnabled()
        return self._EnableWeaponHelp
    end

    --[[ Sniper Mode ]] do

        --- @return boolean
        function INSTANCE:DrawSniper()
            typecheck.NotImplementedError( CLASS, "DrawSniper" )
        end

        --- @param isEnabled boolean
        --- @param zoom number
        function INSTANCE:CinematicSniperControl( isEnabled, zoom )
            typecheck.NotImplementedError( CLASS, "CinematicSniperControl" )
        end

        --- @param isSniping boolean
        function INSTANCE:SetIsStarSniping( isSniping )
            typecheck.NotImplementedError( CLASS, "SetIsStarSniping" )
        end

        --- @return boolean
        function INSTANCE:IsStarSniping()
            return self._IsStarSniping
        end

        --- @return number
        function INSTANCE:GetSniperZoom()
            return self.SniperZoom
        end

        --- @param distance number
        function INSTANCE:SetSniperDistance( distance )
            if self.SniperDistance == distance then
                return
            end

            self.SniperDistance = distance
            self:UpdateSniperListenerPos()
        end

        --- @return number
        function INSTANCE:GetSniperDistance()
            return self.SniperDistance
        end
    end

    --- @return Vector
    function INSTANCE:GetFirstPersonOffsetTweak()
        typecheck.NotImplementedError( CLASS, "GetFirstPersonOffsetTweak" )
    end

    function INSTANCE:ResetFirstPersonOffsetTweak()
        typecheck.NotImplementedError( CLASS, "ResetFirstPersonOffsetTweak" )
    end

    --- @param mode SnapshotMode
    function INSTANCE:SetSnapshotMode( mode )
        self._SnapshotMode = mode
    end

    --- @return boolean
    function INSTANCE:IsSnapshotMode()
        return self._SnapshotMode == snapshot.ON
    end


    --- [[ Protected ]]

    --- Camera Host Model
    --- @class CommandoCameraInstance
    --- @field protected HostModel RenderObjectInstance

    --- Camera Anchor Position
    --- @class CommandoCameraInstance
    --- @field protected AnchorPosition Vector
    --- @field protected _IsValid boolean

    --- Current Camera Orientation
    --- @class CommandoCameraInstance
    --- @field protected Tilt number
    --- @field protected Heading number
    --- @field protected DistanceFraction number

    --- Weapon Help
    --- @class CommandoCameraInstance
    --- @field protected _EnableWeaponHelp boolean
    --- @field protected WeaponHelpTimer number
    --- @field protected WeaponHelpTarget Entity

    --- Targetting
    --- @class CommandoCameraInstance
    --- @field protected StarTargetingPosition Vector
    --- @field protected CameraTarget2dOffset Vector

    --- Linear Interpolation
    --- @class CommandoCameraInstance
    --- @field protected LerpTimeTotal number
    --- @field protected LerpTimeRemaining number
    --- @field protected LastAnchorPosition Vector
    --- @field protected LastHeading number

    --- Parameter Profile
    --- @class CommandoCameraInstance
    --- @field protected CurrentProfile CommandoCameraProfileInstance
    --- @field protected LastProfile CommandoCameraProfileInstance
    --- @field protected DefaultProfile CommandoCameraProfileInstance
    --- @field protected CurrentProfileName string
    --- @field protected LastProfileName string
    --- @field protected DefaultProfileName string

    --- Clipping Planes
    --- @class CommandoCameraInstance
    --- @field protected NearClipPlane number
    --- @field protected FarClipPlane number

    --- Sniper Mode
    --- @class CommandoCameraInstance
    --- @field protected _IsStarSniping boolean
    --- @field protected WasStarSniping boolean
    --- @field protected SniperZoom number
    --- @field protected SniperDistance number
    --- @field protected SniperListener Listener3dInstance
    --- @field protected CinematicSnipingEnabled boolean
    --- @field protected CinematicSnipingDesiredZoon number

    --- Misc.
    --- @class CommandoCameraInstance
    --- @field protected _SnapshotMode SnapshotMode
    --- @field protected _Enable2dTargeting boolean
    --- @field protected LagPersistTimer number
    --- @field protected DisableLag boolean


    --- @param offset Vector
    --- @param distance number
    --- @param intermediatePos Vector
    --- @return number
    --- @protected
    function INSTANCE:GetCameraPos( offset, distance, intermediatePos )
        typecheck.NotImplementedError( CLASS, "GetCameraPos" )
    end

    --- @protected
    function INSTANCE:UseHostModel()
        typecheck.NotImplementedError( CLASS, "UseHostModel" )
    end

    --- @protected
    function INSTANCE:HandleInput()
        typecheck.NotImplementedError( CLASS, "HandleInput" )
    end

    --- "Finds the world position and Entity the player is looking/pointing at"
    --- "The details get stored in HudInfo"
    --- @return boolean isTargetingAnEntity
    --- @protected
    function INSTANCE:DetermineTargetingPosition()
        local lookingAtEntity = false

        local combatStar = combatManager.GetTheStar() --[[@as Player]]
        local isStarDeterminingTarget = combatManager.IsStarDeterminingTarget()

        if IsValid( combatStar ) and isStarDeterminingTarget then

            -- Omitted tracing logic

            local hitEnt, traceLength = infoEntityLib.TraceForInfoEntity()

            if IsValid( hitEnt ) and infoEntityLib.IsEntityTargetable( hitEnt ) then
                --- @cast hitEnt Entity

                -- Check for the MCT
                local isMct = false
                if buildingsBridge.IsBuilding( hitEnt ) then
                    isMct = buildingsBridge.IsMct( hitEnt )
                end

                -- Don't target stealthed enemies
                if smartGameObjectsBridge.IsStealthed( hitEnt ) and physicalGameObjectsBridge.IsEnemy( hitEnt, combatStar ) then
                    hitEnt = NULL
                end

                hudInfo.SetInfoEntity( hitEnt, isMct )
                hudInfo.SetWeaponTargetEntity( hitEnt )
            else
                -- Not in original code.  Not sure where this same code lives originally.
                hudInfo.SetWeaponTargetEntity( NULL )
            end

            self:SetSniperDistance( traceLength )
        end

        return lookingAtEntity
    end

    --- @protected
    function INSTANCE:ApplyWeaponHelp()

        -- Omitted all normal code for now

        local bestObj = infoEntityLib.TraceForInfoEntity()

        if infoEntityLib.IsEntityTargetable( bestObj ) then
            --- @cast bestObj Entity

            -- "remember this guy"
            self.WeaponHelpTarget = bestObj
            self.StarTargetingPosition = bestObj:GetPos() + bestObj:OBBCenter() -- Omitted bestObj:GetBullseyePosition()

            hudInfo.SetInfoEntity( bestObj )
        end
    end

    --- @protected
    function INSTANCE:UpdateSniperListenerPos()

        if IsValid( self.SniperListener ) then
            typecheck.NotImplementedError( CLASS, "UpdateSniperListenerPos" )
        end
    end

    --- @protected
    function INSTANCE:HandleSnapshotMode()
        typecheck.NotImplementedError( CLASS, "HandleSnapshotMode" )
    end
end