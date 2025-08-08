-- Based on ShaderClass within Code/ww3d2/shader.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Shader
    --- @class ShaderInstance
    --- @field Static Shader The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Shader" )

    --- The static components of Shader
    --- @class Shader
    --- @field Instance ShaderInstance The Metatable used by ShaderInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsShader = true
end


--#region Enums

    --- @enum ShaderShiftConstants
    STATIC.SHADER_SHIFT_CONSTANTS = {
        DEPTHCOMPARE        = 0,  -- Bit shift for depth comparison setting
        DEPTHMASK           = 3,  -- Bit shift for depth mask setting
        COLORMASK           = 4,  -- Bit shift for color mask setting
        DSTBLEND            = 5,  -- Bit shift for destination blend setting
        FOG                 = 8,  -- Bit shift for fog setting
        PRIMARYGRADIENT     = 10, -- Bit shift for primary gradient setting
        SECONDARYGRADIENT   = 13, -- Bit shift for secondary gradient setting
        SRCBLEND            = 14, -- Bit shift for source blend setting
        MATERIALING         = 16, -- Bit shift for materialing setting (1 bit)
        NPATCHENABLE        = 17, -- Bit shift for npatch enabling
        ALPHATEST           = 18, -- Bit shift for alpha test setting
        CULLMODE            = 19, -- Bit shift for cullmode setting
        POSTDETAILCOLORFUNC = 20, -- Bit shift for post-detail color function setting
        POSTDETAILALPHAFUNC = 24, -- Bit shift for post-detail alpha function setting
    }
    local SHADER_SHIFT_CONSTANTS = STATIC.SHADER_SHIFT_CONSTANTS

    --- @enum AlphaTest
    STATIC.ALPHA_TEST = {
        DISABLE = 0, -- Disable alpha testing (default)
        ENABLE  = 1, -- Enable alpha testing
    }
    local ALPHA_TEST = STATIC.ALPHA_TEST

    --- @enum DepthCompare
    STATIC.DEPTH_COMPARE = {
        PASS_NEVER    = 0, -- Pass never
        PASS_LESS     = 1, -- Pass if incoming less than stored
        PASS_EQUAL    = 2, -- Pass if incoming equal to stored
        PASS_LEQUAL   = 3, -- Pass if incoming less than or equal to stored (default)
        PASS_GREATER  = 4, -- Pass if incoming greater than stored
        PASS_NOTEQUAL = 5, -- Pass if incoming not equal to stored
        PASS_GEQUAL   = 6, -- Pass if incoming greater than or equal to stored
        PASS_ALWAYS   = 7, -- Pass always
    }
    local DEPTH_COMPARE = STATIC.DEPTH_COMPARE

    --- @enum DepthWrite
    STATIC.DEPTH_WRITE = {
        DISABLE = 0, -- Disable depth buffer writes
        ENABLE  = 1, -- Enable depth buffer writes (default)
    }
    local DEPTH_WRITE = STATIC.DEPTH_WRITE

    --- @enum ColorWrite
    STATIC.COLOR_WRITE = {
        DISABLE = 0, -- Disable color buffer writes
        ENABLE  = 1, -- Enable color buffer writes (default)
    }
    local COLOR_WRITE = STATIC.COLOR_WRITE

    --- @enum DetailAlphaFunc
    STATIC.DETAIL_ALPHA_FUNC = {
        DISABLE  = 0, -- Local (default)
        DETAIL   = 1, -- Other
        SCALE    = 2, -- Local * other
        INVSCALE = 3, -- ~(~local * ~other) = local + (1-local)*other
    }
    local DETAIL_ALPHA_FUNC = STATIC.DETAIL_ALPHA_FUNC

    --- @enum DetailColorFunc
    STATIC.DETAIL_COLOR_FUNC = {
        DISABLE     = 0, -- 0000 local (default)
        DETAIL      = 1, -- 0001 other
        SCALE       = 2, -- 0010 local * other
        INVSCALE    = 3, -- 0011 ~(~local * ~other) = local + (1-local)*other
        ADD         = 4, -- 0100 local + other
        SUB         = 5, -- 0101 local - other
        SUBR        = 6, -- 0110 other - local
        BLEND       = 7, -- 0111 (localAlpha)*local + (~localAlpha)*other
        DETAILBLEND = 8, -- 1000 (otherAlpha)*local + (~otherAlpha)*other
    }
    local DETAIL_COLOR_FUNC = STATIC.DETAIL_COLOR_FUNC

    --- @enum CullMode
    STATIC.CULL_MODE = {
        DISABLE = 0,
        ENABLE  = 1,
    }
    local CULL_MODE = STATIC.CULL_MODE

    --- @enum NPatch
    STATIC.N_PATCH = {
        DISABLE  = 0,
        ENABLE   = 1,
    }
    local N_PATCH = STATIC.N_PATCH

    --- @enum DstBlendFunc
    STATIC.DST_BLEND_FUNC = {
        ZERO                = 0, -- Destination pixel doesn't affect blending (default)
        ONE                 = 1, -- Destination pixel added unmodified
        SRC_COLOR           = 2, -- Destination pixel multiplied by fragment RGB components
        ONE_MINUS_SRC_COLOR = 3, -- Destination pixel multiplied by one minus (i.e. inverse) fragment RGB components
        SRC_ALPHA           = 4, -- Destination pixel multiplied by fragment alpha component
        ONE_MINUS_SRC_ALPHA = 5, -- Destination pixel multiplied by fragment inverse alpha
    }
    local DST_BLEND_FUNC = STATIC.DST_BLEND_FUNC

    --- @enum FogFunc
    STATIC.FOG_FUNC = {
        DISABLE        = 0, -- Don't perform fogging (default)
        ENABLE         = 1, -- Apply fog, f*fogColor + (1-f)*fragment
        SCALE_FRAGMENT = 2, -- Fog scalar value multiplies fragment, (1-f)*fragment
        WHITE          = 3, -- Fog scalar value replaces fragment, f*fogColor
    }
    local FOG_FUNC = STATIC.FOG_FUNC

    --- @enum PrimaryGradient
    STATIC.PRIMARY_GRADIENT = {
        DISABLE             = 0, -- 000 disable primary gradient (same as OpenGL 'decal' texture blend)
        MODULATE            = 1, -- 001 modulate fragment ARGB by gradient ARGB (default)
        ADD                 = 2, -- 010 add gradient RGB to fragment RGB, copy gradient A to fragment A
        BUMPENVMAP          = 3, -- 011
        BUMPENVMAPLUMINANCE = 4, -- 100
        DOTPRODUCT3         = 5, -- 101
    }
    local PRIMARY_GRADIENT = STATIC.PRIMARY_GRADIENT

    --- @enum SecondaryGradient
    STATIC.SECONDARY_GRADIENT = {
        DISABLE = 0, -- Don't draw secondary gradient (default)
        ENABLE  = 1, -- Add secondary gradient RGB to fragment RGB
    }
    local SECONDARY_GRADIENT = STATIC.SECONDARY_GRADIENT

    --- @enum SrcBlendFunc
    STATIC.SRC_BLEND_FUNC = {
        ZERO                = 0, -- Fragment not added to color buffer
        ONE                 = 1, -- Fragment added unmodified to color buffer (default)
        SRC_ALPHA           = 2, -- Fragment RGB components multiplied by fragment A
        ONE_MINUS_SRC_ALPHA = 3, -- Fragment RGB components multiplied by fragment inverse (one minus) A
    }
    local SRC_BLEND_FUNC = STATIC.SRC_BLEND_FUNC

    --- @enum Materialing
    STATIC.MATERIALING = {
        DISABLE = 0, -- No materialing (treat fragment initial color as 1,1,1,1)
        ENABLE  = 1, -- Enable materialing
    }
    local MATERIALING = STATIC.MATERIALING

    --- @enum StaticSortCategory
    STATIC.STATIC_SORT_CATEGORY = {
        OPAQUE     = 0,
        ALPHA_TEST = 1,
        ADDITIVE   = 2,
        OTHER      = 3,
    }
    local STATIC_SORT_CATEGORY = STATIC.STATIC_SORT_CATEGORY

    --- @enum Mask
    STATIC.MASK = {
        DEPTHCOMPARE        = bit.lshift( 7,  0  ),  -- Mask for depth comparison setting
        DEPTHMASK           = bit.lshift( 1,  3  ),  -- Mask for depth mask setting
        COLORMASK           = bit.lshift( 1,  4  ),  -- Mask for color mask setting
        DSTBLEND            = bit.lshift( 7,  5  ),  -- Mask for destination blend setting
        FOG                 = bit.lshift( 3,  8  ),  -- Mask for fog setting
        PRIMARYGRADIENT     = bit.lshift( 7,  10 ),  -- Mask for primary gradient setting
        SECONDARYGRADIENT   = bit.lshift( 1,  13 ),  -- Mask for secondary gradient setting
        SRCBLEND            = bit.lshift( 3,  14 ),  -- Mask for source blend setting
        MATERIALING         = bit.lshift( 1,  16 ),  -- Mask for materialing setting
        NPATCHENABLE        = bit.lshift( 1,  17 ),  -- Mask for npatch enable
        ALPHATEST           = bit.lshift( 1,  18 ),  -- Mask for alpha test enable
        CULLMODE            = bit.lshift( 1,  19 ),  -- Mask for cullmode setting
        POSTDETAILCOLORFUNC = bit.lshift( 15, 20 ),  -- Mask for post detail color function setting
        POSTDETAILALPHAFUNC = bit.lshift( 7,  24 ),  -- Mask for post detail alpha function setting
    }
    local mask = STATIC.MASK
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "Shader"

    --- [[ Public ]]

    --- Creates a new ShaderInstance
    --- @vararg any
    --- @return ShaderInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Shader", ... )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) ShaderInstance, `false` otherwise
    function STATIC.IsShader( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsShader and true or false
    end

    typecheck.RegisterType( "ShaderInstance", STATIC.IsShader )
end


--[[ Instanced Functions and Variables ]] do

    local CLASS = "ShaderInstance"

    --- [[ Public ]]

    --- @class ShaderInstance
    --- @field ShaderBits integer
    --- @field DepthCompare DepthCompare
    --- @field DepthMask DepthWrite
    --- @field ColorMask ColorWrite
    --- @field DstBlendFunc DstBlendFunc
    --- @field FogFunc FogFunc
    --- @field PrimaryGradient PrimaryGradient
    --- @field SecondaryGradient SecondaryGradient
    --- @field SrcBlendFunc SrcBlendFunc
    --- @field Materialing Materialing
    --- @field AlphaTest AlphaTest
    --- @field CullMode CullMode
    --- @field PostDetailColorFunc DetailAlphaFunc
    --- @field PostDetailAlphaFunc DetailColorFunc
    --- @field NPatchEnable NPatch

    --- Constructs a new ShaderInstance
    --- @vararg any
    function INSTANCE:Renegade_Shader( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        if argCount == 0 then
            self:Reset()
            return
        end

        typecheck.NotImplementedError( CLASS )
    end

    local dstBlendFuncConverter = {
        [DST_BLEND_FUNC.ZERO               ] = BLEND_ZERO,
        [DST_BLEND_FUNC.ONE                ] = BLEND_ONE,
        [DST_BLEND_FUNC.SRC_ALPHA          ] = BLEND_SRC_ALPHA,
        [DST_BLEND_FUNC.SRC_COLOR          ] = BLEND_SRC_COLOR,
        [DST_BLEND_FUNC.ONE_MINUS_SRC_ALPHA] = BLEND_ONE_MINUS_SRC_ALPHA,
        [DST_BLEND_FUNC.ONE_MINUS_SRC_COLOR] = BLEND_ONE_MINUS_SRC_COLOR,
    }

    local srcBlendFuncConverter = {
        [SRC_BLEND_FUNC.ZERO               ] = BLEND_ZERO,
        [SRC_BLEND_FUNC.ONE                ] = BLEND_ONE,
        [SRC_BLEND_FUNC.SRC_ALPHA          ] = BLEND_SRC_ALPHA,
        [SRC_BLEND_FUNC.ONE_MINUS_SRC_ALPHA] = BLEND_ONE_MINUS_SRC_ALPHA,
    }

    function INSTANCE:Enable()
        local dstBlendFunc = dstBlendFuncConverter[ self.DstBlendFunc ]
        local srcBlendFunc = srcBlendFuncConverter[ self.SrcBlendFunc ]

        render.OverrideBlend( true, srcBlendFunc, dstBlendFunc, BLENDFUNC_ADD )
    end

    function INSTANCE:Disable()
        render.OverrideBlend( false )
    end

    function INSTANCE:Apply()
        typecheck.NotImplementedError( CLASS, "Apply" )
    end

    function INSTANCE:Reset()
        self.ShaderBits = 0

        self:SetDepthCompare( DEPTH_COMPARE.PASS_LEQUAL )
        self:SetDepthMask( DEPTH_WRITE.ENABLE )
        self:SetColorMask( COLOR_WRITE.ENABLE )
        self:SetDstBlendFunc( DST_BLEND_FUNC.ZERO )
        self:SetFogFunc( FOG_FUNC.DISABLE )
        self:SetPrimaryGradient( PRIMARY_GRADIENT.MODULATE )
        self:SetSecondaryGradient( SECONDARY_GRADIENT.DISABLE )
        self:SetSrcBlendFunc( SRC_BLEND_FUNC.ONE )
        self:SetMaterialing( MATERIALING.DISABLE )
        self:SetAlphaTest( ALPHA_TEST.DISABLE )
        self:SetCullMode( CULL_MODE.ENABLE )
        self:SetPostDetailColorFunc( DETAIL_COLOR_FUNC.DISABLE )
        self:SetPostDetailAlphaFunc( DETAIL_ALPHA_FUNC.DISABLE )
        self:SetNPatchEnable( N_PATCH.DISABLE )
    end

    --- @param flag DepthWrite
    function INSTANCE:SetDepthMask( flag )
        self.DepthMask = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.DEPTHMASK )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.DEPTHMASK )
        )
    end

    --- @param flag ColorWrite
    function INSTANCE:SetColorMask( flag )
        self.ColorMask = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.COLORMASK )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.COLORMASK )
        )
    end

    --- @param flag DepthCompare
    function INSTANCE:SetDepthCompare( flag )
        self.DepthCompare = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.DEPTHCOMPARE )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.DEPTHCOMPARE )
        )
    end

    --- @param flag DstBlendFunc
    function INSTANCE:SetDstBlendFunc( flag )
        self.DstBlendFunc = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.DSTBLEND )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.DSTBLEND )
        )
    end

    --- @param flag SrcBlendFunc
    function INSTANCE:SetSrcBlendFunc( flag )
        self.SrcBlendFunc = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.SRCBLEND )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.SRCBLEND )
        )
    end

    --- @param flag FogFunc
    function INSTANCE:SetFogFunc( flag )
        self.FogFunc = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.FOG )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.FOG )
        )
    end

    --- @param flag PrimaryGradient
    function INSTANCE:SetPrimaryGradient( flag )
        self.PrimaryGradient = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.PRIMARYGRADIENT )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.PRIMARYGRADIENT )
        )
    end

    --- @param flag SecondaryGradient
    function INSTANCE:SetSecondaryGradient( flag )
        self.SecondaryGradient = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.SECONDARYGRADIENT )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.SECONDARYGRADIENT )
        )
    end

    --- @param flag Materialing
    function INSTANCE:SetMaterialing( flag )
        self.Materialing = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.MATERIALING )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.MATERIALING )
        )
    end

    --- @param flag AlphaTest
    function INSTANCE:SetAlphaTest( flag )
        self.AlphaTest = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.ALPHATEST )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.ALPHATEST )
        )
    end

    --- @param flag CullMode
    function INSTANCE:SetCullMode( flag )
        self.CullMode = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.CULLMODE )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.CULLMODE )
        )
    end

    --- @param flag DetailColorFunc
    function INSTANCE:SetPostDetailColorFunc( flag )
        self.PostDetailColorFunc = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.POSTDETAILCOLORFUNC )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.POSTDETAILCOLORFUNC )
        )
    end

    --- @param flag DetailAlphaFunc
    function INSTANCE:SetPostDetailAlphaFunc( flag )
        self.PostDetailAlphaFunc = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.POSTDETAILALPHAFUNC )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.POSTDETAILALPHAFUNC )
        )
    end

    --- @param flag NPatch
    function INSTANCE:SetNPatchEnable( flag )
        self.NPatchEnable = flag

        self.ShaderBits = bit.band( self.ShaderBits,
            bit.bnot( mask.DEPTHCOMPARE )
        )
        self.ShaderBits = bit.bor( self.ShaderBits,
            bit.lshift( flag, SHADER_SHIFT_CONSTANTS.DEPTHCOMPARE )
        )
    end

    --- [[ Protected ]]

    --- @class ShaderInstance
end