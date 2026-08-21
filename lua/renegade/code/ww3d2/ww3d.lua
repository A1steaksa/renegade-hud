-- Based on WW3D within Code/ww3d2/ww3d.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class WW3dClass
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "WW3DClass"

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	local enumBuilder = enumBuilderClass.New()

	--- @enum PrelitModeEnum
	STATIC.PRELIT_MODE_ENUM = {
		PRELIT_MODE_VERTEX                 = enumBuilder:Set( 0 ),
        PRELIT_MODE_LIGHTMAP_MULTI_PASS    = enumBuilder:Next(),
        PRELIT_MODE_LIGHTMAP_MULTI_TEXTURE = enumBuilder:Next(),
	}
	local prelitModeEnum = STATIC.PRELIT_MODE_ENUM

    --- @enum MeshDrawModeEnum
	STATIC.MESH_DRAW_MODE_ENUM = {
		MESH_DRAW_MODE_OLD        = enumBuilder:Set( 0 ),
		MESH_DRAW_MODE_NEW        = enumBuilder:Next(),
		MESH_DRAW_MODE_DEBUG_DRAW = enumBuilder:Next(),
		MESH_DRAW_MODE_DEBUG_CLIP = enumBuilder:Next(),
		MESH_DRAW_MODE_DEBUG_BOX  = enumBuilder:Next(),
		MESH_DRAW_MODE_NONE       = enumBuilder:Next(),
		MESH_DRAW_MODE_DX8_ONLY   = enumBuilder:Next(),
	}
	local meshDrawModeEnum = STATIC.MESH_DRAW_MODE_ENUM

    --- @enum NPatchesGapFillingModeEnum
	STATIC.N_PATCHES_GASP_FILLING_MODE_ENUM = {
		NPATCHES_GAP_FILLING_DISABLED = enumBuilder:Set( 0 ),
        NPATCHES_GAP_FILLING_ENABLED  = enumBuilder:Next(),
        NPATCHES_GAP_FILLING_FORCE    = enumBuilder:Next(),
	}
	local nPatchesGapFillingModeEnum = STATIC.N_PATCHES_GASP_FILLING_MODE_ENUM
--#endregion

--#region Imports

	--- @type FileFactoryClass
	local fileFactoryClass = CNC.Import( "code/wwlib/file-factory.lua" )

	--- @type IniClass
	local iniClass = CNC.Import( "code/wwlib/ini.lua" )

	--- @type WW3dErrorTypes
	local wW3dErrorTypes = CNC.Import( "code/ww3d2/w3d-errors.lua" )

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type ShaderClass
	local shaderClass = CNC.Import( "code/ww3d2/shader.lua" )

	--- @type WW3dClass
	local wW3dClass = CNC.Import( "code/ww3d2/ww3d.lua" )
--#endregion

--#region Imported Enums

	local wW3dErrorTypeEnum = wW3dErrorTypes.WW3D_ERROR_TYPE
	local shaderShiftConstantsEnum = shaderClass.SHADER_SHIFT_CONSTANTS
	local depthCompareEnum = shaderClass.DEPTH_COMPARE
	local depthMaskEnum = shaderClass.DEPTH_MASK
	local colorMaskEnum = shaderClass.COLOR_MASK
	local srcBlendFuncEnum = shaderClass.SRC_BLEND_FUNC
	local dstBlendFuncEnum = shaderClass.DST_BLEND_FUNC
	local fogFuncEnum = shaderClass.FOG_FUNC
	local primaryGradientEnum = shaderClass.PRIMARY_GRADIENT
	local secondaryGradientEnum = shaderClass.SECONDARY_GRADIENT
	local materialingEnum = shaderClass.MATERIALING
	local alphaTestEnum = shaderClass.ALPHA_TEST
	local cullModeEnum = shaderClass.CULL_MODE
	local detailColorFuncEnum = shaderClass.DETAIL_COLOR_FUNC
	local detailAlphaFuncEnum = shaderClass.DETAIL_ALPHA_FUNC
--#endregion

local DAZZLE_INI_FILENAME = "DAZZLE.INI"

--- "This is the collection of static functions and data which initialize and control the behavior of the WW3D library"  
--- @class WW3dClass
--- @field UserStat0 integer
--- @field UserStat1 integer
--- @field UserStat2 integer
--- @field SyncTime number
--- @field PreviousSyncTime number
--- @field PixelCenterX integer
--- @field PixelCenterY integer
--- @field _IsInitted boolean
--- @field IsRendering boolean
--- @field IsCapturing boolean
--- @field _IsSortingEnabled boolean
--- @field _IsScreenUvBiased boolean
--- @field IsBackfaceDebugEnabled boolean
--- @field _AreDecalsEnabled boolean
--- @field DecalRejectionDistance number
--- @field _AreStaticSortListsEnabled boolean
--- @field MungeSortOnLoad boolean
--- @field Movie FrameGrabInstance
--- @field PauseRecord boolean
--- @field RecordNextFrame boolean
--- @field FrameCount integer
--- @field DefaultDebugMaterial VertexMaterialInstance
--- @field BackfaceDebugMaterial VertexMaterialInstance
--- @field DefaultDebugShader ShaderInstance
--- @field LightmapDebugShader ShaderInstance
--- @field PrelitMode PrelitModeEnum
--- @field _ExposePrelit boolean
--- @field TextureFilter integer
--- @field SnapshotActivated boolean
--- @field ThumbnailEnabled boolean
--- @field MeshDrawMode MeshDrawModeEnum
--- @field NPatchesGapFillingMode NPatchesGapFillingModeEnum
--- @field NPatchesLevel integer
--- @field _IsTexturingEnabled boolean
--- @field Lite boolean
--- @field DefaultNativeScreenSize number
--- @field DefaultStaticSortLists RenderObjectInstance[][]
--- @field CurrentStaticSortLists RenderObjectInstance[][]
--- @field MinStaticSortLevel integer
--- @field MaxStaticSortLevel integer
--- @field LastFrameMemoryAllocations integer
--- @field LastFrameMemoryFrees integer
--- @field _TextureReduction integer

STATIC.DEFAULT_DEBUG_SHADER_BITS = shaderClass.SHADE_CNST(
	depthCompareEnum.PassLEqual,
	depthMaskEnum.Enable,
	colorMaskEnum.Enable,
	srcBlendFuncEnum.One,
	dstBlendFuncEnum.Zero,
	fogFuncEnum.Disable,
	primaryGradientEnum.Modulate,
	secondaryGradientEnum.Disable,
	materialingEnum.Disable,
	alphaTestEnum.Disable,
	cullModeEnum.Enable,
	detailColorFuncEnum.Disable,
	detailAlphaFuncEnum.Disable
)

STATIC.LIGHTMAP_DEBUG_SHADER_BITS = shaderClass.SHADE_CNST(
	depthCompareEnum.PassLEqual,
	depthMaskEnum.Enable,
	colorMaskEnum.Enable,
	srcBlendFuncEnum.One,
	dstBlendFuncEnum.Zero,
	fogFuncEnum.Disable,
	primaryGradientEnum.Disable,
	secondaryGradientEnum.Disable,
	materialingEnum.Enable,
	alphaTestEnum.Disable,
	cullModeEnum.Enable,
	detailColorFuncEnum.Disable,
	detailAlphaFuncEnum.Disable
)

STATIC.SyncTime = 0
STATIC.PreviousSyncTime = 0
STATIC._IsSortingEnabled = true

STATIC.PixelCenterX = 0
STATIC.PixelCenterY = 0

STATIC._IsInitted = false
STATIC.IsRendering = false
STATIC.IsCapturing = false
STATIC._IsScreenUvBiased = true

STATIC._AreDecalsEnabled = true
STATIC.DecalRejectionDistance = 1000000.0

STATIC._AreStaticSortListsEnabled = false
STATIC.MungeSortOnLoad = false

STATIC.Movie = nil
STATIC.PauseRecord = false
STATIC.RecordNextFrame = false

STATIC.FrameCount = 0
STATIC.UserStat0 = 0
STATIC.UserStat1 = 0
STATIC.UserStat2 = 0

STATIC.DefaultNativeScreenSize = 1.0

STATIC.DefaultStaticSortLists = {}
STATIC.CurrentStaticSortLists = {}
STATIC.MinStaticSortLevel = 2 -- "The 1 list is not used"
STATIC.MaxStaticSortLevel = w3dFileIds.MAX_SORT_LEVEL

STATIC.DefaultDebugMaterial = nil
STATIC.DefaultDebugShader = shaderClass.New( STATIC.DEFAULT_DEBUG_SHADER_BITS )
STATIC.DefaultLightmapShader = shaderClass.New( STATIC.LIGHTMAP_DEBUG_SHADER_BITS )

STATIC.PrelitMode = prelitModeEnum.PRELIT_MODE_LIGHTMAP_MULTI_PASS
STATIC._ExposePrelit = false

STATIC.SnapshotActivated = false
STATIC.ThumbnailEnabled = true

STATIC.MeshDrawMode = meshDrawModeEnum.MESH_DRAW_MODE_OLD
STATIC.NPatchesGapFillingMode = nPatchesGapFillingModeEnum.NPATCHES_GAP_FILLING_ENABLED
STATIC.NPatchesLevel = 1
STATIC._IsTexturingEnabled = true

STATIC._TextureReduction = 0
STATIC.Lite = false

--- @param lite boolean
--- @return WW3dErrorType
function STATIC.Init( lite )
	section.Start( "WW3D::Init" )
	-- Omitted Hwnd
	assert( STATIC._IsInitted == false )
	STATIC.Lite = lite

	-- "Initialize d3d, this also enumerates the available devices and resolutions."
	-- Omitted initializing D3D

	-- STATIC.AllocateDebugResources()
	-- Omitted allocating debug resources

	-- Omitted getting the time begin period

	-- "Initialize the dazzle system"
	if not lite then
		section.Start( "Init Dazzles" )
		local dazzleIniFile = fileFactoryClass.TheFileFactory:GetFile( DAZZLE_INI_FILENAME )
		if dazzleIniFile then
			local dazzleIni = iniClass.New( dazzleIniFile )
			-- Omitted initializing the dazzle system
			section.Warn( "Skipping dazzle system init" )
			-- dazzleRenderObjectClass.InitFromIni( dazzleIni )
			fileFactoryClass.TheFileFactory:ReturnFile( dazzleIniFile )
		end
		section.End()
	end

	-- "  
	-- Initialize the default static sort lists  
	-- Note that [DefaultStaticSortLists[1]] is unused.  
	-- "  
	STATIC.DefaultStaticSortLists = {}
	STATIC.ResetCurrentStaticSortListsToDefault()

	-- "Initialize the animation-triggered sound system"
	if not lite then
		-- Omitted initializing animated sound manager class
		section.Warn( "Skipping animated sound manager class init" )
		-- animatedSoundManagerClass.Initialize()
		STATIC._IsInitted = true
	end
	section.End( "WW3D Init Completed" )
	return wW3dErrorTypeEnum.WW3D_ERROR_OK
end

function STATIC.Shutdown()
	typecheck.NotImplementedError()
end

--- @return boolean
function STATIC.IsInitted()
	return STATIC._IsInitted
end

--- @return integer
function STATIC.GetRenderDeviceCount()
	-- Omitted original function
	return 1
end

--- @param deviceIndex integer
--- @return string
function STATIC.GetRenderDeviceName( deviceIndex )
	-- Omitted original function
	return "PrimaryDisplay"
end

--- @param device integer? [Default: -1]
--- @return RenderDeviceDescriptionInstance
function STATIC.GetRenderDeviceDescription( device )
	typecheck.NotImplementedError()
end

function STATIC.GetRenderDevice()
	typecheck.NotImplementedError()
end

function STATIC.SetRenderDevice()
	typecheck.NotImplementedError()
end

function STATIC.SetNextRenderDevice()
	typecheck.NotImplementedError()
end

function STATIC.SetAnyRenderDevice()
	typecheck.NotImplementedError()
end

function STATIC.GetPixelCenter()
	typecheck.NotImplementedError()
end

function STATIC.GetRenderTargetResolution()
	typecheck.NotImplementedError()
end

function STATIC.GetDeviceResolution()
	typecheck.NotImplementedError()
end

function STATIC.SetDeviceResolution()
	typecheck.NotImplementedError()
end

function STATIC.IsWindowed()
	typecheck.NotImplementedError()
end

function STATIC.ToggleWindowed()
	typecheck.NotImplementedError()
end

function STATIC.SetWindow()
	typecheck.NotImplementedError()
end

function STATIC.GetWindow()
	typecheck.NotImplementedError()
end

function STATIC.OnActivateApp()
	typecheck.NotImplementedError()
end

function STATIC.OnDeactivateApp()
	typecheck.NotImplementedError()
end

function STATIC.RegistrySaveRenderDevice()
	typecheck.NotImplementedError()
end

function STATIC.RegistryLoadRenderDevice()
	typecheck.NotImplementedError()
end

function STATIC.SetTextureFilter()
	typecheck.NotImplementedError()
end

function STATIC.GetTextureFilter()
	typecheck.NotImplementedError()
end

--[[ Rendering Functions ]] do
	--- "  
    --- Each frame should be bracketed by a Begin_Render and End_Render call.  Between these two calls you will
    --- normally render scenes.  The render function which accepts a single render object is implemented for
    --- special cases like generating a shadow texture for an object.  Basically this function will have the
    --- entire scene rendering overhead.  
    --- "  

	function STATIC.BeginRender()
		typecheck.NotImplementedError()
	end

	function STATIC.Render()
		typecheck.NotImplementedError()
	end

	function STATIC.Flush()
		typecheck.NotImplementedError()
	end

	function STATIC.EndRender()
		typecheck.NotImplementedError()
	end

	function STATIC.FlipToPrimary()
		typecheck.NotImplementedError()
	end
end


--[[ Timing ]] do
	-- "
	-- By calling the Sync function, the application can move the WW3D library time forward.
	-- This will control things like animated uv-offset mappers and render object animations.
	-- "

	function STATIC.Sync()
		typecheck.NotImplementedError()
	end

	--- @return number
	function STATIC.GetSyncTime()
		return STATIC.SyncTime
	end

	--- @return number
	function STATIC.GetFrameTime()
		return STATIC.SyncTime - STATIC.PreviousSyncTime
	end

	--- @return integer
	function STATIC.GetFrameCount()
		return STATIC.FrameCount
	end

	function STATIC.GetLastFramePolyCount()
		typecheck.NotImplementedError()
	end

	function STATIC.GetLastFrameVertexCount()
		typecheck.NotImplementedError()
	end
end

function STATIC.MakeScreenShot()
	typecheck.NotImplementedError()
end

function STATIC.StartMovieCapture()
	typecheck.NotImplementedError()
end

function STATIC.StopMovieCapture()
	typecheck.NotImplementedError()
end

function STATIC.ToggleMovieCapture()
	typecheck.NotImplementedError()
end

function STATIC.StartSingleFrameMovieCapture()
	typecheck.NotImplementedError()
end

function STATIC.CaptureNextMovieFrame()
	typecheck.NotImplementedError()
end

function STATIC.UpdateMovieCapture()
	typecheck.NotImplementedError()
end

function STATIC.GetMovieCaptureFrameRate()
	typecheck.NotImplementedError()
end

function STATIC.PauseMovie()
	typecheck.NotImplementedError()
end

function STATIC.IsMoviePaused()
	typecheck.NotImplementedError()
end

function STATIC.IsRecordingNextFrame()
	typecheck.NotImplementedError()
end

function STATIC.IsMovieReady()
	typecheck.NotImplementedError()
end

function STATIC.SetExtSwapInterval()
	typecheck.NotImplementedError()
end

function STATIC.GetExtSwapInterval()
	typecheck.NotImplementedError()
end


--[[ Texture Reduction ]] do
	-- "  
	-- All currently loaded textures can be de-resed on the fly
	-- by passing in a non-unit value to [SetTextureReduction].  
	-- Passing in 2 causes all textures to be half their normal 
	-- resolution.  Passing in 3 causes them to be cut in half
	-- twice, etc
	-- "  

	--- "Sets the (hacky) texture reduction factor"
	--- @param value integer
	function STATIC.SetTextureReduction( value )
		if STATIC._TextureReduction ~= value then
			STATIC._TextureReduction = value
			STATIC.InvalidateTextures()
		end
	end

	--- "Gets the (hacky) texture reduction factor"
	--- @return integer
	function STATIC.GetTextureReduction()
		return STATIC._TextureReduction
	end

	function STATIC.InvalidateMeshCache()
		typecheck.NotImplementedError()
	end

	function STATIC.InvalidateTextures()
		typecheck.NotImplementedError()
	end

	--- @param isEnabled boolean
	function STATIC.SetThumbnailEnabled( isEnabled )
		STATIC.ThumbnailEnabled = isEnabled
	end

	--- @return boolean
	function STATIC.GetThumbnailEnabled()
		return STATIC.ThumbnailEnabled
	end
end

--- @param onOff boolean
function STATIC.EnableSorting( onOff )
	STATIC._IsSortingEnabled = onOff
end

--- @return boolean
function STATIC.IsSortingEnabled()
	return STATIC._IsSortingEnabled

	-- "  
	-- Have to invalidate mesh rendering system because meshes are put
	-- into different fvfs depending on their sort state  
	-- "  
	-- Omitted invalidating the dx8 mesh renderer
end

--- @param onOff boolean
function STATIC.SetScreenUvBias( onOff )
	STATIC._IsScreenUvBiased = onOff
end

--- @return boolean
function STATIC.IsScreenUvBiased()
	return STATIC._IsScreenUvBiased
end

function STATIC.SetCollisionBoxDisplayMask()
	typecheck.NotImplementedError()
end

function STATIC.GetCollisionBoxDisplayMask()
	typecheck.NotImplementedError()
end

function STATIC.SetDefaultNativeScreenSize()
	typecheck.NotImplementedError()
end

--- @return number
function STATIC.GetDefaultNativeScreenSize()
	return STATIC.DefaultNativeScreenSize
end

function STATIC.NormalizeCoordinates()
	typecheck.NotImplementedError()
end

function STATIC.PeekDefaultDebugMaterial()
	typecheck.NotImplementedError()
end

function STATIC.PeekDefaultDebugShader()
	typecheck.NotImplementedError()
end

function STATIC.PeekBackfaceDebugShader()
	typecheck.NotImplementedError()
end

function STATIC.PeekLightmapDebugShader()
	typecheck.NotImplementedError()
end

function STATIC.SetPrelitMode()
	typecheck.NotImplementedError()
end

function STATIC.GetPrelitMode()
	typecheck.NotImplementedError()
end

function STATIC.SupportsPrelitMode()
	typecheck.NotImplementedError()
end

function STATIC.ExposePrelit()
	typecheck.NotImplementedError()
end

function STATIC.SetTextureBitdepth()
	typecheck.NotImplementedError()
end

function STATIC.GetTextureBitdepth()
	typecheck.NotImplementedError()
end

function STATIC.SetMeshDrawMode()
	typecheck.NotImplementedError()
end

function STATIC.GetMeshDrawMode()
	typecheck.NotImplementedError()
end

function STATIC.SetNPatchesGapFillingMode()
	typecheck.NotImplementedError()
end

function STATIC.GetNPatchesGapFillingMode()
	typecheck.NotImplementedError()
end

--- @param level integer
function STATIC.SetNPatchesLevel( level )
	typecheck.NotImplementedError()
end

--- @return integer
function STATIC.GetNPatchesLevel()
	return STATIC.NPatchesLevel
end

--- @param isEnabled boolean
function STATIC.EnableTexturing( isEnabled )
	if isEnabled == STATIC.IsTexturingEnabled then
		return
	end

	STATIC._IsTexturingEnabled = isEnabled
end

--- @return boolean
function STATIC.IsTexturingEnabled()
	return STATIC._IsTexturingEnabled
end

--- @return integer
function STATIC.GetLastFrameMemoryAllocationCount()
	return STATIC.LastFrameMemoryAllocations
end

--- @return integer
function STATIC.GetLastFrameMemoryFreeCount()
	return STATIC.LastFrameMemoryFrees
end

--[[ Decal Control ]] do
	-- "  
	-- These global settings can control whether decals are rendered at all and 
	-- at what distance to stop rendering/creating decals  
	-- "  

	--- @param onOff boolean
	function STATIC.EnableDecals( onOff )
		STATIC._AreDecalsEnabled = onOff
	end

	--- @return boolean
	function STATIC.AreDecalsEnabled()
		return STATIC._AreDecalsEnabled
	end

	--- @param distance number
	function STATIC.SetDecalRejectionDistance( distance )
		STATIC.DecalRejectionDistance = distance
	end

	--- @return number
	function STATIC.GetDecalRejectionDistance()
		return STATIC.DecalRejectionDistance
	end
end

--[[ Static Sort Lists ]] do
	-- "  
	-- The ability to temporarily set a different static sort list from the default one
	-- and a min/max sort list range is for specialized uses (such as [picture]-in-picture
	-- windows which need to sort at a certain sort level).  After this override is called,
	-- the default sort list must be restored.  
	-- "  

	--- @param onOff boolean
	function STATIC.EnableStaticSortLists( onOff )
		STATIC._AreStaticSortListsEnabled = onOff
	end

	--- @return boolean
	function STATIC.AreStaticSortListsEnabled()
		return STATIC._AreStaticSortListsEnabled
	end

	--- @param onOff boolean
	function STATIC.EnableMungeSortOnLoad( onOff )
		STATIC.MungeSortOnLoad = onOff
	end

	--- @return boolean
	function STATIC.IsMungeSortOnLoadEnabled()
		return STATIC.MungeSortOnLoad
	end

	--- @param renderObject RenderObjectInstance
	--- @param sortLevel integer
	function STATIC.AddToStaticSortList( renderObject, sortLevel )
		if sortLevel < 1 or sortLevel > w3dFileIds.MAX_SORT_LEVEL then
			assert( false )
			return
		end

		local sortList = STATIC.CurrentStaticSortLists[sortLevel]
		sortList[#sortList + 1] = renderObject
	end

	--- @param renderInfo RenderInfoInstance
	function STATIC.RenderAndClearStaticSortLists( renderInfo )
		typecheck.NotImplementedError()
	end

	function STATIC.OverrideCurrentStaticSortLists( sortList, minSort, maxSort )
		typecheck.NotImplementedError()
	end

	function STATIC.ResetCurrentStaticSortListsToDefault()
		STATIC.CurrentStaticSortLists = STATIC.DefaultStaticSortLists
		STATIC.MinStaticSortLevel = 2 -- "The [1] list is not used"
		STATIC.MaxStaticSortLevel = w3dFileIds.MAX_SORT_LEVEL
	end
end

--- @return boolean
function STATIC.IsSnapshotActivated()
	return STATIC.SnapshotActivated
end

--- @param onOff boolean
function STATIC.ActivateSnapshot( onOff )
	STATIC.SnapshotActivated = onOff
end

function STATIC.ReadGerdRenderDeviceDescription()
	typecheck.NotImplementedError()
end

function STATIC.UpdatePixelCenter()
	typecheck.NotImplementedError()
end

function STATIC.AllocateDebugResources()
	-- empty in the original code
end

function STATIC.ReleaseDebugResources()
	typecheck.NotImplementedError()
end
