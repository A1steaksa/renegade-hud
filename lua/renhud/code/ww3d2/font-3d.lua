-- Based on Font3DInstanceClass within Code/ww3d2/font3d.cpp/h

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Font3d
    --- @class Font3dInstance
    --- @field Static Font3d The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Font3d" )

    --- The static components of Font3d
    --- @class Font3d
    --- @field Instance Font3dInstance The Metatable used by Font3dInstance
    STATIC = CNC_RENEGADE.Font3d or {}
    CNC_RENEGADE.Font3d = STATIC

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
end

--#region Imports
    local font3dData    = CNC_RENEGADE.Font3dData
    local rect          = CNC_RENEGADE.Rect
--#endregion

--[[ Static Functions and Variables ]] do

    --- [[ Public ]]

    --- @class Font3d

    --- Creates a new Font3dInstance
    --- @param fontMaterial IMaterial
    --- @return Font3dInstance
    function STATIC.New( fontMaterial )
        return robustclass.New( "Renegade_Font3d", fontMaterial )
    end
end

--[[ Instanced Functions and Variables ]] do

    --- [[ Public ]]

    --- @class Font3dInstance

    --- Constructs a new Font3dInstance
    --- @param fontMaterial IMaterial
    function INSTANCE:Renegade_Font3d( fontMaterial )
        self.FontData = font3dData.New( self, fontMaterial )
        self.MonoSpacing = 0
        self.Scale = 1
        self.SpaceSpacing = self.FontData:GetCharWidth( "H" ) / 2
        self.InterCharSpacing = 1

        self.ScaledSpacingTable = {}
        self.ScaledWidthTable = {}

        self:BuildCachedTables()
    end

    --- @return IMaterial
    function INSTANCE:PeekMaterial()
        return self.FontData:PeekMaterial()
    end

    function INSTANCE:SetMonoSpaced()
        self.MonoSpacing = self.FontData:GetCharWidth( "W" ) + 1
        self:BuildCachedTables()
    end

    function INSTANCE:SetProportional()
        self.MonoSpacing = 0
        self:BuildCachedTables()
    end

    --- @param scale number
    function INSTANCE:SetScale( scale )
        self.Scale = scale
        self:BuildCachedTables()
    end

    --- @param char string
    --- @return number
    function INSTANCE:GetCharWidth( char )
        return self.ScaledWidthTable[ char ]
    end

    --- @param char string
    --- @return number
    function INSTANCE:GetCharSpacing( char )
        return self.ScaledSpacingTable[ char ]
    end

    --- @return number
    function INSTANCE:GetCharHeight()
        return self.ScaledHeight
    end

    --- @param text string
    --- @return number
    function INSTANCE:GetStringWidth( text )
        local width = 0

        for _, char in ipairs( string.Explode( "", text ) ) do
            width = width + self:GetCharSpacing( char )
        end

        return width
    end

    --- @param char string
    --- @return RectInstance
    function INSTANCE:GetCharUv( char )
        return rect.New(
            self.FontData:GetCharUOffset( char ),
            self.FontData:GetCharVOffset( char ),
            self.FontData:GetCharUOffset( char ) + self.FontData:GetCharUWidth( char ),
            self.FontData:GetCharVOffset( char ) + self.FontData:GetCharVHeight()
        )
    end

    --- [[ Private ]]

    --- @class Font3dInstance
    --- @field FontData Font3dDataInstance
    --- @field private SpaceSpacing number The unscaled width of a space, in pixels [Default: 1/2 'H' width]
    --- @field private InterCharSpacing number The unscaled width between characters, in pixels
    --- @field private MonoSpacing number The unscaled width between monospaced characters, in pixels (Set to `0` to disable monospacing)
    --- @field private ScaledWidthTable number[] The scaled cache of character widths, in pixels
    --- @field private ScaledSpacingTable number[] The scaled cache of character spacing, in pixels
    --- @field private ScaledHeight number The scaled height of characters, in pixels

    function INSTANCE:BuildCachedTables()
        for i = 0, 255 do
            local char = string.char( i )
            local width = self.FontData:GetCharWidth( char )
            if char == " " then
                width = self.SpaceSpacing
            end

            self.ScaledWidthTable[char] = self.Scale * width

            if self.MonoSpacing ~= 0 then
                self.ScaledSpacingTable[char] = self.Scale * self.MonoSpacing
            else
                self.ScaledSpacingTable[char] = self.Scale * ( width + self.InterCharSpacing )
            end
        end

        self.ScaledHeight = math.floor( self.Scale * self.FontData:GetCharHeight() )
    end
end