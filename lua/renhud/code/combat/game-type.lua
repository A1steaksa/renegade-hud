-- Based on GameType within Code/Combat/gametype.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

local STATIC

--[[ Class Setup ]] do

    --- The static components of GameType
    --- @class GameType
    STATIC = CNC.CreateExport()
end


--#region Enums

    --- @enum GameTypeEnum
    STATIC.GAME_TYPE_ENUM = {
        NONE      = 0, -- Unassigned
        MISSION   = 1, -- Traditional soloplay
        SKIRMISH  = 2, -- C&C practice against AI
        MULTIPLAY = 3, -- C&C against humans
    }
    local gameTypeEnum = STATIC.GAME_TYPE_ENUM
--#endregion


--[[ Static Functions and Variables ]] do

    local CLASS = "GameType"

    --- [[ Public ]]

    ---@param gameType GameTypeEnum
    function STATIC.SetGameType( gameType )
        STATIC.GameType = gameType
    end

    ---@return GameTypeEnum
    function STATIC.GetGameType()
        return STATIC.GameType
    end

    --- @return boolean
    function STATIC.IsMission()
        return STATIC.GameType == gameTypeEnum.MISSION
    end

    --- @return boolean
    function STATIC.IsSkirmish()
        return STATIC.GameType == gameTypeEnum.SKIRMISH
    end

    --- @return boolean
    function STATIC.IsMultiplay()
        return STATIC.GameType == gameTypeEnum.MULTIPLAY
    end

    --- @return boolean
    function STATIC.IsSoloplay()
        return STATIC.GameType ~= gameTypeEnum.MULTIPLAY
    end


    --- [[ Private ]]

    --- @class GameType
    --- @field GameType GameTypeEnum

    STATIC.GameType = gameTypeEnum.NONE
end