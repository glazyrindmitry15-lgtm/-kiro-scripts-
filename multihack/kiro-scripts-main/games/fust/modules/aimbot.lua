-- KIRO HACK | AIMBOT CORE (FULL)
local K = shared.KIRO
if not K then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP, Camera, Settings = K.LP, K.Camera, K.Settings

local LastTriggerTime = 0

-- Функция проверки видимости (MultiPointVis)
local function IsVisible(part, char, silent)
    local check = silent and Settings.Aimbot.SilentWallCheck or Settings.Aimbot.WallCheck
    if not check then return true end
    local origin = Camera.CFrame.Position
    if LP.Character and LP.Character:FindFirstChild("Head") then origin = LP.Character.Head.Position end
    local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {LP.Character}
    
    if Settings.Aimbot.MultiPointVis then
        local points = {
            part.Position,
            part.Position + Vector3.new(0, 0.4, 0),
            part.Position - Vector3.new(0, 0.4, 0),
            part.Position + Vector3.new(0.4, 0, 0)
        }
        for _, pt in ipairs(points) do
            local r = Workspace:Raycast(origin, pt - origin, rp)
            if not r or r.Instance:IsDescendantOf(char) then return true end
        end
        return false
    else
        local r = Workspace:Raycast(origin, part.Position - origin, rp)
        return not r or r.Instance:IsDescendantOf(char)
    end
end

-- Поиск лучшей цели
K.GetTarget = function(silent)
    local best, bd = nil, Settings.Aimbot.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, t in ipairs(K.CachedTargets) do
        if t.hum and t.hum.Health > 0 and t.head and t.head.Parent and t.hrp and t.hrp.Parent then
            local part = Settings.Aimbot.AimAtBody and t.hrp or t.head
            if part and IsVisible(part, t.obj, silent) then
                local worldDist = (part.Position - Camera.CFrame.Position).Magnitude
                if worldDist <= Settings.Aimbot.MaxDistance then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        local dot = Camera.CFrame.LookVector:Dot((part.Position - Camera.CFrame.Position).Unit)
                        if dot > 0.1 and d2 < bd then bd = d2; best = part end
                    end
                end
            end
        end
    end
    return best
end

-- Предсказание (для пушек/луков)
local function PredictAim(targetPart)
    if not targetPart then return nil end
    local tp = targetPart.Position
    local hrp = nil
    for _, tg in ipairs(K.CachedTargets) do
        if tg.head == targetPart or tg.hrp == targetPart then hrp = tg.hrp; break end
    end
    local vel = Vector3.new()
    if hrp and hrp.Parent then
        pcall(function()
            vel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.new()
            if vel.Magnitude > 50 then vel = vel.Unit * 50 end
        end)
    end
    local pt = math.clamp(Settings.Aimbot.Prediction, 0, 0.15)
    return tp + vel * pt
end

-- Кривые сглаживания
local function GetSmoothVal(curve, t)
    if curve == "Linear" then return t
    elseif curve == "EaseOut" then return 1 - (1 - t)^2
    elseif curve == "EaseIn" then return t^2
    elseif curve == "SmoothStep" then return t * t * (3 - 2 * t) end
    return t
end

-- Скан целей в фоне
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local new = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character and plr.Character.Parent then
                    local isFriend = false
                    if Settings.Aimbot.IgnoreFriends then pcall(function() isFriend = LP:IsFriendsWith(plr.UserId) end) end
                    if not isFriend then
                        local char = plr.Character
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            local head = char:FindFirstChild("Head")
                            local hasWeapon = true
                            if Settings.Aimbot.OnlyArmed then hasWeapon = (char:FindFirstChildOfClass("Tool") ~= nil) end
                            if hrp and head and hasWeapon then
                                table.insert(new, {obj=char, hrp=hrp, head=head, name=plr.Name, type="P", hum=hum, player=plr})
                            end
                        end
                    end
                end
            end
            K.CachedTargets = new
        end)
    end
end)

-- Сайлент Аим (Хук)
pcall(function()
    if hookmetamethod then
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if not checkcaller() and Settings.Aimbot.SilentAim and K.CurrentSilentTarget and K.CurrentSilentTarget.Parent and not (K.MenuOpen or K.Loading) then
                local a = {...}
                if m == "Raycast" and self == Workspace then
                    local o = a[1]
                    if typeof(o) == "Vector3" and typeof(a[2]) == "Vector3" then
                        local aim = PredictAim(K.CurrentSilentTarget)
                        if aim then a[2] = (aim - o).Unit * a[2].Magnitude; return oldNC(self, table.unpack(a)) end
                    end
                elseif m == "FireServer" or m == "InvokeServer" then
                    local aim = PredictAim(K.CurrentSilentTarget)
                    if aim then
                        local mod = false
                        for i, v in ipairs(a) do
                            if typeof(v) == "Vector3" and v.Magnitude > 5 then
                                a[i] = (aim - Camera.CFrame.Position).Unit * v.Magnitude; mod = true
                            elseif typeof(v) == "CFrame" then
                                a[i] = CFrame.new(v.Position, aim); mod = true
                            end
                        end
                        if mod then return oldNC(self, table.unpack(a)) end
                    end
                end
            end
            return oldNC(self, ...)
        end)
    end
end)

-- Рендер (Обычный Аим + Триггер)
RunService:BindToRenderStep("KiroAimCalc", Enum.RenderPriority.Last.Value - 1, function()
    if Settings.Aimbot.AimMode == "AlwaysOn" then K.Aiming = Settings.Aimbot.Enabled end
    if K.MenuOpen or K.Loading or not K.Aiming or not Settings.Aimbot.Enabled or Settings.Aimbot.SilentAim then K.CurrentAimCFrame = nil; return end
    local t = K.GetTarget(false)
    if not t then K.CurrentAimCFrame = nil; return end
    
    local aim = PredictAim(t)
    if not aim then K.CurrentAimCFrame = nil; return end
    
    local targetCF = CFrame.new(Camera.CFrame.Position, aim)
    local smooth = Settings.Aimbot.SnapAim and 1 or math.clamp(Settings.Aimbot.Smoothness, 0.05, 1)
    local finalSmooth = GetSmoothVal(Settings.Aimbot.SmoothCurve, smooth)
    local newCF = Camera.CFrame:Lerp(targetCF, finalSmooth)
    
    if Settings.Aimbot.Humanize and Settings.Aimbot.Jitter > 0 then
        local j = math.rad(Settings.Aimbot.Jitter) * (math.random()-0.5)*2
        local j2 = math.rad(Settings.Aimbot.Jitter) * (math.random()-0.5)*2
        newCF = newCF * CFrame.Angles(j, j2, 0)
    end
    K.CurrentAimCFrame = newCF
end)

RunService:BindToRenderStep("KiroAimApply", Enum.RenderPriority.Last.Value, function()
    if K.MenuOpen or K.Loading then return end
    if K.CurrentAimCFrame and K.Aiming and Settings.Aimbot.Enabled and not Settings.Aimbot.SilentAim then
        pcall(function() Camera.CFrame = K.CurrentAimCFrame end)
    end
    
    -- Триггер бот
    if Settings.Combat.TriggerBot and (tick() - LastTriggerTime > Settings.Combat.TriggerDelay) then
        local t = K.GetTarget(false)
        if t then
            local sp, on = Camera:WorldToViewportPoint(t.Position)
            if on and (Vector2.new(sp.X, sp.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude < Settings.Aimbot.FOV then
                if mouse1click then pcall(mouse1click) end
                LastTriggerTime = tick()
            end
        end
    end
end)

-- Бинды
UIS.InputBegan:Connect(function(input, gpe)
    if K.MatchesKeybind(input, Settings.Aimbot.Key) then
        if Settings.Aimbot.AimMode == "Hold" then K.Aiming = true
        elseif Settings.Aimbot.AimMode == "Toggle" then K.AimToggled = not K.AimToggled; K.Aiming = K.AimToggled end
    end
end)
UIS.InputEnded:Connect(function(input)
    if K.MatchesKeybind(input, Settings.Aimbot.Key) and Settings.Aimbot.AimMode == "Hold" then K.Aiming = false end
end)

print("[KIRO AIMBOT] Загружено (FULL).")