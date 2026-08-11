-- Based on LineSegClass within Code/WWMath/lineseg.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class LineSegClass
--- @field Instance LineSegInstance The metatable used by LineSegInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "LineSegClass"

--- @class LineSegInstance
--- @field Static LineSegClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_LineSeg" )
INSTANCE.Class = "LineSegInstance"
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

    --- @class LineSegClass

    --- Creates a new LineSegInstance
    --- @return LineSegInstance
    function STATIC.New()
        return robustclass.New( "Renegade_LineSeg" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) LineSegInstance, `false` otherwise
    function STATIC.IsLineSeg( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsLineSeg and true or false
    end

    typecheck.RegisterType( "LineSegInstance", STATIC.IsLineSeg )
end


--- @class LineSegInstance
--- @field P0 Vector
--- @field P1 Vector
--- @field Dp Vector
--- @field Dir Vector
--- @field Length number

function INSTANCE:Renegade_LineSeg()
	typecheck.NotImplementedError()
end

function INSTANCE:Renegade_LineSeg()
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
