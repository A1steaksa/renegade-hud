-- Based on TimeCodedMotionChannelClass within var/home/JSchneider/Projects/LuaRenegadePort/C&amp;C Renegade/Code/ww3d2/motchan.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class TimeCodedMotionChannelClass
--- @field Instance TimeCodedMotionChannelInstance The metatable used by TimeCodedMotionChannelInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "TimeCodedMotionChannelClass"

--- @class TimeCodedMotionChannelInstance
--- @field Static TimeCodedMotionChannelClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_TimeCodedMotionChannel" )
INSTANCE.Class = "TimeCodedMotionChannelInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsTimeCodedMotionChannel = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class TimeCodedMotionChannelClass

    --- Creates a new TimeCodedMotionChannelInstance
    --- @return TimeCodedMotionChannelInstance
    function STATIC.New()
        return robustclass.New( "Renegade_TimeCodedMotionChannel" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) TimeCodedMotionChannelInstance, `false` otherwise
    function STATIC.IsTimeCodedMotionChannel( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsTimeCodedMotionChannel and true or false
    end

    typecheck.RegisterType( "TimeCodedMotionChannelInstance", STATIC.IsTimeCodedMotionChannel )
end


--- @class TimeCodedMotionChannelInstance
--- @field PivotIdx any
--- @field Type any
--- @field VectorLen any
--- @field PacketSize any
--- @field NumTimeCodes any
--- @field LastTimeCodeIdx any
--- @field CachedIdx any
--- @field Data any

function INSTANCE:Renegade_TimeCodedMotionChannel()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_TimeCodedMotionChannel()
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

function INSTANCE:GetVector()
	typecheck.NotImplementedError()
end

function INSTANCE:GetQuatVector()
	typecheck.NotImplementedError()
end

function INSTANCE:Free()
	typecheck.NotImplementedError()
end

function INSTANCE:SetIdentity()
	typecheck.NotImplementedError()
end

function INSTANCE:GetIndex()
	typecheck.NotImplementedError()
end

function INSTANCE:BinarySearchIndex()
	typecheck.NotImplementedError()
end
