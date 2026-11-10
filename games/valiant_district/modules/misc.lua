-- misc.lua | Kiro Scripts
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}

if type(K.GetSetting) ~= "function" then
    function K.GetSetting(path)
        if type(path) ~= "string" then return nil end
        if K.Settings[path] ~= nil then return K.Settings[path] end
        local current = K.Settings
        for part in string.gmatch(path, "[^%.]+") do
            if type(current) == "table" and current[part] ~= nil then
                current = current[part]
            else
                return nil
            end
        end
        return current
    end
end

if type(K.SetSetting) ~= "function" then
    function K.SetSetting(path, value)
        if type(path) ~= "string" then return end
        K.Settings[path] = value
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        local current = K.Settings
        for i = 1, #parts - 1 do
            local key = parts[i]
            if type(current[key]) ~= "table" then current[key] = {} end
            current = current[key]
        end
        current[parts[#parts]] = value
    end
end

local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

-- Fullbright
RunService.RenderStepped:Connect(function()
    if G("Misc.Fullbright", false) then
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1e6
    end
end)

-- BunnyHop (handled in movement.lua, but kept here for compatibility)
-- No-Flash: remove flash effects
task.spawn(function()
    while task.wait(1) do
        if not G("Misc.Fullbright", false) then
            -- restore if needed
        end
    end
end)

print("[KIRO MISC] Loaded. Game: " .. (K.GameId or "unknown"))
return K
-- Zoom on key (hold)
local zooming = false
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local zoomKey = K.GetSetting("Camera.ZoomKey")
    if zoomKey and input.KeyCode == zoomKey then
        zooming = true
    end
    -- Keybind toggles
    for name, path in pairs({
        ESP = "Visuals.Enabled",
        Aimbot = "Combat.Aimbot",
        Triggerbot = "Combat.Triggerbot",
        Fly = "Misc.Fly",
        Speed = "Misc.Speed",
        Noclip = "Misc.Noclip",
        AutoRepair = "Utility.AutoRepair",
    }) do
        local kb = K.GetSetting("Keybinds." .. name)
        if kb and input.KeyCode == kb then
            local cur = K.GetSetting(path)
            K.SetSetting(path, not cur)
            if K.Notify then K.Notify(name, (not cur) and "Enabled" or "Disabled", "info") end
        end
    end
end)
UIS.InputEnded:Connect(function(input)
    local zoomKey = K.GetSetting("Camera.ZoomKey")
    if zoomKey and input.KeyCode == zoomKey then
        zooming = false
    end
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local defaultFOV = K.GetSetting("Camera.DefaultFOV") or 70
    local zoomFOV = K.GetSetting("Camera.ZoomFOV") or 40
    if zooming then
        cam.FieldOfView = cam.FieldOfView + (zoomFOV - cam.FieldOfView) * 0.3
    else
        cam.FieldOfView = cam.FieldOfView + (defaultFOV - cam.FieldOfView) * 0.3
    end
end)
