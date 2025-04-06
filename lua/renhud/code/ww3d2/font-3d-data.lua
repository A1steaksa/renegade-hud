-- Based loosely on Font3DDataClass within Code/ww3d2/font3d.cpp/h

-- This class is not a direct port of the original code, but rather is a "hack" to provide
-- the same functionality based on hard-coded values

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Font3dData
    --- @class Font3dDataInstance
    --- @field Static Font3dData The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Font3dData" )

    --- The static components of Font3dData
    --- @class Font3dData
    --- @field Instance Font3dDataInstance The Metatable used by Font3DDataInstance
    STATIC = CNC_RENEGADE.Font3dData or {}
    CNC_RENEGADE.Font3dData = STATIC

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
end

--[[ Static Functions and Variables ]] do

    --- [[ Public ]]

    --- @class Font3dData

    --- Creates a new Font3dData
    --- @param font3dInstance Font3dInstance The Font3dInstance that owns this Font3dDataInstance
    --- @param fontMaterial IMaterial The font atlas to be used
    function STATIC.New( font3dInstance, fontMaterial )
        return robustclass.New( "Renegade_Font3dData",  font3dInstance, fontMaterial )
    end

    -- [[ Private ]]

    --- @class Font3dData
    --- @field private ProcessingRenderTarget ITexture The Render Target used for per-pixel processing of font materials
    --- @field private FontsToMakeProportional Font3dDataInstance[]

    STATIC.FontsToMakeProportional = {}

    local function ProportionalizeFontData()
        if not STATIC.ProcessingRenderTarget then
            STATIC.ProcessingRenderTarget = GetRenderTarget( "Renegade_Font3dData_FontProcessing", ScrW(), ScrH() )
        end

        cam.Start2D()

        local rt = STATIC.ProcessingRenderTarget
        render.PushRenderTarget( rt )

        for _, fontData in ipairs( STATIC.FontsToMakeProportional ) do
            local fontMaterial = fontData:PeekMaterial()
            local texture = fontMaterial:GetTexture( "$basetexture" )

            local materialWidth = fontMaterial:Width()
            local materialHeight = fontMaterial:Height()

            --- Get the pixels of the material by putting them on our Render Target and capturing it
            render.Clear( 0, 0, 0, 0 )
            render.DrawTextureToScreenRect( texture, 0, 0, materialWidth, materialHeight )
            render.CapturePixels()

            for charIndex = 0, 255 do

                local char = string.char( charIndex )

                local startX, endX, charWidth = STATIC.FindHorizontalCharBounds( fontMaterial, charIndex )

                fontData.UOffsetTable[char] = startX / materialWidth
                fontData.UWidthTable[char] = charWidth / materialWidth
                fontData.CharWidthTable[char] = charWidth
            end

            -- Tell the Font3dInstance that owns this Font3dDataInstance that we've changed our values and they need to rebuild their cache
            fontData.Font3dInstance:BuildCachedTables()
        end

        render.PopRenderTarget()

        cam.End2D()

        STATIC.FontsToMakeProportional = {}

        hook.Remove( "PreRender", "A1_Renegade_Font3dData_MakeFontsProportional" )
    end

    --- @param fontData Font3dDataInstance
    --- @private
    function STATIC.MakeProportional( fontData )
        STATIC.FontsToMakeProportional[#STATIC.FontsToMakeProportional + 1] = fontData

        hook.Add( "PreRender", "A1_Renegade_Font3dData_MakeFontsProportional", ProportionalizeFontData )
    end

    --- Checks each pixel of the specified index within a given font atlas material and determines its left and right bounds
    --- @param fontMaterial IMaterial The font atlas to be checked.  Assumed to be a 16x16 grid of characters on a completely transparent background.
    --- @param charIndex integer The index of the character to be checked, starting at 0
    --- @return number startX, number endX, number width
    --- @private
    function STATIC.FindHorizontalCharBounds( fontMaterial, charIndex )
        local gridX = charIndex % 16
        local gridY = math.floor( charIndex / 16 )

        local monoCharWidth = fontMaterial:Width() / 16
        local monoCharHeight = fontMaterial:Height() / 16

        local startX = gridX * monoCharWidth
        local startY = gridY * monoCharHeight

        local minX = startX + monoCharWidth
        local maxX = startX

        for x = startX, startX + monoCharWidth do
            for y = startY, startY + monoCharHeight do
                local r, g, b, _ = render.ReadPixel( x, y ) -- Relies on this function being called after render.CapturePixels()

                local pixelHasContent = r ~= 0 and g ~= 0 and b ~= 0

                if pixelHasContent then
                    if x < minX then
                        minX = x
                    end

                    if x > maxX then
                        maxX = x
                    end
                end
            end
        end

        -- It's always off by 1 for reasons, I'm sure
        if maxX ~= startX then
            maxX = maxX + 1
        end

        return minX, maxX, maxX - minX
    end

end

--[[ Instanced Functions and Variables ]] do

    --- [[ Public ]]

    --- @class Font3dDataInstance
    --- @field Font3dInstance Font3dInstance
    --- @field UOffsetTable number[]
    --- @field CharWidthTable number[]
    --- @field UWidthTable number[]

    --- Constructs a new Font3dDataInstance
    --- @param font3dInstance Font3dInstance The Font3dInstance that owns this Font3dDataInstance
    --- @param fontMaterial IMaterial The font atlas to be used
    function INSTANCE:Renegade_Font3dData( font3dInstance, fontMaterial )
        self.Font3dInstance = font3dInstance

        self.Material = nil
        self.CharWidthTable = {}
        self.UWidthTable = {}
        self.UOffsetTable = {}
        self.VOffsetTable = {}

        self:LoadFontImage( fontMaterial )
    end

    --- @param char string? [Default: "H"]
    --- @return number
    function INSTANCE:GetCharWidth( char )
        if not char then
            char = "H"
        end

        return self.CharWidthTable[ char ]
    end

    --- @return number
    function INSTANCE:GetCharHeight()
        return self.CharHeight
    end

    --- @param char string? [Default: "H"]
    --- @return number
    function INSTANCE:GetCharUOffset( char )
        if not char then
            char = "H"
        end

        return self.UOffsetTable[ char ]
    end

    --- @param char string? [Default: "H"]
    --- @return number
    function INSTANCE:GetCharVOffset( char )
        if not char then
            char = "H"
        end

        return self.VOffsetTable[ char ]
    end

    --- @param char string? [Default: "H"]
    --- @return number
    function INSTANCE:GetCharUWidth( char )
        if not char then
            char = "H"
        end

        return self.UWidthTable[ char ]
    end

    --- @return number
    function INSTANCE:GetCharVHeight()
        return self.VHeight
    end

    --- @param char string? [Default: "H"]
    --- @return table
    function INSTANCE:GetCharUvCorners( char )
        if not char then
            char = "H"
        end

        return {
            self.UOffsetTable[ char ],
            self.VOffsetTable[ char ],
            self.UOffsetTable[ char ] + self.UWidthTable[ char ],
            self.VOffsetTable[ char ] + self.VHeight
        }
    end

    --- @return IMaterial
    function INSTANCE:PeekMaterial()
        return self.Material
    end


    --- [[ Private ]]

    --- @class Font3dDataInstance
    --- @field private Material IMaterial
    --- @field private VOffsetTable number[]
    --- @field private VHeight number
    --- @field private CharHeight number

    --- @private
    --- @param fontMaterial IMaterial
    --- @return boolean success
    function INSTANCE:LoadFontImage( fontMaterial )
        self.Material = fontMaterial

        -- The size of the texture atlas, just to cut down on function calls
        -- Assume all font materials are an atlas of 16x16 elements
        local atlasPixelWidth = fontMaterial:Width()
        local atlasPixelHeight = fontMaterial:Height()

        -- The monospaced size of each character
        local monoCharPixelHeight = atlasPixelHeight / 16
        local monoCharPixelWidth = atlasPixelWidth / 16

        -- Cache the monospaced UVs for each character
        for charIndex = 0, 255 do
            local char = string.char( charIndex )

            self.UOffsetTable[char] = ( ( charIndex % 16 ) * monoCharPixelWidth ) / atlasPixelWidth
            self.VOffsetTable[char] = ( math.floor( charIndex / 16 ) * monoCharPixelHeight ) / atlasPixelHeight
            self.UWidthTable[char] = monoCharPixelWidth / atlasPixelWidth
            self.CharWidthTable[char] = monoCharPixelWidth
        end

        -- The height of each character
        self.VHeight = monoCharPixelHeight / atlasPixelHeight
        self.CharHeight = monoCharPixelHeight

        self:MakeProportional()

        return true
    end

    --- @private
    function INSTANCE:MakeProportional()
        STATIC.MakeProportional( self )
    end

    --- @private
    --- @param fontMaterial IMaterial
    --- @return IMaterial
    function INSTANCE:MinimizeFontMaterial( fontMaterial )
        error( "Function not yet implemented" )
    end

end