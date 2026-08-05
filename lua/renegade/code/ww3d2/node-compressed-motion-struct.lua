-- Based on NodeCompressedMotionStruct within Code/ww3d2/hcanim.cpp

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class NodeCompressedMotionStruct
--- @field Instance NodeCompressedMotionInstance The metatable used by NodeCompressedMotionInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "NodeCompressedMotionStruct"

--- @class NodeCompressedMotionInstance
--- @field Static NodeCompressedMotionStruct The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_NodeCompressedMotionStruct" )
INSTANCE.Class = "NodeCompressedMotionInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsNodeCompressedMotionStruct = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class NodeCompressedMotionStruct

    --- Creates a new NodeCompressedMotionInstance
    --- @return NodeCompressedMotionInstance
    function STATIC.New()
        return robustclass.New( "Renegade_NodeCompressedMotionStruct" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) NodeCompressedMotionInstance, `false` otherwise
    function STATIC.IsNodeCompressedMotionStruct( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsNodeCompressedMotionStruct and true or false
    end

    typecheck.RegisterType( "NodeCompressedMotionInstance", STATIC.IsNodeCompressedMotionStruct )
end

--- @class TimeCodedMotion
--- @field X TimeCodedMotionChannelInstance
--- @field Y TimeCodedMotionChannelInstance
--- @field Z TimeCodedMotionChannelInstance
--- @field Q TimeCodedMotionChannelInstance

--- @class AdaptiveDeltaMotion
--- @field X AdaptiveDeltaMotionChannelInstance
--- @field Y AdaptiveDeltaMotionChannelInstance
--- @field Z AdaptiveDeltaMotionChannelInstance
--- @field Q AdaptiveDeltaMotionChannelInstance

--- @class VectorDeltaMotion
--- @field X integer?
--- @field Y integer?
--- @field Z integer?
--- @field Q integer?

--- @class NodeCompressedMotionInstance
--- @field Flavor integer
--- @field TimeCoded TimeCodedMotion
--- @field AdaptiveDelta AdaptiveDeltaMotion
--- @field VectorDelta VectorDeltaMotion
--- @field Visibility TimeCodedBitChannelInstance

function INSTANCE:Renegade_NodeCompressedMotionStruct()
    self.Visibility = nil
    self.VectorDelta = {
        X = nil,
        Y = nil,
        Z = nil,
        Q = nil,
    }
end

function INSTANCE:_Renegade_NodeCompressedMotionStruct()
    -- "Needs to be changed to call the correct destructors"
    -- Omitted function contents until they're actually needed.
end

--- @param flavor AnimationFlavor
function INSTANCE:SetFlavor( flavor )
	self.Flavor = flavor
end
