-- Handles exporting classes from their scripts and and importing them as dependencies elsewhere

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class Imports
local LIB = {}

local CLASS = "Imports"

--- @type table<string, table>
--- @private
LIB.ExportedTables = {}

function LIB.GetOrCreateExport()
    local path
    --[[ Get the calling script's file path ]] do
        local info = debug.getinfo( 2 )
        local fullFilePath = info.source

        local startPos, endPos, _ = string.find( fullFilePath, "/lua", nil, true )

        if not endPos then
            typecheck.Error( CLASS, "Export", "Could not parse export script path. It does not appear to be a Lua file: " .. fullFilePath )
            error() -- To make LuaLS happy
        end

        path = string.sub( fullFilePath, endPos + 2 ):Trim()
    end

    local tbl = LIB.ExportedTables[path]

    -- If this has already been exported, re-use the existing table
    if tbl then
        return tbl
    end

    -- If we haven't exported this file before, create a new table for it
    tbl = {}
    LIB.ExportedTables[path] = tbl
    return tbl
end

--- Retrieves or creates a table for a new class or library to populate for importing into other scripts as a dependency
--- Other scripts can import this script's exported table by importing this script's file path starting with `/lua/` and ending in `.lua`
--- @return table # The table for this library to use.
function LIB.CreateExport()
    local path
    --[[ Get the calling script's file path ]] do
        local info = debug.getinfo( 2 )
        local fullFilePath = info.source

        local startPos, endPos, _ = string.find( fullFilePath, "/lua", nil, true )

        if not endPos then
            typecheck.Error( CLASS, "Export", "Could not parse export script path. It does not appear to be a Lua file: " .. fullFilePath )
            error() -- To make LuaLS happy
        end

        path = string.sub( fullFilePath, endPos + 2 ):Trim()
    end

    local tbl = LIB.ExportedTables[path]

    -- If this has already been exported, re-use the existing table
    if tbl then
        return tbl
    end

    -- If we haven't exported this file before, create a new table for it
    tbl = {}
    LIB.ExportedTables[path] = tbl
    return tbl
end

--- Returns an exported table exported from a script, only executing the script if it has not been imported elsewhere already.
--- @param path string The file path, ending in .lua, of the script to import
--- @return table
function LIB.Import( path )
    typecheck.AssertArgType( CLASS, 1, path, "string" )

    path = path:Trim()

    -- Execute the script if it hasn't already been imported elsewhere
    local tbl = LIB.ExportedTables[path]
    if not tbl then
        include( path )

        -- Confirm that the script exported something for us to import
        tbl = LIB.ExportedTables[path]
        if not tbl then
            typecheck.Error( CLASS, "Import", "No table was exported by script: " .. path )
        end
    end

    return tbl
end

CNC.Import = LIB.Import
CNC.CreateExport = LIB.CreateExport