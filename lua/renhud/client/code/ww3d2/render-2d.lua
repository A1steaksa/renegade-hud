-- Based on Render2DClass within Code/ww3d2/render2d.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Render2d
    --- @class Render2dInstance
    INSTANCE = robustclass.Register( "Renegade_Render2d" )

    --- A 2D renderer that constructs an internal IMesh
    --- @class Render2d
    --- @field Instance Render2dInstance The Metatable used by Render2dInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsRender2d = true
end


--#region Imports

    --- @type Rect
    local rect = CNC.Import( "renhud/client/code/wwmath/rect.lua" )

    --- @type WW3d
    local ww3d = CNC.Import( "renhud/client/code/ww3d2/ww3d.lua" )

    --- @type Shader
    local shader = CNC.Import( "renhud/client/code/ww3d2/shader.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "Render2d"

    --- [[ Public ]]

    --- Creates a new Render2d
    --- @param material IMaterial?
    --- @return Render2dInstance
    function STATIC.New( material )
        return robustclass.New( "Renegade_Render2d", material )
    end

    ---@param arg any
    ---@return boolean `true` if the passed argument is a(n) Render2dInstance, `false` otherwise
    function STATIC.IsRender2d( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsRender2d and true or false
    end

    typecheck.RegisterType( "Render2dInstance", STATIC.IsRender2d )

    --- @return ShaderInstance
    function STATIC.GetDefaultShader()
        local shaderInstance = shader.New()

        shaderInstance:SetDepthMask( shader.DEPTH_WRITE.DISABLE )
        shaderInstance:SetDepthCompare( shader.DEPTH_COMPARE.PASS_ALWAYS )
        shaderInstance:SetDstBlendFunc( shader.DST_BLEND_FUNC.ONE_MINUS_SRC_ALPHA )
        shaderInstance:SetSrcBlendFunc( shader.SRC_BLEND_FUNC.SRC_ALPHA )
        shaderInstance:SetFogFunc( shader.FOG_FUNC.DISABLE )
        shaderInstance:SetPrimaryGradient( shader.PRIMARY_GRADIENT.MODULATE )
        shaderInstance:SetMaterialing( shader.MATERIALING.ENABLE )

        return shaderInstance
    end

    --- Retrieves the screen size as a RectangleInstance
    --- @return RectInstance 
    function STATIC.GetScreenResolution()
        if not STATIC.ScreenResolution then
            STATIC.ScreenResolution = robustclass.New( "Renegade_Rect", 0, 0, ScrW(), ScrH() )
        end

        return STATIC.ScreenResolution
    end

    --- [[ Protected ]]

    --- @class Render2d
    --- @field protected ScreenResolution RectInstance
    --- @field protected BiasAdd Vector The amount to offset all 2D rendering if ScreenUvBias is enabled

    --- Recalculates the BiasAdd value based on the current screen size
    --- @protected
    function STATIC.UpdateBiasAdd()
        STATIC.BiasAdd = Vector(
            -0.5 / ( ScrW() *  0.5 ),
            -0.5 / ( ScrH() * -0.5 )
        )
    end
    hook.Add( "OnScreenSizeChanged", "A1_Renegade_Render2d_UpdateScreenSizeDependencies", STATIC.UpdateBiasAdd )
end


--[[ Instanced Functions and Variables ]] do

    local CLASS = "Render2dInstance"

    --- [[ Public ]]

    --- Constructs a new Render2D object
    --- @param material IMaterial?
    function INSTANCE:Renegade_Render2d( material )
        self.CoordinateScale = Vector( 1, 1 )
        self.CoordinateOffset = Vector( 0, 0 )
        self.ZValue = 0
        self.IsHidden = false

        self.Vertices = {}
        self.Uvs = {}
        self.Colors = {}
        self.ShouldRebuildMesh = false

        self:SetMaterial( material )
        self.Shader = STATIC.GetDefaultShader();

        self:UpdateBias()
    end

    --- Deletes the Mesh contents of this renderer
    function INSTANCE:Reset()

        if self.Mesh then
            self.Mesh:Destroy()
            self.Mesh = nil
        end

        self.Vertices = {}
        self.Uvs = {}
        self.Colors = {}
        self.ShouldRebuildMesh = true

        self:UpdateBias()
    end

    function INSTANCE:Render()
        if self.IsHidden then
            return
        end

        -- Build the mesh if it's out of date
        if self.ShouldRebuildMesh then

            -- Sanity check
            if #self.Vertices ~= #self.Uvs or #self.Uvs ~= #self.Colors then
                typecheck.Error( CLASS, "Render", string.format( "Render2d:Render has mismatch in list counts: Vertices (%d), UVs (%d), Colors (%d)", #self.Vertices, #self.Uvs, #self.Colors ) )
            end

            local triCount = #self.Vertices / 3

            -- Can't have partial triangles
            if triCount ~= math.floor( triCount ) then
                typecheck.Error( CLASS, "Render", string.format(  "Render2d:Render count of Vertices (%d) must be divisible by 3", #self.Vertices ) )
            end

            if self.Mesh then
                self.Mesh:Destroy()
            end

            self.Mesh = Mesh()

            mesh.Begin( self.Mesh, MATERIAL_TRIANGLES, triCount )

            for i = 1, #self.Vertices do
                local vertex = self.Vertices[i]
                local uv     = self.Uvs[i]
                local color  = self.Colors[i]

                mesh.Position( vertex )
                mesh.TexCoord( 0, uv.x, uv.y )
                mesh.Color( color.r, color.g, color.b, color.a )
                mesh.AdvanceVertex()
            end

            mesh.End()

            self.ShouldRebuildMesh = false
        end

        if self.Mesh then

            local material = self.Material
            if material then
                render.SetMaterial( material )
            else
                render.SetColorMaterial()
            end

            cam.Start2D()
            render.CullMode( MATERIAL_CULLMODE_CW )

            render.PushFilterMin( TEXFILTER.POINT )
            render.PushFilterMag( TEXFILTER.POINT )

            self.Shader:Enable()

            self.Mesh:Draw()

            self.Shader:Disable()

            render.PopFilterMag()
            render.PopFilterMin()

            render.CullMode( MATERIAL_CULLMODE_CCW )
            cam.End2D()
        end
    end

    --- > *"default range is (-1,1)-(1,-1)" -Code/ww3d2/render2d.cpp#170*
    --- @param range RectInstance
    function INSTANCE:SetCoordinateRange( range )
        -- self.CoordinateScale.x =  2 / range:Width()
        -- self.CoordinateScale.y = -2 / range:Height()
        -- self.CoordinateOffset.x = -( self.CoordinateScale.x * range.Left ) - 1
        -- self.CoordinateOffset.y = -( self.CoordinateScale.y * range.Top  ) + 1

        self.CoordinateScale.x = range:Width()
        self.CoordinateScale.y = range:Height()
        self.CoordinateOffset.x = 0
        self.CoordinateOffset.y = 0

        self:UpdateBias()
    end

    --- Sets the IMaterial that this renderer will use
    --- Originally called `Set_Texture`
    --- @param material IMaterial?
    function INSTANCE:SetMaterial( material )
        self.Material = material
    end

    --- Originally called `Peek_Texture`
    --- @returns IMaterial
    function INSTANCE:PeekMaterial()
        return self.Material
    end

    --- @param hasAlpha boolean
    function INSTANCE:EnableAlpha( hasAlpha )
        if hasAlpha then
            self.Shader:SetDstBlendFunc( shader.DST_BLEND_FUNC.ONE_MINUS_SRC_ALPHA )
            self.Shader:SetSrcBlendFunc( shader.SRC_BLEND_FUNC.SRC_ALPHA )
        else
            self.Shader:SetDstBlendFunc( shader.DST_BLEND_FUNC.ONE )
            self.Shader:SetSrcBlendFunc( shader.SRC_BLEND_FUNC.ZERO )
        end
    end

    --- @param isAdditive boolean
    function INSTANCE:EnableAdditive( isAdditive )
        if isAdditive then
            self.Shader:SetDstBlendFunc( shader.DST_BLEND_FUNC.ONE )
            self.Shader:SetSrcBlendFunc( shader.SRC_BLEND_FUNC.ONE )
        else
            self.Shader:SetDstBlendFunc( shader.DST_BLEND_FUNC.ONE )
            self.Shader:SetSrcBlendFunc( shader.SRC_BLEND_FUNC.ZERO )
        end
    end

    --- Originally called `Enable_Texturing`
    --- @param useMaterial boolean
    function INSTANCE:EnableMaterial( useMaterial )
        if useMaterial then
            self.Shader:SetMaterialing( shader.MATERIALING.ENABLE )
        else
            self.Shader:SetMaterialing( shader.MATERIALING.DISABLE )
        end
    end

    --- @return ShaderInstance
    function INSTANCE:GetShader()
        return self.Shader
    end

    --- Adds a Quad to this renderer
    --- @param ... any
    --- @overload fun( self: Render2dInstance,  vertex0: Vector,     vertex1: Vector,    vertex2: Vector,    vertex3: Vector,    uvs: RectInstance,  color: Color?   ) Adds a UV'd Quad to this renderer by individually defining its points
    --- @overload fun( self: Render2dInstance,  vertex0: Vector,     vertex1: Vector,    vertex2: Vector,    vertex3: Vector,    color: Color?                       ) Adds an un-UV'd Quad to this renderer by individually defining its points
    --- @overload fun( self: Render2dInstance,  rect: RectInstance,  uvs: RectInstance,  color: Color?                                                               ) Adds a UV'd Quad to this renderer using Rects
    --- @overload fun( self: Render2dInstance,  rect: RectInstance,  color: Color?                                                                                   ) Adds an un-UV'd Quad to this renderer using a Rect
    function INSTANCE:AddQuad( ... )
        local args = { ... }

        local firstArg  = args[1]
        local secondArg = args[2]
        local thirdArg  = args[3]
        local fourthArg = args[4]
        local fifthArg  = args[5]
        local sixthArg  = args[6]

        --- For individually defined vertices
        --- @type Vector, Vector, Vector, Vector
        local vertex0, vertex1, vertex2, vertex3

        --- For collectively defined vertices
        --- @type RectInstance
        local _rect

        local uvs = robustclass.New( "Renegade_Rect", 0, 0, 1, 1 )
        local color = Color( 255, 255, 255, 255 )

        typecheck.AssertArgType( CLASS, 1, firstArg, { "Vector", "RectInstance" } )

        -- ( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector, ... )
        if isvector( firstArg ) then
            --- @cast firstArg Vector

            typecheck.AssertArgType( CLASS, 2, secondArg, "vector" )
            typecheck.AssertArgType( CLASS, 3, thirdArg, "vector" )
            typecheck.AssertArgType( CLASS, 4, fourthArg, "vector" )

            vertex0 = firstArg
            vertex1 = secondArg
            vertex2 = thirdArg
            vertex3 = fourthArg

            -- ( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector, uvs: RectInstance, color: Color? )
            if rect.IsRect( fifthArg ) then
                --- @cast fifthArg RectInstance
                uvs = fifthArg

                -- Sixth arg must be Color
                if sixthArg then
                    typecheck.AssertArgType( CLASS, 6, sixthArg, "color" )

                    --- @cast sixthArg Color
                    color = sixthArg
                end

            -- ( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector, color: Color? )
            else
                -- Fifth arg must be Color
                if fifthArg then
                    typecheck.AssertArgType( CLASS, 5, fifthArg, "color" )

                    --- @cast fifthArg Color
                    color = fifthArg
                end
            end

        -- ( rect: RectInstance, ... )
        else
            --- @cast firstArg RectInstance

            -- ( rect: RectInstance, uvs: RectInstance, color: Color? )
            if rect.IsRect( secondArg ) then
                --- @cast secondArg RectInstance

                _rect = firstArg
                uvs = secondArg

                -- Third arg must be Color
                if thirdArg then
                    typecheck.AssertArgType( CLASS, 3, thirdArg, "color" )
                    --- @cast thirdArg Color
                    color = thirdArg
                end

            -- ( rect: RectInstance, color: Color? )
            else
                _rect  = firstArg

                if secondArg then
                    typecheck.AssertArgType( CLASS, 2, secondArg, "color" )
                    --- @cast secondArg Color
                    color = secondArg
                end
            end
        end

        -- One final sanity check
        local hasVertices = ( _rect or ( vertex0 and vertex1 and vertex2 and vertex3 ) )
        if not hasVertices or not uvs or not color then
            typecheck.Error( CLASS, "AddQuad", "an unknown error occurred" )
        end

        if _rect then
            self:InternalAddQuadVertices( _rect )
        else
            self:InternalAddQuadVertices( vertex0, vertex1, vertex2, vertex3 )
        end

        self:InternalAddQuadUvs( uvs )
        self:InternalAddQuadColors( color )

        self.ShouldRebuildMesh = true
    end

    --- @param vertex0 Vector
    --- @param vertex1 Vector
    --- @param vertex2 Vector
    --- @param vertex3 Vector
    --- @param uv RectInstance
    --- @param color Color? [Default: White]
    function INSTANCE:AddQuadBackfaced( vertex0, vertex1, vertex2, vertex3, uv, color )
        typecheck.NotImplementedError( CLASS, "AddQuadBackfaced" )
    end

    --- @param screen RectInstance
    --- @param topColor Color
    --- @param bottomColor Color
    function INSTANCE:AddQuadVerticalGradient( screen, topColor, bottomColor )
        typecheck.NotImplementedError( CLASS, "AddQuadVerticalGradient" )
    end

    ---@param screen RectInstance
    ---@param leftColor Color
    ---@param rightColor Color
    function INSTANCE:AddQuadVerticalGradient( screen, leftColor, rightColor )
        typecheck.NotImplementedError( CLASS, "AddQuadVerticalGradient" )
    end

    --- @param vertex0 Vector
    --- @param vertex1 Vector
    --- @param vertex2 Vector
    --- @param uv0 Vector
    --- @param uv1 Vector
    --- @param uv2 Vector
    --- @param color Color? [Default: White]
    function INSTANCE:AddTri( vertex0, vertex1, vertex2, uv0, uv1, uv2, color )
        -- Vertices
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex0 )
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex1 )
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex2 )

        -- UVs
        self.Uvs[#self.Uvs + 1] = uv0
        self.Uvs[#self.Uvs + 1] = uv1
        self.Uvs[#self.Uvs + 1] = uv2

        -- Colors
        self.Colors[#self.Colors + 1] = color
        self.Colors[#self.Colors + 1] = color
        self.Colors[#self.Colors + 1] = color
    end

    --- @overload fun( self: Render2dInstance, startPos: Vector, endPos: Vector, width: number, color: Color )
    --- @overload fun( self: Render2dInstance, startPos: Vector, endPos: Vector, width: number, uv: RectInstance, color: Color )
    function INSTANCE:AddLine( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        typecheck.AssertArgCount( CLASS, argCount, { 4, 5 } )

        local startPos
        local endPos
        local width
        local uv
        local color

        -- ( startPos: Vector, endPos: Vector, width: number, color: Color )
        if argCount == 4 then
            typecheck.AssertArgType( CLASS, 1, args[1], "Vector" )
            typecheck.AssertArgType( CLASS, 2, args[2], "Vector" )
            typecheck.AssertArgType( CLASS, 3, args[3], "number" )
            typecheck.AssertArgType( CLASS, 4, args[4], "Color"  )

            startPos = args[1] --[[@as Vector]]
            endPos   = args[2] --[[@as Vector]]
            width    = args[3] --[[@as number]]
            uv       = rect.New( 0, 0, 1, 1 ) --[[@as RectInstance]]
            color    = args[4] --[[@as Color]]
        end

        -- ( startPos: Vector, endPos: Vector, width: number, uv: RectInstance, color: Color )
        if argCount == 5 then
            typecheck.AssertArgType( CLASS, 1, startPos, "Vector"       )
            typecheck.AssertArgType( CLASS, 2, endPos,   "Vector"       )
            typecheck.AssertArgType( CLASS, 3, width,    "number"       )
            typecheck.AssertArgType( CLASS, 4, uv,       "RectInstance" )
            typecheck.AssertArgType( CLASS, 5, color,    "Color"        )

            startPos = args[1] --[[@as Vector]]
            endPos   = args[2] --[[@as Vector]]
            width    = args[3] --[[@as number]]
            uv       = args[4] --[[@as RectInstance]]
            color    = args[5] --[[@as Color]]
        end

        local cornerOffset = startPos - endPos -- "Get line relative to endPos"
        local temp = cornerOffset.x -- "Rotate 90"
        cornerOffset.x = cornerOffset.y
        cornerOffset.y = -temp
        cornerOffset:Normalize()
        cornerOffset = cornerOffset * width / 2

        self:AddQuad( startPos - cornerOffset, startPos + cornerOffset, endPos - cornerOffset, endPos + cornerOffset, uv, color )
    end

    function INSTANCE:AddOutline( ... )
        typecheck.NotImplementedError( CLASS, "AddOutline" )
    end

    --- @param rect RectInstance
    --- @param borderWidth number
    --- @param borderColor Color? [Default: Red]
    --- @param fillColor Color? [Default: White]
    function INSTANCE:AddRect( rect, borderWidth, borderColor, fillColor )
        typecheck.NotImplementedError( CLASS, "AddRect" )
    end

    ---@param isHidden boolean
    function INSTANCE:SetHidden( isHidden )
        self.IsHidden = isHidden
    end

    --- > *"this is usefull for playing tricks with the z-buffer" -Code/ww3d2/render2d.h#142*
    --- @param zValue number
    function INSTANCE:SetZValue( zValue )
        self.ZValue = zValue
    end

    --- Moves/translates all vertices
    --- @param translation Vector
    function INSTANCE:Move( translation )
        typecheck.NotImplementedError( CLASS, "Move" )
    end

    --- @param alpha number
    function INSTANCE:ForceAlpha( alpha )
        typecheck.NotImplementedError( CLASS, "ForceAlpha" )
    end

    --- @param color Color
    function INSTANCE:ForceColor( color )
        typecheck.NotImplementedError( CLASS, "ForceColor" )
    end

    --- @return Color[]
    function INSTANCE:GetColorArray()
        return self.Colors
    end

    --[[ Protected ]]

    --- @class Render2dInstance
    --- @field protected CoordinateScale Vector
    --- @field protected CoordinateOffset Vector
    --- @field protected BiasedCoordinateOffset Vector
    --- @field protected Material IMaterial? (Originally called "Texture") The material to be drawn on this renderer's faces
    --- @field protected Shader ShaderInstance
    --- @field protected Vertices Vector[]
    --- @field protected Uvs Vector[]
    --- @field protected ShouldRebuildMesh boolean
    --- @field protected Colors Color[]
    --- @field protected IsHidden boolean
    --- @field protected ZValue number The depth value used when rendering vertices
    --- @field protected Mesh IMesh The mesh that this renderer wraps

    --- Adjusts a given Vector based on the Screen UV Bias
    --- @param ... unknown
    --- @overload fun( self: Render2dInstance, vector: Vector ): Vector
    --- @overload fun( self: Render2dInstance, x: number, y: number ): Vector
    function INSTANCE:ConvertVert( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        local firstArg  = args[1]
        local secondArg = args[2]

        local convertedVert

        if argCount == 1 then
            typecheck.AssertArgType( CLASS, 1, firstArg, "vector" )

            --- @cast firstArg Vector
            local vector = firstArg

            convertedVert = Vector(
                vector.x / self.CoordinateScale.x,
                vector.y / self.CoordinateScale.y
            )
        elseif argCount == 2 then
            typecheck.AssertArgType( CLASS, 1, firstArg, "number" )
            typecheck.AssertArgType( CLASS, 2, secondArg, "number" )

            --- @cast firstArg number
            local x = firstArg

            --- @cast secondArg number
            local y = secondArg

            convertedVert = Vector(
                x / self.CoordinateScale.x,
                y / self.CoordinateScale.y
            )
        else
            typecheck.AssertArgCount( CLASS, argCount )
        end

        -- Convert from whatever weird coordinate space this renderer is using to Garry's Mod's screen pixel coordinate space
        convertedVert.x = ( convertedVert.x * STATIC.GetScreenResolution():Width() ) + self.BiasedCoordinateOffset.x
        convertedVert.y = ( convertedVert.y * STATIC.GetScreenResolution():Height() ) + self.BiasedCoordinateOffset.y

        return convertedVert
    end

    --- Adds the Vertices of a Quad to the internal list of Vertices
    --- @param ... unknown
    --- @overload fun( self: Render2dInstance, vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector )
    --- @overload fun( self: Render2dInstance, rect: RectInstance )
    --- @protected
    function INSTANCE:InternalAddQuadVertices( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        local firstArg  = args[1]
        local secondArg = args[2]
        local thirdArg  = args[3]
        local fourthArg = args[4]

        --- @type Vector, Vector, Vector, Vector
        local vertex0, vertex1, vertex2, vertex3

        -- InternalAddQuadVertices( rect: RectInstance )
        if argCount == 1 then
            local rect = firstArg --[[@as RectInstance]]

            typecheck.AssertArgType( CLASS, 1, firstArg, "RectInstance" )

            vertex0 = Vector( rect.Left,    rect.Top    )
            vertex1 = Vector( rect.Left,    rect.Bottom )
            vertex2 = Vector( rect.Right,   rect.Top    )
            vertex3 = Vector( rect.Right,   rect.Bottom )

        -- InternalAddQuadVertices( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector )
        elseif argCount == 4 then
            vertex0 = firstArg --[[@as Vector]]
            vertex1 = secondArg --[[@as Vector]]
            vertex2 = thirdArg --[[@as Vector]]
            vertex3 = fourthArg --[[@as Vector]]

            typecheck.AssertArgType( CLASS, 1, firstArg, "vector" )
            typecheck.AssertArgType( CLASS, 2, secondArg, "vector" )
            typecheck.AssertArgType( CLASS, 3, thirdArg, "vector" )
            typecheck.AssertArgType( CLASS, 4, fourthArg, "vector" )

        else
            typecheck.AssertArgCount( CLASS, argCount )
        end

        local convertedVertex0 = self:ConvertVert( vertex0 )
        local convertedVertex1 = self:ConvertVert( vertex1 )
        local convertedVertex2 = self:ConvertVert( vertex2 )
        local convertedVertex3 = self:ConvertVert( vertex3 )

        -- First triangle
        self.Vertices[#self.Vertices + 1] = convertedVertex0
        self.Vertices[#self.Vertices + 1] = convertedVertex1
        self.Vertices[#self.Vertices + 1] = convertedVertex2

        -- Second triangle
        self.Vertices[#self.Vertices + 1] = convertedVertex1
        self.Vertices[#self.Vertices + 1] = convertedVertex3
        self.Vertices[#self.Vertices + 1] = convertedVertex2
    end

    --- Adds the UVs of a Quad to the internal list of UVs
    --- @param uv RectInstance
    --- @protected
    function INSTANCE:InternalAddQuadUvs( uv )
        -- First triangle
        self.Uvs[#self.Uvs + 1] = Vector( uv.Left,  uv.Top    ) -- Vertex 0
        self.Uvs[#self.Uvs + 1] = Vector( uv.Left,  uv.Bottom ) -- Vertex 1
        self.Uvs[#self.Uvs + 1] = Vector( uv.Right, uv.Top    ) -- Vertex 2

        -- Second triangle
        self.Uvs[#self.Uvs + 1] = Vector( uv.Left,  uv.Bottom ) -- Vertex 1
        self.Uvs[#self.Uvs + 1] = Vector( uv.Right, uv.Bottom ) -- Vertex 3
        self.Uvs[#self.Uvs + 1] = Vector( uv.Right, uv.Top    ) -- Vertex 2
    end

    --- Adds a given color to a Quad in the internal list of Colors
    --- @param color Color
    --- @protected
    function INSTANCE:InternalAddQuadColors( color )

        -- First Triangle
        self.Colors[#self.Colors + 1] = color
        self.Colors[#self.Colors + 1] = color
        self.Colors[#self.Colors + 1] = color

        -- Second Triangle
        self.Colors[#self.Colors + 1] = color
        self.Colors[#self.Colors + 1] = color
        self.Colors[#self.Colors + 1] = color
    end

    --- Updates the biased coordinate offsets based on if ScreenUvBias is enabled
    --- @protected
    function INSTANCE:UpdateBias()
        self.BiasedCoordinateOffset = self.CoordinateOffset

        if ww3d.IsScreenUvBiased() then
            if not STATIC.BiasAdd then
                STATIC.UpdateBiasAdd()
            end

            self.BiasedCoordinateOffset = self.BiasedCoordinateOffset + STATIC.BiasAdd
        end
    end
end