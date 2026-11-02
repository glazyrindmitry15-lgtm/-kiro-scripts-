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

local function getChar(plr)
    local c = plr.Character or workspace:FindFirstChild(plr.Name)
    if not c then return nil end
    local head = c:FindFirstChild("Head") or c:FindFirstChild("head") or c:FindFirstChild("UpperTorso")
    local hrp  = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    if head and hrp and hum and hum.Health > 0 then return c, head, hrp, hum end
    return nil
end

local function isEnemy(plr)
    if not K.GetSetting("Aimbot.TeamCheck") then return true end
    if plr == LP then return false end
    if plr.Team and LP.Team then return plr.Team ~= LP.Team end
    local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
    local lTeam = LP:GetAttribute("Team") or LP:GetAttribute("team")
    if pTeam and lTeam then return pTeam ~= lTeam end
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

local function closest()
    local bestPart, bestDist = nil, (K.GetSetting("Aimbot.FOV") or 150)
    local mouse = UIS:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if not isEnemy(plr) then continue end
        local res = getChar(plr)
        if not res then continue end
        local char, head, hrp, hum = res
        local partName = K.GetSetting("Aimbot.Part") or "Head"
        local part = char:FindFirstChild(partName) or head
        if not part then continue end
        local scr, on = Camera:WorldToViewportPoint(part.Position)
        if not on or scr.Z <= 0 then continue end
        local d = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
        if d < bestDist and hasLOS(char, part) then
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
