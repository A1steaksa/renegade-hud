if CLIENT then
    --- The table containing all addon content for Command and Conquer: Renegade
    --- @class Renegade
    CNC_RENEGADE = CNC_RENEGADE or {}
end

local function RunCS( filePath )
    AddCSLuaFile( filePath )

    if CLIENT then
        MsgC( "Running " .. filePath .. "...", "\n" )
        include( filePath )
    end
end

local clientScripts = {
    -- Lua Libraries
    "renhud/lua-libraries/robustclass.lua",

    -- data/*
    "renhud/data/style-manager.lua",

    -- code/wmath/*
    "renhud/code/wwmath/rect.lua",

    -- Lua Library that relies on rect
    "renhud/lua-libraries/typecheck.lua",

    -- code/ww3d2/*
    "renhud/code/ww3d2/ww3d.lua",
    "renhud/code/ww3d2/render-2d.lua",
    "renhud/code/ww3d2/font-3d.lua",
    "renhud/code/ww3d2/render-2d-sentence.lua",
    "renhud/code/ww3d2/render-2d-text.lua",

    -- code/combat/*
    "renhud/code/combat/global-settings.lua",
    "renhud/code/combat/combat-manager.lua",
    "renhud/code/combat/hud.lua",
    "renhud/code/combat/objectives.lua",
    
    -- code/combat/wwtranslatedb/*
    "renhud/code/wwtranslatedb/translatedb.lua"
}

-- Client Scripts
for _, filePath in ipairs( clientScripts ) do
    RunCS( filePath )
end

if SERVER then
    local files = {
        -- Fonts
        "resource/fonts/54251___.ttf",
        "resource/fonts/ARI_____.ttf",

        -- HUD Materials
        "materials/renhud/font6x8.png",
        "materials/renhud/font12x16.png",
        "materials/renhud/hd_reticle_hit.png",
        "materials/renhud/hud_armedal.png",
        "materials/renhud/hud_armor1.png",
        "materials/renhud/hud_armor2.png",
        "materials/renhud/hud_armor3.png",
        "materials/renhud/hud_cd_rom.png",
        "materials/renhud/hud_chatpbox.png",
        "materials/renhud/hud_driverseat.png",
        "materials/renhud/hud_gunseat.png",
        "materials/renhud/hud_health1.png",
        "materials/renhud/hud_health2.png",
        "materials/renhud/hud_health3.png",
        "materials/renhud/hud_hemedal.png",
        "materials/renhud/hud_keycard_green.png",
        "materials/renhud/hud_keycard_red.png",
        "materials/renhud/hud_keycard_yellow.png",
        "materials/renhud/hud_main.png",
        "materials/renhud/hud_obje_arrow.png",
        "materials/renhud/hud_passseat.png",
        "materials/renhud/hud_star.png",
        "materials/renhud/p_eva1.png",
        "materials/renhud/p_eva2.png"
    }

    for _, file in ipairs( files ) do
        resource.AddFile( file )
    end
end