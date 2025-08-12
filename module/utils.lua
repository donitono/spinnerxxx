-- Utility Functions Module
-- Author: donitono
-- Date: 2025-08-12

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Utils = {}

function Utils.randomWait(minDelay, maxDelay)
    minDelay = minDelay or 0.1
    maxDelay = maxDelay or 0.3
    return math.random(minDelay * 1000, maxDelay * 1000) / 1000
end

function Utils.safeCall(func)
    local success, result = pcall(func)
    if not success then
        warn("Error: " .. tostring(result))
    end
    return success, result
end

function Utils.setWalkSpeed(speed)
    Utils.safeCall(function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end)
end

function Utils.setJumpPower(power)
    Utils.safeCall(function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = power
        end
    end)
end

function Utils.createNotification(text, color, gui)
    if not gui then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Parent = gui
    notification.BackgroundColor3 = color or Color3.fromRGB(0, 200, 0)
    notification.BorderSizePixel = 0
    notification.Position = UDim2.new(1, -250, 0, 50)
    notification.Size = UDim2.new(0, 240, 0, 50)
    notification.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = notification
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    
    -- Animate in
    notification:TweenPosition(
        UDim2.new(1, -260, 0, 50),
        "Out", "Quad", 0.3, true
    )
    
    -- Remove after 3 seconds
    task.wait(3)
    notification:TweenPosition(
        UDim2.new(1, 10, 0, 50),
        "In", "Quad", 0.3, true,
        function() notification:Destroy() end
    )
end

function Utils.antiAFK()
    task.spawn(function()
        while true do
            task.wait(300) -- Every 5 minutes
            Utils.safeCall(function()
                local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:Move(Vector3.new(0.1, 0, 0))
                    task.wait(0.1)
                    humanoid:Move(Vector3.new(-0.1, 0, 0))
                end
            end)
        end
    end)
end

return Utils