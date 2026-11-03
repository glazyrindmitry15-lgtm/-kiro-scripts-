-- aimbot.lua | Kiro Scripts
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

-- Helpers
local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

local function S(path, value)
    K.SetSetting(path, value)
end

-- FOV Circle
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

-- Cached models
local cachedModels = {}
local lastModelUpdate = 0

local function refreshModels()
    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(models, {model = plr.Character, player = plr})
            seen[plr.Character] = true
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local m = d.Parent
            if m and m:IsA("Model") and m ~= LocalPlayer.Character and not seen[m] then
                if LocalPlayer.Character and m:IsDescendantOf(LocalPlayer.Character) then continue end
                table.insert(models, {model = m, player = nil})
                seen[m] = true
            end
        end
    end
    cachedModels = models
end

task.spawn(function()
    while true do
        refreshModels()
        task.wait(0.5)
    end
end)

local function getModels()
    return cachedModels
end

local function isEnemy(entry)
    if not G("Combat.TeamCheck", true) then return true end
    local plr = entry.player
    if plr then
        if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
        local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
        local lTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("team")
        if pTeam and lTeam then return pTeam ~= lTeam end
    end
    return true
end

local function getPart(model)
    local partName = "Head"
    local part = model:FindFirstChild(partName)
    if not part then
        part = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
    end
    return part
end

local function hasLOS(model, part)
    if not G("Combat.WallCheck", true) then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, model}
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local hit = workspace:Raycast(origin, dir, params)
    return hit == nil
end

-- Throttled target search
local cachedTarget = nil
local lastTargetUpdate = 0

local function findTarget()
    if tick() - lastTargetUpdate < 0.15 then return cachedTarget end
    lastTargetUpdate = tick()

    local bestPart, bestScore = nil, math.huge
    local fov = G("Combat.FOV", 120)
    local mouse = UserInputService:GetMouseLocation()

    for _, entry in ipairs(getModels()) do
        if not isEnemy(entry) then continue end
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

-- RCS (Recoil Control) - only for CS:GO
local rcsEnabled = false
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

-- Humanizer: jitter
local function applyJitter(cframe)
    if not G("Combat.Aimbot", false) then return cframe end
    -- simple jitter
    local jitter = 0.002
    local rx = (math.random() - 0.5) * jitter
    local ry = (math.random() - 0.5) * jitter
    return cframe * CFrame.Angles(rx, ry, 0)
end

-- Aim target
local aimTarget = nil

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and G("Combat.Aimbot", false) then
        aimTarget = findTarget()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimTarget = nil
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
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
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        aimTarget = nil
        return
    end

    if not aimTarget or not aimTarget.Parent then
        aimTarget = findTarget()
    end

    if aimTarget and aimTarget.Parent then
        local targetPos = aimTarget.Position

        -- Silent aim: just adjust camera slightly
        local goal = CFrame.new(Camera.CFrame.Position, targetPos)
        goal = applyJitter(goal)

        -- RCS compensation
        if rcsOffset.Magnitude > 0.1 then
            goal = goal * CFrame.Angles(math.rad(rcsOffset.Y), math.rad(rcsOffset.X), 0)
        end

        local smoothness = G("Combat.Smoothness", 5) / 100
        smoothness = math.clamp(smoothness, 0.01, 1)
        Camera.CFrame = Camera.CFrame:Lerp(goal, smoothness)
    end
end)

print("[KIRO AIMBOT] Loaded. Game: " .. (K.GameId or "unknown"))
return K