-- Fishing System Module
-- Author: donitono
-- Date: 2025-08-12

local Fishing = {}

-- Dependencies (akan di-load dari main script)
local Remotes, Utils, LuckWeather

function Fishing.init(remotes, utils, luckWeather)
    Remotes = remotes
    Utils = utils
    LuckWeather = luckWeather
end

function Fishing.smartFishingLogic(settings)
    if not settings.SmartFishing then return true end
    
    -- Skip fishing during low-luck periods
    local currentLuck = LuckWeather.calculateCurrentLuck(settings)
    if currentLuck < LuckWeather.LuckSystem.baseChance * 0.8 then
        return false
    end
    
    -- Check fish value filter
    if settings.FishValueFilter then
        local estimatedValue = math.random(10, 100) -- Simulate fish detection
        if estimatedValue < settings.MinFishValue then
            return false
        end
    end
    
    return true
end

function Fishing.enhancedAutoFishing(settings, stats, createNotification)
    task.spawn(function()
        while settings.AutoFishing do
            Utils.safeCall(function()
                -- Safety check - stop if player is in danger
                if settings.SafeMode then
                    local player = game:GetService("Players").LocalPlayer
                    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health < 20 then
                        warn("⚠️ Low health detected! Stopping auto fishing for safety.")
                        task.wait(5)
                        return
                    end
                end
                
                -- Smart fishing check
                if not Fishing.smartFishingLogic(settings) then
                    task.wait(Utils.randomWait() * 2) -- Wait longer during bad conditions
                    return
                end
                
                -- Add random delays to avoid detection
                task.wait(Utils.randomWait())
                
                local player = game:GetService("Players").LocalPlayer
                local char = player.Character or player.CharacterAdded:Wait()
                local equippedTool = char:FindFirstChild("!!!EQUIPPED_TOOL!!!")

                if not equippedTool then
                    Remotes.CancelFishing:InvokeServer()
                    task.wait(Utils.randomWait())
                    Remotes.EquipRod:FireServer(1)
                end

                task.wait(Utils.randomWait())
                Remotes.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
                
                task.wait(Utils.randomWait())
                Remotes.RequestFishing:InvokeServer(-1.2379989624023438, 0.9800224985802423)
                
                task.wait(0.4 + Utils.randomWait())
                Remotes.FishingComplete:FireServer()
                
                stats.fishCaught = stats.fishCaught + 1
                
                -- Simulate fish catch with luck system
                local rarity, color = LuckWeather.getFishRarity()
                local fishValue = LuckWeather.simulateFishValue(rarity)
                stats.moneyEarned = stats.moneyEarned + fishValue
                
                if rarity ~= "Common" then
                    if createNotification then
                        createNotification("🎣 Caught " .. rarity .. " fish! (₡" .. fishValue .. ")", color)
                    end
                    if rarity == "Legendary" or rarity == "Mythical" then
                        stats.bestFish = rarity .. " Fish"
                    end
                end
                
                -- Update luck XP
                LuckWeather.updateLuckLevel(createNotification)
                
                -- Auto sell when inventory might be full
                if settings.AutoSell and stats.fishCaught % 10 == 0 then
                    task.wait(1)
                    Utils.safeCall(function()
                        Remotes.sellAll:InvokeServer()
                        if createNotification then
                            createNotification("🛒 Auto-sold items! (₡" .. stats.moneyEarned .. ")", Color3.fromRGB(255, 215, 0))
                        end
                    end)
                end
            end)
        end
    end)
end

-- Implement other fishing methods (AFK2, Extreme, Brutal) dengan struktur yang sama...

return Fishing