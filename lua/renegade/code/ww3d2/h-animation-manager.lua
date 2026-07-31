-- Based on HAnimManagerClass within Code/ww3d2/hanimmgr.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class HAnimationManagerClass
--- @field Instance HAnimationManagerInstance The metatable used by HAnimationManagerInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HAnimationManagerClass"

--- @class HAnimationManagerInstance
--- @field Static HAnimationManagerClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HAnimationManager" )
INSTANCE.Class = "HAnimationManagerInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHAnimationManager = true

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass.New()

    --- @enum HRawAnimationLoadResult
    STATIC.H_RAW_ANIMATION_LOAD_RESULT = {
        OK		   = enumBuilder:Set( 0 ),
        LOAD_ERROR = enumBuilder:Next(),
    }
    local hRawAnimationLoadResult = STATIC.H_RAW_ANIMATION_LOAD_RESULT
--#endregion

--#region Imports

	--- @type W3dFileIds
	local w3dFileIds = CNC.Import( "code/ww3d2/w3d-file.lua" )

	--- @type HRawAnimationClass
	local hRawAnimationClass = CNC.Import( "code/ww3d2/h-raw-animation.lua" )

	--- @type HAnimationManagerClass
	local hAnimationManagerClass = CNC.Import( "code/ww3d2/h-animation-manager.lua" )

	--- @type HCompressedAnimationClass
	local hCompressedAnimationClass = CNC.Import( "code/ww3d2/h-compressed-animation.lua" )
--#endregion

--#region Imported Enums

	local w3dChunkTypeEnum = w3dFileIds.W3D_CHUNK_TYPE
	local hRawAnimationLoadResultEnum = hAnimationManagerClass.H_RAW_ANIMATION_LOAD_RESULT
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HAnimationManagerClass

    --- Creates a new HAnimationManagerInstance
    --- @return HAnimationManagerInstance
    function STATIC.New()
        return robustclass.New( "Renegade_HAnimationManager" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HAnimationManagerInstance, `false` otherwise
    function STATIC.IsHAnimationManager( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end
        return arg.IsHAnimationManager and true or false
    end

    typecheck.RegisterType( "HAnimationManagerInstance", STATIC.IsHAnimationManager )
end


--- @class HAnimationManagerInstance
--- @field AnimationPointerTable table<string, HAnimationInstance|boolean>

function INSTANCE:Renegade_HAnimationManager()
    -- "Create the hash tables"
    self.AnimationPointerTable = {}
end

function INSTANCE:_Renegade_HAnimationManager()
    self:FreeAllAnims()
    self:ResetMissing() -- "Jani: Deleting missing animations as well"

    self.AnimationPointerTable = nil
end

--- "Loads a set of motion data from a file"
--- @param cload ChunkLoadInstance
--- @return integer
function INSTANCE:LoadAnimation( cload )
    local id = cload:CurChunkId()

    if id == w3dChunkTypeEnum.W3D_CHUNK_ANIMATION then
        return self:LoadRawAnimation( cload )

    elseif id == w3dChunkTypeEnum.W3D_CHUNK_COMPRESSED_ANIMATION then
        return self:LoadCompressedAnimation( cload )

    elseif id == w3dChunkTypeEnum.W3D_CHUNK_MORPH_ANIMATION then
        return self:LoadMorphAnimation()
    end

    return 0
end

--- "Returns a pointer to the specified animation data"
--- @param name string
--- @return HAnimationInstance?
function INSTANCE:GetAnimation( name )
	return self:PeekAnimation( name )
end

--- "Returns a pointer to the specified animation data"
--- @param name string
--- @return HAnimationInstance?
function INSTANCE:PeekAnimation( name )
    local animation = self.AnimationPointerTable[name]
    if animation then
        return animation --[[@as HAnimationInstance]]
    end
    return nil
end

--- "Adds an externally created animation to the manager"
--- @param newAnimation HAnimationInstance
--- @return boolean
function INSTANCE:AddAnimation( newAnimation )
    assert( newAnimation ~= nil )

    -- "Increment the refcount on the new animation and add it to our table."
    self.AnimationPointerTable[newAnimation:GetName()] = newAnimation

    -- "Check to see if this animation has any embedded sounds that may need to play while its animating."
    -- local hasSoundTrigger = animatedSoundManagerClass.DoesAnimationHaveEmbeddedSounds( newAnimation )
    -- newAnimation:SetHasEmbeddedSounds( hasSoundTrigger )
    -- Omitted setting up animation-embedded sound effects
    section.Warn( "Skipping setting up embedded animation sounds" )

    return true
end

--- "De-allocate all currently loaded animations"
function INSTANCE:FreeAllAnims()
    for name, value in pairs( self.AnimationPointerTable ) do
        if value ~= false then
            self.AnimationPointerTable[name] = nil
        end
    end
end

--- "  
--- The idea here, allow the system to register which anims are determined to be missing
--- so that if they are asked for again, we can quickly return NULL, without searching the
--- disk again.
--- "  
--- @param name string
function INSTANCE:RegisterMissing( name )
    section.Warn( INSTANCE.Class, " - RegisterMissing - Animation missing: '", name, "'" )
    self.AnimationPointerTable[name] = false
end

--- @param name string
function INSTANCE:IsMissing( name )
    return self.AnimationPointerTable[name] == false
end

function INSTANCE:ResetMissing()
    for name, value in pairs( self.AnimationPointerTable ) do
        if value == false then
            self.AnimationPointerTable[name] = nil
        end
    end
end

--- @param cload ChunkLoadInstance
--- @return integer
function INSTANCE:LoadCompressedAnimation( cload )
	local newAnimation = hCompressedAnimationClass.New()
    if newAnimation == nil then
        return 1
    end

    if newAnimation:LoadW3d( cload ) ~= hCompressedAnimationClass.OK then
        -- "Load failed"
        return 1
    elseif INSTANCE.PeekAnimation( self, newAnimation:GetName() ) ~= nil then
        -- "Duplicate exists!"
        return 1
    else
        INSTANCE.AddAnimation( self, newAnimation )
    end

    return 0
end

--- "Load a raw anim"
--- @param cload ChunkLoadInstance
--- @return integer
function INSTANCE:LoadRawAnimation( cload )
    local newAnimation = hRawAnimationClass.New()

    if newAnimation == nil then
        return 1
    end

    if newAnimation:LoadW3d( cload ) ~= hRawAnimationLoadResultEnum.OK then
        -- "Load failed!"
        return 1
    elseif self:PeekAnimation( newAnimation:GetName() ) ~= nil then
        -- "Duplicate exists"
        return 1
    else
        self:AddAnimation( newAnimation )
    end

    return 0
end

function INSTANCE:LoadMorphAnimation()
	typecheck.NotImplementedError()
end
