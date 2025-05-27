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

        return arg.IsShader
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

    function INSTANCE:Apply()
        typecheck.NotImplementedError( CLASS, "Apply" )
    end

    function INSTANCE:Reset()
        self.ShaderBits = 0

        self:SetDepthCompare( PASS_LEQUAL )
        self:SetDepthMask( DEPTH_WRITE_ENABLE )
        self:SetColorMask( COLOR_WRITE_ENABLE )
        self:SetDstBlendFunc( DSTBLEND_ZERO )
        self:SetFogFunc( FOG_DISABLE )
        self:SetPrimaryGradient( GRADIENT_MODULATE )
        self:SetSecondaryGradient( SECONDARY_GRADIENT_DISABLE )
        self:SetSrcBlendFunc( SRCBLEND_ONE )
        self:SetTexturing( TEXTURING_DISABLE )
        self:SetAlphaTest( ALPHATEST_DISABLE )
        self:SetCullMode( CULL_MODE_ENABLE )
        self:SetPostDetailColorFunc( DETAILCOLOR_DISABLE )
        self:SetPostDetailAlphaFunc( DETAILALPHA_DISABLE )
        self:SetNPatchEnable( NPATCH_DISABLE )
    end

    --- @param flag integer
    function INSTANCE:SetDepthMask( flag )
        self.DepthMask = flag
    end

    --- @param flag integer
    function INSTANCE:SetColorMask( flag )
        self.ColorMask = flag
    end

    --- @param flag integer
    function INSTANCE:SetDepthCompare( flag )
        self.DepthCompare = flag
    end

    --- @param flag integer
    function INSTANCE:SetDstBlendFunc( flag )
        self.DstBlendFunc = flag
    end

    --- @param flag integer
    function INSTANCE:SetSrcBlendFunc( flag )
        self.SrcBlendFunc = flag
    end

    --- @param flag integer
    function INSTANCE:SetFogFunc( flag )
        self.FogFunc = flag
    end

    --- @param flag integer
    function INSTANCE:SetPrimaryGradient( flag )
        self.PrimaryGradient = flag
    end

    --- @param flag integer
    function INSTANCE:SetSecondaryGradient( flag )
        self.SecondaryGradient = flag
    end

    --- @param flag integer
    function INSTANCE:SetTexturing( flag )
        self.Texturing = flag
    end

    --- @param flag integer
    function INSTANCE:SetAlphaTest( flag )
        self.AlphaTest = flag
    end

    --- @param flag integer
    function INSTANCE:SetCullMode( flag )
        self.CullMode = flag
    end

    --- @param flag integer
    function INSTANCE:SetPostDetailColorFunc( flag )
        self.PostDetailColorFunc = flag
    end

    --- @param flag integer
    function INSTANCE:SetPostDetailAlphaFunc( flag )
        self.PostDetailAlphaFunc = flag
    end

    --- @param flag integer
    function INSTANCE:SetNPatchEnable( flag )
        self.NPatchEnable = flag
    end

    --- [[ Protected ]]

    --- @class ShaderInstance

end