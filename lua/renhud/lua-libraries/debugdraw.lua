-- Provides utilities for drawing debug shapes and networking them from the server to clients

if SERVER then
    util.AddNetworkString( "A1_DebugDraw" )
end

--- @class DebugDraw
--- The DebugDraw library, used to help with debugging
debugdraw = debugdraw or {}

--- @enum DebugDraw.ShapeType
debugdraw.ShapeType = {
    Entity  = 1,
    Box     = 2,
    Line    = 3,
    Sphere  = 4,
    Text    = 4,
}

--- Draws the bounding box of a given Entity
--- @param ent Entity The Entity to draw
--- @param color Color? [Default: `Color( 255, 255, 255, 200 )`]
--- @param duration number? [Default: `1`] The length of time, in seconds, to draw this Entity
--- @param ignoreZ boolean? [Default: `false`] Should the Entity draw through other objects?
function debugdraw.Entity( ent, color, duration, ignoreZ )
    if not IsValid( ent ) then return end
    if not color then color = Color( 255, 255, 255, 200 ) end
    if not duration then duration = 1 end
    if not ignoreZ then ignoreZ = false end

    if SERVER then
        net.Start( "A1_DebugDraw" )

        -- Write standard arguments
        net.WriteColor( color )
        net.WriteFloat( duration )
        net.WriteBool( ignoreZ )

        -- Write type-dependent arguments
        net.WriteInt( debugdraw.ShapeType.Entity, 8 )
        net.WriteEntity( ent )

        net.Broadcast()
    end

    if CLIENT then
        debugdraw.AddEntity( ent, color, duration, ignoreZ )
    end
end

--- Draws a sphere
--- @param pos Vector
--- @param radius number
--- @param color Color? [Default: `Color( 255, 255, 255, 200 )`]
--- @param duration number? [Default: `1`] The length of time, in seconds, to draw this Entity
--- @param ignoreZ boolean? [Default: `false`] Should the Entity draw through other objects?
function debugdraw.Sphere( pos, radius, color, duration, ignoreZ )
    if not color then color = Color( 255, 255, 255, 200 ) end
    if not duration then duration = 1 end
    if not ignoreZ then ignoreZ = false end

    -- To avoid reference issues
    pos = Vector( pos )

    if SERVER then
        net.Start( "A1_DebugDraw" )

        -- Write standard arguments
        net.WriteColor( color )
        net.WriteFloat( duration )
        net.WriteBool( ignoreZ )

        -- Write type-dependent arguments
        net.WriteInt( debugdraw.ShapeType.Sphere, 8 )
        net.WriteVector( pos )
        net.WriteFloat( radius )

        net.Broadcast()
    end

    if CLIENT then
        debugdraw.AddSphere( pos, radius, color, duration, ignoreZ )
    end
end

--- Draws a line
--- @param startPos Vector
--- @param endPos Vector
--- @param width number
--- @param color Color? [Default: `Color( 255, 255, 255, 200 )`]
--- @param duration number? [Default: `1`] The length of time, in seconds, to draw this Entity
--- @param ignoreZ boolean? [Default: `false`] Should the Entity draw through other objects?
function debugdraw.Line( startPos, endPos, width, color, duration, ignoreZ )
    if not color then color = Color( 255, 255, 255, 200 ) end
    if not duration then duration = 1 end
    if not ignoreZ then ignoreZ = false end

    -- To avoid reference issues
    startPos = Vector( startPos )
    endPos = Vector( endPos )

    if SERVER then
        net.Start( "A1_DebugDraw" )

        -- Write standard arguments
        net.WriteColor( color )
        net.WriteFloat( duration )
        net.WriteBool( ignoreZ )

        -- Write type-dependent arguments
        net.WriteInt( debugdraw.ShapeType.Line, 8 )
        net.WriteVector( startPos )
        net.WriteVector( endPos )
        net.WriteFloat( width )

        net.Broadcast()
    end

    if CLIENT then
        debugdraw.AddLine( startPos, endPos, width, color, duration, ignoreZ )
    end
end

--- Draws text
--- @param pos Vector
--- @param text string
--- @param color Color? [Default: `Color( 255, 255, 255, 200 )`]
--- @param duration number? [Default: `1`] The length of time, in seconds, to draw this Entity
--- @param ignoreZ boolean? [Default: `false`] Should the Entity draw through other objects?
function debugdraw.Text( pos, text, color, duration, ignoreZ )
    if not color then color = Color( 255, 255, 255, 200 ) end
    if not duration then duration = 1 end
    if not ignoreZ then ignoreZ = false end

    -- To avoid reference issues
    pos = Vector( pos )

    if SERVER then
        net.Start( "A1_DebugDraw" )

        -- Write standard arguments
        net.WriteColor( color )
        net.WriteFloat( duration )
        net.WriteBool( ignoreZ )

        -- Write type-dependent arguments
        net.WriteInt( debugdraw.ShapeType.Text, 8 )
        net.WriteVector( pos )
        net.WriteString( text )

        net.Broadcast()
    end

    if CLIENT then
        debugdraw.AddText( pos, text, color, duration, ignoreZ )
    end
end

if CLIENT then

    --- The base for all other shapes
    --- @class DebugDraw.Base
    --- @field StartTime number The time, relative to CurTime, when this shape was first drawn
    --- @field Lifetime number The length of time, in seconds, that this shape should be drawn
    --- @field Color Color The color the shape should be drawn in
    --- @field IgnoreZ boolean Should the shape draw through other objects?

    --- Called when a new debug draw message has been received from the server
    local function ReceiveDebugDraw()
        -- Read standard arguments
        local color     = net.ReadColor()
        local duration  = net.ReadFloat()
        local ignoreZ   = net.ReadBool()

        -- Find out which shape we're receiving
        local shapeType = net.ReadInt( 8 ) --[[@as DebugDraw.ShapeType]]

        -- Entities
        if shapeType == debugdraw.ShapeType.Entity then
            local ent = net.ReadEntity()

            debugdraw.AddEntity( ent, color, duration, ignoreZ )
        end

        -- Spheres
        if shapeType == debugdraw.ShapeType.Sphere then
            local pos = net.ReadVector()
            local radius = net.ReadFloat()

            debugdraw.AddSphere( pos, radius, color, duration, ignoreZ )
        end

        -- Lines
        if shapeType == debugdraw.ShapeType.Line then
            local startPos = net.ReadVector()
            local endPos = net.ReadVector()
            local width = net.ReadFloat()

            debugdraw.AddLine( startPos, endPos, width, color, duration, ignoreZ )
        end

        -- Text
        if shapeType == debugdraw.ShapeType.Text then
            local pos = net.ReadVector()
            local text = net.ReadString()

            debugdraw.AddText( pos, text, color, duration, ignoreZ )
        end
    end
    net.Receive( "A1_DebugDraw", ReceiveDebugDraw )

    --- @param time number CurTime
    --- @param shapeList DebugDraw.Base[]
    --- @param drawFunction fun( shape: DebugDraw.Base ):boolean
    function debugdraw.DrawShapeList( time, shapeList, drawFunction )
        --- @type table<integer, boolean>
        local indicesToRemove = {}

        -- Draw each Entity's bounding box
        --- @param shapeInfo DebugDraw.Base
        for index, shapeInfo in pairs( shapeList ) do
            if shapeInfo.IgnoreZ then
                render.SetColorMaterialIgnoreZ()
            else
                render.SetColorMaterial()
            end

            local shouldStopEarly = drawFunction( shapeInfo )
            local isLifetimeOver = time > ( shapeInfo.StartTime + shapeInfo.Lifetime )

            if shouldStopEarly or isLifetimeOver then
                -- Keep track of the entries that have expired
                indicesToRemove[index] = true
            end
        end

        -- Remove entries that have expired
        for index, _ in pairs( indicesToRemove ) do
            table.remove( shapeList, index )
        end
    end

    hook.Add( "PostDrawOpaqueRenderables", "A1_DebugDraw_Render", function()
        local time = CurTime()

        -- Entities
        debugdraw.DrawShapeList( time, debugdraw.DebugEntities, debugdraw.DrawEntity )

        -- Spheres
        debugdraw.DrawShapeList( time, debugdraw.DebugSpheres, debugdraw.DrawSphere )

        -- Lines
        debugdraw.DrawShapeList( time, debugdraw.DebugLines, debugdraw.DrawLine )

        -- Text
        debugdraw.DrawShapeList( time, debugdraw.DebugTexts, debugdraw.DrawText )
    end )

    --[[ Entities ]] do
        --- A shape for drawing the bounding box of an Entity
        --- @class DebugDraw.Entity : DebugDraw.Base
        --- @field Entity Entity

        --- @type DebugDraw.Entity[]
        --- @private
        debugdraw.DebugEntities = {}

        --- Registers a new Entity to draw
        --- @param ent Entity The Entity to draw
        --- @param color Color
        --- @param duration number The length of time, in seconds, to draw this Entity
        --- @param ignoreZ boolean Should the Entity draw through other objects?
        --- @private
        function debugdraw.AddEntity( ent, color, duration, ignoreZ )
            debugdraw.DebugEntities[#debugdraw.DebugEntities + 1] = {
                StartTime = CurTime(),
                Lifetime = duration,
                Color = color,
                IgnoreZ = ignoreZ,
                Entity = ent
            }
        end

        --- Draws a given Entity's bounding box
        --- @param shapeInfo DebugDraw.Entity
        --- @return boolean? shouldStopDrawing `true` if there was an issue drawing that indicates we should stop trying early 
        --- @private
        function debugdraw.DrawEntity( shapeInfo )
            if not IsValid( shapeInfo.Entity ) then
                return true
            end

            local ent = shapeInfo.Entity
            local pos = ent:GetPos()
            local ang = ent:GetAngles()
            local mins, maxs = ent:OBBMins(), ent:OBBMaxs()

            local boxColor = shapeInfo.Color
            local wireframeColor = Color( 255 - boxColor.r, 255 - boxColor.g, 255 - boxColor.b )

            render.DrawBox( pos, ang, mins, maxs, shapeInfo.Color )
            render.DrawWireframeBox( pos, ang, mins, maxs, wireframeColor )
        end
    end

    --[[ Spheres ]] do
        --- A shape for drawing a sphere
        --- @class DebugDraw.Sphere : DebugDraw.Base
        --- @field Pos Vector
        --- @field Radius number

        --- @type DebugDraw.Sphere[]
        --- @private
        debugdraw.DebugSpheres = {}

        --- Registers a new sphere to draw
        --- @param pos Vector
        --- @param radius number
        --- @param color Color
        --- @param duration number The length of time, in seconds, to draw this Entity
        --- @param ignoreZ boolean Should the Entity draw through other objects?
        --- @private
        function debugdraw.AddSphere( pos, radius, color, duration, ignoreZ )
            debugdraw.DebugSpheres[#debugdraw.DebugSpheres + 1] = {
                StartTime = CurTime(),
                Lifetime = duration,
                Color = color,
                IgnoreZ = ignoreZ,
                Pos = pos,
                Radius = radius
            }
        end

        --- Draws a given sphere
        --- @param shapeInfo DebugDraw.Sphere
        --- @return boolean? shouldStopDrawing `true` if there was an issue drawing that indicates we should stop trying early 
        --- @private
        function debugdraw.DrawSphere( shapeInfo )
            render.DrawSphere( shapeInfo.Pos, shapeInfo.Radius, 10, 10, shapeInfo.Color )
        end
    end

    --[[ Lines ]] do
        --- A shape for drawing a line
        --- @class DebugDraw.Line : DebugDraw.Base
        --- @field StartPos Vector
        --- @field EndPos Vector
        --- @field Width number

        --- @type DebugDraw.Line[]
        --- @private
        debugdraw.DebugLines = {}

        --- Registers a new line to draw
        --- @param startPos Vector
        --- @param endPos Vector
        --- @param width number
        --- @param color Color
        --- @param duration number The length of time, in seconds, to draw this Entity
        --- @param ignoreZ boolean Should the Entity draw through other objects?
        --- @private
        function debugdraw.AddLine( startPos, endPos, width, color, duration, ignoreZ )
            debugdraw.DebugLines[#debugdraw.DebugLines + 1] = {
                StartTime = CurTime(),
                Lifetime = duration,
                Color = color,
                IgnoreZ = ignoreZ,
                StartPos = startPos,
                EndPos = endPos,
                Width = width
            }
        end

        --- Draws a given line
        --- @param shapeInfo DebugDraw.Line
        --- @return boolean? shouldStopDrawing `true` if there was an issue drawing that indicates we should stop trying early 
        --- @private
        function debugdraw.DrawLine( shapeInfo )
            render.DrawBeam( shapeInfo.StartPos, shapeInfo.EndPos, shapeInfo.Width, 0, 1, shapeInfo.Color )
            render.DrawLine( shapeInfo.StartPos, shapeInfo.EndPos, shapeInfo.Color, shapeInfo.IgnoreZ )
        end
    end

    --[[ Text ]] do
        --- A shape for drawing text
        --- @class DebugDraw.Text : DebugDraw.Base
        --- @field Pos Vector
        --- @field Text string

        --- @private
        --- @type DebugDraw.Text[]
        debugdraw.DebugTexts = {}

        --- @private
        --- Registers new text to draw
        --- @param pos Vector
        --- @param text string
        --- @param color Color
        --- @param duration number The length of time, in seconds, to draw this Entity
        --- @param ignoreZ boolean Should the Entity draw through other objects?
        function debugdraw.AddText( pos, text, color, duration, ignoreZ )
            debugdraw.DebugTexts[#debugdraw.DebugTexts + 1] = {
                StartTime = CurTime(),
                Lifetime = duration,
                Color = color,
                IgnoreZ = ignoreZ,
                Pos = pos,
                Text = text
            }
        end

        --- @private
        --- Draws given text
        --- @param shapeInfo DebugDraw.Text
        --- @return boolean? shouldStopDrawing `true` if there was an issue drawing that indicates we should stop trying early 
        function debugdraw.DrawText( shapeInfo )
            local screenPos = shapeInfo.Pos:ToScreen()
            if not screenPos.visible then return end

            cam.Start2D()

            surface.SetFont( "ChatFont" )
            local color = shapeInfo.Color
            surface.SetTextColor( color.r, color.g, color.b, color.a )
            surface.SetTextPos( screenPos.x, screenPos.y )
            surface.DrawText( shapeInfo.Text )

            cam.End2D()
        end
    end
end


