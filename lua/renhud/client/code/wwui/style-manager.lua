-- Based on StyleMgrClass within Code/wwui/stylemgr.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of StyleManager
    --- @class StyleManager
    STATIC = CNC.CreateExport()
end


--#region Imports

    --- @type Render2d
    local render2d = CNC.Import( "renhud/client/code/ww3d2/render-2d.lua" )

    --- @type FontsLib
    local fontsLib = CNC.Import( "renhud/client/cl_fonts.lua" )
--#endregion


--#region Enums

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
    local fontStyle = STATIC.FONT_STYLE

    --- @enum JUSTIFICATION
    STATIC.JUSTIFICATION = {
        LEFT_JUSTIFY    = 0,
        RIGHT_JUSTIFY   = 1,
        CENTER_JUSTIFY  = 2
    }
    local justification = STATIC.JUSTIFICATION

    --- @enum EVENT_AUDIO
    STATIC.EVENT_AUDIO = {
        EVENT_MOUSE_CLICK = 0,
        EVENT_MOUSE_OVER  = 1,
        EVENT_MENU_BACK   = 2,
        EVENT_POPUP       = 3,
        EVENT_AUDIO_MAX   = 4
    }
    local eventAudio = STATIC.EVENT_AUDIO
--#endregion


--[[ Default Fonts ]] do

    --- @class FontDescription
    --- @field Name string
    --- @field PointSize integer
    --- @field InterCharSpacing integer
    --- @field IsBold boolean

    --- The amount to multiply Renegade font point sizes by to convert them to the same visual size in Garry's Mod
    --- This value was determined by experimentation and is not yet understood.
    local sizeMultipler = 1.75

    --- The font defaults as found in stylemgr.cpp and, seemingly identically, in data/stylemgr.ini
    --- @type FontDescription[]
    STATIC.DefaultFonts = {
        [ fontStyle.FONT_TITLE              ] = { Name = "Regatta Condensed LET", PointSize = math.floor( sizeMultipler * 52 ), InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_LG_CONTROLS        ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 12 ), InterCharSpacing = 2, IsBold = true  },
        [ fontStyle.FONT_CONTROLS           ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 8  ),  InterCharSpacing = 2, IsBold = true  },
        [ fontStyle.FONT_LISTS              ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 8  ),  InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_TOOLTIPS           ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 8  ),  InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_MENU               ] = { Name = "Regatta Condensed LET", PointSize = math.floor( sizeMultipler * 32 ), InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_SM_MENU            ] = { Name = "Regatta Condensed LET", PointSize = math.floor( sizeMultipler * 20 ), InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_HEADER             ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 9  ),  InterCharSpacing = 2, IsBold = true  },
        [ fontStyle.FONT_BIG_HEADER         ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 12 ), InterCharSpacing = 2, IsBold = true  },
        [ fontStyle.FONT_CREDITS            ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 10 ), InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_CREDITS_BOLD       ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 10 ), InterCharSpacing = 2, IsBold = true  },
        [ fontStyle.FONT_INGAME_TXT         ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 8  ),  InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_INGAME_BIG_TXT     ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 16 ), InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_INGAME_SUBTITLE_TXT] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 14 ), InterCharSpacing = 2, IsBold = false },
        [ fontStyle.FONT_INGAME_HEADER_TXT  ] = { Name = "Arial MT",              PointSize = math.floor( sizeMultipler * 9  ),  InterCharSpacing = 2, IsBold = true  },
    }
end


--[[ Static Functions and Variables ]] do

    local CLASS = "StyleManager"

    --- [[ Public ]]

    --[[ Initialization ]] do

        function STATIC.Initialize()
            -- Compute font scale for this resolution
            local screenRes = render2d.GetScreenResolution()
            STATIC.ScaleX = screenRes:Width() / 800
            STATIC.ScaleY = screenRes:Height() / 600

            -- Create font atlases for the default fonts
            for _, fontDescription in pairs( STATIC.DefaultFonts ) do
                if not fontsLib.IsFontCreated( fontDescription ) then
                    fontsLib.QueueRenegadeFontCreation( fontDescription )
                end
            end

            -- Not loading backdrop here because I don't need it (yet?)
        end

        --- @param fileName string
        function STATIC.InitializeFromIni( fileName )
            typecheck.NotImplementedError( CLASS, "InitializeFromIni" )
        end

        function STATIC.Shutdown()
            typecheck.NotImplementedError( CLASS, "Shutdown" )
        end
    end

    --[[ Font methods ]] do

        --- @param style FONT_STYLE
        --- @return FontCharsInstance
        function STATIC.GetFont( style )
            typecheck.NotImplementedError( CLASS, "GetFont" )
        end

        --- @param style FONT_STYLE
        --- @return Font3dInstance
        function STATIC.PeekFont( style )
            -- Pull the font from the cache
            local cachedFont = STATIC.FontStyleToFont3d[ style ]

            -- If this font isn't already cached, cache it
            if not cachedFont then
                local fontDescription = STATIC.DefaultFonts[ style ]
                if not fontsLib.IsFontCreated( fontDescription ) then
                    typecheck.Error( CLASS, "PeekFont",
                        "Unable to peek un-created font: '" .. fontDescription.Name .. "', size: " ..fontDescription.PointSize .. ", boldness:" .. tostring( fontDescription.IsBold )
                    )
                end

                STATIC.FontStyleToFont3d[ style ] = fontsLib.GetCreatedFont( fontDescription )
                cachedFont = STATIC.FontStyleToFont3d[ style ]
            end

            return cachedFont
        end

        --- @param renderer Render2dTextInstance
        --- @param style FONT_STYLE
        function STATIC.AssignFont( renderer, style )
            typecheck.NotImplementedError( CLASS, "AssignFont" )
        end
    end

    --[[ Sound methods ]] do

        --- @param event EVENT_AUDIO
        function STATIC.PlaySound( event )
            typecheck.NotImplementedError( CLASS, "PlaySound" )
        end
    end

    --[[ Configuration methods ]] do

        --- @param renderer Render2dTextInstance
        function STATIC.ConfigureRenderer( renderer )
            typecheck.NotImplementedError( CLASS, "ConfigureRenderer" )
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

            typecheck.NotImplementedError( CLASS, "RenderText" )
        end

        --- @param text string
        --- @param renderer Render2dTextInstance
        --- @param rect RectInstance
        function STATIC.RenderTitleText( text, renderer, rect )
            typecheck.NotImplementedError( CLASS, "RenderTitleText" )
        end

        --- @overload fun( text: string, renderer: Render2dTextInstance, textColor: Color, shadowColor: Color, rect: RectInstance, doShadow: boolean?, doVCenter: boolean? )
        --- @overload fun( text: string, renderer: Render2dTextInstance, rect: RectInstance, doShadow: boolean?, doVCenter: boolean?, isEnabled: boolean? )
        function STATIC.RenderWrappedText( ... )
            local args = { ... }
            local argCount = select( "#", ... )

            typecheck.NotImplementedError( CLASS, "RenderWrappedText" )
        end

        --- @overload fun( text: string, renderer: Render2dTextInstance, rect: RectInstance, doShadow: boolean?, doVCenter: boolean?, isEnabled:boolean?, justify: JUSTIFICATION? )
        --- @overload fun( text: string, renderer: Render2dTextInstance, textColor: Color, shadowColor: Color, rect: RectInstance, doShadow: boolean?, doVCenter: boolean?, justify: JUSTIFICATION? )
        function STATIC.RenderWrappedTextEx( ... )
            local args = { ... }
            local argCount = select( "#", ... )

            typecheck.NotImplementedError( CLASS, "RenderWrappedTextEx" )
        end
    end

    --[[ Hilight support ]] do

        --- @param renderer Render2dTextInstance
        function STATIC.ConfigureHilighter( renderer )
            typecheck.NotImplementedError( CLASS, "ConfigureHilighter" )
        end

        --- @param renderer Render2dTextInstance
        --- @param rect RectInstance
        function STATIC.RenderHilight( renderer, rect )
            typecheck.NotImplementedError( CLASS, "RenderHilight" )
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
            typecheck.NotImplementedError( CLASS, "RenderGlow" )
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

    --- @private
    --- A map of FONT_STYLE to its matching Font3dInstance
    --- @type table<FONT_STYLE, Font3dInstance>
    STATIC.FontStyleToFont3d = {}
end