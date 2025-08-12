-- Luck and Weather System Module
-- Author: donitono
-- Date: 2025-08-12

local LuckWeather = {}

-- Luck System
LuckWeather.LuckSystem = {
    baseChance = 0.1,
    boostMultiplier = 1.0,
    weatherMultiplier = 1.0,
    timeMultiplier = 1.0,
    spotMultiplier = 1.0,
    maxLuckLevel = 10,
    luckXP = 0,
    xpPerLevel = 100
}

-- Weather System
LuckWeather.WeatherTypes = {
    "Sunny", "Rainy", "Cloudy", "Stormy", "Foggy", "Windy"
}

LuckWeather.WeatherEffects = {
    Sunny = {luck = 1.2, fish_rate = 1.1, description = "☀️ Perfect fishing weather!"},
    Rainy = {luck = 1.5, fish_rate = 1.3, description = "🌧️ Fish are more active!"},
    Cloudy = {luck = 1.0, fish_rate = 1.0, description = "☁️ Normal conditions"},
    Stormy = {luck = 2.0, fish_rate = 0.8, description = "⛈️ Dangerous but lucky!"},
    Foggy = {luck = 1.8, fish_rate = 0.9, description = "🌫️ Mysterious waters"},
    Windy = {luck = 1.1, fish_rate = 1.2, description = "💨 Good for surface fish"}
}

LuckWeather.currentWeather = "Sunny"

-- Time Effects
LuckWeather.TimeEffects = {
    Dawn = {luck = 1.4, fish_rate = 1.2, description = "🌅 Golden hour fishing!"},
    Morning = {luck = 1.1, fish_rate = 1.1, description = "🌞 Good morning catch"},
    Noon = {luck = 0.9, fish_rate = 1.0, description = "☀️ Fish are hiding"},
    Evening = {luck = 1.3, fish_rate = 1.3, description = "🌆 Prime fishing time"},
    Night = {luck = 1.6, fish_rate = 0.8, description = "🌙 Rare night fish"},
    Midnight = {luck = 2.2, fish_rate = 0.6, description = "🌌 Legendary hour"}
}

-- Statistics
LuckWeather.Stats = {
    currentLuckLevel = 1,
    weatherBonuses = 0,
    timeBonuses = 0,
    rareFishCaught = 0,
    legendaryFishCaught = 0
}

function LuckWeather.calculateCurrentLuck(settings)
    local baseLuck = LuckWeather.LuckSystem.baseChance
    local totalMultiplier = LuckWeather.LuckSystem.boostMultiplier
    
    if settings and settings.WeatherBoost then
        totalMultiplier = totalMultiplier * (LuckWeather.WeatherEffects[LuckWeather.currentWeather].luck or 1.0)
    end
    
    if settings and settings.TimeBoost then
        local hour = tonumber(os.date("%H"))
        local timeKey = "Morning"
        if hour >= 5 and hour < 8 then timeKey = "Dawn"
        elseif hour >= 8 and hour < 12 then timeKey = "Morning"  
        elseif hour >= 12 and hour < 17 then timeKey = "Noon"
        elseif hour >= 17 and hour < 20 then timeKey = "Evening"
        elseif hour >= 20 and hour < 24 then timeKey = "Night"
        else timeKey = "Midnight" end
        
        totalMultiplier = totalMultiplier * (LuckWeather.TimeEffects[timeKey].luck or 1.0)
    end
    
    if settings and settings.LuckBoost then
        local levelBonus = 1 + (LuckWeather.Stats.currentLuckLevel * 0.1)
        totalMultiplier = totalMultiplier * levelBonus
    end
    
    return baseLuck * totalMultiplier
end

function LuckWeather.updateLuckLevel(createNotification)
    LuckWeather.LuckSystem.luckXP = LuckWeather.LuckSystem.luckXP + 1
    local requiredXP = LuckWeather.Stats.currentLuckLevel * LuckWeather.LuckSystem.xpPerLevel
    
    if LuckWeather.LuckSystem.luckXP >= requiredXP and LuckWeather.Stats.currentLuckLevel < LuckWeather.LuckSystem.maxLuckLevel then
        LuckWeather.Stats.currentLuckLevel = LuckWeather.Stats.currentLuckLevel + 1
        LuckWeather.LuckSystem.luckXP = 0
        if createNotification then
            createNotification("🍀 Luck Level Up! Level " .. LuckWeather.Stats.currentLuckLevel, Color3.fromRGB(0, 255, 0))
        end
        
        -- Bonus reward for leveling up
        if LuckWeather.Stats.currentLuckLevel % 5 == 0 then
            if createNotification then
                createNotification("🎁 Milestone Bonus! Special luck boost!", Color3.fromRGB(255, 215, 0))
            end
        end
    end
end

function LuckWeather.generateRandomWeather(createNotification)
    local oldWeather = LuckWeather.currentWeather
    LuckWeather.currentWeather = LuckWeather.WeatherTypes[math.random(1, #LuckWeather.WeatherTypes)]
    
    if LuckWeather.currentWeather ~= oldWeather then
        local effect = LuckWeather.WeatherEffects[LuckWeather.currentWeather]
        if createNotification then
            createNotification(effect.description, Color3.fromRGB(100, 200, 255))
        end
        LuckWeather.Stats.weatherBonuses = LuckWeather.Stats.weatherBonuses + 1
    end
end

function LuckWeather.getFishRarity()
    local luck = LuckWeather.calculateCurrentLuck()
    local roll = math.random()
    
    if roll <= luck * 0.001 then -- 0.1% base for mythical
        return "Mythical", Color3.fromRGB(255, 0, 255)
    elseif roll <= luck * 0.01 then -- 1% base for legendary  
        LuckWeather.Stats.legendaryFishCaught = LuckWeather.Stats.legendaryFishCaught + 1
        return "Legendary", Color3.fromRGB(255, 215, 0)
    elseif roll <= luck * 0.05 then -- 5% base for rare
        LuckWeather.Stats.rareFishCaught = LuckWeather.Stats.rareFishCaught + 1
        return "Rare", Color3.fromRGB(128, 0, 255)
    elseif roll <= luck * 0.15 then -- 15% base for uncommon
        return "Uncommon", Color3.fromRGB(0, 255, 0)
    else
        return "Common", Color3.fromRGB(255, 255, 255)
    end
end

function LuckWeather.simulateFishValue(rarity)
    local baseValues = {
        Common = {min = 10, max = 50},
        Uncommon = {min = 40, max = 120},
        Rare = {min = 100, max = 300},
        Legendary = {min = 250, max = 800},
        Mythical = {min = 500, max = 2000}
    }
    
    local range = baseValues[rarity]
    if range then
        return math.random(range.min, range.max)
    end
    return 25
end

function LuckWeather.startWeatherCycle(createNotification)
    task.spawn(function()
        while true do
            task.wait(math.random(300, 600)) -- Weather changes every 5-10 minutes
            LuckWeather.generateRandomWeather(createNotification)
        end
    end)
end

return LuckWeather