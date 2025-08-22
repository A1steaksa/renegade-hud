-- Based on Render2DTextClass within Code/ww3d2/render2d.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Render2dText
    --- @class Render2dTextInstance : Render2dInstance
    --- @field Static Render2dText The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Render2dText : Renegade_Render2d" )

    --- An image-based text renderer
    --- The static components of Render2dText
    --- @class Render2dText : Render2d
    --- @field Instance Render2dTextInstance The Metatable used by Render2dTextInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsRender2dText = true
end


--#region Imports

    --- @type Render2d
    local render2d = CNC.Import( "renhud/client/code/ww3d2/render-2d.lua" )

    --- @type Rect
    local rect = CNC.Import( "renhud/client/code/wwmath/rect.lua" )
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "Render2dText"

    --- [[ Public ]]

    --- Creates a new Render2dTextInstance
    --- @param font Font3dInstance?
    --- @return Render2dTextInstance
    function STATIC.New( font )
        return robustclass.New( "Renegade_Render2dText", font )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) Render2dTextInstance, `false` otherwise
    function STATIC.IsRender2dText( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsRender2dText and true or false
    end

    typecheck.RegisterType( "Render2dTextInstance", STATIC.IsRender2dText )
end


--[[ Instanced Functions and Variables ]] do

    local CLASS = "Render2dTextInstance"

    --- [[ Public ]]

    --- @class Render2dTextInstance
    --- @field Font Font3dInstance
    --- @field Location Vector
    --- @field Cursor Vector
    --- @field WrapWidth number
    --- @field DrawExtents RectInstance
    --- @field TotalExtents RectInstance
    --- @field BlockUv RectInstance
    --- @field ClipRect RectInstance
    --- @field IsClippedEnabled boolean

    --- Constructs a new Render2DTextInstance
    --- @param font Font3dInstance
    function INSTANCE:Renegade_Render2dText( font )
        self.Location = Vector( 0, 0 )
        self.Cursor = Vector( 0, 0 )
        self.WrapWidth = 0
        self.ClipRect = rect.New( 0, 0, 0, 0 )
        self.IsClippedEnabled = false
        self.Font = nil

        self:Reset()

        self:SetFont( font )

        self:SetCoordinateRange( rect.New( -320, -240, 320, 240 ) )
    end

    function INSTANCE:Reset()
        render2d.Instance.Reset( self )

        self.Cursor       = self.Location
        self.WrapWidth    = 0
        self.DrawExtents  = robustclass.New( "Renegade_Rect", 0, 0, 0, 0 )
        self.TotalExtents = robustclass.New( "Renegade_Rect", 0, 0, 0, 0 )
        self.ClipRect     = robustclass.New( "Renegade_Rect", 0, 0, 0, 0 )
        self.IsClippedEnabled = false
    end

    ---@return Font3dInstance
    function INSTANCE:PeekFont()
        return self.Font
    end

    ---@param font Font3dInstance
    function INSTANCE:SetFont( font )
        self.Font = font
        self:SetMaterial( font:PeekMaterial() )

        self.BlockUv = font:GetCharUv( string.char( 0 ) )

        -- "Inset it a bit to be sure we have no edge problems" -Code/ww3d2/render2d.cpp#655
        self.BlockUv:Inflate( Vector(
            -self.BlockUv:Width() / 4,
            -self.BlockUv:Height() / 4
        ) )
    end

    ---@param char string
    ---@param color Color
    function INSTANCE:DrawChar( char, color )
        local cursor = self.Cursor
        local font = self.Font

        local charSpacing = font:GetCharSpacing( char )
        local charHeight = font:GetCharHeight()

        local isClipped = false
        if self.IsClippedEnabled and (
            cursor.x < self.ClipRect.Left or
            cursor.x + charSpacing < self.ClipRect.Right or
            cursor.y < self.ClipRect.Top or
            cursor.y + charHeight < self.ClipRect.Bottom
        ) then
            isClipped = true
        end

        if char ~= " " and not isClipped then
            local charRect = rect.New(
                cursor.x,
                cursor.y,
                cursor.x + font:GetCharWidth( char ),
                cursor.y + charHeight
            )

            local charUv = font:GetCharUv( char )
            
            -- Adding 0.5 to avoid off by one errors when flooring
            local fontAtlasWidth  = font:PeekMaterial():Width()  + 0.5
            local fontAtlasHeight = font:PeekMaterial():Height() + 0.5

            -- Make sure the UVs align with the pixels of the font atlas material
            charUv.Left   = math.floor( charUv.Left   * fontAtlasWidth  ) / fontAtlasWidth
            charUv.Top    = math.floor( charUv.Top    * fontAtlasHeight ) / fontAtlasHeight
            charUv.Right  = math.floor( charUv.Right  * fontAtlasWidth  ) / fontAtlasWidth
            charUv.Bottom = math.floor( charUv.Bottom * fontAtlasHeight ) / fontAtlasHeight

            self:InternalAddQuadVertices( charRect )
            self:InternalAddQuadUvs( charUv )
            self:InternalAddQuadColors( color )

            self.DrawExtents = self.DrawExtents + charRect
            self.TotalExtents = self.TotalExtents + charRect
        end

        cursor.x = cursor.x + charSpacing
    end

    ---@param pos Vector
    function INSTANCE:SetLocation( pos )
        self.Location = pos
        self.Cursor = pos
    end

    ---@param width number
    function INSTANCE:SetWrappingWidth( width )
        self.WrapWidth = width
    end

    --- @param rect RectInstance
    function INSTANCE:SetClippingRect( rect )
        self.ClipRect = rect
        self.IsClippedEnabled = true
    end

    --- @return boolean
    function INSTANCE:IsClippingEnabled()
        return self.IsClippedEnabled
    end

    function INSTANCE:EnableClipping( isClipping )
        self.IsClippedEnabled = isClipping
    end

    --- @param text string
    --- @param color Color? [Default: White]
    function INSTANCE:DrawText( text, color )
        if not color then
            color = Color( 255, 255, 255 )
        end

        local font = self.Font

        -- Reset extents
        self.DrawExtents = rect.New( self.Location, self.Location )
        if self.TotalExtents:Width() == 0 then
            self.TotalExtents = rect.New( self.Location, self.Location )
        end

        for _, char in ipairs( string.Explode( "", text ) ) do

            -- Check if we need to move to a new line
            local wrap = char == "\n"

            -- If we're at a space and the next word would put us past our max width, wrap
            -- if char == " " and self.WrapWidth > 0 then
            --     -- TODO: Implement this
            -- end

            if wrap then
                self.Cursor.y = self.Cursor.y + font:GetCharHeight()
                self.Cursor.x = self.Location.x
            else
                self:DrawChar( char, color )
            end
        end

        self.ShouldRebuildMesh = true
    end

    --- @param blockRect RectInstance
    --- @param color Color
    function INSTANCE:DrawBlock( blockRect, color )
        self:InternalAddQuadVertices( blockRect )
        self:InternalAddQuadUvs( self.BlockUv )
        self:InternalAddQuadColors( color )

        self.TotalExtents = self.TotalExtents + blockRect
    end

    --- @return RectInstance
    function INSTANCE:GetDrawExtents()
        return self.DrawExtents
    end

    --- @return RectInstance
    function INSTANCE:GetTotalExtents()
        return self.TotalExtents
    end

    --- @return Vector
    function INSTANCE:GetCursor()
        return self.Cursor
    end

    --- @param text string
    --- @return Vector
    function INSTANCE:GetTextExtents( text )
        local font = self.Font
        local extent = Vector( 0, font:GetCharHeight() )

        if text then
            for _, char in ipairs( string.Explode( "", text ) ) do
                if char ~= "\n" then
                    extent.x = extent.x + font:GetCharSpacing( char )
                end
            end
        end

        return extent
    end
end