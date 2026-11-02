local K = shared.KIRO
if not K then return end
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local spaceDown = false
UIS.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.Space then spaceDown = true end end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Space then spaceDown = false end end)

RunService.Heartbeat:Connect(function()
    if spaceDown and K.GetSetting("Misc.Bunnyhop") then
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.Jump = true
        end
    end
    if K.GetSetting("Misc.Fullbright") then
        Lighting.Ambient = Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
        Lighting.Brightness = 2
    end
end)

task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if K.GetSetting("Security.AntiAFK") then
            pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
        end
    end)
end)

print("[KIRO MISC] Загружено.")
