-- Based on GameModeManager within Code/Commando/gamemode.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class GameModeManagerClass
local STATIC = CNC.CreateExport()
STATIC.Class = "GameModeManagerClass"
local isHotload = not table.IsEmpty( STATIC )


--#region Exported Enums
--#endregion


--#region Imports

    --- @type DialogManagerClass
    local dialogManagerClass = CNC.Import( "code/wwui/dialog-manager.lua" )

    --- @type ObjectiveManagerClass
    local objectiveManagerClass = CNC.Import( "code/combat/objective-manager.lua" )

    --- @type CombatManagerClass
    local combatManagerClass = CNC.Import( "code/combat/combat-manager.lua" )

    ---@type GameModeClass
    local gameModeClass = CNC.Import( "code/commando/game-mode.lua" )
--#endregion


--#region Imported Enums

    local gameModeStateEnum = gameModeClass.GAME_MODE_STATE
--#endregion

--- "An object to maintain a list of all GameModes"
--- @class GameModeManagerClass

--- @type GameModeInstance[]
STATIC.GameModeList = {}
STATIC.BackgroundColor = Color( 0, 0, 0 )
STATIC._HiddenFrameCount = 0

--- @param mode GameModeInstance
--- @return GameModeInstance
function STATIC.Add( mode )
    STATIC.GameModeList[#STATIC.GameModeList + 1] = mode
    return mode
end

--- @param mode GameModeInstance
function STATIC.Remove( mode )
    table.RemoveByValue( STATIC.GameModeList, mode )
end

--- @return integer
function STATIC.Count()
    return #STATIC.GameModeList
end

--- @param mode GameModeInstance
function STATIC.Destroy( mode )
    assert( mode ~= nil )

    mode:Deactivate()
    mode:SafelyDeactivate()
    STATIC.Remove( mode )
end

function STATIC.DestroyAll()
    while STATIC.Count() ~= 0 do
        STATIC.Destroy( STATIC.GameModeList[#STATIC.GameModeList] )
    end
end

-- "Diagnostic"
function STATIC.ListActiveGameModes()
    section.Start( "Active game modes:" )

    for _, gameMode in ipairs( STATIC.GameModeList ) do
        assert( gameMode ~= nil )

        if gameMode:IsActive() then
            section.Print( gameMode:Name() )
        end
    end

    section.End()
end

--- @param color Color
function STATIC.SetBackgroundColor( color )
    STATIC.BackgroundColor = color
end

--- "Let all non-inactive, game modes think"
function STATIC.Think()
    for _, gameMode in ipairs( STATIC.GameModeList ) do
        if not gameMode:IsInactive() then
            gameMode:Think()
        end

        -- "If required"
        gameMode:SafelyDeactivate()
    end

    -- Omitted BINKMovie update
end

--- "Let all non-inactive, game modes draw"
function STATIC.Render()
    if not CLIENT then return end

    render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD )

    render.PushFilterMin( TEXFILTER.POINT )
    render.PushFilterMag( TEXFILTER.POINT )

    -- Omitting hidden frames

    -- Omitting mesh debugger

    -- Omitting pre-processing combat scene

    -- Omitting begin render

    -- Omitting focus checking
    for _, gameMode in ipairs( STATIC.GameModeList ) do
        if gameMode:GetState() ~= gameModeStateEnum.GAME_MODE_INACTIVE then
            gameMode:Render()
        end
    end

    local messageWindow = combatManagerClass.GetMessageWindow()
    if messageWindow then
        messageWindow:Render()
    end

    -- objectiveManagerClass.RenderViewer()

    -- dialogManagerClass.Render()

    -- cDiagnosticsClass.Render()

    -- Omitted BINKMovie render

    -- Omitted end render

    -- Omitted post-processing combat scene

    -- Omitted thread switch

    -- Omitted hidden frames

    render.PopFilterMag()
    render.PopFilterMin()

    render.OverrideBlend( false )
end

--- "Find a registered game mode by name"
--- @param name string
--- @return GameModeInstance?
function STATIC.Find( name )
    for _, gameMode in ipairs( STATIC.GameModeList ) do
        if gameMode:Name() == name then
            return gameMode
        end
    end
end

-- "This method safely deactives any inactive pending mode without attempting a think"
function STATIC.SafelyDeactivate()
    for k, gameMode in ipairs( STATIC.GameModeList ) do
        assert( gameMode ~= nil )

        -- "If required"
        gameMode:SafelyDeactivate()
    end
end

--- "Hide rendering for n frames"
--- @param frameCount integer
function STATIC.HideRenderedFrames( frameCount )
    STATIC._HiddenFrameCount = frameCount
end