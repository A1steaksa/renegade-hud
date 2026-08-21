-- Based on AdaptiveDeltaMotionChannelClass within var/home/JSchneider/Projects/LuaRenegadePort/C&amp;C Renegade/Code/ww3d2/motchan.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class AdaptiveDeltaMotionChannelClass
--- @field Instance AdaptiveDeltaMotionChannelInstance The metatable used by AdaptiveDeltaMotionChannelInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "AdaptiveDeltaMotionChannelClass"

--- @class AdaptiveDeltaMotionChannelInstance
--- @field Static AdaptiveDeltaMotionChannelClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_AdaptiveDeltaMotionChannel" )
INSTANCE.Class = "AdaptiveDeltaMotionChannelInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsAdaptiveDeltaMotionChannel = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class AdaptiveDeltaMotionChannelClass

    --- Creates a new AdaptiveDeltaMotionChannelInstance
    --- @return AdaptiveDeltaMotionChannelInstance
    function STATIC.New()
        return robustclass.New( "Renegade_AdaptiveDeltaMotionChannel" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) AdaptiveDeltaMotionChannelInstance, `false` otherwise
    function STATIC.IsAdaptiveDeltaMotionChannel( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsAdaptiveDeltaMotionChannel and true or false
    end

    typecheck.RegisterType( "AdaptiveDeltaMotionChannelInstance", STATIC.IsAdaptiveDeltaMotionChannel )
end


--- @class AdaptiveDeltaMotionChannelInstance
--- @field PivotIdx any
--- @field Type any
--- @field VectorLen any
--- @field NumFrames any
--- @field Scale any
--- @field Data any
--- @field CacheFrame any
--- @field CacheData any

function INSTANCE:Renegade_AdaptiveDeltaMotionChannel()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_AdaptiveDeltaMotionChannel()
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

function INSTANCE:Getframe()
	typecheck.NotImplementedError()
end

function INSTANCE:Decompress()
	typecheck.NotImplementedError()
end
