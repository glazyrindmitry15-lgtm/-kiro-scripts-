-- misc.lua | Kiro Scripts — hitmarker, fullbright, zoom, viewmodel, keybinds
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

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
-- HITMARKER
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
    line.Size = UDim2.new(0, 9, 0, 2)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(0.5, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.ZIndex = 101
    line.Visible = false
    line.Parent = hmContainer
    table.insert(hmLines, line)
end

local hmAngle = { 45, 135, 225, 315 }
local hmDist = 11
for i, line in ipairs(hmLines) do
    local rad = math.rad(hmAngle[i])
    line.Rotation = hmAngle[i]
    line.Position = UDim2.new(0.5, math.cos(rad) * hmDist, 0.5, math.sin(rad) * hmDist)
end

local hitActive = false
local hitEndTime = 0

local function showHitmarker()
    hitActive = true
    hitEndTime = tick() + 0.2
    for _, line in ipairs(hmLines) do
        line.Visible = true
        line.BackgroundTransparency = 0
    end
end

RunService.Heartbeat:Connect(function()
    if not hitActive then return end
    local t = tick()
    if t >= hitEndTime then
        hitActive = false
        for _, line in ipairs(hmLines) do line.Visible = false end
        return
    end
    local alpha = 1 - math.min((t - (hitEndTime - 0.2)) / 0.2, 1)
    for _, line in ipairs(hmLines) do line.BackgroundTransparency = alpha end
end)

-- consumes the flag set by aimbot / triggerbot when the player lands a hit
RunService.Heartbeat:Connect(function()
    if not G("Visuals.Hitmarker", false) then return end
    if K._lastPlayerDamageTime and (tick() - K._lastPlayerDamageTime) < 0.2 then
        showHitmarker()
        K._lastPlayerDamageTime = nil
    end
end)

-- ============================================================
-- FULLBRIGHT
-- ============================================================
local lastFB = 0
RunService.Heartbeat:Connect(function()
    if not G("Misc.Fullbright", false) then return end
    if tick() - lastFB < 0.2 then return end
    lastFB = tick()

    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e6
    Lighting.GlobalShadows = false
end)

-- ============================================================
-- ZOOM
-- ============================================================
local zooming = false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local zoomKey = K.GetSetting("Camera.ZoomKey")
    if zoomKey and input.KeyCode == zoomKey and G("Misc.Zoom", false) then
        zooming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local zoomKey = K.GetSetting("Camera.ZoomKey")
    if zoomKey and input.KeyCode == zoomKey then zooming = false end
end)

-- ============================================================
-- CAMERA FX (FOV + viewmodel) — runs AFTER the game camera
-- Zoom and CustomFOV used to write FieldOfView in two separate loops
-- every frame and fight each other. Now one loop with a priority chain.
-- ============================================================
local lastCamClock = os.clock()

RunService:BindToRenderStep("KiroCameraFX", Enum.RenderPriority.Camera.Value + 2, function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    local nowClock = os.clock()
    local dt = nowClock - lastCamClock
    lastCamClock = nowClock
    if dt <= 0 or dt > 0.1 then dt = 1 / 60 end

    local defaultFOV = tonumber(K.GetSetting("Camera.DefaultFOV")) or 70
    local zoomFOV = tonumber(K.GetSetting("Camera.ZoomFOV")) or 40

    -- priority: zoom > default (CustomFOV used to override both every frame)
    local target = zooming and zoomFOV or defaultFOV

    if math.abs(cam.FieldOfView - target) > 0.01 then
        -- 0.25 per frame at 60fps -> rate 17/s, applied over dt
        cam.FieldOfView = cam.FieldOfView + (target - cam.FieldOfView) * (1 - math.exp(-17 * dt))
    end

    -- viewmodel offset: only when the aimbot is not moving the camera,
    -- otherwise the two would shift the aim together
    local vx = tonumber(K.GetSetting("Camera.ViewmodelX")) or 0
    local vy = tonumber(K.GetSetting("Camera.ViewmodelY")) or 0
    local vz = tonumber(K.GetSetting("Camera.ViewmodelZ")) or 0
    if (vx ~= 0 or vy ~= 0 or vz ~= 0) and not G("Combat.Aimbot", false) then
        cam.CFrame = cam.CFrame * CFrame.new(vx, vy, vz)
    end
end)

-- ============================================================
-- KEYBINDS
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
            if K.Notify then
                K.Notify(name, (not cur) and "Enabled" or "Disabled", "info")
            end
        end
    end
end)

print("[KIRO MISC] Loaded. Game: " .. (K.GameId or "unknown"))
return K