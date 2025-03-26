-- Based on Code/Combat/objectives.cpp

--- @class Renegade
--- @field ObjectiveManager ObjectiveManager

CNC_RENEGADE.ObjectiveManager = CNC_RENEGADE.ObjectiveManager or {}

--- @class ObjectiveManager
local STATIC = CNC_RENEGADE.ObjectiveManager

--- @enum ObjectiveType
STATIC.ObjectiveType = {
    TYPE_PRIMARY    = 0,
    TYPE_SECONDARY  = 1,
    TYPE_TERTIARY   = 2
}

--- @enum ObjectiveStatus
STATIC.ObjectiveStatus = {
    STATUS_IS_PENDING   = 0,
    STATUS_ACCOMPLISHED = 1,
    STATUS_FAILED       = 2,
    STATUS_HIDDEN       = 3
}

