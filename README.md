# The Goal

The goal is to recreate the HUD from Command & Conquer: Renegade as completely as possible in Garry's Mod by porting the relevant portions of the original game's source code to Lua.

# File List

The core of the HUD lives in `Code/Combat/hud.cpp/h` which depends on:

<details>
    <summary>
        Files to be fully or partially ported to Lua
    </summary>

| Status | Path | C++ Link | Header Link |
| ------ | ---- | -------- | ----------- |
| 🔴 | Code/Combat/assets             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/assets.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/assets.h)  
| 🔴 | Code/ww3d2/font3d              | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/font3d.cpp)              | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/font3d.h)  
| 🔴 | Code/WWMath/rect               | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/WWMath/rect.cpp)               | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/WWMath/rect.h)  
| 🔴 | Code/Combat/combat             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/combat.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/combat.h)  
| 🔴 | Code/Combat/soldier            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/soldier.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/soldier.h)  
| 🔴 | Code/Combat/ccamera            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/ccamera.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/ccamera.h)  
| 🔴 | Code/Combat/vehicle            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/vehicle.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/vehicle.h)  
| 🔴 | Code/Combat/weapons            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weapons.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weapons.h)  
| 🔴 | Code/Combat/radar              | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/radar.cpp)              | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/radar.h)  
| 🔴 | Code/ww3d2/texture             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/texture.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/texture.h)  
| 🔴 | Code/wwphys/phys               | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwphys/phys.cpp)               | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwphys/phys.h)  
| 🔴 | Code/ww3d2/render2d            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2d.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2d.h)  
| 🔴 | Code/Combat/hudinfo            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/hudinfo.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/hudinfo.h)  
| 🔴 | Code/Combat/globalsettings     | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/globalsettings.cpp)     | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/globalsettings.h)  
| 🔴 | Code/wwtranslatedb/translatedb | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwtranslatedb/translatedb.cpp) | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwtranslatedb/translatedb.h)  
| 🔴 | Code/Combat/playerdata         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playerdata.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playerdata.h)  
| 🔴 | Code/Combat/playertype         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playertype.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playertype.h)  
| 🔴 | Code/Combat/sniper             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/sniper.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/sniper.h)  
| 🔴 | Code/ww3d2/render2dsentence    | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2dsentence.cpp)    | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2dsentence.h)  
| 🔴 | Code/Combat/input              | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/input.cpp)              | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/input.h)  
| 🔴 | Code/Combat/building           | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/building.cpp)           | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/building.h)  
| 🔴 | Code/Combat/objectives         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/objectives.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/objectives.h)  
| 🔴 | Code/Combat/weaponbag          | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weaponbag.cpp)          | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weaponbag.h)  
| 🔴 | Code/Combat/string_ids         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/string_ids.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/string_ids.h)  
| 🔴 | Code/Combat/gametype           | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/gametype.cpp)           | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/gametype.h)  
| 🔴 | Code/wwui/stylemgr             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwui/stylemgr.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwui/stylemgr.h)  
</details>

# Breaking the HUD down

The HUD is made up of a few discrete sections within `Code/Combat/hud.cpp`:

* Powerup (Pickups) Notification Feed
* Weapon Info
* HUD Help Text
* Weapon Chart Display
* Damage Indicator
* Target Display
* Objective Display
* Health and Armor Info Display
* Reticles
