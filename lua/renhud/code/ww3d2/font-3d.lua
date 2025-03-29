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

--[[ Static Functions and Variables ]] do

    --- [[ Public ]]

    --- @class Font3d


    --- [[ Protected ]]

    --- @class Font3d


    --- [[ Private ]]

    --- @class Font3d

end

--[[ Instanced Functions and Variables ]] do

    --- [[ Public ]]

    --- @class Font3dInstance

    --- Constructs a new Font3dInstance
    --- @param fontName string Originally a filepath called `path`
    function INSTANCE:Renegade_Font3d( fontName )
        print( "Font3D instance constructor called", fontName )
    end


    --- [[ Protected ]]

    --- @class Font3dInstance


    --- [[ Private ]]

    --- @class Font3dInstance

end