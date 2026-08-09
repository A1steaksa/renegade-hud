-- Based on RawFileClass within Code/wwlib/rawfile.h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @type FileClass
local fileClass = CNC.Import( "code/wwlib/file.lua" )

--- @class RawFileClass : FileClass
--- @field Instance RawFileInstance The metatable used by RawFileInstance
local STATIC = CNC.CreateExport( fileClass )
local isHotload = not table.IsEmpty( STATIC )
STATIC.Class = "RawFileClass"

--- @class RawFileInstance : FileInstance
--- @field Static RawFileClass The static table for this instance's class
local INSTANCE = robustclass.Register( "Renegade_RawFile : Renegade_File" )
INSTANCE.Class = "RawFileInstance"
STATIC.Instance = INSTANCE
INSTANCE.Static = STATIC
INSTANCE.IsRawFile = true

--#region Exported Enums
--#endregion

--#region Imports

    --- @type FileClass
    local fileClass = CNC.Import( "code/wwlib/file.lua" )
--#endregion

--#region Imported Enums

    local seekDirectionEnum = fileClass.SEEK_DIRECTION
    local fileRightsEnum = fileClass.FILE_RIGHTS
--#endregion

--[[ Static Functions and Variables ]] do

    --- @class RawFileClass

    --- Creates a new RawFileInstance
    --- @return RawFileInstance
    function STATIC.New()
        return robustclass.New( "Renegade_RawFile" )
    end

    --- @param arg any
    --- @return boolean `true` if the passed argument is a(n) RawFileInstance, `false` otherwise
    function STATIC.IsRawFile( arg )
        if not istable( arg ) then return false end
        if getmetatable( arg ) ~= INSTANCE then return false end

        return arg.IsRawFile and true or false
    end

    typecheck.RegisterType( "RawFileInstance", STATIC.IsRawFile )
end


--- @class RawFileInstance
--- @field Rights integer "This is a record of the access rights used to open the file.  These rights are used if the file object is duplicated."
--- @field BiasStart integer
--- @field BiasLength integer
--- @field Handle file_class|File The Garry's Mod File object that underlies this class
--- @field Filename string
--- @field Date integer
--- @field Time integer


--- @param fileName string? (Optional) "The filename to assign to this file object."
function INSTANCE:Renegade_RawFile( fileName )
    -- ( fileName: string )
    if fileName ~= nil then
        fileClass.Instance.Renegade_File( self )

        self.Rights = 0
        self.BiasStart = 0
        self.BiasLength = -1
        self.Handle = nil
        self.Filename = fileName
        self.Date = 0
        self.Time = 0

    -- (): string
    else
        fileClass.Instance.Renegade_File( self )

        self.Rights = fileRightsEnum.READ
        self.BiasStart = 0
        self.BiasLength = -1
        self.Handle = nil
        self.Filename = ""
        self.Date = 0
        self.Time = 0
    end
end

function INSTANCE:_Renegade_RawFile()
    self:Reset()
end

--- "Returns with the filename associate with the file object."
--- @return string
function INSTANCE:FileName()
    return self.Filename
end

--- "Manually sets the name for a file object."
--- @param fileName string "The filename to assign to this file object."
--- @return string
function INSTANCE:SetName( fileName )
    -- Ensure that we look for files within the Garry's Mod data directory for this addon
    if not fileName:StartsWith( "data/renegade" ) then
        fileName = "data/renegade/" .. fileName
    end

    self:Bias( 1 )
    self.Filename = fileName
    return self.Filename
end

function INSTANCE:Create()
    typecheck.NotImplementedError()
end

function INSTANCE:Delete()
    typecheck.NotImplementedError()
end

--- @param isForced boolean
--- @return boolean
function INSTANCE:IsAvailable( isForced )
    if self.Filename:len() == 0 then
        return false
    end

    -- "If the file is already open, then is must have already passed the availability check."
    -- "Return true in this case."
    if self:IsOpen() then
        return true
    end

    -- "
    -- If this is a forced check, then go through the normal open channels, since those
    -- channels ensure that the file must exist.
    -- "
    if isForced then
        self:Open( fileRightsEnum.READ )
        self:Close()
        return true
    end

    -- Omitted remainder of function as it determines file availability using
    -- OS-level file handles which I don't have access to.

    return file.Exists( self.Filename, "THIRDPARTY" )
end

--- "Checks to see if the file is open or not."
--- @return boolean # Is the file open?
function INSTANCE:IsOpen()
    return self.Handle ~= nil
end

--- @overload fun( self: RawFileInstance, fileName: string, rights: FileRights? ): boolean
--- @overload fun( self: RawFileInstance, rights: FileRights? ): boolean
function INSTANCE:Open( ... )
    local args = { ... }
    local argCount = select( "#", ... )
    typecheck.AssertArgCount( INSTANCE.Class, argCount, { 0, 1, 2 } )

    --- @type FileRights
    local rights

    -- (): boolean
    if argCount == 0 then
        rights = fileRightsEnum.READ
    elseif argCount == 1 then
        local arg = typecheck.AssertArgType( STATIC.Class, 1, args[1], { "string", "number" } )

        if typecheck.IsOfType( arg, "string" ) then
            self:SetName( arg --[[@as string]] )
            rights = fileRightsEnum.READ
        elseif typecheck.IsOfType( arg, "number" ) then

            -- "
            -- Verify that there is a filename associated with this file object.
            -- If not, then this is a big error condition
            -- "
            if self.Filename == nil or self.Filename:len() == 0 then
                section.Error( "Failed to open file due to missing file name" )
            end
            rights = arg --[[@as FileRights]]
        end
    elseif argCount == 2 then
        local fileName = typecheck.AssertArgType( STATIC.Class, 1, args[1], "string" ) --[[@as string]]
        self:SetName( fileName )
        rights = typecheck.AssertArgType( STATIC.Class, 2, args[2], "number" ) --[[@as FileRights]]
    end

    self:Close()

    -- "
    -- Record the access rights used for this open call.
    -- These rights will be used if the file object is duplicated.
    -- "
    self.Rights = rights

    local fileMode = ( ( self.Rights == fileRightsEnum.READ ) and "rb" or "wb" )
    self.Handle = file.Open( self.Filename, fileMode, "THIRDPARTY" )

    -- "Biased files must be positioned past the bias start position."
    if self.BiasStart ~= 0 or self.BiasLength ~= -1 then
        self:Seek( 0, seekDirectionEnum.SEEK_SET )
    end

    -- "
    -- If the handle indicates the file is not open, then this is an error condition.
    -- For the case of the file cannot be found, then allow a retry.
    -- All other cases are fatal.
    -- "
    if self.Handle == nil then
        return false
    end

    return true
end

--- "Reads the specified number of bytes into a memory buffer"
--- @param size integer "The number of bytes to read"
--- @return string buffer The bytes read from the file
--- @return integer actualSize "... the number of bytes read into the buffer."
function INSTANCE:Read( size )
    -- "Running count of the number of bytes read into the buffer."
    local bytesRead = 0
    -- "Was the file opened by this routine?"
    local opened = false

    --- "If the file isn't opened, open it.  This serves as a convenience for the programmer."
    if not self:IsOpen() then
        -- "The error check here is moot.  Open will never return unless it succeeded."
        if not self:Open( fileRightsEnum.READ ) then
            return "", 0
        end
        opened = true
    end

    -- "A biased file has the requested read length limited to the bias length of the file."
    if self.BiasLength ~= -1 then
        local remainder = self.BiasLength - self:Seek( 0 )
        size = ( size < remainder ) and size or remainder
    end

    local total = 0
    local buffer = ""
    while size > 0 do
        bytesRead = 0

        local readBytes = self.Handle:Read( size )
        buffer = readBytes or buffer
        bytesRead = ( readBytes ~= nil ) and readBytes:len() or 0

        -- Omitted "readOk" check as I don't think there's a Lua equivalent

        size = size - bytesRead
        total = total + bytesRead
        if bytesRead == 0 then
            break
        end
    end
    bytesRead = total

    -- "Close the file if it was opened by this routine and return the actual number of bytes read into the buffer."
    if opened then
        self:Close()
    end

    return buffer, bytesRead
end

--- "Reposition the file pointer as indicated."
--- @param pos integer "The position to seek to.  This is interpreted as relative to the position indicated by the 'dir' parameter"
--- @param direction SeekDirection? [Default: `SEEK_CUR`] "The relative position to relate the seek to. This can be either `SEEK_SET` for the beginning of the file, `SEEK_CUR` for the current position, or `SEEK_END` for the end of the file.
--- @return integer "...the position that the seek ended up at."
function INSTANCE:Seek( pos, direction )
    direction = direction or seekDirectionEnum.SEEK_CUR

    --- "
    --- A file that is biased will have a seek operation modified so that the file appears to
    --- exist only within the bias range.  All bytes outside of this range appear to be
    --- non-0existant.
    --- "
    if self.BiasLength ~= -1 then
        if direction == seekDirectionEnum.SEEK_SET then
            if pos > self.BiasLength then
                pos = self.BiasLength
            end
            pos = pos + self.BiasStart

        elseif direction == seekDirectionEnum.SEEK_CUR then
            -- Empty in the original code

        elseif direction ==seekDirectionEnum.SEEK_END then
            direction = seekDirectionEnum.SEEK_SET
            pos = pos + self.BiasStart + self.BiasLength
        end

        -- "Perform the modified raw seek into the file."
        local newPos = self:RawSeek( pos, direction ) - self.BiasStart

        -- "Perform a final double check to make sure the file position fits with the bias range"
        if newPos < 1 then
            newPos = self:RawSeek( self.BiasStart, seekDirectionEnum.SEEK_SET ) - self.BiasStart
        end
        if newPos > self.BiasLength then
            newPos = self:RawSeek( self.BiasStart + self.BiasLength, seekDirectionEnum.SEEK_SET ) - self.BiasStart
        end

        return newPos
    end

    --- "
    --- If the file is not biased in any fashion, then the normal seek logic will work just fine.
    --- "
    return self:RawSeek( pos, direction )
end

--- "Determines the size of file (in bytes)."
--- @return integer # "...the number of bytes in the file."
function INSTANCE:Size()
    local size = 0

    -- "A biased file already has its length determined."
    if self.BiasLength ~= -1 then
        return self.BiasLength
    end

    -- "If the file is open, then proceed normally."
    if self:IsOpen() then
        size = self.Handle:Size()
    else

        --- "
        --- If the file wasn't open, then open the file and call this routine again.
        --- Count on the fact that the open function must succeed.
        ---"
        if self:Open() then
            size = self:Size()

            -- "Since we needed to open the file we must remember to close the file when the size has been determined"
            self:Close()
        end
    end

    self.BiasLength = size - self.BiasStart
    return self.BiasLength
end

function INSTANCE:Write()
    typecheck.NotImplementedError()
end

--- "Perform a closure of the file."
function INSTANCE:Close()

    --- "
    --- If the file is open, then close it.
    --- If the file is already closed, then just return.
    --- This isn't considered an error condition.
    --- "
    if self:IsOpen() then

        -- "Try to close the file."
        self.Handle:Close()

        -- Omitted error handling

        --- "
        --- At this point the file must have been closed.
        --- Mark the file as empty and return.
        ---"
        self.Handle = nil
    end
end

function INSTANCE:GetDateTime()
    typecheck.NotImplementedError()
end

function INSTANCE:SetDateTime()
    typecheck.NotImplementedError()
end

function INSTANCE:Error()
    typecheck.NotImplementedError()
end

--- @param start integer
--- @param length integer? [Default: -1]
function INSTANCE:Bias( start, length )
    length = length or -1

    if start == 1 then
        self.BiasStart = 0
        self.BiasLength = -1
        return
    end

    self.BiasLength = self:Size()
    self.BiasStart = self.BiasStart + start
    if length ~= -1 then
        self.BiasLength = ( ( self.BiasLength < length ) and self.BiasLength or length )
    end
    self.BiasLength = ( ( self.BiasLength > 0 ) and self.BiasLength or 0 )

    -- "Move the current file offset to a legal position if necessary and the file was open"
    if self:IsOpen() then
        self:Seek( 0, seekDirectionEnum.SEEK_SET )
    end
end

function INSTANCE:GetFileHandle()
    typecheck.NotImplementedError()
end

function INSTANCE:Attach()
    typecheck.NotImplementedError()
end

function INSTANCE:Detach()
    typecheck.NotImplementedError()
end

function INSTANCE:TransferBlockSize()
    typecheck.NotImplementedError()
end

--- "Performs a seek on the unbiased file"
--- @param pos integer
--- @param direction SeekDirection
--- @return integer # "...the new position of the seek operation."
function INSTANCE:RawSeek( pos, direction )
    -- "If the file isn't opened, then this is a fatal error condition"
    if not self:IsOpen() then
        section.Error( "Cannot seek in closed file: ", self.Filename )
    end

    if direction == seekDirectionEnum.SEEK_SET then
        -- Move to the provided position
        self.Handle:Seek( pos )

    elseif direction == seekDirectionEnum.SEEK_CUR then
        -- Move by the provided position relative to the current position
       self.Handle:Skip( pos )

    elseif direction == seekDirectionEnum.SEEK_END then
        -- Move to the provided position relative to the end of the file
        self.Handle:Seek( self.Handle:Size() - pos )
    end
    pos = self.Handle:Tell()

    -- "If there was an error in the seek, then bail with an error condition"
    if pos == 0xFFFFFFFF then
        section.Error( "Seek produced an error position: ", self.Filename )
    end

    --- "
    --- Return with the new possition of the file.
    --- This will be range between [one] and the number of bytes the file contains
    --- "
    return pos
end

--- Closes the file handle and resets the object's state.
function INSTANCE:Reset()
    self:Close()
    self.Filename = ""
end
