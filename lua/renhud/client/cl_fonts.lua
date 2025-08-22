--- @class Renegade
local CNC = CNC_RENEGADE

-- A library supporting the creation of font atlases from OS fonts
--- @class FontsLib
local LIB = CNC.CreateExport()
local CLASS = "FontsLib"
local isHotload = not table.IsEmpty( LIB )


--#region Imports

    --- @type FontChars
    local fontCharsClass = CNC.Import( "renhud/client/code/ww3d2/font-chars.lua" )

    --- @type Font3d
    local font3dClass = CNC.Import( "renhud/client/code/ww3d2/font-3d.lua" )
--#endregion


--[[ Configuration ]] do

    --- @private
    --- The byte in the ASCII char range that font atlas rendering range starts at
    LIB.FontAtlasStartChar = 33

    --- @private
    --- The byte in the ASCII char range that font atlas rendering range stops at
    LIB.FontAtlasEndChar = 127

    --- @private
    --- The width and height, in number of characters, of font atlases
    LIB.FontAtlasGridSize = Vector( 16, 16 )

    --- @private
    --- What color text should be when it is rendered to a new font atlas
    LIB.FontAtlasTextColor = Color( 255, 255, 255, 255 )
end


--- @private
--- All of the font atlases that have been created and their corresponding Font3dInstance
--- A map of [string: System Font Name][integer: Point Size][boolean: Is Bold?] -> Font3dInstance
--- @type table<string, table<integer, table<boolean, Font3dInstance>>>
LIB.CreatedFonts = {}

--- @private
--- A queue of the fonts that need to have atlases created for them in the next batch of conversions
--- @type FontDescription[]
LIB.FontsToCreate = {}


--- @param font FontDescription
--- @return boolean
function LIB.IsFontCreated( font )
    local fontsWithName = LIB.CreatedFonts[ font.Name ]
    if not fontsWithName then return false end

    local fontsWithSize = fontsWithName[ font.PointSize ]
    if not fontsWithSize then return false end

    local fontWithBold = fontsWithSize[font.IsBold]
    if not fontWithBold then return false end

    return true
end

--- Retrieves an existing font
--- @param font FontDescription
--- @return Font3dInstance
function LIB.GetCreatedFont( font )
    local fontsWithName = LIB.CreatedFonts[ font.Name ]
    if not fontsWithName then
        typecheck.Error( CLASS, "GetCreatedFont",
            "Unable to find Renegade font with name '" .. font.Name .. "'"
        )
    end

    local fontsWithSize = fontsWithName[ font.PointSize ]
    if not fontsWithSize then
        typecheck.Error( CLASS, "GetCreatedFont",
            "Unable to find Renegade font with name '" .. font.Name .. "' and size " .. font.PointSize
        )
    end

    local fontWithBold = fontsWithSize[font.IsBold]
    if not fontWithBold then
        typecheck.Error( CLASS, "GetCreatedFont",
            "Unable to find Renegade font with name '" .. font.Name .. "', size " .. font.PointSize .. ", and boldness: " .. tostring( font.IsBold )
        )
    end

    return fontWithBold
end

--- Schedules a font to have a character atlas created for it during the next frame
--- @param fontToCreate FontDescription
function LIB.QueueRenegadeFontCreation( fontToCreate )
    -- Add the font atlas to the queue
    LIB.FontsToCreate[#LIB.FontsToCreate + 1] = fontToCreate

    -- Ensure that we render font atlases next frame
    hook.Add( "PreRender", "A1_Renegade_Fonts_RenderFontAtlases", LIB.CreateAllQueuedFonts )
end

--- @private
--- Immediately renders all queued font atlases
function LIB.CreateAllQueuedFonts()
    -- Render each queued font atlas
    for i = 1, #LIB.FontsToCreate do
        LIB.CreateFont( LIB.FontsToCreate[i] )
        LIB.FontsToCreate[i] = nil
    end

    -- Now that there are no remaining atlases in the queue we can remove this hook
    hook.Remove( "PreRender", "A1_Renegade_Fonts_RenderFontAtlases" )
end

--- @private
--- Immediately renders a single font atlas
--- @param font FontDescription
--- @return Font3dInstance # The font for the created font atlas
function LIB.CreateFont( font )
    -- Register this font with Garry's Mod so we can draw it
    local fontChars = fontCharsClass.New()
    fontChars:InitializeGdiFont( font.Name, font.PointSize, font.IsBold )

    -- Use the newly created Garry's Mod font
    local createdFontName = fontChars:GetCreatedFontName()
    surface.SetFont( createdFontName )

    -- Find the font's widest character width and height
    local maxCharWidth, maxCharHeight = 0, 0
    for byte = LIB.FontAtlasStartChar, LIB.FontAtlasEndChar do
        local char = string.char( byte )

        local charWidth, charHeight = surface.GetTextSize( char )

        maxCharWidth = ( charWidth > maxCharWidth ) and charWidth or maxCharWidth
        maxCharHeight = ( charHeight > maxCharHeight ) and charHeight or maxCharHeight
    end

    -- Adjust the maximum size slightly as a safety margin
    maxCharWidth = maxCharWidth + 2
    maxCharHeight = maxCharHeight + 2

    -- Create a Render Target to store the font atlas
    local atlasWidth = maxCharWidth * LIB.FontAtlasGridSize.x
    local atlasHeight = maxCharHeight * LIB.FontAtlasGridSize.y
    local atlasRenderTarget = GetRenderTargetEx( "RENEGADE_FONT-ATLAS-RT_" .. createdFontName, atlasWidth, atlasHeight, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_NONE, bit.bor( 1 ), 0, IMAGE_FORMAT_RGBA8888 )

    --[[ Populate Atlas ]] do

        local color = LIB.FontAtlasTextColor
        surface.SetTextColor( color.r, color.g, color.b, color.a )

        render.PushRenderTarget( atlasRenderTarget )
        cam.Start2D()

        render.Clear( 0, 0, 0, 0 )

        render.OverrideColorWriteEnable( true, true )
        render.OverrideAlphaWriteEnable( true, true )
        render.OverrideBlend( false )

        -- Draw each character onto the Render Target
        for byte = LIB.FontAtlasStartChar, LIB.FontAtlasEndChar do
            local char = string.char( byte )

            -- The position of this character within the atlas's grid
            local gridX = ( byte % LIB.FontAtlasGridSize.x )
            local gridY = math.floor( byte / LIB.FontAtlasGridSize.y )

            -- The top-left corner of this character's cell on the grid
            local charOriginX = gridX * maxCharWidth
            local charOriginY = gridY * maxCharHeight

            local charWidth, charHeight = surface.GetTextSize( char )

            -- Draw the character in the center of its grid cell
            local charDrawX = math.floor( charOriginX + ( maxCharWidth  / 2 ) - ( charWidth  / 2 ) )
            local charDrawY = math.floor( charOriginY + ( maxCharHeight / 2 ) - ( charHeight / 2 ) )

            surface.SetTextPos( charDrawX, charDrawY )
            surface.DrawText( char )
        end

        render.OverrideColorWriteEnable( false, false )
        render.OverrideAlphaWriteEnable( false, false )

        cam.End2D()
        render.PopRenderTarget()
    end

    -- The IMaterial that will be used by a Render2dTextInstance to draw this font
    local atlasMaterial = CreateMaterial( "RENEGADE_FONT-ATLAS-MAT_" .. createdFontName, "UnlitGeneric", {
        ["$basetexture"]    = atlasRenderTarget:GetName(),
        ["$translucent"]    = 1,
        ["$gammacolorread"] = 1,    -- Disables SRGB conversion of color texture read.  Credit: Noaccess
        ["$linearwrite"]    = 1,    -- Disables SRGB conversion of shader results.      Credit: Noaccess
        ["$vertexcolor"]    = 1
    } )

    -- This font3d will ultimately be used to set the font of a Render2dTextInstance
    local font3d = font3dClass.New( atlasMaterial )
    font3d:SetInterCharSpacing( font.InterCharSpacing )

    --[[ Store the New Font ]] do

        local matchingNames = LIB.CreatedFonts[font.Name]
        if not matchingNames then
            LIB.CreatedFonts[font.Name] = {}
            matchingNames = LIB.CreatedFonts[font.Name]
        end

        local matchingSizes = matchingNames[font.PointSize]
        if not matchingSizes then
            matchingNames[font.PointSize] = {}
            matchingSizes = matchingNames[font.PointSize]
        end

        LIB.CreatedFonts[font.Name][font.PointSize][font.IsBold] = font3d
    end

    return font3d
end