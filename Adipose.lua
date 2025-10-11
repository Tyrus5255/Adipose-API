---@class Adipose
local adipose = {}

-- CONSTANTS

adipose.minWeight = 100
adipose.maxWeight = 1000

-- VARIABLES

adipose.currentWeight = config:load("adipose.currentWeight") or adipose.minWeight
adipose.currentWeightStage = config:load("adipose.currentWeightStage") or 1
adipose.granularWeight = 0
adipose.stuffed = 0

-- Previous index used by setWeight()
local oldindex = nil

-- Whether the player is dead
local isDead = false

-- Maintain table of nearby players
local knownReceivers = {}

-- Timer used to check for nearby players
local timerDuration = 40
local timer = timerDuration

-- FUNCTIONS
adipose.onStageChange = function(_, _, _, _) end

--- Set function that will be called when weight stage changes
--- @param callback fun(weight: number, index: number, granularity: number, stuffed: number)
function adipose.setOnStageChange(callback)
    adipose.onStageChange = callback
end

--- Calculate weight from index
---@param index integer Index for weight stage table
---@return number weight Weight between minimum and maximum
local function calculateWeightFromIndex(index)
    if index == #adipose.weightStages + 1 then return adipose.maxWeight end

    local normalized = (index - 1) / (#adipose.weightStages)
    local weight = adipose.minWeight + normalized * (adipose.maxWeight - adipose.minWeight)

    return weight
end

--- Calculate progress from weight
---@param weight number Weight
---@return integer index Index for weight stage table
---@return number granularity Fractional value of weight between stages
local function calculateProgressFromWeight(weight)
    local normalized = (weight - adipose.minWeight) / (adipose.maxWeight - adipose.minWeight)
    local exactWeightStage = normalized * #adipose.weightStages + 1

    if exactWeightStage == #adipose.weightStages + 1 then
        return #adipose.weightStages, 1
    end

    local index = math.floor(exactWeightStage)
    local granularity = exactWeightStage - index

    return index, granularity
end

--- Update timer value
---@return boolean tick Whether timer has ticked
local function doTimer()
    if timer > 0 then
        timer = timer - 1
        return false
    else
        timer = timerDuration
        return true
    end
end

-- MODEL FUNCTIONS

--- Set visibility of model parts
---@param index integer Index for weight stage table
local function setModelPartsVisibility(index)
    local visibleParts = {}
    for _, p in ipairs(adipose.weightStages[index].partsList) do
        visibleParts[p] = true
    end

    for _, s in ipairs(adipose.weightStages) do
        for _, p in ipairs(s.partsList) do
            p:setVisible(visibleParts[p] == true)
        end
    end
end

--- Set offset of granularity animation
---@param index integer Index for weight stage table
---@param granularity number Fractional value of animation length
local function setGranularity(index, granularity)
    for i, stage in ipairs(adipose.weightStages) do
        local animation = stage.granularAnim

        if animation then
            if index == i then
                animation:play()
                animation:setSpeed(0)

                local offset = animation:getLength() * granularity
                animation:setOffset(offset)
            else
                animation:stop()
            end
        end
    end
end

-- Stuffed override value
local stuffedOverride = nil

--- Set override stuffed value
--- Used in setStuffed
--- @param stuffed number | nil Fractional value of animation length or nil to disable override
function adipose.setStuffedOverride(stuffed)
    stuffedOverride = stuffed
end

--- Set offset of stuffed animation
--- May be overriden by setStuffedOverride()
---@param index integer Index for weight stage table
---@param stuffed number Fractional value of animation length
local function setStuffed(index, stuffed)
    if stuffedOverride ~= nil then
        stuffed = stuffedOverride
    end

    for i, stage in ipairs(adipose.weightStages) do
        local animation = stage.stuffedAnim

        if animation then
            if index == i then
                animation:play()
                animation:setSpeed(0)

                local offset = animation:getLength() * stuffed
                animation:setOffset(offset)
            else
                animation:stop()
            end
        end
    end
end

-- EVENTS

-- Set weight when player respawns
function events.tick()
    -- Check health of player
    if player:getHealth() <= 0 then
        -- Player is dead
        if not isDead then
            -- Remember the player has died for when they respawn
            isDead = true
        end
    else
        -- Player is alive
        if isDead then
            -- Player was dead a moment ago and has now respawned
            pings.AdiposeSetWeight(adipose.currentWeight, true)
            -- Remember player is now alive
            isDead = false
        end
    end
end

-- Set weight when players enter range
function events.tick()
    if not doTimer() then return end

    local doPing = false
    local newReceivers = {}

    for _, v in pairs(world:getPlayers()) do
        local uuid = v:getUUID()

        if uuid ~= avatar:getUUID() then
            newReceivers[uuid] = true

            if not knownReceivers[uuid] then doPing = true end
        end
    end

    knownReceivers = newReceivers
    if doPing then pings.AdiposeSetWeight(adipose.currentWeight, true) end
end

-- Set weight after a delay when script is loaded
if host:isHost() then
    local initTimer = 25

    events.TICK:register(function()
        if initTimer > 0 then
            initTimer = initTimer - 1
            return
        end

        pings.AdiposeSetWeight(adipose.currentWeight)
        events.TICK:remove("InitAdiposeModel")
    end, "InitAdiposeModel")
end

-- WEIGHT MANAGEMENT

--- Set weight
---@param amount number Weight value
---@param forceUpdate boolean? Ignore stage change condition (optional, default false)
function adipose.setWeight(amount, forceUpdate)
    if #adipose.weightStages == 0 then return end

    amount = math.clamp(amount, adipose.minWeight, adipose.maxWeight)

    local index, granularity = calculateProgressFromWeight(amount)
    local stuffed = player:isLoaded() and player:getSaturation() / 20 or 0

    adipose.currentWeight = amount
    adipose.currentWeightStage = index
    adipose.granularWeight = granularity
    adipose.stuffed = stuffed

    if oldindex ~= index or forceUpdate then
        oldindex = index
        adipose.onStageChange(amount, index, granularity, stuffed)
        setModelPartsVisibility(index)
    end

    setGranularity(index, granularity)
    setStuffed(index, stuffed)

    config:save("adipose.currentWeight", math.floor(adipose.currentWeight * 10) / 10)
    config:save("adipose.currentWeightStage", adipose.currentWeightStage)
end

pings.AdiposeSetWeight = adipose.setWeight

--- Set current weight stage
---@param stage integer Index for weight stage table
function adipose.setCurrentWeightStage(stage)
    stage = math.clamp(math.floor(stage), 1, #adipose.weightStages + 1)
    pings.AdiposeSetWeight(calculateWeightFromIndex(stage))
end

--- Adjust weight by value
---@param amount number Weight value to gain (may be negative to lose weight)
function adipose.adjustWeightByAmount(amount)
    amount = math.clamp((adipose.currentWeight + math.floor(amount)),
        adipose.minWeight, adipose.maxWeight)
    pings.AdiposeSetWeight(amount)
end

--- Adjust weight by index
---@param amount integer Weight stage to gain (may be negative to lose weight)
function adipose.adjustWeightByStage(amount)
    amount = math.clamp((adipose.currentWeightStage + math.floor(amount)),
        1, #adipose.weightStages + 1)
    pings.AdiposeSetWeight(calculateWeightFromIndex(amount))
end

-- WEIGHT STAGE

---@class Adipose.WeightStage
adipose.weightStage = {}
adipose.weightStage.__index = adipose.weightStage

---@class Adipose.WeightStage[]
adipose.weightStages = {}

--- Create new stage
---@return Adipose.WeightStage
function adipose.weightStage:newStage()
    local obj = setmetatable({
        partsList = {},
        granularAnim = nil,
        stuffedAnim = nil,
        scalingList = {},
    }, self)

    table.insert(adipose.weightStages, obj)
    return obj
end

--- Set parts
---@param parts ModelPart|[ModelPart]
---@return Adipose.WeightStage
function adipose.weightStage:setParts(parts)
    -- Validate type of parts
    assert(type(parts) == "ModelPart" or type(parts) == "table", "Invalid parts")

    -- If parts is a table, validate the contents
    if type(parts) == "table" then
        for i, p in ipairs(parts) do
            assert(type(p) == "ModelPart", "Invalid part " .. tostring(i))
        end
    end

    self.partsList = parts
    return self
end

--- Set granular animation
---@param animation Animation
---@return Adipose.WeightStage
function adipose.weightStage:setGranularAnimation(animation)
    self.granularAnim = animation
    return self
end

--- Set stuffed animation
---@param animation Animation
---@return Adipose.WeightStage
function adipose.weightStage:setStuffedAnimation(animation)
    self.stuffedAnim = animation
    return self
end

--- Set scaling table
---@param scaling table<string, number>
---@return Adipose.WeightStage
function adipose.weightStage:setScaling(scaling)
    self.scalingList = scaling
    return self
end

return adipose
