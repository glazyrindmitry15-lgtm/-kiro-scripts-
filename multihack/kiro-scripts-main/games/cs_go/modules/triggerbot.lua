local K = shared.KIRO
if not K then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local last = 0

RunService.Heartbeat:Connect(function()
    if not K.GetSetting("Combat.TriggerBot") then return end
    if tick() - last < K.GetSetting("Combat.TriggerDelay") then return end

    local mouse = UIS:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            local scr, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if on and (Vector2.new(scr.X, scr.Y) - mouse).Magnitude < 15 then
                last = tick()
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController(); vu:ClickButton1(Vector2.new())
                end)
                break
            end
        end
    end
end)
print("[KIRO TRIGGER] Загружено.")
