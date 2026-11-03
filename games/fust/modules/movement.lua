-- =====================================================================
-- MOVEMENT | Fust Survival (Speed, Auto-Farm, BHop)
-- =====================================================================
local K = shared.KIRO
if not K then return end

local gameId = K.GameId or "unknown"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Bunnyhop
local spaceDown = false
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = true end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = false end
end)

-- Speed (BodyVelocity)
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if spaceDown and K.GetSetting("Misc.Bunnyhop") then
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            hum.Jump = true
        end
    end

    if K.GetSetting("Misc.Speed") then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local bv = hrp:FindFirstChild("SpeedBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "SpeedBV"
                bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                bv.Parent = hrp
            end
            bv.Velocity = moveDir * (K.GetSetting("Misc.SpeedValue") or 50)
        end
        hum.WalkSpeed = 16
    else
        local bv = hrp:FindFirstChild("SpeedBV")
        if bv then bv:Destroy() end
    end

    -- Auto-Farm: move to nearest chest/resource
    if K.GetSetting("Utils.AutoCollect") then
        local nearest, nearestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("chest") or obj.Name:lower():find("barrel") or obj.Name:lower():find("loot") or obj.Name:lower():find("resource") then
                if obj:IsA("BasePart") then
                    local d = (obj.Position - hrp.Position).Magnitude
                    if d < nearestDist and d > 5 then
                        nearestDist = d
                        nearest = obj
                    end
                end
            end
        end
        if nearest and nearestDist < 200 then
            local dir = (nearest.Position - hrp.Position).Unit
            hrp.CFrame = hrp.CFrame + dir * 2
        end
    end
end)

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

print("[KIRO MOVEMENT] Loaded. Game: " .. gameId)
