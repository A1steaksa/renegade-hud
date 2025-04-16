-- Based on StyleMgrClass within Code/wwui/stylemgr.cpp/h

local STATIC

--[[ Class Setup ]] do

    --- The static components of StyleManager
    --- @class StyleManager
    STATIC = CNC_RENEGADE.StyleManager or {}
    CNC_RENEGADE.StyleManager = STATIC
end

--#region Imports

local render2d = CNC_RENEGADE.Render2d
local fontChars = CNC_RENEGADE.FontChars
local font3d = CNC_RENEGADE.Font3d
--#endregion

--- @enum FONT_STYLE
STATIC.FONT_STYLE = {
    FONT_TITLE               = 0,
    FONT_LG_CONTROLS         = 1,
    FONT_CONTROLS            = 2,
    FONT_LISTS               = 3,
    FONT_TOOLTIPS            = 4,
    FONT_MENU                = 5,
    FONT_SM_MENU             = 6,
    FONT_HEADER              = 7,
    FONT_BIG_HEADER          = 8,
    FONT_CREDITS             = 9,
    FONT_CREDITS_BOLD        = 10,
    FONT_INGAME_TXT          = 11,
    FONT_INGAME_BIG_TXT      = 12,
    FONT_INGAME_SUBTITLE_TXT = 13,
    FONT_INGAME_HEADER_TXT   = 14
}

--- @enum JUSTIFICATION
STATIC.JUSTIFICATION = {
    LEFT_JUSTIFY    = 0,
    RIGHT_JUSTIFY   = 1,
    CENTER_JUSTIFY  = 2
}

--- @enum EVENT_AUDIO
STATIC.EVENT_AUDIO = {
    EVENT_MOUSE_CLICK = 0,
    EVENT_MOUSE_OVER  = 1,
    EVENT_MENU_BACK   = 2,
    EVENT_POPUP       = 3,
    EVENT_AUDIO_MAX   = 4
}

--- @class FONT_DESC
--- @field name string
--- @field pointSize integer
--- @field interCharSpacing integer
--- @field isBold boolean

--- The font defaults as found in stylemgr.cpp and, seemingly identically, in data/stylemgr.ini
--- @type FONT_DESC[]
STATIC.DEFAULT_FONTS = {
   [STATIC.FONT_STYLE.FONT_TITLE              ] = { name = "Regatta Condensed LET", pointSize = 52, interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_LG_CONTROLS        ] = { name = "Arial MT",              pointSize = 12, interCharSpacing = 2, isBold = true  },
   [STATIC.FONT_STYLE.FONT_CONTROLS           ] = { name = "Arial MT",              pointSize = 8,  interCharSpacing = 2, isBold = true  },
   [STATIC.FONT_STYLE.FONT_LISTS              ] = { name = "Arial MT",              pointSize = 8,  interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_TOOLTIPS           ] = { name = "Arial MT",              pointSize = 8,  interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_MENU               ] = { name = "Regatta Condensed LET", pointSize = 32, interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_SM_MENU            ] = { name = "Regatta Condensed LET", pointSize = 20, interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_HEADER             ] = { name = "Arial MT",              pointSize = 9,  interCharSpacing = 2, isBold = true  },
   [STATIC.FONT_STYLE.FONT_BIG_HEADER         ] = { name = "Arial MT",              pointSize = 12, interCharSpacing = 2, isBold = true  },
   [STATIC.FONT_STYLE.FONT_CREDITS            ] = { name = "Arial MT",              pointSize = 10, interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_CREDITS_BOLD       ] = { name = "Arial MT",              pointSize = 10, interCharSpacing = 2, isBold = true  },
   [STATIC.FONT_STYLE.FONT_INGAME_TXT         ] = { name = "Arial MT",              pointSize = 8,  interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_INGAME_BIG_TXT     ] = { name = "Arial MT",              pointSize = 16, interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_INGAME_SUBTITLE_TXT] = { name = "Arial MT",              pointSize = 14, interCharSpacing = 2, isBold = false },
   [STATIC.FONT_STYLE.FONT_INGAME_HEADER_TXT  ] = { name = "Arial MT",              pointSize = 9,  interCharSpacing = 2, isBold = true  },
}

--[[ Static Functions and Variables ]] do

    --- [[ Public ]]

    --- @class StyleManager

    --[[ Initialization ]] do

        function STATIC.Initialize()

            -- Compute font scale for this resolution
            local screenRes = render2d.GetScreenResolution()
            STATIC.ScaleX = screenRes:Width() / 800
            STATIC.ScaleY = screenRes:Height() / 600

            -- Create font atlases for the default fonts
            for _, index in pairs( STATIC.FONT_STYLE ) do
                local fontDetails = STATIC.DEFAULT_FONTS[ index ]

                -- Convert from Renegade's font sizing to Garry's Mod's font sizing
                local convertedFontSize = fontDetails.pointSize * 1.75

                local createdFont3d = STATIC.GetOrCreateFontAtlas( fontDetails.name, convertedFontSize, fontDetails.isBold )
                createdFont3d:SetInterCharSpacing( fontDetails.interCharSpacing )

                --createdFont3d:SetScale( 1 )

                STATIC.FontStyleToFont3d[ index ] = createdFont3d
            end

            -- Not loading backdrop here because I don't need it (yet?)
        end

        --- @param fileName string
        function STATIC.InitializeFromIni( fileName )
            error( "Function not yet implemented" )
        end

        function STATIC.Shutdown()
            error( "Function not yet implemented" )
        end
    end

    --[[ Font methods ]] do

        --- @param style FONT_STYLE
        --- @return FontCharsInstance
        function STATIC.GetFont( style )
            error( "Function not yet implemented" )
        end

        --- @param style FONT_STYLE
        --- @return Font3dInstance
        function STATIC.PeekFont( style )
            return STATIC.FontStyleToFont3d[ style ]
        end

        --- @param renderer Render2dTextInstance
        --- @param style FONT_STYLE
        function STATIC.AssignFont( renderer, style )
            error( "Function not yet implemented" )
        end
    end

    --[[ Sound methods ]] do

        --- @param event EVENT_AUDIO
        function STATIC.PlaySound( event )
            error( "Function not yet implemented" )
        end
    end

    --[[ Configuration methods ]] do

        --- @param renderer Render2dTextInstance
        function STATIC.ConfigureRenderer( renderer )
            error( "Function not yet implemented" )
        end
    end

    --[[ Scale support ]] do

        --- @return number
        function STATIC.GetXScale()
            return STATIC.ScaleX
        end

        --- @return number
        function STATIC.GetYScale()
            return STATIC.ScaleY
        end
    end

    --[[ Color methods ]] do

        --- @return Color
        function STATIC.GetTextColor()
            return STATIC.TextColor
        end

        --- @return Color
        function STATIC.GetTextShadowColor()
            return STATIC.TextShadowColor
        end

        --- @return Color
        function STATIC.GetDisabledTextColor()
            return STATIC.DisabledTextColor
        end

        --- @return Color
        function STATIC.GetDisabledTextShadowColor()
            return STATIC.DisabledTextShadowColor
        end

        --- @return Color
        function STATIC.GetLineColor()
            return STATIC.LineColor
        end

        --- @return Color
        function STATIC.GetBkColor()
            return STATIC.BkColor
        end

        --- @return Color
        function STATIC.GetDisabledLineColor()
            return STATIC.DisabledLineColor
        end

        --- @return Color
        function STATIC.GetDisabledBkColor()
            return STATIC.DisabledBkColor
        end

        --- @return Color
        function STATIC.GetTabTextColor()
            return STATIC.TabTextColor
        end

        --- @return Color
        function STATIC.GetTabGlowColor()
            return STATIC.TabGlowColor
        end
    end

    --[[ Backdrop support ]] do

        --- @param renderer Render2dTextInstance
        --- @param rect RectInstance
        function STATIC.RenderBackdrop( renderer, rect )
            return STATIC.TabGlowColor
        end
    end

    --[[ Text support ]] do

        --- @overload fun( text: string, renderer:Render2dTextInstance, textColor: Color, shadowColor: Color, rect: RectInstance, doShadow: boolean?, doClip: boolean, justify: JUSTIFICATION?, isVCentered: boolean? )
	    --- @overload fun( text: string, renderer:Render2dTextInstance, rect:RectInstance, doShadow: boolean?, doClip: boolean?, justify: JUSTIFICATION?, isEnabled:boolean?, isVCentered: boolean? )
        function STATIC.RenderText( ... )
            local args = { ... }
            local argCount = select( "#", ... )

            error( "Function not yet implemented" )
        end

        --- @param text string
        --- @param renderer Render2dTextInstance
        --- @param rect RectInstance
        function STATIC.RenderTitleText( text, renderer, rect )
            error( "Function not yet implemented" )
        end

        --- @overload fun( text: string, renderer: Render2dTextInstance, textColor: Color, shadowColor: Color, rect: RectInstance, doShadow: boolean?, doVCenter: boolean? )
        --- @overload fun( text: string, renderer: Render2dTextInstance, rect: RectInstance, doShadow: boolean?, doVCenter: boolean?, isEnabled: boolean? )
        function STATIC.RenderWrappedText( ... )
            local args = { ... }
            local argCount = select( "#", ... )

            error( "Function not yet implemented" )
        end

        --- @overload fun( text: string, renderer: Render2dTextInstance, rect: RectInstance, doShadow: boolean?, doVCenter: boolean?, isEnabled:boolean?, justify: JUSTIFICATION? )
        --- @overload fun( text: string, renderer: Render2dTextInstance, textColor: Color, shadowColor: Color, rect: RectInstance, doShadow: boolean?, doVCenter: boolean?, justify: JUSTIFICATION? )
        function STATIC.RenderWrappedTextEx( ... )
            local args = { ... }
            local argCount = select( "#", ... )

            error( "Function not yet implemented" )
        end
    end

    --[[ Hilight support ]] do

        --- @param renderer Render2dTextInstance
        function STATIC.ConfigureHilighter( renderer )
            error( "Function not yet implemented" )
        end

        --- @param renderer Render2dTextInstance
        --- @param rect RectInstance
        function STATIC.RenderHilight( renderer, rect )
            error( "Function not yet implemented" )
        end
    end

    --[[ Text "glow" support ]] do

        --- @param text string
        --- @param renderer Render2dTextInstance
        --- @param rect RectInstance
        --- @param radiusX integer
        --- @param radiusY integer
        --- @param color Color
        --- @param justify JUSTIFICATION
        function STATIC.RenderGlow( text, renderer, rect, radiusX, radiusY, color, justify )
            error( "Function not yet implemented" )
        end
    end


    --- [[ Private ]]

    --- @class StyleManager
    --- @field private BackdropMaterial IMaterial
    --- @field private TitleColor Color
    --- @field private TitleHilightColor Color
    --- @field private TitleShadowColor Color
    --- @field private TextColor Color
    --- @field private TextShadowColor Color
    --- @field private LineColor Color
    --- @field private BkColor Color
    --- @field private DisabledTextColor Color
    --- @field private DisabledTextShadowColor Color
    --- @field private DisabledLineColor Color
    --- @field private DisabledBkColor Color
    --- @field private HilightColor Color
    --- @field private TabTextColor Color
    --- @field private TabGlowColor Color
    --- @field private Fonts FontCharsInstance[]
    --- @field private ScaleX number
    --- @field private ScaleY number
    --- @field private FontFileList string[]
    --- @field private EventAudioList string[]

    --- The byte in the ASCII char range that font atlas rendering range starts at
    --- @private
    STATIC.FontAtlasStartChar = 33

    --- The byte in the ASCII char range that font atlas rendering range stops at
    --- @private
    STATIC.FontAtlasEndChar = 127

    --- What color text should be when it is rendered to a new font atlas
    --- @private
    STATIC.FontAtlasTextColor = Color( 255, 255, 255, 255 )

    --- A map of [string: System Font Name][integer: Point Size][boolean: Is Bold?] -> Font3dInstance
    --- @type table<string, table<integer, table<boolean, Font3dInstance>>>
    --- @private
    STATIC.FontAtlases = {}

    --- A map of FONT_STYLE to its matching Font3dInstance
    --- @type table<FONT_STYLE, Font3dInstance>
    --- @private
    STATIC.FontStyleToFont3d = {}

    --- @param fontChars FontCharsInstance
    --- @return IMaterial # The font atlas that was created
    --- @private
    function STATIC.CreateFontAtlas( fontChars )
        local fontName = fontChars:GetCreatedFontName()
        surface.SetFont( fontName )
        surface.SetTextColor( STATIC.FontAtlasTextColor )

        -- Find the font's widest character width 
        local maxCharWidth, maxCharHeight = 0, 0
        for byte = STATIC.FontAtlasStartChar, STATIC.FontAtlasEndChar do
            local char = string.char( byte )

            local charWidth, charHeight = surface.GetTextSize( char )

            maxCharWidth = ( charWidth > maxCharWidth ) and charWidth or maxCharWidth
            maxCharHeight = ( charHeight > maxCharHeight ) and charHeight or maxCharHeight
        end

        -- Add a couple of pixels just as a safety margin
        maxCharWidth = maxCharWidth + 2
        maxCharHeight = maxCharHeight + 2

        -- Create a Render Target to hold the atlas
        -- Assumes a 16 x 16 grid
        local atlasWidth = maxCharWidth * 16
        local atlasHeight = maxCharHeight * 16

        local atlas = GetRenderTargetEx( "RENEGADE_FONT-ATLAS-RT_" .. fontName, atlasWidth, atlasHeight, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_NONE, bit.bor( 1 ), 0, IMAGE_FORMAT_RGBA8888 )
        local atlasMaterial = CreateMaterial( "RENEGADE_FONT-ATLAS-MAT_" .. fontName, "UnlitGeneric", {
            ["$basetexture"] = atlas:GetName(),
            ["$translucent"] = 1
        } )

        -- Render the font to the atlas
        render.PushRenderTarget( atlas )
        cam.Start2D()

        render.Clear( 0, 0, 0, 0 )

        for byte = STATIC.FontAtlasStartChar, STATIC.FontAtlasEndChar do
            local char = string.char( byte )

            local gridX = ( byte % 16 )
            local gridY = math.floor( byte / 16 )

            local charOriginX = gridX * maxCharWidth
            local charOriginY = gridY * maxCharHeight

            local charWidth, charHeight = surface.GetTextSize( char )

            local charDrawX = math.floor( charOriginX + ( maxCharWidth / 2 ) - ( charWidth / 2 ) )
            local charDrawY = math.floor( charOriginY + ( maxCharHeight / 2 ) - ( charHeight / 2 ) )

            surface.SetTextPos( charDrawX, charDrawY )
            surface.DrawText( char )
        end

        cam.End2D()
        render.PopRenderTarget()

        return atlasMaterial
    end

    --- @param systemFontName string
    --- @param pointSize integer
    --- @param isBold boolean?
    --- @return Font3dInstance
    function STATIC.GetOrCreateFontAtlas( systemFontName, pointSize, isBold )
        if not isBold then
            isBold = false
        end

        local fontsWithName = STATIC.FontAtlases[ systemFontName ]

        if not fontsWithName then
            fontsWithName = {}
            STATIC.FontAtlases[ systemFontName ] = fontsWithName
        end

        local fontsWithSize = fontsWithName[ pointSize ]

        if not fontsWithSize then
            fontsWithSize = {}
            fontsWithName[ pointSize ] = fontsWithSize
        end

        local fontWithBold = fontsWithName[ pointSize ][ isBold ]

        -- We may need to create this font atlas from scratch
        if not fontWithBold then
            -- Register the font with Garry's Mod
            local createdFontChars = fontChars.New()
            createdFontChars:InitializeGdiFont( systemFontName, pointSize, isBold )

            -- Create a font atlas for the registered font
            local fontAtlas = STATIC.CreateFontAtlas( createdFontChars )

            -- Create and store the Font3dInstance for the font atlas
            fontWithBold = font3d.New( fontAtlas )
            fontsWithName[ pointSize ][ isBold ] = fontWithBold
        end

        return fontWithBold
    end
    

end