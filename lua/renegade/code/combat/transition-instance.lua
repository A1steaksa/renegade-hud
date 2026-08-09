-- Based on TransitionInstanceClass within Code/Combat/transition.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class TransitionInstanceClass
--- @field Instance TransitionInstanceInstance The metatable used by TransitionInstanceInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "TransitionInstanceClass"

--- @class TransitionInstanceInstance
--- @field Static TransitionInstanceClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_TransitionInstance" )
INSTANCE.Class = "TransitionInstanceInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsTransitionInstance = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class TransitionInstanceClass

    --- Creates a new TransitionInstanceInstance
    --- @return TransitionInstanceInstance
    function STATIC.New()
        return robustclass.New( "Renegade_TransitionInstance" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) TransitionInstanceInstance, `false` otherwise
    function STATIC.IsTransitionInstance( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsTransitionInstance and true or false
    end

    typecheck.RegisterType( "TransitionInstanceInstance", STATIC.IsTransitionInstance )

	function STATIC.End()
		typecheck.NotImplementedError()
	end
end


--- @class TransitionInstanceInstance
--- @field EndingTM Matrix3d
--- @field Zone ObBoxInstance
--- @field Vehicle ScriptableGameObjectInstance
--- @field Data ConstTransitionDataInstance
--- @field LadderIndex integer

function INSTANCE:Renegade_TransitionInstance()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_TransitionInstance()
	typecheck.NotImplementedError()
end

function INSTANCE:Check()
	typecheck.NotImplementedError()
end

function INSTANCE:Start()
	typecheck.NotImplementedError()
end

function INSTANCE:GetType()
	typecheck.NotImplementedError()
end

function INSTANCE:SetParentTransform()
	typecheck.NotImplementedError()
end

function INSTANCE:GetVehicle()
	typecheck.NotImplementedError()
end

function INSTANCE:SetVehicle()
	typecheck.NotImplementedError()
end

function INSTANCE:GetZone()
	typecheck.NotImplementedError()
end

function INSTANCE:GetEndingTm()
	typecheck.NotImplementedError()
end

function INSTANCE:GetLadderIndex()
	typecheck.NotImplementedError()
end

function INSTANCE:SetLadderIndex()
	typecheck.NotImplementedError()
end
