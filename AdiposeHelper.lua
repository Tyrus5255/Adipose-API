
local adiposeHelper = {}

local pehkui = require('Pehkui')
local adipose = require('Adipose')


adiposeHelper.syncTimer = config:load("adiposeHelper.syncTimer") or 200
adiposeHelper.weightRate = config:load("adiposeHelper.weightRate") or 0.1
adiposeHelper.enableWeightLoss = config:load("adiposeHelper.enableWeightLoss") or true

local foodQueue = 0

--Configs

--How many ticks between each adipose helper cycle, default : 200
function adiposeHelper.setSyncTimer(value)
    adiposeHelper.syncTimer = value
	config:save("adiposeHelper.syncTimer", value)
end


--Overall multiplier for weight gained/lost, default : 0.1
function adiposeHelper.setWeightRate(value)
    adiposeHelper.weightRate = value
	config:save("adiposeHelper.weightRate", value)
end

--Sets whether weight loss is enabled default : true
function adiposeHelper.setWeightLoss(value)
    adiposeHelper.enableWeightLoss = value
	config:save("adiposeHelper.enableWeightLoss", value)
end

--Helper Functions
local function bool_to_number(value)
	return value and 1 or 0
end


local function checkFood()
	
	local absWeight = (adipose.currentWeight-adipose.minWeight)/(adipose.maxWeight-adipose.minWeight)
	
	local gainThreshold = 2+(math.floor(10*(absWeight*9))/10)
	
	local deltaWeightGain = math.max((player:getSaturation() - gainThreshold) , 0)
	
	local deltaWeightLoss = (5*absWeight*math.max(16-player:getFood(),0)/20) * bool_to_number(adiposeHelper.enableWeightLoss)
	
	adiposeHelper.deltaWeight = (deltaWeightGain-deltaWeightLoss) * adiposeHelper.weightRate
	
	--print(deltaWeightGain, deltaWeightLoss, adiposeHelper.deltaWeight)
	
	return adiposeHelper.deltaWeight
end


adipose.setOnStageChange( function (amount, index, granularity, stuffed)
	for k, v in pairs(adipose.weightStages[index].scalingList) do
		pehkui.setScale(k, v)
	end
end)

local timer = adiposeHelper.syncTimer
local function doTimer() 
    if timer > 0 then
        timer = timer - 1
        return false
    else
		timer = adiposeHelper.syncTimer
        return true
    end
end

function events.tick()
	if not doTimer() or not player:isLoaded() then return end

	foodQueue = foodQueue + checkFood()
	
	local roundedFoodQueue = 0
	if foodQueue ~= 0 then roundedFoodQueue =((foodQueue/math.abs(foodQueue)) * math.floor(math.abs(foodQueue))) end
		
	if roundedFoodQueue ~= 0 then	
		foodQueue = foodQueue - math.floor(roundedFoodQueue)	
		
		weightDelta = adipose.currentWeight + math.floor(roundedFoodQueue)
		
		pings.AdiposeSetWeight(weightDelta)
	end
end

return adiposeHelper 