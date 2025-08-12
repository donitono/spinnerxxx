-- Security System Module
-- Author: donitono
-- Date: 2025-08-12

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Security = {}

-- Security Settings
Security.Settings = {
    AdminDetection = true,
    PlayerProximityAlert = true,
    SuspiciousActivityLogger = true,
    AutoHideOnAdmin = true,
    ProximityDistance = 20,
    BlacklistedPlayers = {},
    WhitelistedPlayers = {}
}

-- Security Statistics
Security.Stats = {
    AdminsDetected = 0,
    ProximityAlerts = 0,
    AutoHides = 0,
    SuspiciousActivities = 0
}

function Security.isPlayerAdmin(targetPlayer)
    -- Check if player is admin/moderator
    if targetPlayer:GetRankInGroup(0) >= 100 then return true end
    if targetPlayer.Name:lower():find("admin") or targetPlayer.Name:lower():find("mod") then return true end
    if targetPlayer.DisplayName:lower():find("admin") or targetPlayer.DisplayName:lower():find("mod") then return true end
    
    -- Check for admin gamepass or badges (customize these IDs based on the game)
    local adminGamepasses = {123456, 789012} -- Replace with actual admin gamepass IDs
    for _, gamepassId in ipairs(adminGamepasses) do
        local success, owns = pcall(function()
            return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(targetPlayer.UserId, gamepassId)
        end)
        if success and owns then
            return true
        end
    end
    
    return false
end

function Security.logSuspiciousActivity(activity, playerName)
    Security.Stats.SuspiciousActivities = Security.Stats.SuspiciousActivities + 1
    local timestamp = os.date("%H:%M:%S")
    warn(string.format("🔒 [%s] Suspicious Activity: %s | Player: %s", timestamp, activity, playerName or "Unknown"))
end

function Security.getPlayerDistance(targetPlayer)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
    
    local distance = (player.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
    return distance
end

function Security.checkPlayerProximity(createNotification, gui)
    if not Security.Settings.PlayerProximityAlert then return end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local distance = Security.getPlayerDistance(targetPlayer)
            
            if distance <= Security.Settings.ProximityDistance then
                -- Check if player is blacklisted
                for _, blacklisted in ipairs(Security.Settings.BlacklistedPlayers) do
                    if targetPlayer.Name == blacklisted then
                        Security.Stats.ProximityAlerts = Security.Stats.ProximityAlerts + 1
                        if createNotification then
                            createNotification("⚠️ Blacklisted player nearby: " .. targetPlayer.Name, Color3.fromRGB(255, 0, 0))
                        end
                        Security.logSuspiciousActivity("Blacklisted player proximity", targetPlayer.Name)
                        
                        if Security.Settings.AutoHideOnAdmin and gui then
                            gui.Enabled = false
                            Security.Stats.AutoHides = Security.Stats.AutoHides + 1
                        end
                        break
                    end
                end
                
                -- Check if admin is nearby
                if Security.isPlayerAdmin(targetPlayer) then
                    Security.Stats.AdminsDetected = Security.Stats.AdminsDetected + 1
                    Security.Stats.ProximityAlerts = Security.Stats.ProximityAlerts + 1
                    if createNotification then
                        createNotification("🚨 ADMIN NEARBY: " .. targetPlayer.Name, Color3.fromRGB(255, 0, 0))
                    end
                    Security.logSuspiciousActivity("Admin proximity detected", targetPlayer.Name)
                    
                    if Security.Settings.AutoHideOnAdmin and gui then
                        gui.Enabled = false
                        Security.Stats.AutoHides = Security.Stats.AutoHides + 1
                    end
                end
            end
        end
    end
end

function Security.initializeMonitoring(createNotification, gui)
    -- Start proximity monitoring
    task.spawn(function()
        while true do
            Security.checkPlayerProximity(createNotification, gui)
            task.wait(2) -- Check every 2 seconds
        end
    end)
    
    -- Monitor for admin activity
    local connections = {}
    
    connections[#connections + 1] = Players.PlayerAdded:Connect(function(newPlayer)
        if Security.isPlayerAdmin(newPlayer) then
            Security.Stats.AdminsDetected = Security.Stats.AdminsDetected + 1
            if createNotification then
                createNotification("🚨 Admin joined server: " .. newPlayer.Name, Color3.fromRGB(255, 0, 0))
            end
            Security.logSuspiciousActivity("Admin joined server", newPlayer.Name)
        end
        
        newPlayer.Chatted:Connect(function(message)
            local adminCommands = {":ban", ":kick", ":warn", "/ban", "/kick", "/warn", ":tp", "/tp"}
            for _, command in ipairs(adminCommands) do
                if message:lower():find(command) then
                    if Security.isPlayerAdmin(newPlayer) then
                        if createNotification then
                            createNotification("🔴 Admin command detected!", Color3.fromRGB(255, 0, 0))
                        end
                        Security.logSuspiciousActivity("Admin command used: " .. command, newPlayer.Name)
                        
                        if Security.Settings.AutoHideOnAdmin and gui then
                            gui.Enabled = false
                            Security.Stats.AutoHides = Security.Stats.AutoHides + 1
                        end
                    end
                    break
                end
            end
        end)
    end)
    
    -- Check existing players
    for _, existingPlayer in pairs(Players:GetPlayers()) do
        if existingPlayer ~= player and Security.isPlayerAdmin(existingPlayer) then
            Security.Stats.AdminsDetected = Security.Stats.AdminsDetected + 1
            if createNotification then
                createNotification("🚨 Admin in server: " .. existingPlayer.Name, Color3.fromRGB(255, 0, 0))
            end
        end
    end
    
    return connections
end

return Security