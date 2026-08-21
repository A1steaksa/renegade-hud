-- Based on TimeCodedBitChannelClass within var/home/JSchneider/Projects/LuaRenegadePort/C&amp;C Renegade/Code/ww3d2/motchan.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class TimeCodedBitChannelClass
--- @field Instance TimeCodedBitChannelInstance The metatable used by TimeCodedBitChannelInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "TimeCodedBitChannelClass"

--- @class TimeCodedBitChannelInstance
--- @field Static TimeCodedBitChannelClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_TimeCodedBitChannel" )
INSTANCE.Class = "TimeCodedBitChannelInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsTimeCodedBitChannel = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class TimeCodedBitChannelClass

    --- Creates a new TimeCodedBitChannelInstance
    --- @return TimeCodedBitChannelInstance
    function STATIC.New()
        return robustclass.New( "Renegade_TimeCodedBitChannel" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) TimeCodedBitChannelInstance, `false` otherwise
    function STATIC.IsTimeCodedBitChannel( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsTimeCodedBitChannel and true or false
    end

    typecheck.RegisterType( "TimeCodedBitChannelInstance", STATIC.IsTimeCodedBitChannel )
end


--- @class TimeCodedBitChannelInstance
--- @field PivotIndex integer
--- @field Type any
--- @field DefaultValue any
--- @field NumTimeCodes any
--- @field CachedIndex any
--- @field Bits any

function INSTANCE:Renegade_TimeCodedBitChannel()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_TimeCodedBitChannel()
	typecheck.NotImplementedError()
end

--- @param cload ChunkLoadInstance
--- @return boolean
function INSTANCE:LoadW3d( cload )
	typecheck.NotImplementedError()
end

function INSTANCE:GetType()
	typecheck.NotImplementedError()
end

function INSTANCE:GetPivot()
	typecheck.NotImplementedError()
end

function INSTANCE:GetBit()
	typecheck.NotImplementedError()
end

function INSTANCE:Free()
	typecheck.NotImplementedError()
end
