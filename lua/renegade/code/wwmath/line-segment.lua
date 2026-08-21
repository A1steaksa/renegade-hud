-- Based on LineSegmentClass within Code/WWMath/lineseg.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class LineSegmentClass
--- @field Instance LineSegmentInstance The metatable used by LineSegmentInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "LineSegmentClass"

--- @class LineSegmentInstance
--- @field Static LineSegmentClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_LineSegment" )
INSTANCE.Class = "LineSegmentInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsLineSeg = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class LineSegmentClass

    --- Creates a new LineSegmentInstance
    --- @return LineSegmentInstance
    function STATIC.New()
        return robustclass.New( "Renegade_LineSegment" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) LineSegmentInstance, `false` otherwise
    function STATIC.IsLineSeg( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsLineSeg and true or false
    end

    typecheck.RegisterType( "LineSegmentInstance", STATIC.IsLineSeg )
end


--- @class LineSegmentInstance
--- @field P0 Vector
--- @field P1 Vector
--- @field Dp Vector
--- @field Dir Vector
--- @field Length number

function INSTANCE:Renegade_LineSegment()
	typecheck.NotImplementedError()
end

function INSTANCE:Set()
	typecheck.NotImplementedError()
end

function INSTANCE:SetRandom()
	typecheck.NotImplementedError()
end

function INSTANCE:GetP0()
	typecheck.NotImplementedError()
end

function INSTANCE:GetP1()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDp()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDir()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLength()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputePoint()
	typecheck.NotImplementedError()
end

function INSTANCE:FindPointClosestTo()
	typecheck.NotImplementedError()
end

function INSTANCE:FindIntersection()
	typecheck.NotImplementedError()
end

function INSTANCE:Recalculate()
	typecheck.NotImplementedError()
end
