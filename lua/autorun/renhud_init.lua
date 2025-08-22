-- The kernel file for the Command & Conquer Renegade HUD port

--- Finds all files within a directory and its sub-directories and call a function for each file, passing in the file's path 
--- @param name string
--- @param path string
--- @param func fun( filePath: string )
local function IterateFilesRecursively( name, path, func )
    if not string.EndsWith( name, "/" ) then name = name .. "/" end
    local files, directories = file.Find( name .. "*", path )

    -- Run the function on each file in the directory
    for _, file in ipairs( files ) do
        func( name .. file )
    end

    -- Recurse on each sub-directory
    for _, directory in ipairs( directories ) do
        local nextDir = name .. directory .. "/"
        IterateFilesRecursively( nextDir, path, func )
    end
end

--- Finds all files within a directory and call a function for each file, passing in the file's path 
--- @param name string
--- @param path string
--- @param func fun( filePath: string )
local function IterateFiles( name, path, func )
    if not string.EndsWith( name, "/" ) then name = name .. "/" end
    local files, directories = file.Find( name .. "*", path )

    -- Run the function on each file in the directory
    for _, file in ipairs( files ) do
        func( name .. file )
    end
end

--- The global table containing all addon content for Command and Conquer: Renegade
--- @class Renegade
CNC_RENEGADE = CNC_RENEGADE or {}
local isHotload = table.Count( CNC_RENEGADE ) ~= 0

--[[ Server Setup ]]
if SERVER then
    -- Load ConVars
    include( "renhud/server/sv_convars.lua" )

    -- Let clients know that we're running the server side of this addon
    SetGlobal2Bool( "A1_Renegade_ServerRunning", true )

    -- Send Lua files to clients
    IterateFilesRecursively( "renhud/client/", "LUA", AddCSLuaFile )
    IterateFiles( "renhud/lua-libraries/", "LUA", AddCSLuaFile )
    IterateFiles( "renhud/", "LUA", AddCSLuaFile )

    -- Send all materials to the clients
    IterateFilesRecursively( "materials/renhud/", "THIRDPARTY", resource.AddFile )

    -- Send all fonts to the clients
    resource.AddFile( "resource/fonts/54251___.ttf" )
    resource.AddFile( "resource/fonts/ARI_____.ttf" )
end

--[[ Client Setup ]]
if CLIENT then
    -- Load ConVars
    include( "renhud/client/cl_convars.lua" )
end

--[[ Shared Init ]] do

    -- Load prerequisite libraries
    include( "renhud/lua-libraries/robustclass.lua" )
    include( "renhud/lua-libraries/typecheck.lua" )
    include( "renhud/lua-libraries/imports.lua" )
    include( "renhud/lua-libraries/debugdraw.lua" )

    -- Load shared utilities
    include( "renhud/sh_info-entity.lua" )
    include( "renhud/sh_damage.lua" )
end

--[[ Client Init ]]
if CLIENT then
    --- @class Renegade
    local CNC = CNC_RENEGADE

    --- @type StyleManager
    local styleManager = CNC.Import( "renhud/client/code/wwui/style-manager.lua" )

    --- @type FontsLib
    local fontsLib = CNC.Import( "renhud/client/cl_fonts.lua" )

    -- Hide the default HUD
    -- TODO: Replace this with a per-element system in a menu somewhere that ties in with ConVars for enabling/disabling individual HUD elements
    include( "renhud/client/cl_hide-hud.lua" )

    -- Load Renegade bridge libraries
    IterateFiles( "renhud/client/bridges/", "LUA", include )

    -- Begin creating fonts because they are a prerequisite for the rest of the HUD
    styleManager.Initialize()

    local function StartHud()

        -- Ensure that fonts have loaded and that the player exists
        if not IsValid( LocalPlayer() ) then return end
        if not fontsLib.IsFontCreated( styleManager.DefaultFonts[ styleManager.FONT_STYLE.FONT_INGAME_TXT ] ) then return end

        -- Check if the server is running the HUD
        CNC.IsServerEnabled = GetGlobal2Bool( "A1_Renegade_ServerRunning", false )
        MsgC( "[REN] HUD Server is ", ( CNC.IsServerEnabled and Color( 43, 250, 100 ) or Color( 250, 100, 43 ) ), ( CNC.IsServerEnabled and "Online" or "Offline" ), "\n" )

        -- Load the game's kernel file
        --- @type CombatManager
        local combatManager = CNC.Import( "renhud/client/code/combat/combat-manager.lua" )

        -- Load overrides for Renegade's default settings
        include( "renhud/client/cl_updated-global-settings.lua" )

        -- Start the HUD
        combatManager.Init( true )

        hook.Remove( "PostRender", "A1_Renegade_Init_StartHud" )
    end

    hook.Add( "PostRender", "A1_Renegade_Init_StartHud", StartHud )
end