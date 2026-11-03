local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T and K.GetSetting("Teleport.Enabled") then
        -- teleport to nearest player
        local myChar = LP.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        local nearest, nearestDist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myHrp.Position).Magnitude
                    if d < nearestDist then nearestDist = d; nearest = hrp end
                end
            end
        end
        if nearest then
            myHrp.CFrame = nearest.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

print("[KIRO TELEPORT] Модуль загружен.")
