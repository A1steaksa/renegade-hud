-- Based on CullableClass within Code/WWMath/cullsys.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class CullableClass
--- @field Instance CullableInstance The metatable used by CullableInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "CullableClass"

--- @class CullableInstance
--- @field Static CullableClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Cullable" )
INSTANCE.Class = "CullableInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsCullable = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type AABoxClass
	local aABoxClass = CNC.Import( "code/wwmath/aabox.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class CullableClass

    --- Creates a new CullableInstance
    --- @return CullableInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Cullable" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) CullableInstance, `false` otherwise
    function STATIC.IsCullable( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsCullable and true or false
    end

    typecheck.RegisterType( "CullableInstance", STATIC.IsCullable )
end


--- @class CullableInstance
--- @field CullLink CullLinkInstance
--- @field CullBox AABoxInstance
--- @field NextCollected CullableInstance

function INSTANCE:Renegade_Cullable()
    self.CullLink = nil
    self.NextCollected = nil
    self.CullBox = aABoxClass.New()
    self.CullBox:Init( Vector( 0, 0, 0 ), Vector( 1, 1, 1 ) )
end

function INSTANCE:_Renegade_Cullable()
	typecheck.NotImplementedError()
end

--- @return AABoxInstance
function INSTANCE:GetCullBox()
	return self.CullBox
end

--- @param box AABoxInstance
--- @param justLoaded boolean? [Default: `false`]
function INSTANCE:SetCullBox( box, justLoaded )
    if justLoaded == nil then justLoaded = false end

    self.CullBox = box

    -- "  
    -- [justLoaded] flag allows us to update the box without notifying the culling system.
    -- Use this when you've saved and loaded the linkage so you know you're in the right node
    -- of the culling system...  
    -- "  
    if not justLoaded then
        local sys = self:GetCullingSystem()
        if sys ~= nil then
            sys:UpdateCulling( self )
        end
    end
end

function INSTANCE:SetCullingSystem()
	typecheck.NotImplementedError()
end

--- @return CullSystemInstance?
function INSTANCE:GetCullingSystem()
    if self.CullLink then
        return self.CullLink:GetCullingSystem()
    end
end

function INSTANCE:SetCullLink()
	typecheck.NotImplementedError()
end

function INSTANCE:GetCullLink()
	typecheck.NotImplementedError()
end

function INSTANCE:SetNextCollected()
	typecheck.NotImplementedError()
end

function INSTANCE:GetNextCollected()
	typecheck.NotImplementedError()
end
