-- Based on Code/ww3d2/ww3d.cpp/h

--- @class Renegade
--- @field WW3d WW3d

CNC_RENEGADE.WW3d = CNC_RENEGADE.WW3d or {}

--- @class WW3d
--- @field _IsScreenUvBiased boolean Whether or not all 2D rendering should be slightly moved to be off of the pixel grid
local STATIC = CNC_RENEGADE.WW3d

--#region Static Functions and Values

--- @param isBiased boolean `true` if 2D rendering should be biased, `false` otherwise
function STATIC.SetScreenUvBias( isBiased )
    STATIC._IsScreenUvBiased = isBiased
end

--- @return boolean `true` if 2D rendering should be biased, `false` otherwise
function STATIC.IsScreenUvBiased()
    return STATIC._IsScreenUvBiased
end

--#endregion