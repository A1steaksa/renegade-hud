-- Based on HAnimComboDataClass within Code/ww3d2/hanim.h

--- @class Renegade
local CNC = CNC_RENEGADE


--- @class HAnimationComboDataClass
--- @field Instance HAnimationComboDataInstance The metatable used by HAnimationComboDataInstance
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HAnimationComboDataClass"

--- @class HAnimationComboDataInstance
--- @field Static HAnimationComboDataClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HAnimationComboData" )
INSTANCE.Class = "HAnimationComboDataInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHAnimationComboData = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type HAnimationClass
	local hAnimationClass = CNC.Import( "code/ww3d2/h-animation.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HAnimationComboDataClass

    --- Creates a new HAnimationComboDataInstance
    --- @return HAnimationComboDataInstance
    function STATIC.New()
        return robustclass.New( "Renegade_HAnimationComboData" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HAnimationComboDataInstance, `false` otherwise
    function STATIC.IsHAnimationComboData( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHAnimationComboData and true or false
    end

    typecheck.RegisterType( "HAnimationComboDataInstance", STATIC.IsHAnimationComboData )
end


--- "  
--- The HAnimComboDataClass is used by the new HAnimComboClass to allow for a mix of shared/unshared data
--- which will allow us to have the anim combo refer to data whereever we wish to put it.  
--- "  
--- @class HAnimationComboDataInstance
--- @field HAnimation HAnimationInstance
--- @field Frame number
--- @field PreviousFrame number
--- @field Weight number
--- @field PivotMap number[]
--- @field Shared boolean "This is set to false when the HAnimCombo allocates it"

--- @param shared boolean? [Default: `false`]
--- @overload fun( src: HAnimationComboDataInstance )
function INSTANCE:Renegade_HAnimationComboData( shared )
	if shared == nil then shared = false end

	-- ( shared: boolean? )
	if typecheck.IsOfType( shared, "boolean" ) then

		self.Shared = shared
		self.HAnimation = hAnimationClass.New()
		self.PivotMap = {}
		self.Frame = 0
		self.PreviousFrame = 0
		self.Weight = 1

		return
	end

	-- ( src: HAnimationComboDataInstance )
	typecheck.AssertArgType( INSTANCE.Class, 1, shared, "HAnimationComboDataInstance" )
	local src = shared --[[@as HAnimationComboDataInstance]]

	self.PivotMap = src:GetPivotMap()
	self.HAnimation = src:GetHAnimation()

	self.Shared = src:IsShared()
	self.Frame = src:GetFrame()
	self.PreviousFrame = src:GetPreviousFrame()
	self.Weight = src:GetWeight()
end

function INSTANCE:_Renegade_HAnimationComboData()
	self.HAnimation = nil
	self.PivotMap = nil
end

--- @param src HAnimationComboDataInstance?
function INSTANCE:Copy( src )
	if src then
		self.HAnimation    = src:GetHAnimation()
		self.PivotMap      = src:GetPivotMap()
		self.Frame         = src:GetFrame()
		self.PreviousFrame = src:GetPreviousFrame()
		self.Weight        = src:GetWeight()
	else
		self.HAnimation    = hAnimationClass.New()
		self.PivotMap      = {}
		self.Frame         = 0
		self.PreviousFrame = 0
		self.Weight        = 1
	end
end

function INSTANCE:Clear()
	self.HAnimation = nil

	-- "Not sure if the pivot map should be deleted or just have everything set to one."
	-- "Removing it effectively sets it to one, so that's what I'm doing for now."
	if self.PivotMap then
		self.PivotMap = nil
	end

	self.Frame = 0.0
	self.PreviousFrame = 0.0
	self.Weight = 1.0
	self.PivotMap = nil
end

--- @param motion HAnimationInstance
function INSTANCE:SetHAnimation( motion )
	self.HAnimation = motion
end

--- "Used for giving this object the reference"
--- @param motion HAnimationInstance
function INSTANCE:GiveHAnimation( motion )
	if self.HAnimation then
		self.HAnimation = motion
	end
end

--- @param frame number
function INSTANCE:SetFrame( frame )
	self.PreviousFrame = frame
	self.Frame = frame
end

--- @param frame number
function INSTANCE:SetPreviousFrame( frame )
	self.PreviousFrame = frame
end

--- @param weight number
function INSTANCE:SetWeight( weight )
	self.Weight = weight
end

--- @param map number[]
function INSTANCE:SetPivotMap( map )
	self.PivotMap = map
end

--- @return HAnimationInstance
function INSTANCE:PeekHAnimation()
	return self.HAnimation
end

--- @return HAnimationInstance
function INSTANCE:GetHAnimation()
	return self.HAnimation
end

--- @return number
function INSTANCE:GetFrame()
	return self.Frame
end

--- @return number
function INSTANCE:GetPreviousFrame()
	return self.PreviousFrame
end

--- @return number
function INSTANCE:GetWeight()
	return self.Weight
end

--- @return number[]
function INSTANCE:PeekPivotMap()
	return self.PivotMap
end

--- @return number[]
function INSTANCE:GetPivotMap()
	return self.PivotMap
end

--- @return boolean
function INSTANCE:IsShared()
	return self.Shared
end

--- " 
--- This function will replace the current pivot map (if any) with another pivot map that is
--- set to 1 for only those pivot indices that actually have data.
--- "
function INSTANCE:BuildActivePivotMap()
	if self.PivotMap ~= nil then
		self.PivotMap = nil
	end

	if self.HAnimation == nil then
		self.PivotMap = {}
		return
	end

	local numPivots = self.HAnimation:GetNumPivots()
	self.PivotMap = {}

	local count = 1
	while count <= numPivots do
		if self.HAnimation:IsNodeMotionPresent( count ) then
			self.PivotMap[#self.PivotMap + 1] = 1
		else
			self.PivotMap[#self.PivotMap + 1] = 0
		end

		count = count + 1
	end
end
