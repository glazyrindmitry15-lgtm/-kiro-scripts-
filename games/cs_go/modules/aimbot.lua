local K = shared.KIRO
if not K then return end
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

local fovCircle
if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 60
    fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(255,140,0)
    fovCircle.Visible = false
end

local function getModels()
    local models = {}
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

local function getParts(model)
    local head = model:FindFirstChild("Head") or model:FindFirstChild("head") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    if not head then return nil end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    return head, hum
end

local function hasLOS(char, part)
    if not K.GetSetting("Aimbot.VisibleOnly") then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LP.Character, char }
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local hit = workspace:Raycast(origin, dir, params)
    return hit == nil
end

local function closest()
    local bestPart, bestDist = nil, (K.GetSetting("Aimbot.FOV") or 150)
    local mouse = UIS:GetMouseLocation()
    for _, entry in ipairs(getModels()) do
        if not isEnemy(entry) then continue end
        local head, hum = getParts(entry.model)
        if not head then continue end
        local partName = K.GetSetting("Aimbot.Part") or "Head"
        local part = entry.model:FindFirstChild(partName) or head
        local scr, on = Camera:WorldToViewportPoint(part.Position)
        if not on or scr.Z <= 0 then continue end
        local d = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
        if d < bestDist and hasLOS(entry.model, part) then
            bestDist, bestPart = d, part
        end
    end
    return bestPart
end

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

RunService.RenderStepped:Connect(function()
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

    if not K.GetSetting("Aimbot.Enabled") then return end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        aimTarget = nil; return
    end
    if not aimTarget or not aimTarget.Parent then
        aimTarget = closest()
    end
    if aimTarget and aimTarget.Parent then
        local goal = CFrame.new(Camera.CFrame.Position, aimTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(goal, K.GetSetting("Aimbot.Smoothness") or 0.3)
    end
end)

print("[KIRO AIMBOT] Модуль загружен.")
