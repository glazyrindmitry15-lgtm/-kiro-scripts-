local K = shared.KIRO
if not K then return end
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Anti-AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if K.GetSetting("Security.AntiAFK") then
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end)
end)

-- Bunnyhop
local spaceDown = false
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = true end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = false end
end)

RunService.Heartbeat:Connect(function()
    if spaceDown and K.GetSetting("Misc.Bunnyhop") then
        local c = LP.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping
                and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            hum.Jump = true
        end
    end
    if K.GetSetting("Misc.Fullbright") then
        Lighting.Ambient = Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1e6
    end
end)

-- No-Flash
task.spawn(function()
    while task.wait(1) do
        if not K.GetSetting("Misc.NoFlash") then continue end
        pcall(function()
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("BlurEffect") then obj:Destroy() end
                if obj.Name:lower():find("flash") then obj:Destroy() end
            end
            if LP.Character then
                for _, obj in ipairs(LP.Character:GetChildren()) do
                    if obj:IsA("BlurEffect") or obj.Name:lower():find("flash") then
                        obj:Destroy()
                    end
                end
            end
        end)
    end
end)

print("[KIRO MISC] Модуль загружен.")
