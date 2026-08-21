-- Based on HumanAnimControlClass within Code/Combat/animcontrol.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type AnimationControlClass
local animationControlClass = CNC.Import( "code/combat/animation-control.lua" )

--- @class HumanAnimationControlClass : AnimationControlClass
--- @field Instance HumanAnimationControlInstance The metatable used by HumanAnimationControlInstance
local STATIC = CNC.CreateExport( animationControlClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "HumanAnimationControlClass"

--- @class HumanAnimationControlInstance : AnimationControlInstance
--- @field Static HumanAnimationControlClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_HumanAnimationControl : Renegade_AnimationControl" )
INSTANCE.Class = "HumanAnimationControlInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsHumanAnimationControl = true

--#region Exported Enums

	--- @type EnumBuilderClass
	local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

	local enumBuilder = enumBuilderClass.New()

    --- @enum AnimationControlAnimationMode
	STATIC.ANIMATION_CONTROL_ANIMATION_MODE = {
		ANIM_MODE_ONCE	 = enumBuilder:Set( 0 ),
		ANIM_MODE_LOOP	 = enumBuilder:Next(),
        ANIM_MODE_STOP   = enumBuilder:Next(),
        ANIM_MODE_TARGET = enumBuilder:Next(),
    }

	--- @enum HumanStateType
	STATIC.HUMAN_STATE_TYPE = {
		-- "Interruptable states"
		UPRIGHT	  = enumBuilder:Set( 0 ),
		LAND	  = enumBuilder:Next(),
		ANIMATION = enumBuilder:Next(),
		WOUNDED	  = enumBuilder:Next(),
		LOITER	  = enumBuilder:Next(),

		-- "Uninterruptable states"
		AIRBORNE            = enumBuilder:Next(),
		DIVE                = enumBuilder:Next(),
		DEATH               = enumBuilder:Next(),
		LADDER              = enumBuilder:Next(),
		IN_VEHICLE          = enumBuilder:Next(),
		TRANSITION          = enumBuilder:Next(),
		TRANSITION_COMPLETE = enumBuilder:Next(),
		DESTROY             = enumBuilder:Next(),
		DEBUG_FLY           = enumBuilder:Next(),
		ON_FIRE             = enumBuilder:Next(),
		ON_CHEM             = enumBuilder:Next(),
		ON_ELECTRIC         = enumBuilder:Next(),
		ON_CNC_FIRE         = enumBuilder:Next(),
		ON_CNC_CHEM         = enumBuilder:Next(),
		LOCKED_ANIMATION    = enumBuilder:Next(),

		HIGHEST_HUMAN_STATE = -1
	}
	local humanStateTypeEnum = STATIC.HUMAN_STATE_TYPE
	humanStateTypeEnum.HIGHEST_HUMAN_STATE = humanStateTypeEnum.LOCKED_ANIMATION

	--- @enum HumanStateFlagsType
	STATIC.HUMAN_STATE_FLAGS_TYPE = {
        CROUCHED_FLAG = bit.lshift( 1, 0 ),
        SNIPING_FLAG  = bit.lshift( 1, 1 ),
        HIGHEST_HUMAN_STATE_FLAGS = bit.lshift( 1, 2 ) - 1,
	}
    local humanStateFlagsType = STATIC.HUMAN_STATE_FLAGS_TYPE

	--- @enum HumanSubStateType
	STATIC.HUMAN_SUB_STATE_TYPE = {
        SUB_STATE_FORWARD       = bit.lshift( 1, 0 ),
        SUB_STATE_BACKWARD      = bit.lshift( 1, 1 ),
        SUB_STATE_UP            = bit.lshift( 1, 2 ),
        SUB_STATE_DOWN          = bit.lshift( 1, 3 ),
        SUB_STATE_LEFT          = bit.lshift( 1, 4 ),
        SUB_STATE_RIGHT         = bit.lshift( 1, 5 ),
        SUB_STATE_TURN_LEFT     = bit.lshift( 1, 6 ),
        SUB_STATE_TURN_RIGHT    = bit.lshift( 1, 7 ),
        SUB_STATE_SLOW          = bit.lshift( 1, 8 ),
        HIGHEST_HUMAN_SUB_STATE = bit.lshift( 1, 9 ) - 1
	}
    local humanSubStateType = STATIC.HUMAN_SUB_STATE_TYPE

	--- @enum HumanOuchType
	STATIC.HUMAN_OUCH_TYPE = {
        HEAD_FROM_BEHIND      = enumBuilder:Set( 0 ),
        HEAD_FROM_FRONT       = enumBuilder:Next(),
        TORSO_FROM_BEHIND     = enumBuilder:Next(),
        TORSO_FROM_FRONT      = enumBuilder:Next(),
        LEFT_ARM_FROM_BEHIND  = enumBuilder:Next(),
        LEFT_ARM_FROM_FRONT   = enumBuilder:Next(),
        RIGHT_ARM_FROM_BEHIND = enumBuilder:Next(),
        RIGHT_ARM_FROM_FRONT  = enumBuilder:Next(),
        LEFT_LEG_FROM_BEHIND  = enumBuilder:Next(),
        LEFT_LEG_FROM_FRONT   = enumBuilder:Next(),
        RIGHT_LEG_FROM_BEHIND = enumBuilder:Next(),
        RIGHT_LEG_FROM_FRONT  = enumBuilder:Next(),
        GROIN                 = enumBuilder:Next(),
        OUCH_FIRE             = enumBuilder:Next(),
        OUCH_CHEM             = enumBuilder:Next(),
        OUCH_ELECTRIC         = enumBuilder:Next(),
        OUCH_SUPER_FIRE       = enumBuilder:Next(),
	}
    local humanOuchType = STATIC.HUMAN_OUCH_TYPE

    --- @enum HumanAnimationLegStyle
    STATIC.HUMAN_ANIM_LEG_STYLE = {
        LEG_STYLE_STAND                = enumBuilder:Set( 0 ), -- "A0"
        LEG_STYLE_RUN_FORWARD          = enumBuilder:Next(), -- "A1"
        LEG_STYLE_RUN_BACKWARD         = enumBuilder:Next(), -- "A2"
        LEG_STYLE_RUN_LEFT             = enumBuilder:Next(), -- "A3"
        LEG_STYLE_RUN_RIGHT            = enumBuilder:Next(), -- "A4"
        LEG_STYLE_TURN_LEFT            = enumBuilder:Next(), -- "A5"
        LEG_STYLE_TURN_RIGHT           = enumBuilder:Next(), -- "A6"
        LEG_STYLE_WALK_FORWARD         = enumBuilder:Next(), -- "B1"
        LEG_STYLE_WALK_BACKWARD        = enumBuilder:Next(), -- "B2"
        LEG_STYLE_WALK_LEFT            = enumBuilder:Next(), -- "B3"
        LEG_STYLE_WALK_RIGHT           = enumBuilder:Next(), -- "B4"
        LEG_STYLE_CROUCH               = enumBuilder:Next(), -- "C0"
        LEG_STYLE_CROUCH_MOVE_FORWARD  = enumBuilder:Next(), -- "C1"
        LEG_STYLE_CROUCH_MOVE_BACKWARD = enumBuilder:Next(), -- "C2"
        LEG_STYLE_CROUCH_MOVE_LEFT     = enumBuilder:Next(), -- "C3"
        LEG_STYLE_CROUCH_MOVE_RIGHT    = enumBuilder:Next(), -- "C4"
        LEG_STYLE_CROUCH_TURN_LEFT     = enumBuilder:Next(), -- "C3"
        LEG_STYLE_CROUCH_TURN_RIGHT    = enumBuilder:Next(), -- "C4"
        LEG_STYLE_JUMP_UP              = enumBuilder:Next(), -- "D0"
        LEG_STYLE_JUMP_FORWARD         = enumBuilder:Next(), -- "D1"
        LEG_STYLE_JUMP_BACKWARD        = enumBuilder:Next(), -- "D2"
        LEG_STYLE_JUMP_LEFT            = enumBuilder:Next(), -- "D3"
        LEG_STYLE_JUMP_RIGHT           = enumBuilder:Next(), -- "D4"
    }
    local humanAnimationLegStyle = STATIC.HUMAN_ANIM_LEG_STYLE

--#endregion

--#region Imports

	--- @type HAnimationComboClass
	local hAnimationComboClass = CNC.Import( "code/ww3d2/h-animation-combo.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type HAnimationComboDataClass
	local hAnimationComboDataClass = CNC.Import( "code/ww3d2/h-animation-combo-data.lua" )

	--- @type BlendableAnimationChannelClass
	local blendableAnimationChannelClass = CNC.Import( "code/combat/blendable-animation-channel.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class HumanAnimationControlClass

    STATIC.LegAnimationNames = {
        "A0", --- "LEG_STYLE_STAND"
        "A1", --- "LEG_STYLE_RUN_FORWARD"
        "A2", --- "LEG_STYLE_RUN_BACKWARD"
        "A3", --- "LEG_STYLE_RUN_LEFT"
        "A4", --- "LEG_STYLE_RUN_RIGHT"
        "A5", --- "LEG_STYLE_TURN_LEFT"
        "A6", --- "LEG_STYLE_TURN_RIGHT"
        "B1", --- "LEG_STYLE_WALK_FORWARD"
        "B2", --- "LEG_STYLE_WALK_BACKWARD"
        "B3", --- "LEG_STYLE_WALK_LEFT"
        "B4", --- "LEG_STYLE_WALK_RIGHT"
        "C0", --- "LEG_STYLE_CROUCH"
        "C1", --- "LEG_STYLE_CROUCH_MOVE_FORWARD"
        "C2", --- "LEG_STYLE_CROUCH_MOVE_BACKWARD"
        "C3", --- "LEG_STYLE_CROUCH_MOVE_LEFT"
        "C4", --- "LEG_STYLE_CROUCH_MOVE_RIGHT"
        "C5", --- "LEG_STYLE_CROUCH_TURN_LEFT"
        "C6", --- "LEG_STYLE_CROUCH_TURN_RIGHT"
        "J0", --- "LEG_STYLE_JUMP_UP"
        "J1", --- "LEG_STYLE_JUMP_FORWARD"
        "J2", --- "LEG_STYLE_JUMP_BACKWARD"
        "J3", --- "LEG_STYLE_JUMP_LEFT"
        "J4", --- "LEG_STYLE_JUMP_RIGHT"
    }

    STATIC.WeaponStyleNames = {
        "A0", --- "WEAPON_HOLD_STYLE_C4"
        "A0", --- "WEAPON_HOLD_STYLE_NOT_USED"
        "C2", --- "WEAPON_HOLD_STYLE_AT_SHOULDER"
        "D2", --- "WEAPON_HOLD_STYLE_AT_HIP"
        "E2", --- "WEAPON_HOLD_STYLE_LAUNCHER"
        "F2", --- "WEAPON_HOLD_STYLE_HANDGUN"
        "A0", --- "WEAPON_HOLD_STYLE_BEACO"
        "A0", --- "WEAPON_HOLD_STYLE_EMPTY_HANDS"
        "B0", --- "WEAPON_HOLD_STYLE_AT_CHEST"
        "A0", --- "WEAPON_HOLD_STYLE_HANDS_DOWN"
    }

    STATIC.DiveAnimations = {
        -- "Forwrd Anims"
		"S_A_HUMAN.H_A_SLD1_01",
		"S_A_HUMAN.H_A_SLD1_02",

        -- "Backward anims"
        "S_A_HUMAN.H_A_SLD2_01",
        "S_A_HUMAN.H_A_SLD2_02",

        -- "Left anims"
        "S_A_HUMAN.H_A_SLD3_01",
        "S_A_HUMAN.H_A_SLD3_02",

        -- "Right Anims"
        "S_A_HUMAN.H_A_SLD4_01",
        "S_A_HUMAN.H_A_SLD4_02",
    }

    STATIC.WoundAnimations = {
        "S_A_HUMAN.H_A_811A",	-- "HEAD_FROM_BEHIND"       
        "S_A_HUMAN.H_A_812A",	-- "HEAD_FROM_FRONT"        
        "S_A_HUMAN.H_A_821A",	-- "TORSO_FROM_BEHIND"      
        "S_A_HUMAN.H_A_822A",	-- "TORSO_FROM_FRONT"       
        "S_A_HUMAN.H_A_831A",	-- "LEFT_ARM_FROM_BEHIND"   
        "S_A_HUMAN.H_A_832A",	-- "LEFT_ARM_FROM_FRONT"    
        "S_A_HUMAN.H_A_841A",	-- "RIGHT_ARM_FROM_BEHIND"  
        "S_A_HUMAN.H_A_842A",	-- "RIGHT_ARM_FROM_FRONT"   
        "S_A_HUMAN.H_A_851A",	-- "LEFT_LEG_FROM_BEHIND"   
        "S_A_HUMAN.H_A_852A",	-- "LEFT_LEG_FROM_FRONT"    
        "S_A_HUMAN.H_A_861A",	-- "RIGHT_LEG_FROM_BEHIND"  
        "S_A_HUMAN.H_A_862A",	-- "RIGHT_LEG_FROM_FRONT"   
        "S_A_HUMAN.H_A_871A",	-- "GROIN"                  
    }

    STATIC.DeathAnimations = {
        "S_A_HUMAN.H_A_622A",	-- "HEAD_FROM_BEHIND"
        "S_A_HUMAN.H_A_635A",	-- "HEAD_FROM_FRONT"
        "S_A_HUMAN.H_A_622A",	-- "TORSO_FROM_BEHIND"
        "S_A_HUMAN.H_A_632A",	-- "TORSO_FROM_FRONT"
        "S_A_HUMAN.H_A_623A",	-- "LEFT_ARM_FROM_BEHIND"
        "S_A_HUMAN.H_A_634A",	-- "LEFT_ARM_FROM_FRONT"
        "S_A_HUMAN.H_A_624A",	-- "RIGHT_ARM_FROM_BEHIND"
        "S_A_HUMAN.H_A_633A",	-- "RIGHT_ARM_FROM_FRONT"
        "S_A_HUMAN.H_A_623A",	-- "LEFT_LEG_FROM_BEHIND"
        "S_A_HUMAN.H_A_634A",	-- "LEFT_LEG_FROM_FRONT"
        "S_A_HUMAN.H_A_624A",	-- "RIGHT_LEG_FROM_BEHIND"
        "S_A_HUMAN.H_A_633A",	-- "RIGHT_LEG_FROM_FRONT"
        "S_A_HUMAN.H_A_612A",	-- "GROIN"
        "S_A_HUMAN.H_A_FLMB",	-- "ON_FIRE"
        "S_A_HUMAN.H_A_FLMB",	-- "ON_CHEM"
        "S_A_HUMAN.H_A_FLMB",	-- "ON_ELECTRIC"
        "S_A_HUMAN.H_A_FLMB",	-- "ON_CNC_FIRE"
        "S_A_HUMAN.H_A_FLMB",	-- "ON_CNC_CHEM"
    }

    --- Creates a new HumanAnimationControlInstance
    --- @return HumanAnimationControlInstance
    function STATIC.New()
        return robustclass.New( "Renegade_HumanAnimationControl" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) HumanAnimationControlInstance, `false` otherwise
    function STATIC.IsHumanAnimationControl( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsHumanAnimationControl and true or false
    end

    typecheck.RegisterType( "HumanAnimationControlInstance", STATIC.IsHumanAnimationControl )
end

--- @class HumanAnimationControlInstance
--- @field Channel1 BlendableAnimationChannelInstance
--- @field Channel2 BlendableAnimationChannelInstance
--- @field Channel2Ratio number
--- @field AnimationSpeedScale number
--- @field DataList AnimationDataRecordStruct[]
--- @field AnimationCombo HAnimationComboInstance
--- @field Skeleton string

function INSTANCE:Renegade_HumanAnimationControl()
    animationControlClass.Instance.Renegade_AnimationControl( self )

    self.Channel1 = blendableAnimationChannelClass.New()
    self.Channel2 = blendableAnimationChannelClass.New()

    self.DataList = {}

    self.AnimationCombo = hAnimationComboClass.New( 2 )
    self.Channel2Ratio = 0
    self.Skeleton = "A"
    self.AnimationSpeedScale = 1
end

function INSTANCE:_Renegade_HumanAnimationControl()
    -- Empty in the original code
end

function INSTANCE:Save()
	typecheck.NotImplementedError()
end

function INSTANCE:Load()
	typecheck.NotImplementedError()
end

--- @param animationModel RenderObjectInstance?
function INSTANCE:SetModel( animationModel )
	animationControlClass.Instance.SetModel( self, animationModel )

    -- "Update the skeleton"
    if animationModel ~= nil then
        local tree = animationModel:GetHTree()
        if tree ~= nil then
            local name = tree:GetName()
            self.Skeleton = name:sub( 3, 3 )
        end
    end
end

--- @overload fun( self, name: string, blendTime: number?, startFrame: number? )
--- @overload fun( self, animation: HAnimationInstance, blendTime: number?, startFrame: number? )
--- @overload fun( self, name1: string, name2: string, ratio: number, blendTime: number? )
function INSTANCE:SetAnimation( ... )
    local args = {...}
    local argCount = select( "#", ... )

    typecheck.AssertArgCount( INSTANCE.Class, argCount, { 3, 4 } )

    local arg1 = args[1]

    if argCount == 3 then

        -- ( name: string, blendTime: number?, startFrame: number? )
        if typecheck.IsOfType( arg1, "string" ) then
            local name       = arg1    --[[@as string]]
            local blendTime  = args[2] --[[@as number]] or 0.0
            local startFrame = args[3] --[[@as number]] or 0.0

            typecheck.AssertArgType( INSTANCE.Class, 1, name,       "string" )
            typecheck.AssertArgType( INSTANCE.Class, 2, blendTime,  "number" )
            typecheck.AssertArgType( INSTANCE.Class, 3, startFrame, "number" )

            local newName = self:BuildSkeletonAnimationName( name )

            self.Channel1:SetAnimation( newName, blendTime, startFrame )
            self.Channel2:SetAnimation( nil )
            self.Channel2Ratio = 0
            return

        -- ( animation: HAnimationInstance, blendTime: number?, startFrame: number? )
        else
            local animation  = arg1    --[[@as HAnimationInstance]]
            local blendTime  = args[2] --[[@as number]] or 0.0
            local startFrame = args[3] --[[@as number]] or 0.0

            typecheck.AssertArgType( INSTANCE.Class, 1, animation,  "HAnimationInstance" )
            typecheck.AssertArgType( INSTANCE.Class, 2, blendTime,  "number" )
            typecheck.AssertArgType( INSTANCE.Class, 3, startFrame, "number" )

            if animation ~= nil then
                self:SetAnimation( animation:GetName(), blendTime, startFrame )
            else
                self:SetAnimation( nil, blendTime, startFrame )
            end
            return
        end
    end

    -- ( name1: string, name2: string, ratio: number, blendTime: number? )
    if argCount == 4 then
        local name1     = arg1    --[[@as string]]
        local name2     = args[2] --[[@as string]]
        local ratio     = args[3] --[[@as number]]
        local blendTime = args[4] --[[@as number]] or 0.0

        typecheck.AssertArgType( INSTANCE.Class, 1, name1,     "string" )
        typecheck.AssertArgType( INSTANCE.Class, 2, name2,     "string" )
        typecheck.AssertArgType( INSTANCE.Class, 3, ratio,     "number" )
        typecheck.AssertArgType( INSTANCE.Class, 4, blendTime, "number" )

        local newName1 = self:BuildSkeletonAnimationName( name1 )
        local newName2 = self:BuildSkeletonAnimationName( name2 )

        if ratio == 0 then
            self:SetAnimation( newName1, blendTime )
            return
        end

        if self.Channel2Ratio == 0 then
            self.Channel2 = self.Channel1
        end

        self.Channel1:SetAnimation( newName1, blendTime )
        self.Channel2:SetAnimation( newName2, blendTime )

        self.Channel2Ratio = ratio
        return
    end
end

--- @param mode AnimationControlAnimationMode
--- @param frame number? [Default: -1]
function INSTANCE:SetMode( mode, frame )
    if frame == nil then frame = -1 end

    self.Channel1:SetMode( mode, frame )
    self.Channel2:SetMode( mode, frame )
end

--- @return AnimationControlAnimationMode
function INSTANCE:GetMode()
    return self.Channel1:GetMode()
end

--- @return boolean
function INSTANCE:IsComplete()
	return self.Channel1:IsComplete()
end

--- @return string
function INSTANCE:GetAnimationName()
	return self.Channel1:GetAnimationName()
end

--- @return number
function INSTANCE:GetFrame()
    return self.Channel1:GetFrame()
end

--- @return number
function INSTANCE:GetProgress()
	return self.Channel1:GetProgress()
end

--- @param frame number
function INSTANCE:SetTargetFrame( frame )
	self.Channel1:SetTargetFrame( frame )
end

--- @return number
function INSTANCE:GetTargetFrame()
    return self.Channel1:GetTargetFrame()
end

--- @return number
function INSTANCE:GetCurrentFrame()
	return self.Channel1:GetFrame()
end

--- @param speed number
function INSTANCE:SetAnimationSpeedScale( speed )
	self.AnimationSpeedScale = speed
end

--- @param deltaTime number
function INSTANCE:Update( deltaTime )
    -- "Update channels"
    self.Channel1:Update( deltaTime * self.AnimationSpeedScale )
    self.Channel2:Update( deltaTime * self.AnimationSpeedScale )

    if self.Model ~= nil then
        -- "Get Animation data"
        table.Add( self.DataList, self.Channel1:GetAnimationData( 1 - self.Channel2Ratio ) )
        table.Add( self.DataList, self.Channel2:GetAnimationData( self.Channel2Ratio ) )

        -- "Use the cheapest anim method possible"
        local totalAnimations = #self.DataList

        if totalAnimations == 0 then
            self.Model:SetAnimation()
        elseif totalAnimations == 1 then
            self.Model:SetAnimation( self.DataList[1].Animation, self.DataList[1].Frame )
        elseif totalAnimations == 2 then
            local percent = self.DataList[2].Weight / ( self.DataList[1].Weight + self.DataList[2].Weight )
            self.Model:SetAnimation(
                self.DataList[1].Animation,
                self.DataList[1].Frame,
                self.DataList[2].Animation,
                self.DataList[2].Frame,
                percent
            )
        else
            -- "Set up anim combo"
            self.AnimationCombo:Reset()
            for i = 1, totalAnimations do
                local data = self.DataList[i]
                local animationData = hAnimationComboDataClass.New()
                animationData:SetHAnimation( data.Animation )
                animationData:SetFrame( data.Frame )
                animationData:SetWeight( data.Weight )
                self.AnimationCombo:AppendAnimationComboData( animationData )
            end

            -- "Setup the model for the current frame(s)
            self.Model:SetAnimation( self.AnimationCombo )
        end

        -- Omitted animation monitoring code
    end

end

--- @return HAnimationInstance
function INSTANCE:PeekAnimation()
    return self.Channel1:PeekAnimation()
end

function INSTANCE:GetInformation()
	typecheck.NotImplementedError()
end

function INSTANCE:GetSkeleton()
    return self.Skeleton
end

--- @param name string
--- @return string?
function INSTANCE:BuildSkeletonAnimationName( name )
    if name == nil then
        section.Warn( "No name in BuildSkeletonAnimationName" )
        return
    end
    local newName = name

    -- "Special case for visceroids"
    if self.Skeleton == "V" then
        return
    end

    -- "If the anim doesn't start with 'S_A_HUMAN,', add it"
    if not name:StartsWith( "S_" ) then
        newName = string.format( "S_%c_HUMAN.%s", self.Skeleton, name )
    end

    -- "If the anim name is 'S_A_HUMAN.H_A_*', and the Skeleton is not 'A', use the other skeleton anim, if found"
    if #newName > 14 and self.Skeleton ~= "A" and newName:StartsWith( "S_A_HUMAN.H_A_" ) then
        local modName = newName
        modName = modName:sub( 1, 2 ) .. self.Skeleton .. modName:sub( 4, 12 ) .. self.Skeleton .. modName:sub( 14 )

        -- "Can we find the anim name?"
        local anim = ww3dAssetManagerClass.GetInstance():GetHAnimation( modName )
        if anim ~= nil then
            newName = modName
        end
    end

    return newName
end
