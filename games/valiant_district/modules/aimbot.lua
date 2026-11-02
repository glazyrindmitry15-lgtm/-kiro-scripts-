local K = shared.KIRO
if not K then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local fovCircle
if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5; fovCircle.NumSides = 60; fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(255,140,0); fovCircle.Visible = false
end

local function getModels()
    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            table.insert(models, plr.Character)
            seen[plr.Character] = true
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local m = d.Parent
            if m and m:IsA("Model") and m ~= LP.Character and not seen[m] then
                if LP.Character and m:IsDescendantOf(LP.Character) then continue end
                table.insert(models, m)
                seen[m] = true
            end
        end
    end
    return models
end

local function hasLOS(model, part)
    if not K.GetSetting("Aimbot.VisibleOnly") then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LP.Character, model }
    local hit = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return hit == nil
end

local function closest()
    local bestPart, bestDist = nil, (K.GetSetting("Aimbot.FOV") or 200)
    local mouse = UIS:GetMouseLocation()
    for _, model in ipairs(getModels()) do
        local head = model:FindFirstChild("Head") or model:FindFirstChild("UpperTorso")
        if not head then continue end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local scr, on = Camera:WorldToViewportPoint(head.Position)
        if not on or scr.Z <= 0 then continue end
        local d = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
        if d < bestDist and hasLOS(model, head) then
            bestDist, bestPart = d, head
        end
    end
    return bestPart
end

local aimTarget = nil
UIS.InputBegan:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and K.GetSetting("Aimbot.Enabled") then
        aimTarget = closest()
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aimTarget = nil end
end)

RunService.RenderStepped:Connect(function()
    if fovCircle then
        if K.GetSetting("Aimbot.DrawFOV") and K.GetSetting("Aimbot.Enabled") then
            local mouse = UIS:GetMouseLocation()
            fovCircle.Position = mouse
            fovCircle.Radius = K.GetSetting("Aimbot.FOV") or 200
            fovCircle.Visible = true
        else fovCircle.Visible = false end
    end
    if not K.GetSetting("Aimbot.Enabled") then return end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then aimTarget = nil; return end
    if not aimTarget or not aimTarget.Parent then aimTarget = closest() end
    if aimTarget and aimTarget.Parent then
        local goal = CFrame.new(Camera.CFrame.Position, aimTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(goal, K.GetSetting("Aimbot.Smoothness") or 0.4)
    end
end)

print("[KIRO AIMBOT] Модуль загружен.")
