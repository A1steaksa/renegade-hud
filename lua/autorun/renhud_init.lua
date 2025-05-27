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


--[[ Server Init ]]
if SERVER then

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

    --- The global table containing all addon content for Command and Conquer: Renegade
    --- @class Renegade
    CNC_RENEGADE = CNC_RENEGADE or {}

    local CNC = CNC_RENEGADE

    -- Load prerequisite libraries
    include( "renhud/lua-libraries/robustclass.lua" )
    include( "renhud/lua-libraries/typecheck.lua" )

    -- Load Renegade-specific libraries
    include( "renhud/imports.lua" )
    include( "renhud/buildings.lua" )
    include( "renhud/hide-hud.lua" )

    -- Load the game's kernel file
    --- @type CombatManager
    local combatManager = CNC.Import( "renhud/code/combat/combat-manager.lua" )

    -- Load Renegade-specific overrides
    include( "renhud/updated-global-settings.lua" )

    -- Start the HUD
    combatManager.Init( true )
end