-- Based somewhat loosely on FontCharsClass within Code/ww3d2/render2dsentence.cpp/h

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- @class FontCharsInstance
    --- @field Static FontChars The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_FontChars" )

    --- A container for system fonts  
    --- In Garry's Mod, it's main purpose is to register the font with the game and to act as a look-up for character sizing
    --- @class FontChars
    --- @field Instance FontCharsInstance The Metatable used by FontCharsInstance
    STATIC = CNC_RENEGADE.FontChars or {}
    CNC_RENEGADE.FontChars = STATIC

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
end

--[[ Static Functions and Variables ]] do

    --- [[ Public ]]

    --- @class FontChars

    --- Creates a new FontCharsInstance
    --- @vararg any
    --- @return FontCharsInstance
    function STATIC.New()
        return robustclass.New( "Renegade_FontChars" )
    end

end

--[[ Instanced Functions and Variables ]] do

    --- [[ Public ]]

    --- @class FontCharsInstance

    --- Constructs a new FontCharsInstance
    --- @vararg any
    function INSTANCE:Renegade_FontChars()
        self.OldGdiFont = nil
        self.OldGdiBitmap = nil
        self.GdiFont = nil
        self.GdiBitmap = nil
        self.GdiBitmapBits = nil
        self.MemDc = nil
        self.CurrPixelOffset = 0
        self.PointSize = 0
        self.CharHeight = 0
        self.UnicodeCharArray = nil
        self.FirstUnicodeChar = 0xFFFF
        self.LastUnicodeChar = 0
        self.IsBold = false
        self.BufferList = {}

        self.CharWidths = {}

        self.AsciiCharArray = {}
    end

    --- @param fontName string The OS font name of the font to be used 
    --- @param pointSize integer The height of the font
    --- @param isBold boolean
    --- @return string # The name of the Garry's Mod font that was registered
    function INSTANCE:InitializeGdiFont( fontName, pointSize, isBold )

        -- Remove spaces form the font name
        local cleanedFontName = string.Replace( fontName, " ", "-" )

        -- The font name that the font will be created under within Garry's Mod
        self.CreatedFontName = string.format( "RENEGADE_%s_%d%s", cleanedFontName, pointSize, isBold and "_bold" or "" )

        self.SystemFontName  = fontName
        self.PointSize   = math.floor( pointSize )
        self.IsBold      = isBold
        self.IsArialMt = string.lower( fontName ) == "arial mt"

        surface.CreateFont ( self.CreatedFontName, {
            font    = self.SystemFontName,
            size    = self.PointSize,
            weight  = self.IsBold and 1000 or 0,
            antialias = false
        } )

        return self.CreatedFontName
    end

    --- Checks if another font's values match this font's values
    --- @param fontName string
    --- @param pointSize integer
    --- @param isBold boolean
    --- @return boolean
    function INSTANCE:IsFont( fontName, pointSize, isBold )
        error( "Function not yet implemented" )
    end

    --- @return string
    function INSTANCE:GetName()
        return self.CreatedFontName
    end

    --- @return integer
    function INSTANCE:GetCharHeight()
        if not self.CharHeight then
            surface.SetFont( self.CreatedFontName )
            local _, height = surface.GetTextSize( "H" )
            self.CharHeight = height
        end

        return self.CharHeight
    end

    --- @param char string
    --- @return integer
    function INSTANCE:GetCharWidth( char )
        if not self.CharWidths[ char ] then
            surface.SetFont( self.CreatedFontName )
            self.CharWidths[ char ] = ( surface.GetTextSize( char ) )
        end

        return self.CharWidths[ char ]
    end

    --- @param char string
    function INSTANCE:GetCharSpacing( char )
        local width = self:GetCharWidth( char )

        if width ~= 0 then
            return width + 1
        end

        return  0
    end

    ---@param char string
    ---@param dest unknown
    ---@param destStride integer
    ---@param x integer
    ---@param y integer
    function INSTANCE:BlitChar( char, dest, destStride, x, y )
        -- This function has no Garry's Mod equivalent
    end

    --- @return string
    function INSTANCE:GetCreatedFontName()
        return self.CreatedFontName
    end

    --- [[ Private ]]

    --- @class FontCharsInstance
    --- @field private SystemFontName string
    --- @field private CreatedFontName string Formerly called "Name"
    --- @field private CharHeight integer
    --- @field private PointSize integer
    --- @field private IsBold boolean
    --- @field private IsArialMt boolean Storing this so we don't have to re-evaluate it constantly
    --- @field private CharWidths table<string, integer> A map of characters to their widths
    
    --- @param fontName string
    --- @private
    function INSTANCE:CreateGdiFont( fontName )
        -- This function has no Garry's Mod equivalent
    end

        --- @private
    function INSTANCE:FreeGdiFont()
        -- This function has no Garry's Mod equivalent
    end

    --- @param char string
    --- @private
    function INSTANCE:StoreGdiChar( char )
        -- This function has no Garry's Mod equivalent
    end

    --- @param charWidth integer
    --- @private
    function INSTANCE:UpdateCurrentBuffer( charWidth )
        -- This function has no Garry's Mod equivalent
    end

    --- @param char string
    --- @private
    function INSTANCE:GetCharData( char )
        -- This function has no Garry's Mod equivalent
    end

    --- @param char string
    --- @private
    function INSTANCE:GrowUnicodeArray( char )
        -- This function has no Garry's Mod equivalent
    end

    --- @private
    function INSTANCE:FreeCharacterArrays()
        -- This function has no Garry's Mod equivalent
    end

end