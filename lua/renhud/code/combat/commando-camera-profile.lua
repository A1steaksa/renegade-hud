-- Based on CCameraProfileClass within Code/Combat/ccamera.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of CommandoCameraProfile
    --- @class CommandoCameraProfileInstance
    --- @field Static CommandoCameraProfile The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_CommandoCameraProfile" )

    --- The static components of CommandoCameraProfile
    --- @class CommandoCameraProfile
    --- @field Instance CommandoCameraProfileInstance The Metatable used by CommandoCameraProfileInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsCommandoCameraProfile = true
end


--[[ Static Functions and Variables ]] do
    local CLASS = "CommandoCameraProfile"

    --- [[ Public ]]

    --- @class CommandoCameraProfile
    --- @field ProfileHash table<string, CommandoCameraProfileInstance> Key: name, Value: profile

    STATIC.ProfileHash = {}

    --- Creates a new CommandoCameraProfileInstance
    --- @vararg any
    --- @return CommandoCameraProfileInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_CommandoCameraProfile", ... )
    end

    ---@param arg any
    ---@return boolean `true` if the passed argument is a(n) CommandoCameraProfileInstance, `false` otherwise
    function STATIC.IsCommandoCameraProfile( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCommandoCameraProfile and true or false
    end

    typecheck.RegisterType( "CommandoCameraProfileInstance", STATIC.IsCommandoCameraProfile )

    function STATIC.Init()
        typecheck.NotImplementedError( CLASS, "Init" )
    end

    --- @param name string
    --- @return CommandoCameraProfileInstance
    function STATIC.Find( name )
        return STATIC.ProfileHash[ name:lower() ]
    end
end

--[[ Instanced Functions and Variables ]] do
    local CLASS = "CommandoCameraProfileInstance"

    --- [[ Public ]]

    --- @class CommandoCameraProfileInstance

    --- Constructs a new CommandoCameraProfileInstance
    --- @vararg any
    function INSTANCE:Renegade_CommandoCameraProfile( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        typecheck.AssertArgCount( CLASS, argCount )
    end

    --- @param amount number
    function INSTANCE:SetZoom( amount )
        typecheck.NotImplementedError( CLASS, "SetZoom" )
    end

    --- @return number
    function INSTANCE:GetZoom()
        typecheck.NotImplementedError( CLASS, "GetZoom" )
    end

    --- @param height number
    function INSTANCE:SetHeight( height )
        typecheck.NotImplementedError( CLASS, "SetHeight" )
    end

    --- @return number
    function INSTANCE:GetHeight()
        typecheck.NotImplementedError( CLASS, "GetHeight" )
    end

    --- @param distance number
    function INSTANCE:SetDistance( distance )
        typecheck.NotImplementedError( CLASS, "SetDistance" )
    end

    --- @return number
    function INSTANCE:GetDistance()
        typecheck.NotImplementedError( CLASS, "GetDistance" )
    end

    --- @return number
    function INSTANCE:GetFov()
        return self.Fov
    end

    --- @return number
    function INSTANCE:GetViewTilt()
        return self.ViewTilt
    end

    --- @return number
    function INSTANCE:GetTranslationTilt()
        return self.TranslationTilt
    end

    --- @return number
    function INSTANCE:GetTiltTweak()
        return self.TiltTweak
    end

    --- [[ Protected ]]

    --- @class CommandoCameraProfileInstance
    --- @field protected Fov number "Field of view for the camera"
    --- @field protected Height number "Height above the origin of 'focus' object"
	--- @field protected ViewTilt number "Default tilt of the camera"
	--- @field protected TiltTweak number "Default tilt tweak of the camera"
	--- @field protected TranslationTilt number "Tilt of translation vector for the camera (off of the z axis)"
	--- @field protected Distance number "How far back the camera wants to be normally"
	--- @field protected Lag Vector "The camera lag"
    --- @field protected _ProfilesInitted boolean

    INSTANCE._ProfilesInitted = false

    --- @param a CommandoCameraProfileInstance
    --- @param b CommandoCameraProfileInstance
    --- @param lerp number
    --- @protected
    function INSTANCE:Lerp( a, b, lerp )
        typecheck.NotImplementedError( CLASS, "Lerp" )
    end
end