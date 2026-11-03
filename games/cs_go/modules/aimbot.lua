-- =====================================================================
-- AIMBOT | Smart Aim + RCS + Humanizer
-- =====================================================================
local K = shared.KIRO
if not K then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local gameId = K.GameId or "unknown"

-- RCS (Recoil Control) - только для cs_go
local rcsEnabled = (gameId == "cs_go")
local rcsStrength = 0.3

-- Humanizer settings
local jitterAmount = 0.3
local smoothCurve = "SmoothStep"

-- Priority modes: "closest_crosshair", "lowest_hp", "closest_distance"
local priorityMode = "closest_crosshair"

local fovCircle
if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(255, 140, 0)
    fovCircle.Visible = false
end

local cachedModels = {}
local lastModelUpdate = 0

local cachedTarget = nil
local lastTargetUpdate = 0

local function getModels()
    if tick() - lastModelUpdate < 0.3 then return cachedModels end
    lastModelUpdate = tick()
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            table.insert(models, {model = plr.Character, player = plr})
            seen[plr.Character] = true
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local m = d.Parent
            if m and m:IsA("Model") and m ~= LP.Character and not seen[m] then
                if LP.Character and m:IsDescendantOf(LP.Character) then continue end
                table.insert(models, {model = m, player = nil})
                seen[m] = true
            end
        end
    end
    cachedModels = models
    return models
end

local function isEnemy(entry)
    if not K.GetSetting("Aimbot.TeamCheck") then return true end
    local plr = entry.player
    if plr then
        if plr.Team and LP.Team then return plr.Team ~= LP.Team end
        local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
        local lTeam = LP:GetAttribute("Team") or LP:GetAttribute("team")
        if pTeam and lTeam then return pTeam ~= lTeam end
    end
    local mTeam = entry.model:GetAttribute("Team") or entry.model:GetAttribute("team")
    local lTeam = LP:GetAttribute("Team") or LP:GetAttribute("team")
    if mTeam and lTeam then return mTeam ~= lTeam end
    return true
end

local function getPart(model, partName)
    partName = partName or (K.GetSetting("Aimbot.Part") or "Head")
    local part = model:FindFirstChild(partName)
    if not part then
        part = model:FindFirstChild("Head") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    end
    return part
end

local function getHP(entry)
    local hum = entry.model:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    return 100, 100
end

local function hasLOS(model, part)
    if not K.GetSetting("Aimbot.VisibleOnly") then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character, model}
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local hit = workspace:Raycast(origin, dir, params)
    return hit == nil
end

-- Priority scoring
local function getScore(entry, part)
    local mode = priorityMode
    local mouse = UIS:GetMouseLocation()
    local scr, on = Camera:WorldToViewportPoint(part.Position)
    if not on then return math.huge end

    if mode == "closest_crosshair" then
        return (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
    elseif mode == "lowest_hp" then
        local hp, maxHp = getHP(entry)
        return hp -- lower is better
    elseif mode == "closest_distance" then
        local dist = 0
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            dist = (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude
        end
        return dist
    end
    return (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
end

local function closest()
    if tick() - lastTargetUpdate < 0.15 then return cachedTarget end
    lastTargetUpdate = tick()
    local fov = K.GetSetting("Aimbot.FOV") or 150
    for _, entry in ipairs(getModels()) do
        if not isEnemy(entry) then continue end
        local part = getPart(entry.model)
        if not part then continue end
        local hum = entry.model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if not hasLOS(entry.model, part) then continue end

        local scr, on = Camera:WorldToViewportPoint(part.Position)
        if not on or scr.Z <= 0 then continue end

        local mouseDist = (Vector2.new(scr.X, scr.Y) - UIS:GetMouseLocation()).Magnitude
        if mouseDist > fov then continue end

        local score = getScore(entry, part)
        if score < bestScore then
            bestScore = score
            bestPart = part
        end
    end
    cachedTarget = bestPart
    return bestPart
end

-- Humanizer: jitter
local function applyJitter(cframe)
    if not K.GetSetting("Aimbot.Humanize") then return cframe end
    local jitter = (K.GetSetting("Aimbot.Jitter") or 0.4) * 0.01
    local rx = (math.random() - 0.5) * jitter
    local ry = (math.random() - 0.5) * jitter
    local rz = (math.random() - 0.5) * jitter
    return cframe * CFrame.Angles(rx, ry, rz)
end

-- Smooth curve functions
local function smoothStep(t)
    return t * t * (3 - 2 * t)
end

local function easeIn(t)
    return t * t
end

local function easeOut(t)
    return 1 - (1 - t) * (1 - t)
end

local function getSmoothFactor()
    local curve = K.GetSetting("Aimbot.SmoothCurve") or "SmoothStep"
    local base = K.GetSetting("Aimbot.Smoothness") or 0.3
    if curve == "SmoothStep" then return smoothStep(base)
    elseif curve == "EaseIn" then return easeIn(base)
    elseif curve == "EaseOut" then return easeOut(base)
    else return base end
end

-- RCS compensation
local lastShotTime = 0
local rcsOffset = Vector2.new(0, 0)

local function updateRCS()
    if not rcsEnabled then return end
    if not K.GetSetting("Combat.NoRecoil") then return end
    -- check if shooting
    if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        rcsOffset = rcsOffset + Vector2.new(0, rcsStrength)
    else
        rcsOffset = rcsOffset * 0.9 -- decay
    end
end

-- Aim target
local aimTarget = nil

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and K.GetSetting("Aimbot.Enabled") then
        aimTarget = closest()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimTarget = nil
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    -- FOV circle
    if fovCircle then
        if K.GetSetting("Aimbot.DrawFOV") and K.GetSetting("Aimbot.Enabled") then
            local mouse = UIS:GetMouseLocation()
            fovCircle.Position = mouse
            fovCircle.Radius = K.GetSetting("Aimbot.FOV") or 150
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end

    updateRCS()

    if not K.GetSetting("Aimbot.Enabled") then return end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        aimTarget = nil
        return
    end

    if not aimTarget or not aimTarget.Parent then
        aimTarget = closest()
    end

    if aimTarget and aimTarget.Parent then
        local targetPos = aimTarget.Position
        -- prediction
        local prediction = K.GetSetting("Aimbot.Prediction") or 0
        if prediction > 0 then
            -- simple velocity prediction
            local part = aimTarget
            if part and part.Parent then
                local vel = Vector3.new(0, 0, 0)
                local hrp = part.Parent:FindFirstChild("HumanoidRootPart")
                if hrp then vel = hrp.Velocity end
                targetPos = targetPos + vel * prediction
            end
        end

        local goal = CFrame.new(Camera.CFrame.Position, targetPos)
        goal = applyJitter(goal)

        -- RCS compensation
        if rcsEnabled and rcsOffset.Magnitude > 0.1 then
            goal = goal * CFrame.Angles(math.rad(rcsOffset.Y), math.rad(rcsOffset.X), 0)
        end

        local smoothFactor = getSmoothFactor()
        Camera.CFrame = Camera.CFrame:Lerp(goal, smoothFactor)
    end
end)

-- Expose functions
K.Aimbot = {
    SetPriority = function(mode) priorityMode = mode end,
    SetRCS = function(enabled, strength) rcsEnabled = enabled; rcsStrength = strength or rcsStrength end,
    GetTarget = function() return aimTarget end,
}

print("[KIRO AIMBOT] Smart aimbot loaded. Game: " .. gameId)
