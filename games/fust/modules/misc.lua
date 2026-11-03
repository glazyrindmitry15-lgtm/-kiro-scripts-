-- KIRO HACK | MISC CORE (FULL)
local K = shared.KIRO
if not K then return end
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera, Settings, LP = K.Camera, K.Settings, K.LP

local HitmarkerTime = 0
local LastHealth = {}
local LastToolActivated = 0
local SuspiciousPlayers = {}
local KillCounter = 0

-- Хитмаркер (крестик)
local HM = {}
for i = 1, 4 do local l = Drawing.new("Line"); l.Thickness = 2; l.Visible = false; HM[i] = l end
local KILL_MSGS = {"GG","EZ","get rekt","skill issue","sit down","+rep","lol","noob down","clipped","ez clap","next"}

local function ShowHitmarker(isKill)
    HitmarkerTime = tick()
    local col = isKill and Color3.fromRGB(255,80,120) or Color3.fromRGB(255,255,255)
    for _, l in ipairs(HM) do l.Color = col end
    if isKill and Settings.Fun.KillMessages and K.Notify then
        K.Notify("KILL #" .. KillCounter, KILL_MSGS[math.random(#KILL_MSGS)], false)
    end
end

-- Счетчик убийств и Хитмаркер
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            for _, t in ipairs(K.CachedTargets) do
                if t.player and t.hum and t.hum.Parent then
                    local id, hp, last = t.player.UserId, t.hum.Health, LastHealth[t.player.UserId]
                    if last and hp < last then
                        if hp <= 0 then
                            if (tick() - LastToolActivated) < 5 then
                                KillCounter = KillCounter + 1
                                ShowHitmarker(true)
                            end
                        elseif Settings.Fun.Hitmarker then
                            ShowHitmarker(false)
                        end
                    end
                    LastHealth[id] = hp
                end
            end
        end)
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local char = LP.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then LastToolActivated = tick() end
    end
end)

-- Отрисовка Хитмаркера
RunService.RenderStepped:Connect(function()
    if not (K.MenuOpen or K.Loading) then
        local e = tick() - HitmarkerTime
        if e < 0.15 then
            local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
            local size, alpha = 8 + e*40, 1 - e/0.15
            HM[1].From = Vector2.new(cx-size, cy-size); HM[1].To = Vector2.new(cx-size/2, cy-size/2)
            HM[2].From = Vector2.new(cx+size, cy-size); HM[2].To = Vector2.new(cx+size/2, cy-size/2)
            HM[3].From = Vector2.new(cx-size, cy+size); HM[3].To = Vector2.new(cx-size/2, cy+size/2)
            HM[4].From = Vector2.new(cx+size, cy+size); HM[4].To = Vector2.new(cx+size/2, cy+size/2)
            for _, l in ipairs(HM) do l.Transparency = alpha; l.Visible = true end
        else for _, l in ipairs(HM) do l.Visible = false end end
    else for _, l in ipairs(HM) do l.Visible = false end end
end)

-- Anti-AFK
task.spawn(function()
    while task.wait(1.0) do
        if Settings.Security.AntiAFK then
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(0,0)) end)
        end
    end
end)

-- Big Head / Torso
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            for _, t in ipairs(K.CachedTargets) do
                if t.obj and t.obj.Parent then
                    if Settings.Utils.HeadExpander and t.head and t.head:IsA("BasePart") then
                        if not K.OriginalSizes[t.head] then K.OriginalSizes[t.head] = t.head.Size end
                        t.head.Size = Vector3.new(Settings.Utils.HeadSize, Settings.Utils.HeadSize, Settings.Utils.HeadSize)
                    elseif t.head and t.head:IsA("BasePart") and K.OriginalSizes[t.head] then
                        t.head.Size = K.OriginalSizes[t.head]; K.OriginalSizes[t.head] = nil
                    end
                    if Settings.Utils.TorsoExpander and t.torso and t.torso:IsA("BasePart") then
                        if not K.OriginalSizes[t.torso] then K.OriginalSizes[t.torso] = t.torso.Size end
                        t.torso.Size = Vector3.new(Settings.Utils.TorsoSize+1, Settings.Utils.TorsoSize+1, Settings.Utils.TorsoSize)
                    elseif t.torso and t.torso:IsA("BasePart") and K.OriginalSizes[t.torso] then
                        t.torso.Size = K.OriginalSizes[t.torso]; K.OriginalSizes[t.torso] = nil
                    end
                end
            end
        end)
    end
end)

-- Observer Alert (Кто смотрит)
task.spawn(function()
    while task.wait(0.75) do
        pcall(function()
            if not Settings.Security.ObserverAlert then SuspiciousPlayers = {}; return end
            local char = LP.Character
            if not char then return end
            local myHrp, myHead = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")
            if not myHrp or not myHead then return end
            for _, t in ipairs(K.CachedTargets) do
                if t.player and t.hrp and t.hrp.Parent and t.hum and t.hum.Health > 0 then
                    local toMe = myHrp.Position - t.hrp.Position
                    local dist = toMe.Magnitude
                    if dist > 15 and dist < 150 then
                        local theirHead = t.obj:FindFirstChild("Head") or t.hrp
                        local dot = theirHead.CFrame.LookVector:Dot(toMe.Unit)
                        local hasLOS = true
                        if Settings.Security.LOSRequired and dot > 0.5 then
                            local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = {t.obj, char}
                            hasLOS = (Workspace:Raycast(theirHead.Position, myHead.Position - theirHead.Position, rp) == nil)
                        end
                        if dot > Settings.Security.MinFacing and hasLOS then
                            local vel = t.hrp.AssemblyLinearVelocity
                            local movingTowardMe = vel.Magnitude > 5 and vel.Unit:Dot(toMe.Unit) > 0.5
                            local hasTool = t.obj:FindFirstChildOfClass("Tool") ~= nil
                            local weight = (movingTowardMe and not hasTool) and 0.4 or 1.0
                            SuspiciousPlayers[t.player] = (SuspiciousPlayers[t.player] or 0) + weight
                            if SuspiciousPlayers[t.player] >= Settings.Security.ObserveTime * 2 then
                                local cdKey = tostring(t.player.UserId) .. "_cd"
                                if tick() - (SuspiciousPlayers[cdKey] or 0) > Settings.Security.AlertCooldown then
                                    SuspiciousPlayers[cdKey] = tick()
                                    if K.Notify then K.Notify("👁 СМОТРИТ", t.name .. " смотрит на тебя (" .. math.floor(dist) .. "м)", true) end
                                end
                                SuspiciousPlayers[t.player] = 0
                            end
                        else SuspiciousPlayers[t.player] = math.max((SuspiciousPlayers[t.player] or 0) - 1.5, 0) end
                    else SuspiciousPlayers[t.player] = math.max((SuspiciousPlayers[t.player] or 0) - 0.3, 0) end
                end
            end
        end)
    end
end)

-- Fullbright
local FBBackup = nil
task.spawn(function()
    while task.wait(2.5) do
        pcall(function()
            if Settings.World.Fullbright then
                if not FBBackup then FBBackup = {Brightness=Lighting.Brightness, GlobalShadows=Lighting.GlobalShadows} end
                Lighting.Brightness = 2; Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(185,185,185); Lighting.OutdoorAmbient = Color3.fromRGB(175,175,175)
            elseif FBBackup then
                pcall(function() for k, v in pairs(FBBackup) do if Lighting[k] ~= nil then Lighting[k] = v end end end); FBBackup = nil
            end
        end)
    end
end)

print("[KIRO MISC] Загружено (FULL).")