-- This class supports the HUD's target info box

--- @class Renegade
local CNC = CNC_RENEGADE

local LIB

--[[ Class Setup ]] do

    --- The static components of HudInfoUtilsShared
    --- @class HudInfoUtilsShared
    LIB = CNC.CreateExport()
end


--[[ Static Functions and Variables ]] do
    local CLASS = "HudInfoUtilsShared"

    --- @class HudInfoUtilsShared

    --- @type table<string, boolean|fun( ent:Entity ):boolean>
    LIB.BlacklistedClasses = {
        ["func_wall"]             = true,
        ["func_brush"]            = true,
        ["func_lod"]              = true,
        ["func_reflective_glass"] = true,
        ["func_breakable_surf"]   = true, -- Shatterable glass in Renegade does not get targeted
    }

    --- Determines if a given Entity can be targeted by the HUD
    --- @param ent Entity?
    --- @return boolean
    function LIB.IsTargetable( ent )
        if not IsValid( ent ) then return false end
        --- @cast ent Entity

        local class = ent:GetClass():lower()
        local blacklistEntry = LIB.BlacklistedClasses[class]

        if blacklistEntry then
            if isfunction( blacklistEntry ) then
                --- @cast blacklistEntry fun( ent: Entity ): boolean
                return blacklistEntry( ent )
            else
                --- @cast blacklistEntry boolean
                return not blacklistEntry
            end
        end

        return true
    end

end