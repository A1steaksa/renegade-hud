-- Create and manages Soldier GameObjects for Players

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class PlayerManager
local STATIC = CNC.CreateExport()
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "PlayerManager"

--#region Exported Enums
--#endregion

--#region Imports

	--- @type SoldierGameObjectClass
	local soldierGameObjectClass = CNC.Import( "code/combat/soldier-game-object.lua" )

	--- @type DefinitionManagerClass
	local definitionManagerClass = CNC.Import( "code/wwsaveload/definition-manager.lua" )

	--- @type UnitConversionLib
	local unitConversionLib = CNC.Import( "sh_unit-conversion.lua" )

	--- @type QuaternionClass
	local quaternionClass = CNC.Import( "code/wwmath/quaternion.lua" )

	--- @type RenderInfoClass
	local renderInfoClass = CNC.Import( "code/ww3d2/render-info.lua" )

	--- @type CombatManagerClass
	local combatManagerClass = CNC.Import( "code/combat/combat-manager.lua" )

	--- @type GameObjectManagerClass
	local gameObjectManagerClass = CNC.Import( "code/combat/game-object-manager.lua" )

	--- @type Ww3dAssetManagerClass
	local ww3dAssetManagerClass = CNC.Import( "code/ww3d2/ww3d-asset-manager.lua" )

	--- @type HAnimationManagerClass
	local hAnimationManagerClass = CNC.Import( "code/ww3d2/h-animation-manager.lua" )
--#endregion

--#region Imported Enums
--#endregion


--- @class PlayerManager

--- @type {[Player]: SoldierGameObjectInstance}
STATIC.PlayerSoldiers = STATIC.PlayerSoldiers or {}

--- @param ply Player
--- @return SoldierGameObjectInstance?
function STATIC.InitPlayerSoldier( ply )
	-- Don't create duplicates
	if STATIC.GetPlayerSoldier( ply ) ~= nil then
		return
	end

	section.Print( "Creating Soldier for Player '", ply, "'" )

	-- Some humanoid definition
	local definitionId = 81930232

	local definition = definitionManagerClass.FindDefinition( definitionId ) --[[@as SoldierGameObjectDefinitionInstance]]
	if definition == nil then
		section.Error( "Unable to find definition ID ", definitionId, " to create player soldiers " )
		return
	end

	local physDefinition = definitionManagerClass.FindDefinition( definition.PhysicsDefinitionId ) --[[@as PhysicsDefinitionInstance]]
	if physDefinition == nil then
		section.Error( "Unable to find physics definition ID ", definition.PhysicsDefinitionId, " to modify player soldier's model" )
		return
	end

	-- I think this definition's model is fucked up so swap it
	physDefinition.ModelName = "characters\\nod rocket trooper sf\\c_ag_nod_rsold.w3d"

	local soldier = soldierGameObjectClass.New()
	soldier:Init( definition, ply )
	soldier:SetControlOwner( ply:IsBot() and -1 or 1 )

	STATIC.PlayerSoldiers[ply] = soldier

	return soldier
end

--- @param ply Player
function STATIC.RemovePlayerSoldier( ply )
	local soldier = STATIC.PlayerSoldiers[ply]
	gameObjectManagerClass.Remove( soldier )
	STATIC.PlayerSoldiers[ply] = nil
end


if SERVER then
	-- Create SoldierGameObjects for players as they spawn for the first time
	hook.Add( "PlayerInitialSpawn", "A1_Renegade_CreatePlayerSoldiers", STATIC.InitPlayerSoldier )

	-- Remove SoldierGameObjects for players as they disconnect
	hook.Add( "PlayerDisconnected", "A1_Renegade_RemovePlayerSoldiers", STATIC.RemovePlayerSoldier )
end

if CLIENT then

	-- When we join in, create a SoldierGameObject for each player that's there when we arrive
	hook.Add( "Renegade_PostGameInit", "A1_Renegade_CreatePlayerSoldiers", function()
		for _, ply in player.Iterator() do
			STATIC.InitPlayerSoldier( ply )
		end
	end )




	concommand.Add( "ren_definition_explorer", function()

		local frame = vgui.Create( "DFrame" )
		frame:SetTitle( "Definition Explorer" )
		frame:SetSize( 1200, 600 )
		frame:Center()
		frame:MakePopup()

		local menuBar = vgui.Create( "DMenuBar", frame )
		menuBar:DockMargin( -3, -6, -3, 0 )

		local list = frame:Add( "DListView" )
		list:Dock( FILL )
		list:AddColumn( "ID" )
		list:AddColumn( "Type" )
		list:AddColumn( "Name" )
		list:AddColumn( "Path" )


		--[[ Definition Type Filter ]] do

			-- Get each unique definition class
			local definitionClasses = {}
			for id, definition in pairs( definitionManagerClass.IdToDefinition ) do
				if definitionClasses[definition.Class] == nil then
					definitionClasses[definition.Class] = true
				end
			end

			local definitionTypeMenu = menuBar:AddMenu( "Definition Type" ) --[[@as DMenu]]

			-- The "None" option should re-populate the list with all definitions
			definitionTypeMenu:AddOption( "None", function()
				list:Clear()

				for _, definition in pairs( definitionManagerClass.IdToDefinition ) do
					list:AddLine( definition.Id, definition.Class, definition.Name )
				end
			end )

			-- Add each unique definiiton class to the list and make selecting them re-populate the list with only 
			-- definitions matching that class
			for definitionClass, _ in pairs( definitionClasses ) do
				--- @param panel DMenuOption
				definitionTypeMenu:AddOption( definitionClass, function( panel )
					list:Clear()

					for _, definition in pairs( definitionManagerClass.IdToDefinition ) do

						if definition.Class == panel:GetText() then

							local path = nil
							if definition.Class == "HumanPhysicsDefinitionInstance" then
								--- @cast definition HumanPhysicsDefinitionInstance
								path = definition.ModelName
							end

							local line = list:AddLine( definition.Id, definition.Class, definition.Name, path ) --[[@as DListView_Line]]

							line.OnSelect = function( self )
								if path then
									SetClipboardText( path )
								end
							end
						end
					end
				end )
			end
		end
	end )


	--- @param renMesh MeshInstance
	function STATIC.CreateSourceMesh( renMesh )
		if not renMesh.SourceMesh then
			renMesh.SourceMesh = Mesh( nil, 2 )
		end

		local model = renMesh.Model

		local vertices = model.Vertex
		local triangles = model.Polygons
		local vertexWeights = model.VertexBoneLink
		local normals = model:GetVertexNormalArray()

		local materialDescription = model.DefinitionMaterialDescription
		if not materialDescription then
			return
		end

		local uvArray = materialDescription.Uv
		local uv = uvArray[1]

		mesh.Begin( renMesh.SourceMesh, MATERIAL_TRIANGLES, #triangles )
		for triangleIndex = 1, #triangles do

			local triangleIndices = triangles[triangleIndex]

			local vertex1Index = triangleIndices[1] + 1
			local vertex2Index = triangleIndices[2] + 1
			local vertex3Index = triangleIndices[3] + 1

			local triangleVertex1 = vertices[vertex1Index] * unitConversionLib.MetersToSource
			local triangleVertex2 = vertices[vertex2Index] * unitConversionLib.MetersToSource
			local triangleVertex3 = vertices[vertex3Index] * unitConversionLib.MetersToSource

			local vertex1Bone = vertexWeights[vertex1Index] + 1
			local vertex2Bone = vertexWeights[vertex2Index] + 1
			local vertex3Bone = vertexWeights[vertex3Index] + 1

			local vertex1Uv = uv[vertex1Index]
			local vertex2Uv = uv[vertex2Index]
			local vertex3Uv = uv[vertex3Index]

			local vertex1Normal = normals[vertex1Index]
			local vertex2Normal = normals[vertex2Index]
			local vertex3Normal = normals[vertex3Index]

			mesh.Position( triangleVertex1 )
			mesh.Color( 255, 255, 255, 255 )
			mesh.BoneData( 0, vertex1Bone, 1 )
			mesh.BoneData( 1, vertex1Bone, 0 )
			mesh.TexCoord( 0, vertex1Uv.x, vertex1Uv.y )
			mesh.Normal( vertex1Normal )
			mesh.AdvanceVertex()

			mesh.Position( triangleVertex2 )
			mesh.Color( 255, 255, 255, 255 )
			mesh.BoneData( 0, vertex2Bone, 1 )
			mesh.BoneData( 1, vertex2Bone, 0 )
			mesh.TexCoord( 0, vertex2Uv.x, vertex2Uv.y )
			mesh.Normal( vertex2Normal )
			mesh.AdvanceVertex()

			mesh.Position( triangleVertex3 )
			mesh.Color( 255, 255, 255, 255 )
			mesh.BoneData( 0, vertex3Bone, 1 )
			mesh.BoneData( 1, vertex3Bone, 0 )
			mesh.TexCoord( 0, vertex3Uv.x, vertex3Uv.y )
			mesh.Normal( vertex3Normal )
			mesh.AdvanceVertex()
		end
		mesh.End()
	end

	--- @param renMesh MeshInstance
	function STATIC.CreateSourceBones( renMesh )
		local bones = {}
		renMesh.SourceBones = bones

		for boneIndex = 1, renMesh:GetNumBones() do
			bones[boneIndex] = Matrix()
		end
	end

	--- @param renMesh MeshInstance
	function STATIC.UpdateSourceBones( renMesh )

		if renMesh.UpdateSubObjectTransforms then
			renMesh:UpdateSubObjectTransforms()
		end

		local bones = renMesh.SourceBones

		for boneIndex = 1, renMesh:GetNumBones() do
			local renBoneMatrix = renMesh:GetBoneTransform( boneIndex )
			local sourceBoneMatrix = renBoneMatrix:AsVMatrix()

			local translation = sourceBoneMatrix:GetTranslation() * unitConversionLib.MetersToSource
			local angle 	  = sourceBoneMatrix:GetAngles()

			local sourceBoneMatrix = bones[boneIndex]
			sourceBoneMatrix:Identity()
			sourceBoneMatrix:Translate( translation )
			sourceBoneMatrix:SetAngles( angle )
			sourceBoneMatrix:SetScale( Vector( 1, 1, 1 ) )
		end
	end

	hook.Add( "PrePlayerDraw", "A1_Renegade_Debug_DrawPlayerSoldiers", function( ply )
		if not CNC.HasPostGameInit then return end

		local soldier = STATIC.GetPlayerSoldier( ply )
		if soldier == nil then
			soldier = STATIC.InitPlayerSoldier( ply )

			if soldier == nil then
				section.Error( "Failed to initialize SoldierGameObject for player: '", ply:Nick()(), "'" )
			end
		end
		--- @cast soldier SoldierGameObjectInstance

		local soldierPhys = soldier.PhysicsObject:AsHumanPhysics()
		if soldierPhys == nil then
			return
		end

		if not IsValid( soldier:GetConnectedEntity() ) then
			return
		end

		local model = soldierPhys:GetModel()
		if model == nil then
			return
		end

		local hotload = isHotload
		if hotload then
			isHotload = false
		end

		if hotload or not model.SourceBones then
			STATIC.CreateSourceBones( model )
			STATIC.UpdateSourceBones( model )
		end

		local boneToDraw = 1
		local subObjectToDraw = 6

		local subObject = model:GetSubObjectOnBone( subObjectToDraw, boneToDraw )
		if subObject == nil then
			return
		end

		if subObject.Class == "AABoxRenderObjectInstance" or subObject.Class == "OBBoxRenderObjectInstance" then
			return
		end

		if hotload or not subObject.SourceMesh then
			STATIC.CreateSourceMesh( subObject --[[@as MeshInstance]] )
		end

		if hotload or subObject.SourceMaterial == nil then
			subObject.SourceMaterial = Material( "data/renegade/always_dat/c_nod_sf_rsold.png", "smooth mips" )
		end
		render.SetMaterial( subObject.SourceMaterial )

		-- Make the model do a turntable spin
		local modelMatrix = Matrix( ply:GetWorldTransformMatrix() )
		modelMatrix:Rotate( Angle( 0, CurTime() * 50, 0  ) )

		render.OverrideDepthEnable( true, true )
		cam.PushModelMatrix( modelMatrix )
		render.CullMode( MATERIAL_CULLMODE_CW )
		subObject.SourceMesh:DrawSkinned( model.SourceBones, true )
		render.CullMode( MATERIAL_CULLMODE_CCW )
		cam.PopModelMatrix()
		render.OverrideDepthEnable( false, false )

		return true
	end )
end

--- @param ply Player
--- @return SoldierGameObjectInstance?
function STATIC.GetPlayerSoldier( ply )
	return STATIC.PlayerSoldiers[ ply ]
end
