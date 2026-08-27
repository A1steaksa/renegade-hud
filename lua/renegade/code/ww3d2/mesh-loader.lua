-- Based on MeshLoaderClass within Code/ww3d2/proto.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type PrototypeLoaderClass
local prototypeLoaderClass = CNC.Import( "code/ww3d2/prototype-loader.lua" )

--- @class MeshLoaderClass : PrototypeLoaderClass
--- @field Instance MeshLoaderInstance The metatable used by MeshLoaderInstance
local STATIC = CNC.CreateExport( prototypeLoaderClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "MeshLoaderClass"

--- @class MeshLoaderInstance : PrototypeLoaderInstance
--- @field Static MeshLoaderClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_MeshLoader : Renegade_PrototypeLoader" )
INSTANCE.Class = "MeshLoaderInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMeshLoader = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type MeshClass
	local meshClass = CNC.Import( "code/ww3d2/mesh.lua" )

	--- @type WW3dErrorTypes
	local wW3dErrorTypes = CNC.Import( "code/ww3d2/w3d-errors.lua" )

	--- @type PrimitivePrototypeClass
	local primitivePrototypeClass = CNC.Import( "code/ww3d2/primitive-prototype.lua" )
--#endregion

--#region Imported Enums

	local wW3dErrorTypeEnum = wW3dErrorTypes.WW3D_ERROR_TYPE
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class MeshLoaderClass

    --- Creates a new MeshLoaderInstance
    --- @return MeshLoaderInstance
    function STATIC.New()
        return robustclass.New( "Renegade_MeshLoader" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) MeshLoaderInstance, `false` otherwise
    function STATIC.IsMeshLoader( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMeshLoader and true or false
    end

    typecheck.RegisterType( "MeshLoaderInstance", STATIC.IsMeshLoader )
end

--- "Default Prototype Loaders for Meshes and HModels"
--- @class MeshLoaderInstance

function INSTANCE:Renegade_MeshLoader()
    prototypeLoaderClass.Instance.Renegade_PrototypeLoader( self )
end

--- @return integer
function INSTANCE:ChunkType()
	return w3dFileIds.W3D_CHUNK_TYPE.W3D_CHUNK_MESH
end

--- "Reads in a mesh and creates a prototype for it"
--- @param cload ChunkLoadInstance
--- @return PrototypeInstance?
function INSTANCE:LoadW3d( cload )
	local mesh = meshClass.New()

    if mesh == nil then
        return nil
    end

    if mesh:LoadW3d( cload ) ~= wW3dErrorTypeEnum.WW3D_ERROR_OK then
        return
    else
        -- "Create the prototype and add it to the lists"
        return primitivePrototypeClass.New( mesh )
    end
end
