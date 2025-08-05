-- This file contains code to bridge the gap between Garry's Mod camera view and C&C Renegade 

--- @class Renegade
local CNC = CNC_RENEGADE

--- Parent class
--- @type CommonBridge
local commonBridge = CNC.Import( "renhud/client/bridges/common.lua" )

--- @class CameraBridge : CommonBridge
local LIB = setmetatable( CNC.CreateExport(), { __index = commonBridge } )


--[[ Static Functions and Variables ]] do

    local CLASS = "CameraBridge"

    --- @class CameraBridge
    --- @field ViewOverride ViewSetup

    --- [[ Public ]]

    function LIB.ClearDebugView()
        LIB.ViewOverride = nil
    end

    --- @param viewSetup ViewSetup?
    function LIB.SetViewOverride( viewSetup )

        if not viewSetup then
            viewSetup = render.GetViewSetup() --[[@as ViewSetup]]
        end

        LIB.ViewOverride = viewSetup
    end

    function LIB.ToggleViewOverride()
        if LIB.ViewOverride then
            LIB.ClearDebugView()
        else
            LIB.SetViewOverride()
        end
    end

    concommand.Add( "ren_toggle_debug_view", LIB.ToggleViewOverride )

    --- @return ViewSetup
    function LIB.GetViewSetup()
        local viewSetup = render.GetViewSetup() --[[@as ViewSetup]]

        if LIB.ViewOverride then
            return LIB.ViewOverride
        end

        return viewSetup
    end
end