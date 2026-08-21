-- Based on ArmedGameObj within Code/Combat/armedgameobj.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type PhysicalGameObjectClass
local physicalGameObjectClass = CNC.Import( "code/combat/physical-game-object.lua" )

--- @class ArmedGameObjectClass : PhysicalGameObjectClass
--- @field Instance ArmedGameObjectInstance The metatable used by ArmedGameObjectInstance
local STATIC = CNC.CreateExport( physicalGameObjectClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "ArmedGameObjectClass"

--- @class ArmedGameObjectInstance : PhysicalGameObjectInstance
--- @field Static ArmedGameObjectClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_ArmedGameObject : Renegade_PhysicalGameObject" )
INSTANCE.Class = "ArmedGameObjectInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsArmedGameObject = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type WeaponBagClass
	local weaponBagClass = CNC.Import( "code/combat/weapon-bag.lua" )

	--- @type ClassUtils
	local classUtils = CNC.Import( "sh_class-utils.lua" )

	--- @type MuzzleRecoilClass
	local muzzleRecoilClass = CNC.Import( "code/combat/muzzle-recoil.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class ArmedGameObjectClass

	STATIC.MAX_MUZZLES = 4

    --- Creates a new ArmedGameObjectInstance
    --- @return ArmedGameObjectInstance
    function STATIC.New()
        return robustclass.New( "Renegade_ArmedGameObject" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) ArmedGameObjectInstance, `false` otherwise
    function STATIC.IsArmedGameObject( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsArmedGameObject and true or false
    end

    typecheck.RegisterType( "ArmedGameObjectInstance", STATIC.IsArmedGameObject )
end


--- @class ArmedGameObjectInstance
--- @field WeaponBag WeaponBagInstance
--- @field TargetingPos Vector
--- @field MuzzleA0Bone integer "YUCK!!!"
--- @field MuzzleA1Bone integer
--- @field MuzzleB0Bone integer
--- @field MuzzleB1Bone integer
--- @field MuzzleRecoilController MuzzleRecoilInstance[]

function INSTANCE:Renegade_ArmedGameObject()
	physicalGameObjectClass.Instance.Renegade_PhysicalGameObject( self )

	self.MuzzleRecoilController = classUtils.InitializeTypeArray( "Renegade_MuzzleRecoil", STATIC.MAX_MUZZLES )

	self.MuzzleA0Bone = 0
	self.MuzzleA1Bone = 0
	self.MuzzleB0Bone = 0
	self.MuzzleB1Bone = 0
	self.TargetingPos = Vector( 0, 0, 0 )
	self.WeaponBag = weaponBagClass.New( self )
end

function INSTANCE:_Renegade_ArmedGameObject()
	typecheck.NotImplementedError()
end

--- @param definition ArmedGameObjectDefinitionInstance
--- @param connectedEntity Entity
function INSTANCE:Init( definition, connectedEntity )
	physicalGameObjectClass.Instance.Init( self, definition, connectedEntity )
	INSTANCE.CopySettings( self, definition )
end

--- @param definition ArmedGameObjectDefinitionInstance
function INSTANCE:CopySettings( definition )
	local weapon
	if definition.WeaponDefinitionId ~= 0 then
		weapon = self.WeaponBag:AddWeapon( definition.WeaponDefinitionId, definition.WeaponRounds )
	end

	if definition.SecondaryWeaponDefinitionId ~= 0 then
		local secondaryWeapon = self.WeaponBag:AddWeapon( definition.SecondaryWeaponDefinitionId, definition.WeaponRounds )
		if weapon == nil then
			weapon = secondaryWeapon
		end
	end

	if weapon ~= nil then
		self.WeaponBag:SelectWeapon( weapon )
	end

	self:InitMuzzleBones()
end

function INSTANCE:ReInit()
	typecheck.NotImplementedError()
end

function INSTANCE:GetDefinition()
	typecheck.NotImplementedError()
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

function INSTANCE:OnPostLoad()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportFrequent()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportFrequent()
	typecheck.NotImplementedError()
end

function INSTANCE:ImportStateCs()
	typecheck.NotImplementedError()
end

function INSTANCE:ExportStateCs()
	typecheck.NotImplementedError()
end

function INSTANCE:PostThink()
	physicalGameObjectClass.Instance.PostThink( self )

	-- "Don't update if destroying... (so we don't create a new laser!)"
	if self:IsDeletePending() then
		return
	end

	-- "Update the weapon after the commands and [UpdateHumanAnimation]"
	if self:GetWeapon() ~= nil then
		self:GetWeapon():Update()
	end

	-- "Allow any recoil animation to progress"
	if self:PeekModel() ~= nil then
		for i = 1, STATIC.MAX_MUZZLES do
			self.MuzzleRecoilController[i]:Update( self:PeekModel() )
		end
	end
end

--- @return WeaponInstance?
function INSTANCE:GetWeapon()
	return self.WeaponBag:GetWeapon()
end

function INSTANCE:GetWeaponBag()
	typecheck.NotImplementedError()
end

function INSTANCE:MuzzleExists()
	typecheck.NotImplementedError()
end

function INSTANCE:GetMuzzle()
	typecheck.NotImplementedError()
end

function INSTANCE:StartRecoil()
	typecheck.NotImplementedError()
end

function INSTANCE:GetWeaponError()
	typecheck.NotImplementedError()
end

function INSTANCE:GetTargetingPos()
	typecheck.NotImplementedError()
end

--- @param pos Vector
--- @param doTilt boolean
--- @return boolean
function INSTANCE:SetTargeting( pos, doTilt )
	self.TargetingPos = pos
	-- "Move the turret to match the target"
	return true
end

function INSTANCE:AsArmedGameObject()
	typecheck.NotImplementedError()
end

function INSTANCE:InitMuzzleBones()
	self.MuzzleA0Bone = self:PeekModel():GetBoneIndex( "muzzlea0" )
	self.MuzzleA1Bone = self:PeekModel():GetBoneIndex( "muzzlea1" )
	self.MuzzleB0Bone = self:PeekModel():GetBoneIndex( "muzzleb0" )
	self.MuzzleB1Bone = self:PeekModel():GetBoneIndex( "muzzleb1" )

	if self.MuzzleA1Bone == 0 then
		self.MuzzleA1Bone = self.MuzzleA0Bone
	end
	if self.MuzzleB0Bone == 0 then
		self.MuzzleB0Bone = self.MuzzleA0Bone
	end
	if self.MuzzleB1Bone == 0 then
		self.MuzzleB1Bone = self.MuzzleB0Bone
	end

	self.MuzzleRecoilController[1]:Init( self.MuzzleA0Bone )
	self.MuzzleRecoilController[2]:Init( self.MuzzleA1Bone )
	self.MuzzleRecoilController[3]:Init( self.MuzzleB0Bone )
	self.MuzzleRecoilController[4]:Init( self.MuzzleB1Bone )

	-- "Let the weapon learn about muzzle flashes"
	if self:GetWeapon() then
		self:GetWeapon():SetModel( self:PeekModel() )
	end
end
