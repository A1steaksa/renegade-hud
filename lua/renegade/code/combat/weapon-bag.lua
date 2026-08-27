-- Based on WeaponBagClass within Code/Combat/weaponbag.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class WeaponBagClass
--- @field Instance WeaponBagInstance The metatable used by WeaponBagInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "WeaponBagClass"

--- @class WeaponBagInstance
--- @field Static WeaponBagClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_WeaponBag" )
INSTANCE.Class = "WeaponBagInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsWeaponBag = true

--#region Exported Enums
--#endregion

--#region Imports
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class WeaponBagClass

    --- Creates a new WeaponBagInstance
	--- @param owner ArmedGameObjectInstance
    --- @return WeaponBagInstance
    function STATIC.New( owner )
        return robustclass.New( "Renegade_WeaponBag", owner )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) WeaponBagInstance, `false` otherwise
    function STATIC.IsWeaponBag( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsWeaponBag and true or false
    end

    typecheck.RegisterType( "WeaponBagInstance", STATIC.IsWeaponBag )
end


--- @class WeaponBagInstance
--- @field Owner ArmedGameObjectInstance
--- @field WeaponList WeaponInstance[]
--- @field WeaponIndex integer
--- @field _IsChanged boolean
--- @field _HudIsChanged boolean

--- @param owner ArmedGameObjectInstance
function INSTANCE:Renegade_WeaponBag( owner )
    self.Owner = owner
    self.WeaponIndex = 0
    self._IsChanged = true
    self._HudIsChanged = true

    self.WeaponList = {}
end

function INSTANCE:_Renegade_WeaponBag()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:IsWeaponOwned()
	typecheck.NotImplementedError()
end

function INSTANCE:IsAmmoFull()
	typecheck.NotImplementedError()
end

function INSTANCE:AddWeapon()
	typecheck.NotImplementedError()
end

function INSTANCE:AddWeapon()
	typecheck.NotImplementedError()
end

--- @param index integer
function INSTANCE:RemoveWeapon( index )
	if index >= 1 and index <= #self.WeaponList then
		table.remove( self.WeaponList, index )
	end
end

function INSTANCE:ClearWeapons()
	typecheck.NotImplementedError()
end

--- @return integer
function INSTANCE:GetCount()
	return #self.WeaponList
end

--- @param index integer
--- @return WeaponInstance?
function INSTANCE:PeekWeapon( index )
	return self.WeaponList[index]
end

--- @return WeaponInstance?
function INSTANCE:GetWeapon()
	return self.WeaponList[self.WeaponIndex]
end

--- @return WeaponInstance?
function INSTANCE:GetNextWeapon()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportWeaponList()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportWeaponList()
	typecheck.NotImplementedError()
end

function INSTANCE:GetIndex()
	typecheck.NotImplementedError()
end

function INSTANCE:SelectIndex()
	typecheck.NotImplementedError()
end

function INSTANCE:SelectNext()
	typecheck.NotImplementedError()
end

function INSTANCE:SelectPrevious()
	typecheck.NotImplementedError()
end

function INSTANCE:SelectKeyNumber()
	typecheck.NotImplementedError()
end

function INSTANCE:SelectWeapon()
	typecheck.NotImplementedError()
end

function INSTANCE:SelectWeaponId()
	typecheck.NotImplementedError()
end

function INSTANCE:SelectWeaponName()
	typecheck.NotImplementedError()
end

function INSTANCE:Deselect()
	typecheck.NotImplementedError()
end

function INSTANCE:IsChanged()
	typecheck.NotImplementedError()
end

function INSTANCE:ForceChanged()
	typecheck.NotImplementedError()
end

function INSTANCE:ResetChanged()
	typecheck.NotImplementedError()
end

function INSTANCE:HudIsChanged()
	typecheck.NotImplementedError()
end

function INSTANCE:HudResetChanged()
	typecheck.NotImplementedError()
end

--- @param source WeaponBagInstance
function INSTANCE:MoveContents( source )
	typecheck.NotImplementedError()
end

function INSTANCE:StoreInventory()
	typecheck.NotImplementedError()
end

function INSTANCE:RestoreInventory()
	typecheck.NotImplementedError()
end

function INSTANCE:FindWeapon()
	typecheck.NotImplementedError()
end

function INSTANCE:MarkOwnerDirty()
	typecheck.NotImplementedError()
end
