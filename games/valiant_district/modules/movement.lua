-- =====================================================================
-- MOVEMENT | Valiant District (Fly, Noclip, InfJump, BHop)
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

-- Fly
local flying = false
local flyBV, flyBG

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if K.GetSetting("Misc.InfiniteJump") then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Bunnyhop
    if spaceDown and K.GetSetting("Misc.Bunnyhop") and hum then
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            hum.Jump = true
        end
    end

    -- Fly
    if K.GetSetting("Misc.Fly") and hrp then
        if not flying then
            flying = true
            flyBV = Instance.new("BodyVelocity")
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBG.CFrame = hrp.CFrame
            flyBG.Parent = hrp
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        flyBV.Velocity = move * (K.GetSetting("Misc.FlySpeed") or 50)
        flyBG.CFrame = cam.CFrame
    else
        if flying then
            flying = false
            if flyBV then flyBV:Destroy(); flyBV = nil end
            if flyBG then flyBG:Destroy(); flyBG = nil end
        end
    end

    -- Noclip
    if K.GetSetting("Misc.Noclip") and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- Speed (BodyVelocity)
    if K.GetSetting("Misc.Speed") and hrp and hum then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local bv = hrp:FindFirstChild("SpeedBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "SpeedBV"
                bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                bv.Parent = hrp
            end
            bv.Velocity = moveDir * (K.GetSetting("Misc.SpeedValue") or 32)
        end
        hum.WalkSpeed = 16
    else
        local bv = hrp and hrp:FindFirstChild("SpeedBV")
        if bv then bv:Destroy() end
        if hum then hum.WalkSpeed = 16 end
    end
end)

-- Teleport (T key)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T and K.GetSetting("Teleport.Enabled") then
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
