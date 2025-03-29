-- Based on Render2DTextClass within Code/ww3d2/render2d.cpp/h

-- #region Class Setup

--- @class Renegade
--- @field Render2dText Render2dText

--- The instanced components of Render2dText
--- @class Render2dTextInstance : Render2dInstance
local INSTANCE = robustclass.Register( "Renegade_Render2dText : Renegade_Render2d" )

--- The static components of Render2dText
--- @class Render2dText : Render2d
local STATIC = CNC_RENEGADE.Render2dText or setmetatable( {}, CNC_RENEGADE.Render2d )
CNC_RENEGADE.Render2dText = STATIC
-- #endregion

--[[ Static Functions and Variables ]] do
    --- @class Render2dText
end

--[[ Instanced Functions and Variables ]] do
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

    --- Constructs a new  Render2DTextInstance
    --- @param material IMaterial?
    function INSTANCE:Renegade_Render2dText( material )
        print( "Render 2D Text instance constructor called", material )
    end

    function INSTANCE:Reset()
        CNC_RENEGADE.Render2d.Instance.Reset( self )

        self.Cursor       = self.Location
        self.WrapWidth    = 0
        self.DrawExtents  = robustclass.New( "Renegade_Rect", 0, 0, 0, 0 )
        self.TotalExtents = robustclass.New( "Renegade_Rect", 0, 0, 0, 0 )
        self.ClipRect     = robustclass.New( "Renegade_Rect", 0, 0, 0, 0 )
    end

    ---@return Font3dInstance
    function INSTANCE:PeekFont()
        return self.Font
    end

    ---@param font string
    function INSTANCE:SetFont( font )
        error( "Function not implemented" )
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
    --- @param color Color
    function INSTANCE:DrawText( text, color )
        error( "Function not implemented" )
    end

    --- @param screen RectInstance
    --- @param color Color
    function INSTANCE:DrawBlock( screen, color )
        error( "Function not implemented" )
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
        error( "Function not implemented" )
    end
end