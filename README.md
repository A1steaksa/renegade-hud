# The Goal

The goal is to recreate the HUD from Command & Conquer: Renegade as completely as possible in Garry's Mod by porting the relevant portions of the original game's source code to Lua.

# File List

The core of the HUD lives in `Code/Combat/hud.cpp/h` which depends on:

<details>
    <summary>
        Files to be fully or partially ported to Lua
    </summary>

## Status Legend

| Order | Status            | Meaning                                                                                               |
| ----- | ----------------- | ----------------------------------------------------------------------------------------------------- |
| 1     | Not Started       | No file has been created yet                                                                          |
| 2     | Created           | A file has been created, but it is missing some or all aspects of being stubbed                       |
| 3     | Stubbed           | The file contains class setup and placeholders for all of the original code's functions and variables |
| 4     | In Use            | Some of the functions or variables are filled in and are actively used by other files                 |
| 5     | Fully Ported      | Every function has been filled in and no placeholders remain                                          |

## File Statuses

*Note: This list is not exhaustive and will be added to as new dependencies are found.*

| Status | Path | C++ Link | Header Link |
| ------ | ---- | -------- | ----------- |
| Not Started | Code/Combat/assets             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/assets.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/assets.h)  
| Not Started | Code/ww3d2/font3d              | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/font3d.cpp)              | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/font3d.h)  
| Not Started | Code/WWMath/rect               | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/WWMath/rect.cpp)               | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/WWMath/rect.h)  
| Not Started | Code/Combat/combat             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/combat.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/combat.h)  
| Not Started | Code/Combat/soldier            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/soldier.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/soldier.h)  
| Not Started | Code/Combat/ccamera            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/ccamera.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/ccamera.h)  
| Not Started | Code/Combat/vehicle            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/vehicle.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/vehicle.h)  
| Not Started | Code/Combat/weapons            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weapons.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weapons.h)  
| Not Started | Code/Combat/radar              | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/radar.cpp)              | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/radar.h)  
| Not Started | Code/ww3d2/texture             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/texture.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/texture.h)  
| Not Started | Code/wwphys/phys               | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwphys/phys.cpp)               | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwphys/phys.h)  
| Not Started | Code/ww3d2/render2d            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2d.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2d.h)  
| Not Started | Code/Combat/hudinfo            | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/hudinfo.cpp)            | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/hudinfo.h)  
| Not Started | Code/Combat/globalsettings     | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/globalsettings.cpp)     | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/globalsettings.h)  
| Not Started | Code/wwtranslatedb/translatedb | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwtranslatedb/translatedb.cpp) | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwtranslatedb/translatedb.h)  
| Not Started | Code/Combat/playerdata         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playerdata.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playerdata.h)  
| Not Started | Code/Combat/playertype         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playertype.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/playertype.h)  
| Not Started | Code/Combat/sniper             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/sniper.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/sniper.h)  
| Not Started | Code/ww3d2/render2dsentence    | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2dsentence.cpp)    | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/ww3d2/render2dsentence.h)  
| Not Started | Code/Combat/input              | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/input.cpp)              | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/input.h)  
| Not Started | Code/Combat/building           | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/building.cpp)           | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/building.h)  
| Not Started | Code/Combat/objectives         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/objectives.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/objectives.h)  
| Not Started | Code/Combat/weaponbag          | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weaponbag.cpp)          | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/weaponbag.h)  
| Not Started | Code/Combat/string_ids         | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/string_ids.cpp)         | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/string_ids.h)  
| Not Started | Code/Combat/gametype           | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/gametype.cpp)           | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/Combat/gametype.h)  
| Not Started | Code/wwui/stylemgr             | [C++](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwui/stylemgr.cpp)             | [Header](https://github.com/A1steaksa/CnC_Renegade/blob/main/Code/wwui/stylemgr.h)  
</details>

# Breaking the HUD down

The HUD is made up of a few discrete sections within `Code/Combat/hud.cpp`:

* Powerup Notification Feed
* Weapon Info
* HUD Help Text
* Weapon Chart Display
* Damage Indicator
* Target Display
* Objective Display
* Health and Armor Info Display
* Reticles

## Powerup Notification Feed

[Original code available here](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L280-L569)

Two vertical lists of recently acquired items and objectives on the left and right edges of the screen.

![Pointing out the location of the powerup lists](https://github.com/user-attachments/assets/d730b43e-718d-4e85-967c-43a76180f14d)

Up to 5 icons 
    ([`MAX_ICONS`](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L310))
can be displayed on a list at any given time.  When an item has been visible for 6 seconds 
    ([`POWERUP_TIME`](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L311))
, its opacity begins to fade and all icons above it slide downward to replace it.

The left list contains notifications of new objectives, health and armor upgrades, and map visibility updates.

The right list contains health, armor, weapon, and ammo pickup notifications.

Each list item is comprised of:
* The name of the item or objective that was acquired
* A numerical quantity called "number" or "count" in the original code. (Visible on the right list only)
* The icon for the item or objective called "texture" in the original code. (Vertex colored green on the right list)

![Pointing out the elements of a powerup list element](https://github.com/user-attachments/assets/50607005-15e5-494e-8b54-c38e907d346c)

## Weapon Info

[Original code available here](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L572-L963)

Displays the currently equipped weapon and its ammo.

![Pointing out the location of the weapon info display](https://github.com/user-attachments/assets/5ea08ace-2fff-4d8f-8bcd-7fabeec5cb0e)

The elements of the weapon info display are:
* The green icon for the currently equipped weapon
* The name of the weapon
* The amount of ammo remaining in the weapon
* The amount of ammo of this weapon's type that the player has in reserve

![Pointing out the elements of the weapon info display](https://github.com/user-attachments/assets/ccab928f-c956-4a90-ab04-502e9516a73b)

## HUD Help Text

[Original code available here](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L593-L697)

Green help text that appears slightly above the center of the screen to inform the player of information that can't easily be communicated with iconography alone.

![Pointing out the location of the help text](https://github.com/user-attachments/assets/efe4b98b-d5fa-4b14-baa0-591009d94443)

After the text has been on-screen for 2 seconds
([`HUD_HELP_TEXT_DISPLAY_TIME`](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L615)),
it begins to fade away over the course of 2 additional seconds
([`HUD_HELP_TEXT_FADE_TIME`](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L614)).

## Weapon Chart Display

[Original code available here](https://github.com/A1steaksa/CnC_Renegade/blob/d0e4fde48468faee2ea84e35c21874647a5bbded/Code/Combat/hud.cpp#L966-L1197)

Shows the weapons in the player's inventory while switching weapons to help the player navigate their inventory.

![Pointing out the location of the weapon chart](https://github.com/user-attachments/assets/383d6b23-36de-45ad-aacc-f7e9703cff2f)

The elements of the weapon chart are:
* The column header (The number key the column corresponds to)
* Green icons for each weaopn (More opaque if it's the icon of the currently selected weapon)

![Pointing out the elements of the weapon chart](https://github.com/user-attachments/assets/77dbd9fb-cae3-48c4-ad25-0495b85409c9)

## Damage Indicator

## Target Display

## Objective Display

## Health and Armor Info Display

## Reticles
