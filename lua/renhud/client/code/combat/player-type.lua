-- Based on PlayerType within Code/Combat/playertype.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of PlayerType
    --- @class PlayerType
    STATIC = CNC.CreateExport()
end

--#region Enums

--- @enum PlayerTypeEnum
STATIC.PLAYER_TYPE_ENUM = {
    Spectator = -4,
    Mutant    = -3,
    Neutral   = -2,
    Renegade  = -1,
    Nod       =  0,
    GDI       =  1,
    Combine   =  2,
    Rebels    =  3,
    BlackMesa =  4,
    HECU      =  5,
    Aperture  =  6
}
local playerTypeEnum = STATIC.PLAYER_TYPE_ENUM
--#endregion


--[[ Static Functions and Variables ]] do
    local CLASS = "PlayerType"

    --- [[ Public ]]

    --- @class PlayerType

    --- @param type1 PlayerTypeEnum
    --- @param type2 PlayerTypeEnum
    --- @return boolean
    function STATIC.PlayerTypesAreEnemies( type1, type2 )

        -- "if either are a spectator or neutral, they are not enemies"
        if type1 == playerTypeEnum.Neutral or type2 == playerTypeEnum.Neutral then
            return false
        end

        if type1 == playerTypeEnum.Spectator or type2 == playerTypeEnum.Spectator then
            return false
        end

        -- "if either is Renegade, they are enemies"
        if type1 == playerTypeEnum.Renegade or type2 == playerTypeEnum.Renegade then
            return true
        end

        -- "iff they are not the same type, they are enemies"
        return ( type1 ~= type2 )
    end

    --- @param type PlayerTypeEnum
    --- @return string
    function STATIC.PlayerTypeName( type )
        return STATIC.PlayerTypeNames[ type ]
    end


    --- [[ Private ]]

    --- @class PlayerType

    --- @private
    STATIC.PlayerTypeNames = {
        [ playerTypeEnum.Spectator ] = "Spectator",
        [ playerTypeEnum.Mutant    ] = "Mutant",
        [ playerTypeEnum.Neutral   ] = "Neutral",
        [ playerTypeEnum.Renegade  ] = "Renegade",
        [ playerTypeEnum.Nod       ] = "NOD",
        [ playerTypeEnum.GDI       ] = "GDI",
        [ playerTypeEnum.Combine   ] = "Combine",
        [ playerTypeEnum.Rebels    ] = "Rebels",
    }
end