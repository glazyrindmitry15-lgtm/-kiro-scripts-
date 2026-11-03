-- =====================================================================
-- MOVEMENT | Game-Aware Movement
-- =====================================================================
local K = shared.KIRO
if not K then return end

local gameId = K.GameId or "unknown"

-- Only BHop for cs_go (no fly/noclip/teleport - instant ban)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Bunnyhop (all games)
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
end)

-- Anti-AFK (all games)
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

print("[KIRO MOVEMENT] Loaded. Game: " .. gameId .. " (BHop only)")
