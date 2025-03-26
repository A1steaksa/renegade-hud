if not CLIENT then return end

local testCount = 100000

---
--- Test A
---
local aTestName = "Calling Surface.GetTextSize a lot"

-- Runs once before test A
local function PreTestA()
    surface.CreateFont( "TestFont", {
        font = "Arial MT",
        size = 14,
        antialias = false
    } )
    surface.SetFont( "TestFont" )
end

local function TestA()
    local char = "D"
    local width, height = surface.GetTextSize( char )
    return width
end

-- Runs once after test A
local function PostTestA()
    
end

---
--- Test B
---
local bTestName = "Creating a character size cache"

local cache = {}

-- Runs once before test B
local function PreTestB()
    cache = {}
end

local function TestB()
    local char = "D"
    if not cache[char] then
        local width, height = surface.GetTextSize( char )
        cache[char] = { Width = width, Height = height }
    end

    return cache[char].Width
end

-- Runs once after test B
local function PostTestB()
end

local function RunTests()
    -- Setup tests
    PreTestA()
    PreTestB()

    -- Run Tests
    local aStartTime = SysTime()
    for i = 1, testCount do
        TestA()
    end
    local aEndTime = SysTime()

    local bStartTime = SysTime()
    for i = 1, testCount do
        TestB()
    end
    local bEndTime = SysTime()

    -- Tear down tests
    PostTestA()
    PostTestB()

    -- Calculate timings
    local aDuration = aEndTime - aStartTime
    local bDuration = bEndTime - bStartTime

    local aDurationPerTest = aDuration / testCount
    local bDurationPerTest = bDuration / testCount

    local totalDuration = bEndTime - aStartTime

    print( "The tests \"" .. aTestName .. "\" and \"" .. bTestName .. "\" each ran for " .. testCount .. " iterations over " .. totalDuration .. " seconds" )
    print( "The test \"" .. aTestName .. "\" started at " .. aStartTime .. " and ended at " .. aEndTime .. " for a total duration of " .. aDuration .. " seconds, or " .. aDurationPerTest .. " seconds per test on average" )
    print( "The test \"" .. bTestName .. "\" started at " .. bStartTime .. " and ended at " .. bEndTime .. " for a total duration of " .. bDuration .. " seconds, or " .. bDurationPerTest .. " seconds per test on average" )

    local percentage = ( 1 - ( math.min( aDurationPerTest, bDurationPerTest ) * 1000 ) / ( math.max( aDurationPerTest, bDurationPerTest ) * 1000 ) ) * 100

    print( "Based on these results, " .. ( ( aDurationPerTest > bDurationPerTest ) and bTestName or aTestName ) .. " is faster by " .. percentage .. "%" )

end

concommand.Add( "runtest", RunTests )