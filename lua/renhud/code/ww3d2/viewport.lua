-- Based on ViewportClass within Code/ww3d2/camera.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC, INSTANCE

--[[ Class Setup ]] do

    --- The instanced components of Viewport  
    --- "This class is used to define a "normalized" screen space rectangle for the camera to render into.
    --- A viewport which filled the entire screen would be 
    --- (0,0) - (1,1) with 0,0 being the upper left and 1,1 being the lower right."
    --- @class ViewportInstance
    --- @field Static Viewport The static table for this instance's class
    INSTANCE = robustclass.Register( "Renegade_Viewport" )

    --- The static components of Viewport
    --- @class Viewport
    --- @field Instance ViewportInstance The Metatable used by ViewportInstance
    STATIC = CNC.CreateExport()

    STATIC.Instance = INSTANCE
    INSTANCE.Static = STATIC
    INSTANCE.IsViewport = true
end


--[[ Static Functions and Variables ]] do

    local CLASS = "Viewport"

    --- [[ Public ]]

    --- @class Viewport

    --- Creates a new ViewportInstance
    --- @overload fun() : ViewportInstance
    --- @overload fun( min: Vector, max: Vector ): ViewportInstance
    --- @overload fun( viewport: ViewportInstance ): ViewportInstance
    function STATIC.New( ... )
        return robustclass.New( "Renegade_Viewport", ... )
    end

    ---@param arg any
    ---@return boolean `true` if the passed argument is a(n) ViewportInstance, `false` otherwise
    function STATIC.IsViewport( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsViewport
    end

    typecheck.RegisterType( "ViewportInstance", STATIC.IsViewport )
end


--[[ Instanced Functions and Variables ]] do

    local CLASS = "ViewportInstance"

    --- [[ Public ]]

    --- @class ViewportInstance
    --- @field Min Vector
    --- @field Max Vector

    --- Constructs a new ViewportInstance
    function INSTANCE:Renegade_Viewport( ... )
        local args = { ... }
        local argCount = select( "#", ... )

        -- ( nil )
        if argCount == 0 then
            self.Min = Vector( 0, 0 )
            self.Max = Vector( 1, 1 )
            return
        end

        -- ( viewport: Viewport )
        if argCount == 1 then
            local viewport = args[1] --[[@as ViewportInstance]]
            typecheck.AssertArgType( CLASS, 1, viewport, "Viewport" )

            self.Min = viewport.Min
            self.Max = viewport.Max
            return
        end

        -- ( min: Vector, max: Vector )
        if argCount == 2 then
            local min = args[1] --[[@as Vector]]
            local max = args[2] --[[@as Vector]]

            typecheck.AssertArgType( CLASS, 1, min, "Vector" )
            typecheck.AssertArgType( CLASS, 2, max, "Vector" )

            self.Min = min
            self.max = max
            return
        end

        typecheck.AssertArgCount( CLASS, argCount )
    end

    function INSTANCE:Width()
        return self.Max.x - self.Min.x
    end

    function INSTANCE:Height()
        return self.Max.y - self.Min.y
    end
end