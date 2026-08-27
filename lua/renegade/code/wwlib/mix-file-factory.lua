-- Based on MixFileFactoryClass within Code/wwlib/mixfile.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type FileFactoryClass
local fileFactoryClass = CNC.Import( "code/wwlib/file-factory.lua" )

--- @class MixFileFactoryClass : FileFactoryClass
--- @field Instance MixFileFactoryInstance The metatable used by MixFileFactoryInstance
local STATIC = CNC.CreateExport( fileFactoryClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "MixFileFactoryClass"

--- @class MixFileFactoryInstance : FileFactoryInstance
--- @field Static MixFileFactoryClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_MixFileFactory : Renegade_FileFactory" )
INSTANCE.Class = "MixFileFactoryInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsMixFileFactory = true

--#region Exported Enums
--#endregion

--#region Imports

	--- @type FileClass
	local fileClass = CNC.Import( "code/wwlib/file.lua" )

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )
--#endregion

--#region Imported Enums

	local seekDirectionEnum = fileClass.SEEK_DIRECTION
	local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class MixFileFactoryClass

    --- Creates a new MixFileFactoryInstance
    --- @param mixFileName string
    --- @param factory FileFactoryInstance
    --- @return MixFileFactoryInstance
    function STATIC.New( mixFileName, factory )
        return robustclass.New( "Renegade_MixFileFactory", mixFileName, factory )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) MixFileFactoryInstance, `false` otherwise
    function STATIC.IsMixFileFactory( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsMixFileFactory and true or false
    end

    typecheck.RegisterType( "MixFileFactoryInstance", STATIC.IsMixFileFactory )


    function STATIC.StaticConstructor()

        --- @class FileInfoStruct
        --- @field Crc integer "CRC code for embedded file."
        --- @field Offset integer "Offset from start of data section."
        --- @field Size integer "Size of data subfile."
        deserializeLib.RegisterComplexDataType( "FileInfoStruct", {
            { Name = "Crc",    Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Offset", Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Size",   Type = fundamentalDataTypeEnum.UInt32 },
        } )

        --- @class MixFileHeader
        --- @field Signature string
        --- @field HeaderOffset integer
        --- @field NamesOffset integer
        deserializeLib.RegisterComplexDataType( "MixFileHeader", {
            { Name = "Signature",    Type = fundamentalDataTypeEnum.String, Size = 4 },
            { Name = "HeaderOffset", Type = fundamentalDataTypeEnum.Int },
            { Name = "NamesOffset",  Type = fundamentalDataTypeEnum.Int },
        } )
    end
end

--- @class MixFileFactoryInstance
--- @field Factory FileFactoryInstance
--- @field FileInfo {[string]: FileInfoStruct} A map of file name CRC to its FileInfoStruct
--- @field MixFilename string
--- @field BaseOffset integer
--- @field FileCount integer
--- @field NamesOffset integer
--- @field IsValid boolean
--- @field FilenameList string[]
--- @field PendingAddFileList AddInfoStruct[]
--- @field IsModified boolean

--- @param mixFileName string
--- @param factory FileFactoryInstance
function INSTANCE:Renegade_MixFileFactory( mixFileName, factory )
    fileFactoryClass.Instance.Renegade_FileFactory( self )

    self.FileCount = 0
    self.NamesOffset = 0
    self.IsValid = false
    self.BaseOffset = 0
    self.Factory = nil
    self.IsModified = false

    self.MixFilename = mixFileName
    self.Factory = factory

    -- "First, open the mix file"
    local file = factory:GetFile( mixFileName )

    if file ~= nil and file:IsAvailable() then
        file:Open()

        self.IsValid = true

        -- "Read the file header"
        local mixFileHeaderByteCount = deserializeLib.GetComplexDataTypeSize( "MixFileHeader" )
        local readBytes, readByteCount = file:Read( mixFileHeaderByteCount )
        self.IsValid = ( readByteCount == mixFileHeaderByteCount )
        local header = deserializeLib.Deserialize( "MixFileHeader", readBytes )

        -- "Validate the file header"
        if self.IsValid then
            self.IsValid = ( header.Signature == "MIX1" )
        end

        -- "Seek to the data start"
        self.FileCount = 0
        if self.IsValid then
            file:Seek( header.HeaderOffset, seekDirectionEnum.SEEK_SET )

            local fileCountSize = deserializeLib.GetFundamentalDataTypeSize( fundamentalDataTypeEnum.Int )
            readBytes, readByteCount = file:Read( fileCountSize )
            self.FileCount = deserializeLib.DeserializeInt32( readBytes )
            self.IsValid = ( readByteCount == fileCountSize )
        end

        -- "Read the array of data headers"
        if self.IsValid then
            local size = self.FileCount * deserializeLib.GetDataTypeSize( "FileInfoStruct" )

            readBytes, readByteCount = file:Read( size )
            assert( readByteCount == size )
            local readStructs = deserializeLib.DeserializeArray( "FileInfoStruct", readBytes )

            -- Convert the FileInfoStructs into a map for easier access
            self.FileInfo = {}
            for _, fileInfo in ipairs( readStructs ) do
                self.FileInfo[fileInfo.Crc] = fileInfo
            end

            self.IsValid = table.Count( self.FileInfo ) == self.FileCount
        end

        -- "Check for success"
        if self.IsValid then
            self.BaseOffset = 0
            self.NamesOffset = header.NamesOffset
            section.Print( "MixFileFactory( ", self.MixFilename, " ) loaded successfully ", table.Count( self.FileInfo ), " files" )
        else
            self.FileInfo = {}
            section.Warn( "MixFileFactory( ", self.MixFilename, " ) only loaded ", table.Count( self.FileInfo ), "/", self.FileCount, " files" )
        end

        factory:ReturnFile( file )
    else
        section.Error( "MixFileFactory( ", mixFileName, " ) FAILED" )
    end
end

function INSTANCE:_Renegade_MixFileFactory()
    typecheck.NotImplementedError()
end

--- @param fileName string
--- @return FileInstance?
function INSTANCE:GetFile( fileName )
    -- Replaced binary search with map lookup

    local crc = tonumber( util.CRC( fileName:upper() ) )
    local info = self.FileInfo[crc]

    --- @type RawFileInstance
    local file
    if info ~= nil then
        file = self.Factory:GetFile( self.MixFilename ) --[[@as RawFileInstance]]
        if file ~= nil then
            file:Bias( self.BaseOffset + info.Offset, info.Size )
        end
    end

    return file
end

function INSTANCE:ReturnFile()
    typecheck.NotImplementedError()
end

function INSTANCE:BuildFilenameList()
    typecheck.NotImplementedError()
end

function INSTANCE:BuildInternalFilenameList()
    typecheck.NotImplementedError()
end

function INSTANCE:GetFilenameList()
    typecheck.NotImplementedError()
end

function INSTANCE:AddFile()
    typecheck.NotImplementedError()
end

function INSTANCE:DeleteFile()
    typecheck.NotImplementedError()
end

function INSTANCE:FlushChanges()
    typecheck.NotImplementedError()
end

function INSTANCE:IsValid()
    typecheck.NotImplementedError()
end

function INSTANCE:GetTempFilename()
    typecheck.NotImplementedError()
end
