-- Based on UnitCoordinationZoneMgr within Code/Combat/unitcoordinationzonemgr.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class UnitCoordinationZoneManagerClass
--- @field Instance UnitCoordinationZoneManagerInstance The metatable used by UnitCoordinationZoneManagerInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "UnitCoordinationZoneManagerClass"

--- @class UnitCoordinationZoneManagerInstance
--- @field Static UnitCoordinationZoneManagerClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_UnitCoordinationZoneManager" )
INSTANCE.Class = "UnitCoordinationZoneManagerInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsUnitCoordinationZoneManager = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class UnitCoordinationZoneManagerClass
	--- @field ZoneList AABoxInstance[]

	STATIC.ZoneList = {}

    --- Creates a new UnitCoordinationZoneManagerInstance
    --- @return UnitCoordinationZoneManagerInstance
    function STATIC.New()
        return robustclass.New( "Renegade_UnitCoordinationZoneManager" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) UnitCoordinationZoneManagerInstance, `false` otherwise
    function STATIC.IsUnitCoordinationZoneManager( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsUnitCoordinationZoneManager and true or false
    end

    typecheck.RegisterType( "UnitCoordinationZoneManagerInstance", STATIC.IsUnitCoordinationZoneManager )

	function STATIC.BuildZones()
		STATIC.Reset()

		-- "Build the zone lists for both ladder and elevators"
		STATIC.DetectLadderZones()
		STATIC.DetectElevatorZones()
	end

	function STATIC.Reset()
		STATIC.ZoneList = {}
	end

	--- @param pos Vector
	--- @return boolean
	function STATIC.IsUnitInZone( pos )
		typecheck.NotImplementedError()
	end

	function STATIC.DisplayDebugBoxes()
		typecheck.NotImplementedError()
	end

	function STATIC.DetectLadderZones()
		typecheck.NotImplementedError()
	end

	function STATIC.DetectElevatorZones()
		typecheck.NotImplementedError()
	end
end


--- @class UnitCoordinationZoneManagerInstance
