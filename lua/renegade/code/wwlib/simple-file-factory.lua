-- Based on SimpleFileFactoryClass within Code/wwlib/ffactory.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type FileFactoryClass
local fileFactoryClass = CNC.Import( "code/wwlib/file-factory.lua" )

--- @class SimpleFileFactoryClass : FileFactoryClass
--- @field Instance SimpleFileFactoryInstance The metatable used by SimpleFileFactoryInstance
local STATIC = CNC.CreateExport( fileFactoryClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "SimpleFileFactoryClass"

--- @class SimpleFileFactoryInstance : FileFactoryInstance
--- @field Static SimpleFileFactoryClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_SimpleFileFactory : Renegade_FileFactory" )
INSTANCE.Class = "SimpleFileFactoryInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsSimpleFileFactory = true

--#region Exported Enums
--#endregion

--#region Imports

    --- @type BufferedFileClass
    local bufferedFileClass = CNC.Import( "code/wwlib/buffered-file.lua" )
--#endregion

--#region Imported Enums
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class SimpleFileFactoryClass

    --- Creates a new SimpleFileFactoryInstance
    --- @return SimpleFileFactoryInstance
    function STATIC.New()
        return robustclass.New( "Renegade_SimpleFileFactory" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) SimpleFileFactoryInstance, `false` otherwise
    function STATIC.IsSimpleFileFactory( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsSimpleFileFactory and true or false
    end

    typecheck.RegisterType( "SimpleFileFactoryInstance", STATIC.IsSimpleFileFactory )

    --- @param path string
    --- @return boolean
    function STATIC.IsFullPath( path )
        -- Ommitted original logic as full paths aren't possible in Garry's Mod
        return false
    end
end


--- @class SimpleFileFactoryInstance
--- @field SubDirectory string
--- @field IsStripPath boolean

function INSTANCE:Renegade_SimpleFileFactory()
    fileFactoryClass.Instance.Renegade_FileFactory( self )

    self.IsStripPath = false
end

function INSTANCE:_Renegade_SimpleFileFactory()
    -- Empty in the original code
end

-- Simply horrible that this needs to be implemented manually like this  
-- Credit: https://stackoverflow.com/questions/20459943/find-the-last-index-of-a-character-in-a-string
--- @param haystack string
--- @param needle string
--- @return integer | nil
local function findLast( haystack, needle )
    --Set the third arg to false to allow pattern matching
    local found = haystack:reverse():find(needle:reverse(), nil, true)
    if found then
        return haystack:len() - needle:len() - found + 2
    else
        return found
    end
end

--- @param fileName string
--- @return FileInstance
function INSTANCE:GetFile( fileName )

    -- "
    -- Strip off the path (if needed).  Note that if path stripping is off, and the requested file
    -- has a path in its name, and the current subdirectory is not empty, the paths will just be
    -- concatenatied which may not produce reasonable results.
    -- "
    local strippedName
    if self.IsStripPath then
        local lastSlashIndex = findLast( fileName, "\\" )

        if lastSlashIndex ~= nil then
            strippedName = fileName:sub( lastSlashIndex + 1 )
        else
            strippedName = fileName
        end
    else
        strippedName = fileName
    end

    local file = bufferedFileClass.New()

    -- "Do we need to find the path for this file request?"
    local newName = strippedName
    if STATIC.IsFullPath( newName ) == false then

        -- "BEGIN SERIALIZATION"

        if self.SubDirectory ~= nil and self.SubDirectory:len() ~= 0 then
            --- "  
            --- SubDirectory may contain a semicolon seperated search path...
            --- If the file doesn't exist, we'll set the path to the last dir in
            --- the search path.  Therefore newly created files will always go in the
            --- last dir in the search path.
            --- "
            if self.SubDirectory:find( ";", nil, true ) ~= nil then
                local subDirectories = self.SubDirectory:Split( ";" )
                for _, subDirectory in ipairs(subDirectories) do

                    -- I don't trust these paths to not have trailing semicolons
                    if subDirectory:len() == 0 then
                        break
                    end

                    newName = subDirectory .. strippedName
                    file:SetName( newName ) -- "Call [SetName] to force an allocated name"
                    if file:Open() then
                        file:Close()
                        break
                    end
                end
            else
                newName = self.SubDirectory .. strippedName
            end
        end

        -- "END SERIALIZATION"
    end

    -- "Call [SetName] to force an allocated name"
    file:SetName( newName )

    return file
end

--- @param file FileInstance
function INSTANCE:ReturnFile( file )
    -- This deletes the file in memory in the original code
end

--- "  
--- [SubDirectory] may be a semicolon seperated search path.  
--- New files will always go in the last dir to the path.  
--- "
--- @return string
function INSTANCE:GetSubDirectory()
    return self.SubDirectory
end

--- @param subDirectory string
function INSTANCE:SetSubDirectory( subDirectory )
    self.SubDirectory = subDirectory
end

--- @param subDirectory string
function INSTANCE:PrependSubDirectory( subDirectory )
    typecheck.NotImplementedError()
end

--- @param subDirectory string
function INSTANCE:AppendSubDirectory( subDirectory )
    local subLength = subDirectory:len()
    -- "Overflow prevention"
    if subLength > 1022 then
        section.Error( "Appending sub directory overflow triggered! Dir: '", subDirectory, "'" )
        return
    elseif subLength < 1 then
        section.Error( "Appending sub directory underflow triggered! Dir: '", subDirectory, "'" )
        return
    end

    -- "Ensure [subDirectory] ends with a slash"
    local tempSubDirectory = subDirectory
    if not tempSubDirectory:EndsWith( "/" ) then
        tempSubDirectory = tempSubDirectory .. "/"
        subLength = subLength + 1
    end

    -- "BEGIN SERIALIZATION"

    -- "Ensure a trailing semicolon is present, unless the directory list is empty"
    if not self.SubDirectory:EndsWith( ";" ) then
        self.SubDirectory = self.SubDirectory .. ";"
    end

    self.SubDirectory = self.SubDirectory .. tempSubDirectory
    -- "END SERIALIZATION"
end

--- @return boolean
function INSTANCE:GetStripPath()
    return self.IsStripPath
end

--- @param newIsScriptPath boolean
function INSTANCE:SetStripPath( newIsScriptPath )
    self.IsStripPath = newIsScriptPath
end
