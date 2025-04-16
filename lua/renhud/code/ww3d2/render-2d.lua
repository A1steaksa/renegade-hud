-- Based on Render2DClass within Code/ww3d2/render2d.cpp/h

local STATIC, INSTANCE

--[[ Class Setup ]] do
    --- @class Renegade
    --- @field Render2d Render2d

    --- The instanced components of Render2d
    --- @class Render2dInstance
    INSTANCE = robustclass.Register( "Renegade_Render2d" )

    --- A 2D renderer that constructs an internal IMesh
    --- @class Render2d
    --- @field Instance Render2dInstance The Metatable used by Render2dInstance
    STATIC = CNC_RENEGADE.Render2d or {}
    CNC_RENEGADE.Render2d = STATIC

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
end

--#region Imports

local shader = CNC_RENEGADE.Shader
--#endregion

--[[ Static Functions and Variables ]] do

    --[[ Public ]]

    --- Creates a new Render2d
    --- @param material IMaterial?
    --- @return Render2dInstance
    function STATIC.New( material )
        return robustclass.New( "Renegade_Render2d", material )
    end

    --- @return ShaderInstance
    function STATIC.GetDefaultShader()
        local shaderInstance = shader.New()

        shaderInstance:SetDepthMask(       shader.DEPTH_WRITE_DISABLE          )
        shaderInstance:SetDepthCompare(    shader.PASS_ALWAYS                  )
        shaderInstance:SetDstBlendFunc(    shader.DSTBLEND_ONE_MINUS_SRC_ALPHA )
        shaderInstance:SetSrcBlendFunc(    shader.SRCBLEND_SRC_ALPHA           )
        shaderInstance:SetFogFunc(         shader.FOG_DISABLE                  )
        shaderInstance:SetPrimaryGradient( shader.GRADIENT_MODULATE            )
        shaderInstance:SetTexturing(       shader.TEXTURING_ENABLE             )

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

    --[[ Public ]]

    ---@class Render2dInstance

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
                error( string.format( "Render2d:Render has mismatch in list counts: Vertices (%d), UVs (%d), Colors (%d)", #self.Vertices, #self.Uvs, #self.Colors ) )
            end

            local triCount = #self.Vertices / 3

            -- Can't have partial triangles
            if triCount ~= math.floor( triCount ) then
                error( string.format(  "Render2d:Render count of Vertices (%d) must be divisible by 3", #self.Vertices ) )
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
            render.CullMode( MATERIAL_CULLMODE_CW )

            render.SetMaterial( self.Material )
            self.Mesh:Draw()

            render.CullMode( MATERIAL_CULLMODE_CCW )
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
        error( "Function not yet implemented" )
    end

    --- @param isAdditive boolean
    function INSTANCE:EnableAdditive( isAdditive )
        error( "Function not yet implemented" )
    end

    --- @param hasAlpha boolean
    function INSTANCE:EnableAlpha( hasAlpha )
        error( "Function not yet implemented" )
    end

    --- Originally called `Enable_Texturing`
    --- @param useMaterial boolean
    function INSTANCE:EnableMaterial( useMaterial )
        error( "Function not yet implemented" )
    end

    --- @return unknown
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
        local rect

        local uvs = robustclass.New( "Renegade_Rect", 0, 0, 1, 1 )
        local color = Color( 255, 255, 255, 255 )

        -- AddQuad( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector, ... )
        if isvector( firstArg ) then
            --- @cast firstArg Vector

            typecheck( "Render2D:AddQuad", 2, "vector", secondArg )
            typecheck( "Render2D:AddQuad", 3, "vector", thirdArg )
            typecheck( "Render2D:AddQuad", 4, "vector", fourthArg )

            vertex0 = firstArg
            vertex1 = secondArg
            vertex2 = thirdArg
            vertex3 = fourthArg

            -- AddQuad( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector, uvs: RectInstance, color: Color? )
            if CNC_RENEGADE.Rect.IsRect( fifthArg ) then
                --- @cast fifthArg RectInstance
                uvs = fifthArg

                -- Sixth arg must be Color
                if sixthArg then
                    typecheck( "Render2D:AddQuad", 6, "color", sixthArg )
                    --- @cast sixthArg Color
                    color = sixthArg
                end

            -- AddQuad( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector, color: Color? )
            else
                -- Fifth arg must be Color
                if fifthArg then
                    typecheck( "Render2D:AddQuad", 5, "color", fifthArg )
                    --- @cast fifthArg Color
                    color = fifthArg
                end
            end

        -- AddQuad( rect: RectInstance, ... )
        elseif CNC_RENEGADE.Rect.IsRect( firstArg ) then
            --- @cast firstArg RectInstance

            -- AddQuad( rect: RectInstance, uvs: RectInstance, color: Color? )
            if CNC_RENEGADE.Rect.IsRect( secondArg ) then
                --- @cast secondArg RectInstance

                rect = firstArg
                uvs = secondArg

                -- Third arg must be Color
                if thirdArg then
                    typecheck( "Render2D:AddQuad", 3, "color", thirdArg )
                    --- @cast thirdArg Color
                    color = thirdArg
                end

            -- AddQuad( rect: RectInstance, color: Color? )
            else
                rect  = firstArg

                if secondArg then
                    typecheck( "Render2D:AddQuad", 2, "color", secondArg )
                    --- @cast secondArg Color
                    color = secondArg
                end
            end
        else
            error( "Render2d:AddQuad argument 1: expected Vector or Rect but got " .. type( firstArg ) )
        end

        -- One final sanity check
        local hasVertices = ( rect or ( vertex0 and vertex1 and vertex2 and vertex3 ) )
        if not hasVertices or not uvs or not color then
            error( "Render2d:AddQuad an unknown error occurred" )
        end

        if rect then
            self:InternalAddQuadVertices( rect )
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
        error( "Function not yet implemented" )
    end

    --- @param screen RectInstance
    --- @param topColor Color
    --- @param bottomColor Color
    function INSTANCE:AddQuadVerticalGradient( screen, topColor, bottomColor )
        error( "Function not yet implemented" )
    end

    ---@param screen RectInstance
    ---@param leftColor Color
    ---@param rightColor Color
    function INSTANCE:AddQuadVerticalGradient( screen, leftColor, rightColor )
        error( "Function not yet implemented" )
    end

    --- @param vertex0 Vector
    --- @param vertex1 Vector
    --- @param vertex2 Vector
    --- @param uv0 Vector
    --- @param uv1 Vector
    --- @param uv2 Vector
    --- @param color Color? [Default: White]
    function INSTANCE:AddTri( vertex0, vertex1, vertex2, uv0, uv1, uv2, color )
        error( "Function not yet implemented" )
    end

    function INSTANCE:AddLine( ... )
        error( "Function not yet implemented" )
    end

    function INSTANCE:AddOutline( ... )
        error( "Function not yet implemented" )
    end

    --- @param rect RectInstance
    --- @param borderWidth number
    --- @param borderColor Color? [Default: Red]
    --- @param fillColor Color? [Default: White]
    function INSTANCE:AddRect( rect, borderWidth, borderColor, fillColor )
        error( "Function not yet implemented" )
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
        error( "Function not yet implemented" )
    end

    --- @param alpha number
    function INSTANCE:ForceAlpha( alpha )
        error( "Function not yet implemented" )
    end

    --- @param color Color
    function INSTANCE:ForceColor( color )
        error( "Function not yet implemented" )
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
            typecheck( "Render2d:ConvertVert", 1, "vector", firstArg )

            --- @cast firstArg Vector
            local vector = firstArg

            convertedVert = Vector(
                -- math.floor( vector.x * self.CoordinateScale.x + self.BiasedCoordinateOffset.x ),
                -- math.floor( vector.y * self.CoordinateScale.y + self.BiasedCoordinateOffset.y )
                vector.x / self.CoordinateScale.x + self.BiasedCoordinateOffset.x,
                vector.y / self.CoordinateScale.y + self.BiasedCoordinateOffset.y
            )
        elseif argCount == 2 then
            typecheck( "Render2d:ConvertVert", 1, "number", firstArg )
            typecheck( "Render2d:ConvertVert", 2, "number", secondArg )

            --- @cast firstArg number
            local x = firstArg

            --- @cast secondArg number
            local y = secondArg

            convertedVert = Vector(
                -- math.floor( x * self.CoordinateScale.x + self.BiasedCoordinateOffset.x ),
                -- math.floor( y * self.CoordinateScale.y + self.BiasedCoordinateOffset.y )
                x / self.CoordinateScale.x + self.BiasedCoordinateOffset.x,
                y / self.CoordinateScale.y + self.BiasedCoordinateOffset.y
            )
        else
            error( string.format( "Render2d:ConvertVert received an invalid number of arguments (%d)", argCount ) )
        end

        -- Convert from whatever weird coordinate space this renderer is using to Garry's Mod's screen pixel coordinate space
        convertedVert.x = convertedVert.x * STATIC.GetScreenResolution():Width()
        convertedVert.y = convertedVert.y * STATIC.GetScreenResolution():Height()

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
            typecheck( "Render2d:InternalAddVertices", 1, "rect", firstArg )

            --- @cast firstArg RectInstance
            local rect = firstArg

            vertex0 = Vector( rect.Left,    rect.Top    )
            vertex1 = Vector( rect.Left,    rect.Bottom )
            vertex2 = Vector( rect.Right,   rect.Top    )
            vertex3 = Vector( rect.Right,   rect.Bottom )

        -- InternalAddQuadVertices( vertex0: Vector, vertex1: Vector, vertex2: Vector, vertex3: Vector )
        elseif argCount == 4 then
            typecheck( "Render2d:InternalAddVertices", 1, "vector", firstArg )
            typecheck( "Render2d:InternalAddVertices", 2, "vector", secondArg )
            typecheck( "Render2d:InternalAddVertices", 3, "vector", thirdArg )
            typecheck( "Render2d:InternalAddVertices", 4, "vector", fourthArg )

            --- @cast firstArg Vector
            vertex0 = firstArg

            --- @cast secondArg Vector
            vertex1 = secondArg

            --- @cast thirdArg Vector
            vertex2 = thirdArg

            --- @cast fourthArg Vector
            vertex3 = fourthArg
        else
            error( string.format( "Render2d:InternalAddVertices received an invalid number of arguments (%d)", argCount ) )
        end

        -- First triangle
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex0 ) -- Vertex 0
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex1 ) -- Vertex 1
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex2 ) -- Vertex 2

        -- Second triangle
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex1 ) -- Vertex 1
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex3 ) -- Vertex 3
        self.Vertices[#self.Vertices + 1] = self:ConvertVert( vertex2 ) -- Vertex 2
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

        if CNC_RENEGADE.WW3d.IsScreenUvBiased() then
            if not STATIC.BiasAdd then
                STATIC.UpdateBiasAdd()
            end

            self.BiasedCoordinateOffset = self.BiasedCoordinateOffset + STATIC.BiasAdd
        end
    end
end