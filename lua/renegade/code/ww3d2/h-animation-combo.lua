-- Based on HAnimComboClass within Code/ww3d2/hanim.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class HAnimationComboClass
--- @field Instance HAnimationComboInstance The metatable used by HAnimationComboInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HAnimationComboClass"

--- @class HAnimationComboInstance
--- @field Static HAnimationComboClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HAnimationCombo" )
INSTANCE.Class = "HAnimationComboInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHAnimationCombo = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type HAnimationComboDataClass
	local hAnimationComboDataClass = CNC.Import( "code/ww3d2/h-animation-combo-data.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HAnimationComboClass

    --- Creates a new HAnimationComboInstance
	--- @param animationCount integer?
    --- @return HAnimationComboInstance
    function STATIC.New( animationCount )
        return robustclass.New( "Renegade_HAnimationCombo", animationCount )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HAnimationComboInstance, `false` otherwise
    function STATIC.IsHAnimationCombo( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHAnimationCombo and true or false
    end

    typecheck.RegisterType( "HAnimationComboInstance", STATIC.IsHAnimationCombo )
end


--- @class HAnimationComboInstance
--- @field HAnimationComboData HAnimationComboDataInstance[]

--- @param animationCount integer?
function INSTANCE:Renegade_HAnimationCombo( animationCount )
	-- ()
	if animationCount == nil then
		return
	end

	-- ( animationCount: integer )
	typecheck.AssertArgType( INSTANCE.Class, 1, animationCount, "number" )

	self.HAnimationComboData = {}
	for i = 1, animationCount do
		self.HAnimationComboData[i] = hAnimationComboDataClass.New()
	end
end

function INSTANCE:_Renegade_HAnimationCombo()
	self:Reset()
end

function INSTANCE:Clear()
	local numAnimations = #self.HAnimationComboData
	for i = numAnimations, 1, -1  do
		local data = self.HAnimationComboData[i]
		if data and not data:IsShared() then
			data:Clear()
		end
	end
end

function INSTANCE:Reset()
	self.HAnimationComboData = {}
end

function INSTANCE:NormalizeWeights()
	typecheck.NotImplementedError()
end

function INSTANCE:GetNumAnims()
	typecheck.NotImplementedError()
end

--- @param index integer
--- @param motion HAnimationInstance
function INSTANCE:SetMotion( index, motion )
	local data = self.HAnimationComboData[index]
	assert( data )
	data:SetHAnimation( motion )
end

--- @param index integer
--- @return HAnimationInstance?
function INSTANCE:GetMotion( index )
	local data = self.HAnimationComboData[index]
	assert( data )

	local anim = data:PeekHAnimation()
	return anim
end

--- @param index integer
--- @return HAnimationInstance?
function INSTANCE:PeekMotion( index )
	local data = self.HAnimationComboData[index]
	assert( data )

	local anim = data:PeekHAnimation()
	return anim
end

--- @param index integer
--- @param frame number 
function INSTANCE:SetFrame( index, frame )
	local data = self.HAnimationComboData[index]
	assert( data )

	data:SetFrame( frame )
end

--- @param index integer
--- @param frame number 
function INSTANCE:SetPreviousFrame( index, frame )
	local data = self.HAnimationComboData[index]
	assert( data )

	data:SetPreviousFrame( frame )
end

--- @param index integer
--- @return number
function INSTANCE:GetFrame( index )
	local data = self.HAnimationComboData[index]
	assert( data )

	return data:GetFrame()
end

--- @return number
function INSTANCE:GetPreviousFrame( index )
	local data = self.HAnimationComboData[index]
	assert( data )

	return data:GetPreviousFrame()
end

--- @param index integer
--- @param weight number
function INSTANCE:SetWeight( index, weight )
	local data = self.HAnimationComboData[index]
	assert( data )

	data:SetWeight( weight )
end

--- @param index integer
function INSTANCE:GetWeight( index )
	local data = self.HAnimationComboData[index]
	assert( data )

	return data:GetWeight()
end

--- @param index integer
--- @param map number[]
function INSTANCE:SetPivotWeightMap( index, map )
	local data = self.HAnimationComboData[index]
	assert( data )

	data:SetPivotMap( map )
end

--- @param index integer
function INSTANCE:GetPivotWeightMap( index )
	local data = self.HAnimationComboData[index]
	assert( data )

	return data:GetPivotMap()
end

--- @param index integer
function INSTANCE:PeekPivotWeightMap( index )
	local data = self.HAnimationComboData[index]
	assert( data )

	return data:PeekPivotMap()
end

--- @param data HAnimationComboDataInstance
function INSTANCE:AppendAnimationComboData( data )
	self.HAnimationComboData[#self.HAnimationComboData + 1] = data
end

--- @param data HAnimationComboDataInstance
function INSTANCE:RemoveAnimationComboData( data )
	table.RemoveByValue( self.HAnimationComboData, data )
end

function INSTANCE:PeekAnimationComboData()
	typecheck.NotImplementedError()
end
