-- The kernel file for the Command & Conquer Renegade HUD port

--- Finds all files within a directory and its sub-directories and call a function for each file, passing in the file's path 
--- @param name string
--- @param path string
--- @param func fun( filePath: string )
local function IterateFilesRecursively( name, path, func )
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

--[[ Shared Init ]] do
    --- The global table containing all addon content for Command and Conquer: Renegade
    --- @class Renegade
    CNC_RENEGADE = CNC_RENEGADE or {}

    -- Load prerequisite libraries
    include( "renhud/lua-libraries/robustclass.lua" )
    include( "renhud/lua-libraries/typecheck.lua" )
    include( "renhud/lua-libraries/imports.lua" )
    include( "renhud/lua-libraries/debugdraw.lua" )

    -- Load shared utilities
    include( "renhud/sh_info-entity.lua" )
end

--[[ Server Init ]]
if SERVER then
    -- Let clients know that we're running the server side of this addon`
    SetGlobal2Bool( "A1_Renegade_ServerRunning", true )

    -- Send all Lua files to clients
    IterateFilesRecursively( "renhud/", "LUA", AddCSLuaFile )

    -- Send all materials to the clients

    IterateFilesRecursively( "materials/renhud/", "THIRDPARTY", resource.AddFile )

    -- Send all fonts to the clients
    resource.AddFile( "resource/fonts/54251___.ttf" )
    resource.AddFile( "resource/fonts/ARI_____.ttf" )
end

--[[ Client Init ]]
if CLIENT then
    --- @class Renegade
    local CNC = CNC_RENEGADE

    hook.Add( "InitPostEntity", "A1_Renegade_ServerRunningCheck", function()
        CNC.IsServerEnabled = GetGlobal2Bool( "A1_Renegade_ServerRunning", false )

        local color
        local status
        if CNC.IsServerEnabled then
            color = Color( 43, 250, 100 )
            status = "Online"
        else
            color = Color( 250, 100, 43 )
            status = "Offline"
        end

        MsgC( "[REN] Server:\t", color, status, "\n" )
    end )

    -- Load Renegade-specific libraries
    include( "renhud/client/hide-hud.lua" )

    -- Load Renegade bridge libraries
    IterateFilesRecursively( "renhud/client/bridges/", "LUA", include )

    -- Load the game's kernel file
    --- @type CombatManager
    local combatManager = CNC.Import( "renhud/client/code/combat/combat-manager.lua" )

    -- Load Renegade-specific overrides
    include( "renhud/client/updated-global-settings.lua" )

    -- Start the HUD
    combatManager.Init( true )
end