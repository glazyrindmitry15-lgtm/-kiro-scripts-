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

local target = nil
UIS.InputBegan:Connect(function(i, gp) if not gp and i.UserInputType == Enum.UserInputType.MouseButton2 then target = nil end end)

RunService.RenderStepped:Connect(function()
    if fovCircle then
        if K.GetSetting("Aimbot.DrawFOV") and K.GetSetting("Aimbot.Enabled") then
            local mouse = UIS:GetMouseLocation()
            fovCircle.Position = mouse; fovCircle.Radius = K.GetSetting("Aimbot.FOV"); fovCircle.Visible = true
        else fovCircle.Visible = false end
    end

    if not K.GetSetting("Aimbot.Enabled") or not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local closestDist = K.GetSetting("Aimbot.FOV")
    local mouse = UIS:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(K.GetSetting("Aimbot.Part")) then
            if K.GetSetting("Aimbot.TeamCheck") and p.Team == LP.Team then continue end
            local part = p.Character:FindFirstChild(K.GetSetting("Aimbot.Part"))
            local scr, on = Camera:WorldToViewportPoint(part.Position)
            if on then
                local dist = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
                if dist < closestDist then closestDist = dist; target = part end
            end
        end
    end

    if target and target.Parent then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), K.GetSetting("Aimbot.Smoothness"))
    end
end)
print("[KIRO AIMBOT] Загружено.")
