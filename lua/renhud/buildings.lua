-- This file contains stubs for building-specific behavior that does not currently exist.
-- I don't have a good plan yet for how to handle buildings, so this file exists to
-- fill that gap until I figure out what I want to do for them.

--[[ Entity Extension Functions ]] do

    ---@class Entity
    local entMeta = FindMetaTable( "Entity" )

    --- [Renegade]
    --- @return boolean
    function entMeta:IsBuilding()
        return false
    end
end