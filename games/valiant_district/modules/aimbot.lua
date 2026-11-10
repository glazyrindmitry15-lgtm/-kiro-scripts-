-- aimbot.lua | Kiro Scripts (Optimized: RMB-only targeting + Heartbeat throttling)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
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

-- FOV Circle (single Drawing object, no recreation)
local fovCircle = nil
pcall(function()
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 64
        fovCircle.Filled = false
        fovCircle.Color = Color3.fromRGB(138, 100, 255)
        fovCircle.Visible = false
    end
end)

-- Cached player models (updated 0.5s, not per-frame)
local cachedPlayers = {}
local lastPlayerUpdate = 0

local function refreshPlayers()
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(players, { model = plr.Character, player = plr })
        end
    end
    cachedPlayers = players
end

task.spawn(function()
    while true do
        refreshPlayers()
        task.wait(0.5)
    end
end)

local function getModels()
    return cachedPlayers
end

local function isEnemy(plr)
    if not G("Combat.TeamCheck", true) then return true end
    if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
    local lTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("team")
    if pTeam and lTeam then return pTeam ~= lTeam end
    return true
end

local function getPart(model)
    return model:FindFirstChild("Head")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("HumanoidRootPart")
end

local function hasLOS(model, part)
    if not G("Combat.WallCheck", true) then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character, model }
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local hit = workspace:Raycast(origin, dir, params)
    return hit == nil
end

-- Target cache (throttled)
local cachedTarget = nil
local lastTargetUpdate = 0

local function findTarget()
    if tick() - lastTargetUpdate < 0.1 then return cachedTarget end
    lastTargetUpdate = tick()

    local bestPart, bestScore = nil, math.huge
    local fov = G("Combat.FOV", 120)
    local mouse = UserInputService:GetMouseLocation()

    for _, entry in ipairs(getModels()) do
        if not isEnemy(entry.player) then continue end
        local part = getPart(entry.model)
        if not part then continue end
        local hum = entry.model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if not hasLOS(entry.model, part) then continue end

        local scr, on = Camera:WorldToViewportPoint(part.Position)
        if not on or scr.Z <= 0 then continue end

        local mouseDist = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
        if mouseDist > fov then continue end

        if mouseDist < bestScore then
            bestScore = mouseDist
            bestPart = part
        end
    end

    cachedTarget = bestPart
    return bestPart
end

-- RCS (Recoil Control)
local rcsOffset = Vector2.new(0, 0)

local function updateRCS()
    if not G("Combat.RCS", false) then
        rcsOffset = rcsOffset * 0.9
        return
    end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local strength = (G("Combat.RCSStrength", 80) or 80) / 100
        rcsOffset = rcsOffset + Vector2.new(0, strength * 0.5)
    else
        rcsOffset = rcsOffset * 0.85
    end
end

local function applyJitter(cframe)
    if not G("Combat.Aimbot", false) then return cframe end
    local jitter = 0.002
    local rx = (math.random() - 0.5) * jitter
    local ry = (math.random() - 0.5) * jitter
    return cframe * CFrame.Angles(rx, ry, 0)
end

-- Aim state (only active when RMB held)
local aimTarget = nil
local aimActive = false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimActive = true
        aimTarget = findTarget()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimActive = false
        aimTarget = nil
    end
end)

-- Main loop (Heartbeat, throttled)
RunService.Heartbeat:Connect(function()
    -- FOV circle
    if fovCircle then
        if G("Combat.ShowFOV", true) and G("Combat.Aimbot", false) then
            local mouse = UserInputService:GetMouseLocation()
            fovCircle.Position = mouse
            fovCircle.Radius = G("Combat.FOV", 120)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end

    updateRCS()

    if not G("Combat.Aimbot", false) then return end
    if not aimActive then
        aimTarget = nil
        return
    end

    -- Throttled target search (only when RMB held)
    if not aimTarget or not aimTarget.Parent then
        aimTarget = findTarget()
    end

    if aimTarget and aimTarget.Parent then
        local targetPos = aimTarget.Position

        local goal = CFrame.new(Camera.CFrame.Position, targetPos)
        goal = applyJitter(goal)

        if rcsOffset.Magnitude > 0.1 then
            goal = goal * CFrame.Angles(math.rad(rcsOffset.Y), math.rad(rcsOffset.X), 0)
        end

        local smoothness = G("Combat.Smoothness", 5) / 100
        smoothness = math.clamp(smoothness, 0.01, 1)
        Camera.CFrame = Camera.CFrame:Lerp(goal, smoothness)
    end
end)

print("[KIRO AIMBOT] Loaded (RMB-only + Heartbeat throttled). Game: " .. (K.GameId or "unknown"))
return K