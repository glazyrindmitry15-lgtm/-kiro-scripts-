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

local function isEnemy(plr)
    if not K.GetSetting("Aimbot.TeamCheck") then return true end
    if plr == LP then return false end
    if plr.Team and LP.Team then return plr.Team ~= LP.Team end
    if plr.TeamColor and LP.TeamColor then return plr.TeamColor ~= LP.TeamColor end
    return true
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

local function getPart(plr)
    if not isEnemy(plr) then return nil end
    local c = plr.Character
    if not c then return nil end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local partName = K.GetSetting("Aimbot.Part") or "Head"
    local part = c:FindFirstChild(partName) or c:FindFirstChild("Head")
    return part, c
end

local function closest()
    local bestPart, bestDist = nil, K.GetSetting("Aimbot.FOV")
    local mouse = UIS:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        local part, char = getPart(plr)
        if part and char then
            local scr, on = Camera:WorldToViewportPoint(part.Position)
            if on then
                local d = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
                if d < bestDist and hasLOS(char, part) then
                    bestDist, bestPart = d, part
                end
            end
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
            fovCircle.Radius = K.GetSetting("Aimbot.FOV")
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
        Camera.CFrame = Camera.CFrame:Lerp(goal, K.GetSetting("Aimbot.Smoothness"))
    end
end)

print("[KIRO AIMBOT] Модуль загружен.")
