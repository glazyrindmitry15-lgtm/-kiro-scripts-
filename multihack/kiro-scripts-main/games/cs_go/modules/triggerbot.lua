local K = shared.KIRO
if not K then return end
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

local lastShot = 0

local function hasLOS(char, part)
    if not K.GetSetting("Combat.TriggerBot") then return false end
    -- visibility check always on for triggerbot safety
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LP.Character, char }
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local hit = workspace:Raycast(origin, dir, params)
    return hit == nil
end

RunService.Heartbeat:Connect(function()
    if not K.GetSetting("Combat.TriggerBot") then return end
    if tick() - lastShot < K.GetSetting("Combat.TriggerDelay") then return end

    local mouse = UIS:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local char = plr.Character
            local head = char:FindFirstChild("Head")
            if head and hasLOS(char, head) then
                local scr, on = Camera:WorldToViewportPoint(head.Position)
                if on and (Vector2.new(scr.X, scr.Y) - mouse).Magnitude < 15 then
                    lastShot = tick()
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton1(Vector2.new())
                    end)
                    break
                end
            end
        end
    end
end)

print("[KIRO TRIGGER] Модуль загружен.")
