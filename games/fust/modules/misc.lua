-- misc.lua | Kiro Scripts (Optimized: Zoom + Fullbright + Keybinds + Hitmarker + Viewmodel + CustomFOV + BombTimer)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

if not K.Notify then
    function K.Notify(title, text, ntype)
        print(string.format("[KIRO %s] %s: %s", ntype and ntype:upper() or "INFO", title, text))
    end
end

-- ============================================================
-- HITMARKER (center screen cross, 0.2s on damage)
-- ============================================================
local hitmarkerGui = Instance.new("ScreenGui")
hitmarkerGui.Name = "KiroHitmarker"
hitmarkerGui.ResetOnSpawn = false
hitmarkerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hitmarkerGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local hmContainer = Instance.new("Frame")
hmContainer.Size = UDim2.new(0, 40, 0, 40)
hmContainer.Position = UDim2.new(0.5, -20, 0.5, -20)
hmContainer.BackgroundTransparency = 1
hmContainer.ZIndex = 100
hmContainer.Parent = hitmarkerGui

local hmLines = {}
for i = 1, 4 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 8, 0, 2)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.ZIndex = 101
    line.Parent = hmContainer
    table.insert(hmLines, line)
end

local hmAngle = { 45, 135, 225, 315 }
for i, line in ipairs(hmLines) do
    line.Rotation = hmAngle[i]
    line.Position = UDim2.new(0.5, -4, 0.5, -1)
end

local hitActive = false
local hitEndTime = 0

local function showHitmarker()
    hitActive = true
    hitEndTime = tick() + 0.2
    for _, line in ipairs(hmLines) do
        line.Visible = true
    end
    -- play hit sound
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://131026769"
    s.Volume = 0.5
    s.Parent = SoundService
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

RunService.Heartbeat:Connect(function()
    if hitActive and tick() >= hitEndTime then
        hitActive = false
        for _, line in ipairs(hmLines) do
            line.Visible = false
        end
    end
    if hitActive then
        local alpha = 1 - math.min((tick() - (hitEndTime - 0.2)) / 0.2, 1)
        for _, line in ipairs(hmLines) do
            line.BackgroundTransparency = alpha
        end
    end
end)

-- Track damage: listen to local player's humanoid health changes
local function onHumanoid(hum)
    local lastHealth = hum.Health
    hum.HealthChanged:Connect(function(newHealth)
        if newHealth < lastHealth and G("Visuals.Hitmarker", false) then
            showHitmarker()
        end
        lastHealth = newHealth
    end)
end

if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then onHumanoid(hum) end
end
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    onHumanoid(hum)
end)

-- ============================================================
-- FULLBRIGHT (Lighting, throttled)
-- ============================================================
local lastFBUpdate = 0
RunService.Heartbeat:Connect(function()
    if not G("Misc.Fullbright", false) then return end
    if tick() - lastFBUpdate < 0.2 then return end
    lastFBUpdate = tick()

    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e6
    Lighting.GlobalShadows = false
end)

-- ============================================================
-- ZOOM (hold key, smooth FOV transition)
-- ============================================================
local zooming = false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local zoomKey = K.GetSetting("Camera.ZoomKey")
    if zoomKey and input.KeyCode == zoomKey then
        zooming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local zoomKey = K.GetSetting("Camera.ZoomKey")
    if zoomKey and input.KeyCode == zoomKey then
        zooming = false
    end
end)

RunService.Heartbeat:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    local defaultFOV = K.GetSetting("Camera.DefaultFOV") or 70
    local zoomFOV = K.GetSetting("Camera.ZoomFOV") or 40
    local targetFOV = zooming and zoomFOV or defaultFOV

    -- Smooth lerp
    cam.FieldOfView = cam.FieldOfView + (targetFOV - cam.FieldOfView) * 0.25
end)

-- ============================================================
-- CUSTOM FOV (CS:GO/FUST)
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not G("Camera.CustomFOV") then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local targetFOV = tonumber(K.GetSetting("Camera.CustomFOV")) or 70
    cam.FieldOfView = cam.FieldOfView + (targetFOV - cam.FieldOfView) * 0.15
end)

-- ============================================================
-- VIEWMODEL CHANGER (CS:GO/FUST) - offset camera CFrame
-- ============================================================
RunService.Heartbeat:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vx = tonumber(K.GetSetting("Camera.ViewmodelX")) or 0
    local vy = tonumber(K.GetSetting("Camera.ViewmodelY")) or 0
    local vz = tonumber(K.GetSetting("Camera.ViewmodelZ")) or 0
    if vx ~= 0 or vy ~= 0 or vz ~= 0 then
        cam.CFrame = cam.CFrame * CFrame.new(vx, vy, vz)
    end
end)

-- ============================================================
-- KEYBIND TOGGLES (ESP, Aimbot, Triggerbot, Fly, Speed, Noclip, etc.)
-- ============================================================
local keybindMap = {
    ESP = "Visuals.Enabled",
    Aimbot = "Combat.Aimbot",
    Triggerbot = "Combat.Triggerbot",
    Fly = "Misc.Fly",
    Speed = "Misc.Speed",
    Noclip = "Misc.Noclip",
    AutoRepair = "Utility.AutoRepair",
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    for name, path in pairs(keybindMap) do
        local kb = K.GetSetting("Keybinds." .. name)
        if kb and input.KeyCode == kb then
            local cur = K.GetSetting(path)
            K.SetSetting(path, not cur)
            if K.Notify then K.Notify(name, (not cur) and "Enabled" or "Disabled", "info") end
        end
    end
end)

print("[KIRO MISC] Loaded (Zoom + Fullbright + Keybinds + Hitmarker + Viewmodel + CustomFOV). Game: " .. (K.GameId or "unknown"))
return K