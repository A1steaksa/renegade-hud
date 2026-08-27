-- Based on CCameraProfileClass within Code/Combat/ccamera.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class CommandoCameraProfileClass
--- @field instance CommandoCameraProfileInstance The metatable used by CommandoCameraProfileInstance
local STATIC = CNC.CreateExport()
STATIC.Class = "CommandoCameraProfileClass"
local isHotload = not table.IsEmpty( STATIC )

--- @class CommandoCameraProfileInstance
--- @field Static CommandoCameraProfileClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_CommandoCameraProfile" )
INSTANCE.Class = "CommandoCameraProfileInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsCommandoCameraProfile = true


--#region Imports

    --- @type AssetsClass
    local assetsClass = CNC.Import( "code/combat/assets.lua" )

    --- @type UnitConversionLib
    local unitConversionLib = CNC.Import( "sh_unit-conversion.lua" )
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class CommandoCameraProfileClass
    --- @field ProfileHash table<string, CommandoCameraProfileInstance> Key: name, Value: profile

    STATIC._ProfilesInitted = false
    STATIC.ProfileHash = {}

    STATIC.CAMERAS_INI_FILENAME  = "cameras.ini"
    STATIC.SECTION_PROFILE_LIST  = "Profile_List"
    STATIC.ENTRY_NAME            = "Name"
    STATIC.ENTRY_FOV             = "FOV"
    STATIC.ENTRY_HEIGHT          = "Height"
    STATIC.ENTRY_VIEWTILT        = "ViewTilt"
    STATIC.ENTRY_TRANSLATIONTILT = "TranslationTilt"
    STATIC.ENTRY_DISTANCE        = "Distance"
    STATIC.ENTRY_LAG_UP          = "LagUp"
    STATIC.ENTRY_LAG_LEFT        = "LagLeft"
    STATIC.ENTRY_LAG_FORWARD     = "LagForward"
    STATIC.ENTRY_TILTTWEAK       = "TiltTweak"

    STATIC.MIN_FOV = 0.02

    --- Creates a new CommandoCameraProfileInstance
    --- @return CommandoCameraProfileInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_CommandoCameraProfile" )
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
        if STATIC._ProfilesInitted then
            STATIC.Shutdown()
        end

        local camerasIni = assetsClass.GetIni( STATIC.CAMERAS_INI_FILENAME )

        if camerasIni ~= nil then
            local count = camerasIni:EntryCount( STATIC.SECTION_PROFILE_LIST )

            for entry = 1, count do
                local entryName = camerasIni:GetEntry( STATIC.SECTION_PROFILE_LIST, entry )
                if not entryName then
                    section.Error( "Failed to get entry name for entry ", entry )
                end
                --- @cast entryName string
                local sectionName = camerasIni:GetString( STATIC.SECTION_PROFILE_LIST, entryName )

                local profile = STATIC.New()
                local name = camerasIni:GetString( sectionName, STATIC.ENTRY_NAME )

                profile.Fov = math.rad( camerasIni:GetFloat( sectionName, STATIC.ENTRY_FOV, math.deg( profile.Fov ) ) )
                profile.Height = camerasIni:GetFloat( sectionName, STATIC.ENTRY_HEIGHT, profile.Height )
                profile.ViewTilt = math.rad( camerasIni:GetFloat( sectionName, STATIC.ENTRY_VIEWTILT, math.deg( profile.ViewTilt ) ) )
                profile.TiltTweak = camerasIni:GetFloat( sectionName, STATIC.ENTRY_TILTTWEAK, profile.TiltTweak )
                profile.TranslationTilt = math.rad( camerasIni:GetFloat( sectionName, STATIC.ENTRY_TRANSLATIONTILT, math.deg( profile.TranslationTilt ) ) )
                profile.Distance = camerasIni:GetFloat( sectionName, STATIC.ENTRY_DISTANCE, profile.Distance )

                profile.Lag.y = camerasIni:GetFloat( sectionName, STATIC.ENTRY_LAG_UP, profile.Lag.y )
                profile.Lag.x = camerasIni:GetFloat( sectionName, STATIC.ENTRY_LAG_LEFT, profile.Lag.x )
                profile.Lag.z = camerasIni:GetFloat( sectionName, STATIC.ENTRY_LAG_FORWARD, profile.Lag.z )

                -- "Convert to lower case"
                STATIC.ProfileHash[name:lower()] = profile
            end
        else
            section.Error( "Unable to load ", STATIC.CAMERAS_INI_FILENAME )
        end

        STATIC._ProfilesInitted = true
    end

    function STATIC.Shutdown()
        STATIC.ProfileHash = {}
        STATIC._ProfilesInitted = false
    end

    --- @param name string
    --- @return CommandoCameraProfileInstance
    function STATIC.Find( name )
        return STATIC.ProfileHash[ name:lower() ]
    end
end

--- @class CommandoCameraProfileInstance
--- @field Fov number "Field of view for the camera"
--- @field Height number "Height above the origin of 'focus' object"
--- @field ViewTilt number "Default tilt of the camera"
--- @field TiltTweak number "Default tilt tweak of the camera"
--- @field TranslationTilt number "Tilt of translation vector for the camera (off of the z axis)"
--- @field Distance number "How far back the camera wants to be normally"
--- @field Lag Vector "The camera lag"

INSTANCE._ProfilesInitted = false

--- Constructs a new CommandoCameraProfileInstance
function INSTANCE:Renegade_CommandoCameraProfile()
    self.Fov             = math.rad( 65.0 )
    self.Height          = 1.95 * unitConversionLib.MetersToSource
    self.ViewTilt        = math.rad( 20 )
    self.TiltTweak       = 0.6
    self.TranslationTilt = math.rad( 19.9 )
    self.Distance        = 3.1
    self.Lag             = Vector( 0, 0, 0 )
end

--- @param amount number
function INSTANCE:SetZoom( amount )
    amount = math.sqrt( amount )
    amount = math.Clamp( 1 - amount, 0, 1 )
    self.Fov = STATIC.MIN_FOV + ( ( 0.8 - STATIC.MIN_FOV ) * amount )
end

--- @return number
function INSTANCE:GetZoom()
    --  I love magic numbers!

    -- "TSS - by my reckoning this is the actual zoom factor"
    return 0.8 / self.Fov
end

--- @param height number
function INSTANCE:SetHeight( height )
    typecheck.NotImplementedError()
end

--- @return number
function INSTANCE:GetHeight()
    typecheck.NotImplementedError()
end

--- @param distance number
function INSTANCE:SetDistance( distance )
    typecheck.NotImplementedError()
end

--- @return number
function INSTANCE:GetDistance()
    typecheck.NotImplementedError()
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

--- @param a CommandoCameraProfileInstance
--- @param b CommandoCameraProfileInstance
--- @param lerp number
--- @protected
function INSTANCE:Lerp( a, b, lerp )
    typecheck.NotImplementedError()
end