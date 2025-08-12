-- Main Script - Updated to use modular approach
-- Author: donitono
-- Date: 2025-08-12

local CONFIG = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/spinnerxxx/main/modules/config.lua"))()

local success, error = pcall(function()

-- Load modules
print("🔄 Loading modules...")
local Remotes = loadstring(game:HttpGet(CONFIG.REPO_URL .. "remotes.lua"))()
local Utils = loadstring(game:HttpGet(CONFIG.REPO_URL .. "utils.lua"))()
local Security = loadstring(game:HttpGet(CONFIG.REPO_URL .. "security.lua"))()
local LuckWeather = loadstring(game:HttpGet(CONFIG.REPO_URL .. "luck-weather.lua"))()
local Fishing = loadstring(game:HttpGet(CONFIG.REPO_URL .. "fishing.lua"))()

-- Initialize fishing module with dependencies
Fishing.init(Remotes, Utils, LuckWeather)

print("✅ All modules loaded successfully!")

-- Rest of your main script logic here...
-- (GUI creation, event handlers, etc.)

end)

if not success then
    warn("❌ Script failed to load: " .. tostring(error))
else
    print("🎉 Modular script loaded successfully!")
end