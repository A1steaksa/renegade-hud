-- Based on SceneClass within Code/ww3d2/scene.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class SceneClass
--- @field Instance SceneInstance The metatable used by SceneInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "SceneClass"

--- @class SceneInstance
--- @field Static SceneClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_Scene" )
INSTANCE.Class = "SceneInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsScene = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class SceneClass

    --- Creates a new SceneInstance
    --- @return SceneInstance
    function STATIC.New()
        return robustclass.New( "Renegade_Scene" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) SceneInstance, `false` otherwise
    function STATIC.IsScene( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsScene and true or false
    end

    typecheck.RegisterType( "SceneInstance", STATIC.IsScene )
end


--- @class SceneInstance
--- @field AmbientLight Vector
--- @field PolyRenderMode PolyRenderTypeInstance
--- @field ExtraPassPolyRenderMode ExtraPassPolyRenderTypeInstance
--- @field FogEnabled boolean
--- @field FogColor Vector
--- @field FogStart number
--- @field FogEnd number

function INSTANCE:Renegade_Scene()
	typecheck.NotImplementedError()
end

function INSTANCE:_Renegade_Scene()
	typecheck.NotImplementedError()
end

function INSTANCE:AddRenderObject()
	typecheck.NotImplementedError()
end

function INSTANCE:RemoveRenderObject()
	typecheck.NotImplementedError()
end

function INSTANCE:CreateIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:DestroyIterator()
	typecheck.NotImplementedError()
end

function INSTANCE:SetAmbientLight()
	typecheck.NotImplementedError()
end

function INSTANCE:GetAmbientLight()
	typecheck.NotImplementedError()
end

function INSTANCE:SetFogEnable()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFogEnable()
	typecheck.NotImplementedError()
end

function INSTANCE:SetFogColor()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFogColor()
	typecheck.NotImplementedError()
end

function INSTANCE:SetFogRange()
	typecheck.NotImplementedError()
end

function INSTANCE:GetFogRange()
	typecheck.NotImplementedError()
end

function INSTANCE:SetPolygonMode()
	typecheck.NotImplementedError()
end

function INSTANCE:GetPolygonMode()
	typecheck.NotImplementedError()
end

function INSTANCE:SetExtraPassPolygonMode()
	typecheck.NotImplementedError()
end

function INSTANCE:GetExtraPassPolygonMode()
	typecheck.NotImplementedError()
end

function INSTANCE:Register()
	typecheck.NotImplementedError()
end

function INSTANCE:Unregister()
	typecheck.NotImplementedError()
end

function INSTANCE:ComputePointVisibility()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:Render()
	typecheck.NotImplementedError()
end

function INSTANCE:CustomizedRender()
	typecheck.NotImplementedError()
end

function INSTANCE:PreRenderProcessing()
	typecheck.NotImplementedError()
end

function INSTANCE:PostRenderProcessing()
	typecheck.NotImplementedError()
end
